shader_type canvas_item;
uniform float elapsed = 0.0;
uniform bool reduced = false;

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float edge = max(abs(UV.x - 0.5), abs(UV.y - 0.5)) * 2.0;
	float rim = smoothstep(0.82, 1.0, edge);
	float tick = reduced ? 0.0 : floor(elapsed * 12.0);
	float grain = noise(floor(UV * vec2(320.0, 180.0)) + tick);
	float stripe = step(0.87, noise(vec2(floor(UV.y * 180.0), tick)));
	COLOR = vec4(vec3(0.48, 0.56, 0.57) * grain, rim * (0.12 + stripe * 0.14) * (reduced ? 0.3 : 1.0));
}
