shader_type spatial;
// T-222 shell of room 407: a tiled CC0 scan on UV (metric) aged by a mask atlas on UV2 that was painted for
// this exact room (art_source/graphics_upgrade/room407_shell/make_shell_masks.py).
//   kind 0 (paint on plaster: walls, ceiling, exterior)  mask R paint loss, G grime, B water stain, A mould
//   kind 1 (glazed tiles: floors, skirting)              mask R grout dirt, G grime, B wet,          A wear
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform int kind = 0;
uniform sampler2D base_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D base_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D base_arm : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 base_tint : source_color = vec3(1.0);
uniform float normal_strength = 0.8;
// What shows where the paint is gone (kind 0), on UV * layer_scale.
uniform sampler2D layer_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D layer_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D layer_arm : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float layer_scale = 1.0;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
// R fine, G medium, B large, A cells; tiles every metre or so on UV.
uniform sampler2D noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 grime_color : source_color = vec3(0.55, 0.47, 0.36);
uniform vec3 stain_color : source_color = vec3(0.78, 0.62, 0.36);
uniform vec3 mould_color : source_color = vec3(0.09, 0.10, 0.08);
uniform float grime_strength = 1.0;
uniform float stain_strength = 1.0;
uniform float mould_strength = 1.0;
uniform float peel_strength = 1.0;
uniform float wet_strength = 1.0;
uniform float wear_strength = 1.0;
uniform float grout_strength = 1.0;
// Review aid: 0..3 shows that mask channel as the albedo.
uniform int debug_channel = -1;
// T-273 (R0): the look of the reference pictures, set map-wide by rendering/map_look.gd. Both are 0
// (surface as built) unless that look is on. They read the same noise in world space, so they need no mask.
global uniform float look_age;
global uniform float look_wet;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec4 m = texture(mask, UV2);
	vec4 nf = texture(noise, UV * 2.3);
	vec3 albedo = texture(base_albedo, UV).rgb * base_tint;
	vec3 arm = texture(base_arm, UV).rgb;
	vec3 nrm = texture(base_normal, UV).rgb;
	float rough = arm.g;
	float ao = arm.r;
	float grime = clamp(m.g * grime_strength * (0.7 + 0.6 * nf.g), 0.0, 1.0);

	if (kind == 0) {
		// Paint loss: the painted edge follows the scan's own flakes and a little noise, with a dirty rim.
		vec2 luv = UV * layer_scale;
		vec2 nuv = UV * 0.41 + vec2(0.31, 0.77);
		// Most of the room keeps its paint and has no stain or mould (D-132): the layer and the coarse
		// noise are read only where they show, with gradients taken here so their mip level is unchanged.
		vec2 luv_dx = dFdx(luv);
		vec2 luv_dy = dFdy(luv);
		vec2 nuv_dx = dFdx(nuv);
		vec2 nuv_dy = dFdy(nuv);
		float edge = m.r * peel_strength + (nf.r - 0.5) * 0.3 + (nf.a - 0.5) * 0.3;
		float peel = smoothstep(0.42, 0.5, edge);
		float rim = smoothstep(0.3, 0.42, edge) * (1.0 - peel);
		if (peel > 0.0) {
			albedo = mix(albedo, textureGrad(layer_albedo, luv, luv_dx, luv_dy).rgb * base_tint, peel);
			nrm = mix(nrm, textureGrad(layer_normal, luv, luv_dx, luv_dy).rgb, peel);
			vec3 larm = textureGrad(layer_arm, luv, luv_dx, luv_dy).rgb;
			rough = mix(rough, larm.g, peel);
			ao = mix(ao, larm.r, peel);
		}
		albedo *= 1.0 - 0.3 * rim;
		albedo = mix(albedo, albedo * grime_color, grime);
		rough = min(rough + 0.12 * grime, 1.0);
		if (m.b > 0.0 || m.a >= 0.02) {
			vec4 nc = textureGrad(noise, nuv, nuv_dx, nuv_dy);
			// Water: yellow-brown, tide lines drawn into the mask darker than the body.
			float stain = clamp(m.b * stain_strength * (0.85 + 0.3 * nc.r), 0.0, 1.0);
			albedo = mix(albedo, albedo * stain_color, stain);
			albedo *= 1.0 - 0.18 * smoothstep(0.75, 1.0, m.b) * stain_strength;
			// Mould: speckles that thicken into patches.
			float spores = nf.r * 0.55 + nf.a * 0.25 + nc.g * 0.2;
			float mould = smoothstep(1.0 - m.a * mould_strength, 1.12 - m.a * mould_strength, spores) * step(0.02, m.a);
			albedo = mix(albedo, mould_color, mould * 0.85);
			rough = mix(rough, 0.95, mould);
		}
	} else {
		// Grout lines are the dark creases of the scan's AO.
		float grout = smoothstep(0.985, 0.82, ao);
		albedo *= 1.0 - 0.55 * grout * m.r * grout_strength - 0.06 * m.r * grout_strength;
		albedo = mix(albedo, albedo * grime_color, grime);
		rough = min(rough + 0.1 * grime, 1.0);
		float wear = m.a * wear_strength;
		rough = mix(rough, rough * 0.55, wear);
		albedo = mix(albedo, mix(albedo, vec3(dot(albedo, vec3(0.333))), 0.25) * 1.06, wear * 0.6);
		float wet = clamp(m.b * wet_strength, 0.0, 1.0);
		albedo *= 1.0 - 0.5 * wet;
		rough = mix(rough, 0.04, wet);
		nrm = mix(nrm, vec3(0.5, 0.5, 1.0), wet * 0.7);
	}
	if (look_age > 0.0 && kind == 0 && world_normal.y <= 0.5) {
		// Along the wall (one of x, z is constant on an axis-aligned wall) and up it; ceilings use the plan.
		float along = world_position.x + world_position.z;
		bool flat_face = abs(world_normal.y) > 0.5;
		vec2 blotch_uv = flat_face ? world_position.xz * 0.23 : vec2(along, world_position.y) * 0.27;
		vec2 streak_uv = flat_face ? world_position.xz * 0.61 : vec2(along * 0.83, world_position.y * 0.055);
		vec2 gate_uv = flat_face ? world_position.zx * 0.09 : vec2(along * 0.11, world_position.y * 0.19);
		float blotch = smoothstep(0.46, 0.8, texture(noise, blotch_uv).a * 0.6 + texture(noise, blotch_uv * 3.3).r * 0.4);
		float streak = smoothstep(0.5, 0.78, texture(noise, streak_uv).r) * smoothstep(0.35, 0.7, texture(noise, gate_uv).g);
		// Ceilings take the damp from the slab above: darker, with mould where the blotches are densest.
		float overhead = step(world_normal.y, -0.5);
		albedo *= 1.0 - 0.35 * overhead * look_age;
		albedo = mix(albedo, albedo * grime_color, blotch * (0.32 + 0.5 * overhead) * look_age);
		albedo = mix(albedo, albedo * stain_color * 0.78, streak * 0.8 * look_age);
		albedo = mix(albedo, mould_color, overhead * smoothstep(0.7, 0.95, texture(noise, blotch_uv * 1.9).r * blotch) * 0.6 * look_age);
		rough = min(rough + 0.1 * (blotch + streak) * look_age, 1.0);
	}
	if (look_wet > 0.0 && world_normal.y > 0.5) {
		// Damp, foot-polished floor: glossy everywhere, with pooled patches that are darker and flat.
		float pool = texture(noise, world_position.xz * 0.11).r * 0.6 + texture(noise, world_position.xz * 0.37).g * 0.4;
		float damp = smoothstep(0.3, 0.62, pool);
		rough = mix(rough, mix(max(rough * 0.5, 0.22), 0.16, damp), look_wet);
		albedo = mix(albedo, vec3(dot(albedo, vec3(0.299, 0.587, 0.114))), 0.35 * look_wet);
		albedo *= 1.0 - 0.12 * damp * look_wet;
		nrm = mix(nrm, vec3(0.5, 0.5, 1.0), damp * 0.65 * look_wet);
	}
	if (debug_channel >= 0) {
		albedo = vec3(m[debug_channel]);
	}
	ALBEDO = albedo;
	ROUGHNESS = clamp(rough, 0.03, 1.0);
	AO = ao;
	NORMAL_MAP = nrm;
	NORMAL_MAP_DEPTH = normal_strength;
}
