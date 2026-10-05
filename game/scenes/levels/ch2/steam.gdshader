shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_never, shadows_disabled;
uniform float level : hint_range(0.0, 1.0) = 0.0;
uniform float phase = 0.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float edge = 1.0 - smoothstep(0.35, 1.0, length(p));
	float drift = sin(UV.x * 14.0 + sin(UV.y * 8.0 - TIME * 0.3 + phase) * 2.0);
	float cloud = 0.65 + 0.15 * drift;
	ALBEDO = vec3(0.45, 0.55, 0.50);
	ROUGHNESS = 1.0;
	ALPHA = level * edge * cloud * 0.25;
}
