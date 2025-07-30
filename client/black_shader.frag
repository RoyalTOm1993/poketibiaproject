uniform mat4 u_Color;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_TexCoord3;
varying vec2 v_Position;
uniform sampler2D u_Tex0;
uniform float u_Time;
uniform vec2 u_Resolution;

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord);
    vec4 texcolor = texture2D(u_Tex0, v_TexCoord2);
    vec4 texcolor2 = texture2D(u_Tex0, v_TexCoord3);

    // Se a textura original for muito azul (azul > 0.9)
    if (texcolor.b > 0.9) {
        // Use uma cor branca
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        // Mantenha a cor original
        gl_FragColor *= texcolor;
    }

    if (texcolor2.a > 0.01) {
        // Adicione uma leve cor branca ao pixel
        gl_FragColor += vec4(0.1, 0.1, 0.1, 0.3);
    } else {
        // Mantenha o descarte para um efeito de congelamento
        discard;
    }
}
