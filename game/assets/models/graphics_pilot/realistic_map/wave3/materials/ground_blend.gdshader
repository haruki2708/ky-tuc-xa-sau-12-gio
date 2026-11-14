shader_type spatial;
// T-259 A16: the B-to-garden strip's lawn, worn to bare dirt where people walk (mask R on UV2), wet by the gutter
// (mask G). UV is in metres.
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
uniform vec3 dirt_tint : source_color = vec3(1.0);
uniform float grass_scale = 0.5;
uniform float dirt_scale = 1.25;

void fragment() {
	vec4 m = texture(mask, UV2);
	vec3 grass = texture(grass_albedo, UV * grass_scale).rgb;
	vec3 dirt = texture(dirt_albedo, UV * dirt_scale).rgb * dirt_tint;
	// The grass texture's own tufts break the edge between lawn and dirt.
	float k = smoothstep(0.35, 0.7, m.r + (texture(grass_albedo, UV * grass_scale * 0.37).g - 0.25) * 0.6);
	ALBEDO = mix(grass, dirt, k) * (1.0 - 0.35 * m.g);
	NORMAL_MAP = mix(texture(grass_normal, UV * grass_scale).rgb, texture(dirt_normal, UV * dirt_scale).rgb, k);
	ROUGHNESS = clamp(mix(0.92, 0.96, k) - 0.5 * m.g, 0.05, 1.0);
	SPECULAR = 0.3;
}
