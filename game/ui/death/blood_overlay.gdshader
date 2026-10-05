shader_type canvas_item;
uniform float elapsed = 0.0;
uniform bool splash = false;
uniform bool reduced = false;
uniform bool scald = false;

uniform bool handprints = false;
uniform bool guard_shock = false;

float capsule(vec2 p, vec2 a, vec2 b, float radius) {
	vec2 v = b - a;
	return 1.0 - smoothstep(radius, radius + 0.035, length(p - a - v * clamp(dot(p - a, v) / dot(v, v), 0.0, 1.0)));
}

float hand(vec2 p) {
	float palm = 1.0 - smoothstep(0.85, 1.05, length(p / vec2(0.38, 0.42)));
	for (int i = 0; i < 4; i++) {
		float x = float(i) * 0.18 - 0.27;
		palm = max(palm, capsule(p, vec2(x, -0.23), vec2(x * 1.2, -0.77 - 0.18 * sin(float(i))), 0.072));
	}
	palm = max(palm, capsule(p, vec2(0.27, 0.04), vec2(0.61, -0.24), 0.095));
	float smear = capsule(p, vec2(-0.1, 0.2), vec2(-0.24, 0.85), 0.12) * 0.4;
	return max(palm, smear);
}

void fragment() {
	float edge = max(abs(UV.x - 0.5), abs(UV.y - 0.5)) * 2.0;
	float progress = clamp(elapsed / 2.5, 0.0, 1.0);
	float rim = smoothstep(0.92 - progress * 0.4, 1.0, edge);
	float bands = pow(max(0.0, sin(UV.x * 63.0 + sin(UV.x * 19.0) * 4.0)), 12.0);
	float drip = bands * (1.0 - smoothstep(progress * 0.7, progress * 0.7 + 0.12, UV.y));
	float full_splash = splash ? (1.0 - smoothstep(0.15, 1.5, elapsed)) : 0.0;
	float alpha = max(full_splash, max(rim * 0.9, drip * 0.85));
	COLOR = reduced ? vec4(0.005, 0.005, 0.008, rim * 0.9) : vec4(0.23 + bands * 0.09, 0.008, 0.01, alpha);
	if (handprints && !reduced) {
		vec2 left = (UV - vec2(0.19, 0.46)) * vec2(5.0, 3.6);
		vec2 right = (UV - vec2(0.81, 0.54)) * vec2(-5.0, 3.6);
		left.x += left.y * 0.28;
		right.x += right.y * 0.24;
		float stain = max(hand(left), hand(right)) * smoothstep(0.1, 0.3, elapsed);
		COLOR = mix(COLOR, vec4(0.42, 0.012, 0.018, 0.93), stain);
	}
	if (guard_shock) {
		float fade = smoothstep(0.35, 1.2, elapsed);
		float flash = 1.0 - smoothstep(0.0, 0.18, elapsed);
		float grain = fract(sin(dot(floor(UV * vec2(320.0, 180.0)), vec2(12.9898, 78.233)) + floor(elapsed * 18.0)) * 43758.5453);
		vec3 electricity = mix(vec3(0.04, 0.07, 0.09), vec3(0.55, 0.65, 0.7), grain);
		COLOR = reduced ? vec4(0.005, 0.005, 0.008, mix(0.4, 1.0, smoothstep(0.0, 1.2, elapsed))) : vec4(mix(mix(electricity, vec3(1.0), flash), vec3(0.0), fade), 1.0);
	}
	if (scald && !reduced) {
		float blisters = 0.04 * sin(UV.x * 48.0 + sin(UV.y * 37.0));
		float burn = smoothstep(0.72 + blisters, 1.0, edge);
		COLOR = vec4(mix(vec3(0.97), vec3(0.65, 0.08, 0.06), burn), 0.93);
	}
}
