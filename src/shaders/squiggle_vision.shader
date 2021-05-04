// squiggle vision

shader_type canvas_item;

uniform sampler2D flowMap; //Displacement map
uniform float strength = 0.05;    //Force of the effect
uniform float speed = 5;       //Speed of the effect
uniform int frames : hint_range(1, 10) = 4; //Frames of the effect

//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
	float fframes = float(frames);
	return floor(mod(time * speed, fframes)) / fframes;
}

void fragment(){
	float c = clock(TIME); //Get clock frame
	vec4 offset = texture(flowMap, vec2(UV.x + c, UV.y + c)) * strength; //Get offset 
	//COLOR = texture(TEXTURE, vec2(UV.x,UV.y) + normal.xy); //Apply offset
	COLOR = texture(TEXTURE, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength, 0.0); //We need to remove the displacement 
	
	// disable shader:
	// COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
}


// TEST CLOCK
/*
void fragment(){
	float c = clock(TIME);
	COLOR = vec4( c, c, c, 1);
}
/*