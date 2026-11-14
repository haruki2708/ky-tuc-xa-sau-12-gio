shader_type spatial;
// T-259: leaf, flower and grass cards. Alpha scissor (no blending), both sides lit with the crown's soft normals.
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.42;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.6;
uniform float specular_value : hint_range(0.0, 1.0) = 0.35;
uniform float translucency : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 texel = texture(albedo_tex, UV);
	ALBEDO = texel.rgb * tint;
	ALPHA = texel.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
	BACKLIGHT = texel.rgb * tint * translucency;
	// Godot turns the normal round on the back of a two-sided card; foliage keeps the crown's normal on both sides.
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}
