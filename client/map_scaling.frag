uniform sampler2D virtual_screen;
varying vec2 frag_uv;
vec4 frag_color;
float textureSize;

float sharpen(float pix_coord)
{
	float sharpness = 2.0;
    float norm = (fract(pix_coord) - 0.5) * 2.0;
    float norm2 = norm * norm;
    return floor(pix_coord) + norm * pow(norm2, sharpness) / 2.0 + 0.5;
}

void main(void)
{
    vec2 vres = textureSize(virtual_screen, 0);
    frag_color = texture(virtual_screen, vec2(
        sharpen(frag_uv.x * vres.x) / vres.x,
        sharpen(frag_uv.y * vres.y) / vres.y
    ));
}
