shader_type spatial;
// T-261: tiled alpha-cut cards (goal net, B40 chain-link), UV repeating. The mip's alpha is raised a little with the
// level (minor axis, as the anisotropic filter reads it) so thin wires stay joined in the middle distance; far, where
// a texel holds several meshes, it stays under the cut and the mesh fades out instead of turning into a grey sheet.
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.5;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.6;
uniform float specular_value : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 texel = texture(albedo_tex, UV);
	vec2 size = vec2(textureSize(albedo_tex, 0));
	vec2 dx = dFdx(UV * size);
	vec2 dy = dFdy(UV * size);
	float lod = max(0.0, 0.5 * log2(min(dot(dx, dx), dot(dy, dy))));
	ALBEDO = texel.rgb * tint;
	ALPHA = clamp(texel.a * (1.0 + 0.5 * min(lod, 3.0)), 0.0, 1.0);
	ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}
