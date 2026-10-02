shader_type spatial;
render_mode unshaded, cull_back;

global uniform float ps1_strength;
uniform float visible_amount : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	if (ps1_strength > 0.001 && clip.w > 0.0) {
		vec2 grid = vec2(240.0 * VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, 240.0) / ps1_strength * 0.5;
		clip.xy = round(clip.xy / clip.w * grid) / grid * clip.w;
	}
	POSITION = clip;
}

void fragment() {
	// Ordered 4x4 cutout, opaque depth writes; no translucent sorting artifacts.
	int bayer[16] = int[16](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	ivec2 pixel = ivec2(FRAGCOORD.xy) % 4;
	if (visible_amount < (float(bayer[pixel.y * 4 + pixel.x]) + 0.5) / 16.0) {
		discard;
	}
	float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 3.0);
	ALBEDO = vec3(0.004, 0.006, 0.008) + vec3(0.022, 0.028, 0.031) * rim;
}
