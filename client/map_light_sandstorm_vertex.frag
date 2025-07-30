attribute vec2 a_TexCoord;
attribute vec2 a_Vertex;

varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_TexCoord3;

uniform mat3 u_TextureMatrix;
uniform mat3 u_TransformMatrix;
uniform mat3 u_ProjectionMatrix;

uniform vec2 u_Offset;
uniform vec2 u_Center;
uniform float u_Time;
uniform vec2 u_Resolution;
uniform vec2 u_MapCoords;

vec2 direction = vec2(1.0, 0.1);
float speed = 300.0;

vec2 fogDirection = vec2(1.0, 0.1);
float fogSpeed = 100.0;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

void main()
{
    vec2 b = vec2(u_TextureMatrix[1][1]/u_TextureMatrix[0][0], 1.0);
    vec2 b2 = vec2(-u_TextureMatrix[1][1]/u_TextureMatrix[0][0], 1.0);

    gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord, 1.0)).xy;
	
    v_TexCoord2 = (u_MapCoords + (v_TexCoord * b) + (direction * u_Time * speed) / u_Resolution) * 6.0;
    v_TexCoord3 = (u_MapCoords + (v_TexCoord * b2) + (fogDirection * u_Time * fogSpeed) / u_Resolution);
}
