shader_type canvas_item;

// Configuración del sprite sheet
uniform int hframes = 3;
uniform int vframes = 3;
uniform vec2 tile_amount = vec2(3.0, 3.0);
uniform vec4 color : hint_color = vec4(1.0);

void fragment() {
    // Calcular el tamaño de cada frame
    vec2 frame_size = vec2(1.0 / float(hframes), 1.0 / float(vframes));
    
    // Calcular la posición del frame actual en la textura completa
    ivec2 current_frame = ivec2(UV / frame_size);
    vec2 frame_offset = vec2(current_frame) * frame_size;
    
    // Corregir: convertir a float los parámetros enteros
    vec2 uv_in_frame = fract(UV * vec2(float(hframes), float(vframes)));
    
    // Aplicar repetición solo dentro del frame
    vec2 repeated_uv = fract(uv_in_frame * tile_amount);
    
    // Convertir de vuelta a coordenadas de textura globales
    vec2 final_uv = frame_offset + repeated_uv * frame_size;
    
    vec4 tex_color = texture(TEXTURE, final_uv);
    COLOR = tex_color * color;
} 