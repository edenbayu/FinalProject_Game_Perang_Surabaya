shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;
uniform vec4 modulate_color : source_color = vec4(1.0);

const vec2 OFFSETS[8] = {
    vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
    vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    float outline = 0.0;
    
    for (int i = 0; i < OFFSETS.length(); i++) {
        outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
    }
    outline = min(outline, 1.0);
    
    vec4 color = texture(TEXTURE, UV);
    vec4 mixed_color = mix(color, line_color, outline - color.a);
    
    // Apply modulate color
    mixed_color *= modulate_color;
    
    COLOR = mixed_color;
}

//void light() {
    // Called for every pixel for every light affecting the CanvasItem.
    // Uncomment to replace the default light processing function with this one.
//}
