shader_type canvas_item;
uniform float contraction = 0.0;
void fragment() {
	vec2 p = abs(UV - vec2(0.5)) * 2.0;
	float edge = max(p.x, p.y);
	float alpha = smoothstep(0.78 - contraction * 0.18, 1.0, edge) * 0.8;
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
