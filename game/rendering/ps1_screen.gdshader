shader_type canvas_item;
// PS1 look for everything drawn below this CanvasLayer (the 3D view):
// low internal resolution, ordered 4x4 Bayer dithering, 5-bit colour.
// strength 0 = untouched image; brightness applies regardless (T-118, D-005).

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform float brightness : hint_range(0.5, 1.5) = 1.0;
// Effective vertical resolution at full strength.
uniform float target_height = 360.0;
// 32 levels per channel = 5 bits.
uniform float color_levels = 32.0;

const float BAYER[16] = float[](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec3 color;
	if (strength > 0.001) {
		float rows = mix(screen_size.y, target_height, strength);
		vec2 grid = vec2(rows * screen_size.x / screen_size.y, rows);
		vec2 cell = floor(SCREEN_UV * grid);
		color = texture(screen_texture, (cell + 0.5) / grid).rgb;
		int index = int(mod(cell.x, 4.0)) + int(mod(cell.y, 4.0)) * 4;
		float threshold = (BAYER[index] + 0.5) / 16.0 - 0.5;
		float steps = color_levels - 1.0;
		vec3 quantized = clamp(floor(color * steps + 0.5 + threshold) / steps, 0.0, 1.0);
		color = mix(color, quantized, strength);
	} else {
		color = texture(screen_texture, SCREEN_UV).rgb;
	}
	COLOR = vec4(color * brightness, 1.0);
}
