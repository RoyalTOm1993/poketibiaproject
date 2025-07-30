varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;
uniform sampler2D u_Tex1;
uniform vec4 u_Opacity;

uniform float u_Time;
uniform vec2 u_Resolution;
const float PI = 3.1415926535897932;

// speed
const float speed = 0.06;
const float speed_x = 0.03;
const float speed_y = 0.02;

// geometry
const float intensity = 10.;
const int steps = 5;
const float frequency = 3.0;
const int angle = 7; // better when a prime

// reflection and emboss
const float delta = 200.;
const float intence = 5.0;
const float emboss = 0.1;

//---------- crystals effect
float col(vec2 coord)
{
    float delta_theta = 2.0 * PI / float(angle);
    float col = 0.0;
    float theta = 0.0;
    for(int i = 0; i < steps; i++) {
        vec2 adjc = coord;
        theta = delta_theta*float(i);
        adjc.x += cos(theta)*u_Time*speed + u_Time * speed_x;
        adjc.y -= sin(theta)*u_Time*speed - u_Time * speed_y;
        col = col + cos( (adjc.x*cos(theta) - adjc.y*sin(theta))*frequency)*intensity;
    }
    return cos(col);
}

void main(void)
{
    vec2 p = v_TexCoord, c1 = p, c2 = p;
    float cc1 = col(c1);

    c2.x += u_Resolution.x/delta;
    float dx = emboss*(cc1-col(c2))/delta;

    c2.x = p.x;
    c2.y += u_Resolution.y/delta;
    float dy = emboss*(cc1-col(c2))/delta;

    c1.x += dx;
    c1.y += dy;

    float alpha = 1.+dot(dx,dy)*intence;
    gl_FragColor = texture2D(u_Tex0,c1)*(alpha);
    gl_FragColor += texture2D(u_Tex1, v_TexCoord2) * u_Opacity;
    if(gl_FragColor.a < 0.01)
        discard;
}
