shader_type canvas_item;
uniform float level : hint_range(0.0, 1.0) = 0.0;
uniform bool screen_surface = false;

void fragment() {
	float cloud = 0.5 + 0.25 * sin(UV.x * 11.0 + sin(UV.y * 8.0) + TIME * 0.15)
		+ 0.25 * cos(UV.y * 14.0 + UV.x * 7.0 - TIME * 0.12);
	float haze = screen_surface ? mix(0.8, 1.0, cloud) : mix(0.18, 0.48, cloud);
	float scan = screen_surface ? 0.96 + 0.04 * step(0.5, fract(UV.y * 384.0)) : 1.0;
	COLOR = vec4(vec3(0.8, 0.84, 0.76) * scan, level * haze);
}
