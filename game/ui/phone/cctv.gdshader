shader_type canvas_item;
uniform bool obscured = false;

void fragment() {
	vec2 pixel = floor(UV * vec2(320.0, 180.0));
	vec2 uv = (pixel + 0.5) / vec2(320.0, 180.0);
	float grain = fract(sin(dot(pixel + floor(TIME * 16.0), vec2(12.9898, 78.233))) * 43758.5453);
	float gray = dot(texture(TEXTURE, uv).rgb, vec3(0.299, 0.587, 0.114));
	float scan = mix(0.78, 1.0, mod(pixel.y, 2.0));
	float output_value = obscured ? 0.65 + grain * 0.35 : gray * scan + (grain - 0.5) * 0.12;
	COLOR = vec4(vec3(output_value), 1.0);
}
