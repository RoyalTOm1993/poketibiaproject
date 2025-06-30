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
    if (texcolor.r > 0.9) {
        if (texcolor.g > 0.9) {
            gl_FragColor *= mix(u_Color[0], u_Color[1], 0.5); // Vermelho misturado com preto
        } else {
            gl_FragColor *= u_Color[0]; // Vermelho
        }
    } else if (texcolor.g > 0.9) {
        gl_FragColor *= u_Color[1]; // Preto
    }
    if (gl_FragColor.a < 0.01) {
        if (texcolor2.a > 0.01) {
            float pulse = 0.5 + 0.5 * sin(u_Time * 10.0); // Ajuste a velocidade da pulsação aqui
            vec3 finalColor = mix(vec3(0.0), vec3(1.0), pulse);
            gl_FragColor = vec4(finalColor, 0.8);
        } else {
            discard;
        }
    }
}