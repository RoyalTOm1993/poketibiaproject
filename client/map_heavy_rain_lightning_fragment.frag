
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_TexCoord3;
varying vec2 v_TexCoord4;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;
uniform sampler2D u_Tex1;
uniform sampler2D u_Tex2;
uniform sampler2D u_Tex3;
uniform vec4 u_Opacity;

uniform float u_Time;

float lightningInterval = 10.0;

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord) * u_Color;
    gl_FragColor += texture2D(u_Tex1, v_TexCoord2) * u_Opacity;
    gl_FragColor += texture2D(u_Tex2, v_TexCoord3) * u_Opacity;
    if(mod(u_Time, lightningInterval) < 0.1)
        gl_FragColor += texture2D(u_Tex3, v_TexCoord4);

    if(gl_FragColor.a < 0.01)
        discard;
}
