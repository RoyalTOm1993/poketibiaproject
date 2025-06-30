uniform sampler2D framebuffer;

float contrast(float c)
{
    float a = 0.09;
    return (c - a) / (1 - 2 * a);
}

void main(void)
{
    vec4 pixel = texture2D(framebuffer, gl_TexCoord[0].xy);

    pixel.r = contrast(pixel.r * 1.3);
    pixel.g = contrast(pixel.g + 0.05);
    pixel.b = contrast(pixel.b * 0.4 + 0.3);

    gl_FragColor = pixel;
}