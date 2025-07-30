uniform mat4 u_Color;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_Position;
uniform sampler2D u_Tex0;
uniform float u_Time;

// CONFIG
float speed = 4.0;
float height = 12.0;
float angle = 50.0; // degrees
float intensity = 2.0;
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
        vec2 p = rotate(v_Position, (angle / 180.0) * 3.14);
        float frame = mod(p.y, height);
        float timeFrame = mod(u_Time * speed, height);
        float dist = min(abs(frame - timeFrame), min(abs(frame - timeFrame - height), abs(frame - timeFrame + height)));
        gl_FragColor.xyz *= intensity / sqrt(max(1.0, dist));
    }
    if(gl_FragColor.a < 0.01) discard;
}