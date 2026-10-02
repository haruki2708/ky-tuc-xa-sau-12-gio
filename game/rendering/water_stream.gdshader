shader_type spatial;
// Tap water (T-138): pale, slightly see-through bands sliding down. Unshaded
// so the thin stream still reads in the dim washroom.
render_mode blend_mix, cull_disabled, depth_draw_opaque, unshaded, shadows_disabled;

uniform vec4 tint : source_color = vec4(0.70, 0.80, 0.84, 0.6);
uniform float speed = 2.4;

void fragment() {
	float band = step(0.55, fract(UV.y * 5.0 + TIME * speed + sin(UV.x * 18.85) * 0.08));
	ALBEDO = tint.rgb * (0.8 + 0.3 * band);
	ALPHA = tint.a * (0.65 + 0.35 * band);
}
