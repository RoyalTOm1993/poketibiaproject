
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;
uniform sampler2D u_Tex1;
uniform vec4 u_Opacity;

void main()
{

    // get pixel information
    vec4 texColor = texture2D(u_Tex0, v_TexCoord);
    
    // make a sepia tone color
    vec3 sepia = vec3(1.2, 1.0, 0.8);
    
    // get gray/intensity scale
    float gray = (texColor.r + texColor.g + texColor.b) / 2.5;
    
    // output to screen
    gl_FragColor = vec4(gray * sepia, 1.) * u_Opacity;
    if(gl_FragColor.a < 0.01)
        discard;
}
