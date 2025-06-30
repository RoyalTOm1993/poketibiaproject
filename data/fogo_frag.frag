precision mediump float;

uniform sampler2D u_Tex0;
uniform vec2 u_Resolution;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;

void main()
{
    // Amostra da textura original
    vec4 texColor = texture2D(u_Tex0, v_TexCoord);
    
    // Se o pixel for quase transparente, ignoramos
    if (texColor.a < 0.1) {
        discard;
    }

    // Definição das cores para o contorno
    vec4 outlineColor1 = vec4(1.0, 0.0, 0.0, 1.0); // Vermelho
    vec4 outlineColor2 = vec4(0.0, 1.0, 0.0, 1.0); // Verde
    vec4 outlineColor3 = vec4(0.0, 0.0, 1.0, 1.0); // Azul

    // Criação do efeito de outline usando deslocamento nas coordenadas de textura
    vec4 outline = vec4(0.0);
    float offset = 1.0 / u_Resolution.x; // Usando a resolução para determinar o deslocamento
    
    outline += texture2D(u_Tex0, v_TexCoord + vec2(-offset, 0.0)) * outlineColor1; // Contorno à esquerda
    outline += texture2D(u_Tex0, v_TexCoord + vec2(offset, 0.0)) * outlineColor2;  // Contorno à direita
    outline += texture2D(u_Tex0, v_TexCoord + vec2(0.0, -offset)) * outlineColor3; // Contorno embaixo
    outline += texture2D(u_Tex0, v_TexCoord + vec2(0.0, offset)) * outlineColor1;  // Contorno em cima

    // Combinando a cor da textura original com o contorno colorido
    gl_FragColor = max(texColor, outline);
}
