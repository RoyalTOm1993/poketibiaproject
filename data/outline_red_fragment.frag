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
    float r = 1.0;
    float g = 0.0;
    float b = 0.0;

    float modSpeed = 0.5;
    float mode = abs(0.5 - mod(u_Time * modSpeed, 1.0)) * 1.5;

    gl_FragColor = texture2D(u_Tex0, v_TexCoord);
    vec4 texcolor = texture2D(u_Tex0, v_TexCoord2);
    vec4 texcolor2 = texture2D(u_Tex0, v_TexCoord3);
    if(texcolor.r > 0.9) {
        gl_FragColor *= texcolor.g > 0.9 ? u_Color[0] : u_Color[1];
    } else if(texcolor.g > 0.9) {
        gl_FragColor *= u_Color[2];
    } else if(texcolor.b > 0.9) {
        gl_FragColor *= u_Color[3];
    }

    if(gl_FragColor.a < 0.01) {
        if(texcolor2.a > 0.01) {
            gl_FragColor = vec4(r, g, b, mode);
        } else {
            discard;
        }
    }
}
