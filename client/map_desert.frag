uniform float u_Time;
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;

void main()
{
    vec2 uv = v_TexCoord;

    // Adicione uma cor amarela para simular a areia do deserto
    vec3 desertColor = vec3(1.0, 0.9, 0.6);

    // Misture a cor original com a cor da areia do deserto
    vec4 col = texture2D(u_Tex0, uv);
    col.rgb = mix(col.rgb, desertColor, 0.3);

    gl_FragColor = col;
}
