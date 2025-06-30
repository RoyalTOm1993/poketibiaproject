uniform float u_Time;
uniform sampler2D u_Tex0;
uniform sampler2D u_NoiseTex;
varying vec2 v_TexCoord;

void main()
{
    vec4 col = texture2D(u_Tex0, v_TexCoord);

    float t = u_Time * 100.0;
    float speed = 5.05;
    float intensity = 0.0008;

    // Sample the noise texture to get a random displacement vector
    vec2 noiseTexCoord = v_TexCoord * 10.0;
    vec2 noise = texture2D(u_NoiseTex, noiseTexCoord).rg;

    // Apply the displacement to the texture coordinates
    vec2 offset = vec2(sin(t), cos(t)) * speed * noise;
    vec2 uv = v_TexCoord + offset * intensity;

    // Sample the texture with the displaced coordinates
    col.xyz = texture2D(u_Tex0, uv).xyz;

    gl_FragColor = col;
}
