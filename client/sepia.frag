uniform float u_Time;
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;

vec4 sepia(vec4 color)
{
    return vec4(dot(color, vec4(.242, .17, .17, .0)),
                dot(color, vec4(.242, .17, .17, .0)),
                dot(color, vec4(.196, .49, .49, .0)),
                1);
}

void main()
{
    gl_FragColor = sepia(texture2D(u_Tex0, v_TexCoord));
}