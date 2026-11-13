shader_type spatial;


uniform sampler2D fire_tex;
uniform sampler2D color_gradient;

uniform float time;
void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX *= vec3(time * .75, 1.0,time*.75);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 pan = UV + vec2(TIME * 1.2, 0.0);
	vec4 tex = texture(fire_tex, pan);
	float orange_mix = (1.0 - UV.y) * 0.1;
	
	float vertical_mask = (1.0 - UV.y) * 1.4;
	float center_mask = 1.0 - abs(UV.x - 0.5) * 2.0;
	
	// Combine masks and noise into a single 0.0 - 1.0 "heat" value
	float heat = clamp((vertical_mask * center_mask) * 1.8, 0.0, 1.0);
	
	// Sample the 1D gradient using heat as the X coordinate
	vec4 fire_color = texture(color_gradient, vec2(heat, 0.5));
	//ALBEDO = tex.rbg;
	ALBEDO = fire_color.rgb;
	ALPHA = tex.r;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
