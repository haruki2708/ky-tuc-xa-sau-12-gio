shader_type canvas_item;
uniform float elapsed = 0.0;
uniform bool splash = false;
uniform bool reduced = false;

void fragment() {
	float edge = max(abs(UV.x - 0.5), abs(UV.y - 0.5)) * 2.0;
	float progress = clamp(elapsed / 2.5, 0.0, 1.0);
	float rim = smoothstep(0.92 - progress * 0.4, 1.0, edge);
	float bands = pow(max(0.0, sin(UV.x * 63.0 + sin(UV.x * 19.0) * 4.0)), 12.0);
	float drip = bands * (1.0 - smoothstep(progress * 0.7, progress * 0.7 + 0.12, UV.y));
	float full_splash = splash ? (1.0 - smoothstep(0.15, 1.5, elapsed)) : 0.0;
	float alpha = max(full_splash, max(rim * 0.9, drip * 0.85));
	COLOR = reduced ? vec4(0.005, 0.005, 0.008, rim * 0.9) : vec4(0.23 + bands * 0.09, 0.008, 0.01, alpha);
}
