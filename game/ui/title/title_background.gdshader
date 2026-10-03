shader_type canvas_item;

uniform bool animate_light = true;

void fragment() {
	vec4 corridor = texture(TEXTURE, UV);
	float pulse = animate_light ? 0.012 * sin(TIME * 0.7) : 0.0;
	float shade = mix(0.22, 0.68, smoothstep(0.1, 0.95, UV.x));
	COLOR = vec4(corridor.rgb * (shade + pulse), 1.0);
}
