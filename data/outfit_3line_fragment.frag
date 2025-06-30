uniform mat4 u_Color;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_Position;
uniform sampler2D u_Tex0;
uniform float u_Time;

// CONFIG
float speed = 4.0;
float height = 8.0;
float angle = 290.0; // degrees
float intensity = 1.0;
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
        float frame = mod(p.y, height) - mod(u_Time * speed, height);
        float dist1 = min(abs(frame), min(abs(frame - height), abs(frame + height)));
        frame = mod(p.y + height * 0.33, height) - mod(u_Time * speed, height);
        float dist2 = min(abs(frame), min(abs(frame - height), abs(frame + height)));
        frame = mod(p.y + height * 0.66, height) - mod(u_Time * speed, height);
        float dist3 = min(abs(frame), min(abs(frame - height), abs(frame + height)));
        gl_FragColor.xyz *= vec3(intensity / sqrt(dist1 / 2.0), intensity / sqrt(dist2 / 2.0), intensity/ sqrt(dist3 / 2.0));
    }
    if(gl_FragColor.a < 0.01) discard;
}