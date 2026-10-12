shader_type canvas_item;

uniform bool animate_light = true;

void fragment() {
	vec2 drift = animate_light ? vec2(sin(TIME * 0.055), cos(TIME * 0.045)) * 0.006 : vec2(0.0);
	vec2 photograph_uv = (UV - 0.5) * 0.965 + 0.5 + drift;
	vec3 corridor = texture(TEXTURE, photograph_uv).rgb;
	float pulse = animate_light ? 0.009 * sin(TIME * 0.7) + 0.004 * sin(TIME * 5.9) : 0.0;
	float shade = mix(0.24, 0.95, smoothstep(0.1, 0.92, UV.x));
	vec2 edge = (UV - 0.5) * vec2(1.05, 1.25);
	float vignette = 1.0 - smoothstep(0.15, 0.65, dot(edge, edge)) * 0.62;
	float grain = fract(sin(dot(FRAGCOORD.xy + floor(TIME * 12.0) * float(animate_light), vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
	COLOR = vec4(corridor * (shade + pulse) * vignette + grain * 0.012, 1.0);
}
