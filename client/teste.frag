uniform float borderWidth;
uniform vec3 borderColor;

void main()
{
    vec3 color = vec3(1.0, 0.0, 0.0, 0.0); // define a cor inicial como preto transparente
    float alpha = 0.7; // define a transparência inicial como 100%
    
    // verifica se o pixel está na borda do objeto
    if (gl_FragCoord.x < borderWidth || gl_FragCoord.y < borderWidth || gl_FragCoord.x > (1.0 - borderWidth) || gl_FragCoord.y > (1.0 - borderWidth)) {
        color = borderColor; // define a cor da borda como a cor especificada
        alpha = 1.0; // mantém a transparência como 100%
    }
    
    // define a cor final do pixel com a cor da borda e a transparência calculada
    gl_FragColor = vec3(color.rgb, color.a * alpha);
}