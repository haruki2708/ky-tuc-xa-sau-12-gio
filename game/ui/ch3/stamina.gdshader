shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float strength = 0.0;
uniform float elapsed = 0.0;
uniform bool exhausted = false;
uniform bool reduced = false;

void fragment() {
	float breath = reduced ? 0.0 : sin(elapsed * (exhausted ? 4.2 : 2.8)) * 0.025 * strength;
	vec2 p = abs(UV - vec2(0.5)) * 2.0;
	float edge = max(p.x, p.y);
	float rim = smoothstep(0.76 - strength * 0.12 + breath, 1.05, edge);
	float level = strength * (reduced ? 0.38 : 1.0);
	vec2 jitter = exhausted && !reduced ? vec2(sin(elapsed * 49.0), cos(elapsed * 37.0)) * SCREEN_PIXEL_SIZE * 1.4 * rim : vec2(0.0);
	vec3 blurred = textureLod(screen_texture, clamp(SCREEN_UV + jitter, vec2(0.001), vec2(0.999)), rim * level * 2.7).rgb;
	COLOR = vec4(blurred * (1.0 - rim * level * 0.88), rim * level);
}
