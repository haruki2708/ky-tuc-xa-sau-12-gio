shader_type canvas_item;
uniform float amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec2 p = abs(UV - vec2(0.5)) * 2.0;
	float rim = smoothstep(0.48, 1.0, max(p.x, p.y));
	COLOR = vec4(vec3(0.89, 0.92, 0.93), rim * amount * 0.9);
}
