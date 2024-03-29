shader_type canvas_item;
uniform sampler2D emission_texture;
uniform vec4 bloom_color : hint_color = vec4(1.0);

void fragment()
{
	vec4 current_color = texture(TEXTURE, UV);
	vec4 emission_color = texture(emission_texture, UV);
	
	if(emission_color.r > 0f)
	{
		COLOR = (emission_color + bloom_color);
	}
	else
	{
		COLOR = current_color;
	}

}