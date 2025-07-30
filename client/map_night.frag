uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;

void main()
{
    vec4 col = texture2D(u_Tex0, v_TexCoord);

    // Ajuste as cores para dar um aspecto noturno (tons azulados, escurecimento, etc.)
    col.rgb *= vec3(0.2, 0.3, 0.4); // Escurece a imagem

    gl_FragColor = col;
}