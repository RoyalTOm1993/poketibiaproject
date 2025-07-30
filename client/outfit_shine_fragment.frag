uniform mat4 u_Color;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_Position;
uniform sampler2D u_Tex0;
uniform float u_Time;

// CONFIG
float speed = 2.0;
float height = 2.0;
float radius = 5.0;
// CONFIG END

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord);
    vec4 texcolor = texture2D(u_Tex0, v_TexCoord2);
    if(texcolor.r > 0.9) {
        gl_FragColor *= texcolor.g > 0.9 ? u_Color[0] : u_Color[1];
    } else if(texcolor.g > 0.9) {
        gl_FragColor *= u_Color[2];
    } else if(texcolor.b > 0.9) {
        gl_FragColor *= u_Color[3];
    }
    
    if(texcolor.a > 0.9) {
        gl_FragColor.xyz *= max(1.0, height / sqrt(abs(abs(sqrt(v_Position.x * v_Position.x + v_Position.y * v_Position.y) / 8.0) - abs(mod(u_Time * speed, radius * 2.0) - radius))));
    }
    if(gl_FragColor.a < 0.01) discard;
}