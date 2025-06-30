attribute vec3 a_Position;
attribute vec2 a_TexCoord;

varying vec2 v_TexCoord;

uniform mat4 u_ModelViewProjectionMatrix;

void main()
{
    v_TexCoord = a_TexCoord;
    gl_Position = u_ModelViewProjectionMatrix * vec4(a_Position, 1.0);
}