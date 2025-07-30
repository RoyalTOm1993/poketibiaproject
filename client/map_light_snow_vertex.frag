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

vec2 rainDirection = vec2(-0.3, -1.0);
vec2 fogDirection = vec2(-0.3, -1.0);
float rainSpeed = 100.0;
float fogSpeed = 100.0;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

void main()
{
    gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;

    v_TexCoord2 = ((a_Vertex + rainDirection * u_Time * rainSpeed) / u_Resolution * 8.0);
    v_TexCoord3 = ((a_Vertex + fogDirection * u_Time * fogSpeed) / u_Resolution);
}

