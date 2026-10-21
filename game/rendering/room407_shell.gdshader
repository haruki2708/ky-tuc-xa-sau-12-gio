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

void fragment() {
	vec4 m = texture(mask, UV2);
	vec4 nf = texture(noise, UV * 2.3);
	vec4 nc = texture(noise, UV * 0.41 + vec2(0.31, 0.77));
	vec3 albedo = texture(base_albedo, UV).rgb * base_tint;
	vec3 arm = texture(base_arm, UV).rgb;
	vec3 nrm = texture(base_normal, UV).rgb;
	float rough = arm.g;
	float ao = arm.r;
	float grime = clamp(m.g * grime_strength * (0.7 + 0.6 * nf.g), 0.0, 1.0);

	if (kind == 0) {
		// Paint loss: the painted edge follows the scan's own flakes and a little noise, with a dirty rim.
		vec2 luv = UV * layer_scale;
		float edge = m.r * peel_strength + (nf.r - 0.5) * 0.3 + (nf.a - 0.5) * 0.3;
		float peel = smoothstep(0.42, 0.5, edge);
		float rim = smoothstep(0.3, 0.42, edge) * (1.0 - peel);
		albedo = mix(albedo, texture(layer_albedo, luv).rgb * base_tint, peel) * (1.0 - 0.3 * rim);
		nrm = mix(nrm, texture(layer_normal, luv).rgb, peel);
		vec3 larm = texture(layer_arm, luv).rgb;
		rough = mix(rough, larm.g, peel);
		ao = mix(ao, larm.r, peel);
		albedo = mix(albedo, albedo * grime_color, grime);
		rough = min(rough + 0.12 * grime, 1.0);
		// Water: yellow-brown, tide lines drawn into the mask darker than the body.
		float stain = clamp(m.b * stain_strength * (0.85 + 0.3 * nc.r), 0.0, 1.0);
		albedo = mix(albedo, albedo * stain_color, stain);
		albedo *= 1.0 - 0.18 * smoothstep(0.75, 1.0, m.b) * stain_strength;
		// Mould: speckles that thicken into patches.
		float spores = nf.r * 0.55 + nf.a * 0.25 + nc.g * 0.2;
		float mould = smoothstep(1.0 - m.a * mould_strength, 1.12 - m.a * mould_strength, spores) * step(0.02, m.a);
		albedo = mix(albedo, mould_color, mould * 0.85);
		rough = mix(rough, 0.95, mould);
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
	if (debug_channel >= 0) {
		albedo = vec3(m[debug_channel]);
	}
	ALBEDO = albedo;
	ROUGHNESS = clamp(rough, 0.03, 1.0);
	AO = ao;
	NORMAL_MAP = nrm;
	NORMAL_MAP_DEPTH = normal_strength;
}
