// Shared by ps1_surface*.gdshader: nearest-filtered albedo and mild vertex
// snapping to a low-resolution screen grid. Snapping scales with the global
// ps1_strength (project shader global, set by ps1_filter.gd); 0 disables it.

global uniform float ps1_strength;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.88;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
// Snap grid rows at full strength; higher = subtler wobble.
uniform float snap_rows = 240.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	if (ps1_strength > 0.001 && clip.w > 0.0) {
		float rows = snap_rows / ps1_strength;
		vec2 grid = vec2(rows * VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, rows) * 0.5;
		clip.xy = round(clip.xy / clip.w * grid) / grid * clip.w;
	}
	POSITION = clip;
}
