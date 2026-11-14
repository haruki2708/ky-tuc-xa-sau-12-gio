shader_type spatial;
// T-261: running track. UV.x = metres across from the inner kerb, UV.y = metres along the track; UV2 = mask_field.png
// (G wet). Lane lines are painted (or chalked) here, worn by a noise texture; lane 1 is worn lighter by feet.
uniform sampler2D surface_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
uniform float tile = 0.5;
uniform vec3 line_color : source_color = vec3(0.8);
uniform float line_width = 0.05;
uniform float lane_width = 1.22;
uniform float first_line = 0.025;
uniform float lines = 8.0;
uniform float line_wear = 0.35;
uniform float line_softness = 0.003;
uniform float inner_wear = 0.4;
uniform vec3 wear_color : source_color = vec3(0.5, 0.4, 0.35);
uniform float roughness_value = 0.88;
uniform float wet_strength = 0.7;

void fragment() {
	vec2 uv = UV * tile;
	vec3 base = texture(surface_albedo, uv).rgb;
	vec4 nf = texture(noise, UV * vec2(0.9, 0.23));
	vec4 nb = texture(noise, UV * 0.031);
	vec4 m = texture(mask, UV2);
	float k = (UV.x - first_line) / lane_width;
	float lane_pos = fract(k);
	float worn = inner_wear * (exp(-UV.x / 1.6) + 0.3 * exp(-lane_pos * 5.0)) * smoothstep(0.25, 0.75, nb.b + 0.3 * nf.g);
	base = mix(base, wear_color * (0.85 + 0.3 * nf.r), clamp(worn, 0.0, 0.8));
	float idx = clamp(round(k), 0.0, lines - 1.0);
	float d = abs(UV.x - (first_line + idx * lane_width));
	// Antialiased: crisp near, and far (a pixel wider than the line) dimmed to the line's share of the pixel.
	float fw = max(fwidth(UV.x), 1e-4) + line_softness;
	float line = clamp((line_width * 0.5 + 0.5 * fw - d) / fw, 0.0, 1.0) * min(1.0, line_width / fw);
	float gone = 1.0 - smoothstep(line_wear - 0.08, line_wear + 0.08, nf.g * 0.6 + nb.r * 0.4);
	base = mix(base, line_color * (0.85 + 0.2 * nf.r), line * (1.0 - gone));
	float wet = clamp(m.g * wet_strength, 0.0, 1.0);
	ALBEDO = base * (1.0 - 0.35 * wet);
	ROUGHNESS = mix(roughness_value - 0.1 * line, 0.2, wet);
	NORMAL_MAP = mix(texture(surface_normal, uv).rgb, vec3(0.5, 0.5, 1.0), line * 0.6 + wet * 0.5);
	SPECULAR = 0.4;
}
