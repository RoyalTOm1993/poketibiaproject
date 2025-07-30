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
        gl_FragColor *= texcolor.g > 0.9 ? u_Color[0] : u_Color[1];
    } else if (texcolor.g > 0.9) {
        gl_FragColor *= u_Color[2];
    } else if (texcolor.b > 0.9) {
        gl_FragColor *= u_Color[3];
    }
    if (gl_FragColor.a < 0.01) {
        if (texcolor2.a > 0.01) {
            float hue = mod((v_Position.y - u_Time * 100.0) * 0.005, 1.0); // Adjust the speed and thickness here
            vec3 rainbowColor = vec3(
                0.5 + 0.5 * sin(hue * 6.28318 * 3.0),
                0.5 + 0.5 * sin(hue * 6.28318 * 3.0 + 2.094),
                0.5 + 0.5 * sin(hue * 6.28318 * 3.0 + 4.188)
            );
            gl_FragColor = vec4(rainbowColor, 0.8);
        } else {
            discard;
        }
    }
}
