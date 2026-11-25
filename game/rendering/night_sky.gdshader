shader_type sky;
// T-273 (R0): the overcast night of the reference pictures. Clouds are the shell noise (no new texture) read
// on a flat layer overhead; nothing moves, so the sky is drawn once.
uniform sampler2D noise : filter_linear_mipmap, repeat_enable;
uniform vec3 zenith : source_color = vec3(0.014, 0.018, 0.030);
uniform vec3 horizon : source_color = vec3(0.040, 0.046, 0.062);
uniform vec3 cloud : source_color = vec3(0.105, 0.115, 0.145);

void sky() {
	vec3 direction = normalize(EYEDIR);
	float up = max(direction.y, 0.0);
	vec3 color = mix(horizon, zenith, pow(up, 0.45));
	vec2 uv = direction.xz / (up + 0.14);
	float density = texture(noise, uv * 0.11).r * 0.55 + texture(noise, uv * 0.27 + vec2(0.37, 0.11)).g * 0.3
			+ texture(noise, uv * 0.71).a * 0.15;
	float cover = smoothstep(0.36, 0.7, density) * smoothstep(0.0, 0.1, direction.y);
	color = mix(color, cloud, cover * 0.8);
	COLOR = direction.y < 0.0 ? horizon * 0.6 : color;
}
