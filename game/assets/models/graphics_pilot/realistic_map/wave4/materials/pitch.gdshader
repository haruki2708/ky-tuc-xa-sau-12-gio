shader_type spatial;
// T-261: the infield. UV = world (x, z) in metres; UV2 = mask_field.png (R bare dirt, G wet, B dry grass, A turf worn to
// the crumb). kind 0 living grass (C1), kind 1 artificial turf (C2). The pitch markings (96 x 58 m, centre 198, 166)
// are drawn here and worn by the noise texture.
uniform int kind = 0;
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D turf_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D turf_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 dry_tint : source_color = vec3(1.0, 0.82, 0.5);
uniform vec3 line_color : source_color = vec3(0.72, 0.72, 0.68);
uniform float line_wear = 0.45;
uniform vec2 centre = vec2(198.0, 166.0);
uniform vec2 half_size = vec2(48.0, 29.0);

float seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a, ba = b - a;
	return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}

float markings(vec2 w) {
	vec2 p = w - centre;
	vec2 q = abs(p);
	float d = seg(q, vec2(0.0, half_size.y), half_size);       // touchlines
	d = min(d, seg(q, vec2(half_size.x, 0.0), half_size));      // goal lines
	d = min(d, seg(q, vec2(0.0), vec2(0.0, half_size.y)));      // halfway line
	d = min(d, abs(length(p) - 9.15));                           // centre circle
	float pa = half_size.x - 16.5;                               // penalty areas
	d = min(d, seg(q, vec2(pa, 0.0), vec2(pa, 20.16)));
	d = min(d, seg(q, vec2(pa, 20.16), vec2(half_size.x, 20.16)));
	float ga = half_size.x - 5.5;                                // goal areas
	d = min(d, seg(q, vec2(ga, 0.0), vec2(ga, 9.16)));
	d = min(d, seg(q, vec2(ga, 9.16), vec2(half_size.x, 9.16)));
	vec2 spot = vec2(half_size.x - 11.0, 0.0);
	if (q.x < pa) {
		d = min(d, abs(length(q - spot) - 9.15));                // penalty arcs
	}
	d = min(d, max(length(q - spot) - 0.06, 0.0));               // penalty spots
	d = min(d, max(length(p) - 0.06, 0.0));                      // centre spot
	if (q.x <= half_size.x && q.y <= half_size.y) {
		d = min(d, abs(length(q - half_size) - 1.0));            // corner arcs
	}
	return d;
}

void fragment() {
	vec2 w = UV;
	vec4 m = texture(mask, UV2);
	vec4 nf = texture(noise, w * 0.37);
	vec4 nb = texture(noise, w * 0.043);
	float line = 1.0 - smoothstep(0.055, 0.075, markings(w));
	float gone = smoothstep(line_wear - 0.15, line_wear + 0.15, 1.0 - (nf.g * 0.55 + nb.r * 0.45));
	line *= 1.0 - gone;
	vec3 albedo;
	vec3 nrm;
	float rough;
	if (kind == 0) {
		vec3 grass = texture(grass_albedo, w * 0.5).rgb;
		vec3 dry = grass * dry_tint * 1.25;
		grass = mix(grass, dry, clamp(m.b * (0.6 + 0.6 * nf.b), 0.0, 1.0));
		vec3 dirt = texture(dirt_albedo, w * 0.9).rgb * vec3(1.45, 1.35, 1.25);
		float bald = smoothstep(0.35, 0.7, m.r + (texture(grass_albedo, w * 0.19).g - 0.25) * 0.6 + (nf.a - 0.5) * 0.3);
		albedo = mix(grass, dirt, bald);
		nrm = mix(texture(grass_normal, w * 0.5).rgb, texture(dirt_normal, w * 0.9).rgb, bald);
		albedo = mix(albedo, line_color * (0.75 + 0.25 * grass.g * 3.0), line);
		rough = 0.93;
	} else {
		vec3 turf = texture(turf_albedo, w).rgb * mix(vec3(1.0), vec3(1.25, 1.2, 1.0), m.b * 0.6);
		float bare = smoothstep(0.4, 0.75, m.a + (nf.a - 0.5) * 0.35);
		vec3 crumb = vec3(0.05) * (0.8 + 0.4 * nf.r);
		float lum = dot(texture(turf_albedo, w).rgb, vec3(0.33)) * 2.5;
		albedo = mix(turf, crumb, bare);
		albedo = mix(albedo, line_color * clamp(lum, 0.6, 1.1), line * (1.0 - bare));
		nrm = mix(texture(turf_normal, w).rgb, vec3(0.5, 0.5, 1.0), bare * 0.6);
		rough = mix(0.75, 0.9, bare);
	}
	float wet = clamp(m.g * 0.7, 0.0, 1.0);
	ALBEDO = albedo * (1.0 - 0.35 * wet);
	ROUGHNESS = mix(rough, 0.25, wet);
	NORMAL_MAP = nrm;
	SPECULAR = 0.3;
}
