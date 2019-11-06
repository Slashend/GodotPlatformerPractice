shader_type canvas_item;

uniform vec3 color = vec3(0.6, 0.45, 0.55);
uniform int OCTAVES = 4;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0,0.0));
	float c = rand(i + vec2(0.0,1.0));
	float d = rand(i + vec2(1.0,1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	
	return value;
}

void fragment(){
	vec2 coord = UV * 20.0;
	
	vec2 motion = vec2(fbm(coord + vec2(TIME * -0.65, TIME * 0.65)));
	
	float final = fbm(coord + motion);
	
	float near_top = (UV.y) / (0.075);
	near_top = clamp(near_top, 0.0, 1.0);
	near_top = 1.0 - near_top;
	vec4 color2 = vec4(color, final * 0.70);
	color2 = mix(color2, vec4(1.0), near_top);
	
	float edge_lower = 0.6;
	float edge_upper = edge_lower + 0.1;
	
	if(near_top > edge_lower){
		color2.a = 0.0;
		
		if(near_top < edge_upper){
			color2.a = (edge_upper - near_top) / (edge_upper - edge_lower);
		}
	}
	
	COLOR = color2;
	
}