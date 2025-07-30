precision mediump float;

attribute vec2 a_Vertex;
attribute vec2 a_TexCoord;
uniform mat3 u_TextureMatrix;
uniform mat3 u_TransformMatrix;
uniform mat3 u_ProjectionMatrix;
uniform vec2 u_Offset;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;

void main()
{
    // Transformação do vértice e projeção
    gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);
    
    // Passando as coordenadas de textura para o fragment shader
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord, 1.0)).xy;
    v_TexCoord2 = (u_TextureMatrix * vec3(a_TexCoord + u_Offset, 1.0)).xy;
}
