attribute vec2 a_TexCoord;
attribute vec2 a_Vertex;

varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_TexCoord3;
varying vec2 v_TexCoord4;

uniform mat3 u_TextureMatrix;
uniform mat3 u_TransformMatrix;
uniform mat3 u_ProjectionMatrix;

uniform vec2 u_Offset;
uniform vec2 u_Center;
uniform float u_Time;
uniform vec2 u_Resolution;
uniform vec2 u_MapCoords;

vec2 rainDirection = vec2(0.3, 1.0);
vec2 fogDirection = vec2(1.0, 0.2);
float rainSpeed = 1500.0;
float fogSpeed = 50.0;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

/*
void main()
{
    gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;

    v_TexCoord2 = ((a_Vertex + rainDirection * u_Time * rainSpeed) / u_Resolution * 2.0);
    v_TexCoord3 = ((a_Vertex + fogDirection * u_Time * fogSpeed) / u_Resolution);
    v_TexCoord4 = (a_Vertex / u_Resolution);
}
*/

void main()
{
    vec2 b = vec2(u_TextureMatrix[1][1]/u_TextureMatrix[0][0], 1.5);
    vec2 b2 = vec2(-u_TextureMatrix[1][1]/u_TextureMatrix[0][0], 1.0);

    gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord, 1.0)).xy;
	
    v_TexCoord2 = (u_MapCoords + (v_TexCoord * b) + (rainDirection * u_Time * rainSpeed) / u_Resolution) * 1.5;
    v_TexCoord3 = (u_MapCoords + (v_TexCoord * b2) + (fogDirection * u_Time * fogSpeed) / u_Resolution) * 0.8;
    v_TexCoord4 = (a_Vertex / u_Resolution);
}

