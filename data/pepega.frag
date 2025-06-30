uniform float u_Time;
uniform float u_Opacity;
uniform vec2 u_Resolution;

varying vec2 v_TexCoord;
uniform sampler2D u_Tex0;

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898,12.1414))) * 83758.5453);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n);
    vec2 f = mix(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);   
}

vec3 ramp(float t) {
	return t <= .5 ? vec3( 1. - t * 1.4, .2, 1.05 ) / t : vec3( .3 * (1. - t) * 2., .2, 1.05 ) / t;
}

float fire(vec2 n) {
    return noise(n) + noise(n * 2.1) * .6 + noise(n * 1.4) * .42;
}

vec3 getLine(vec3 col, vec2 fc, mat2 mtx, float shift){
    float t = u_Time;
    vec2 uv = (fc / u_Resolution.xy) * mtx;
    
    uv.x += uv.y < .5 ? 23.0 + t * .35 : -11.0 + t * .3;    
    uv.y = abs(uv.y - shift);
    uv *= 10.0;
    
    float q = fire(uv - t * .013) / 10.0;
    vec2 r = vec2(fire(uv + q / 2.0 + t - uv.x - uv.y), fire(uv + q - t));
    vec3 color = vec3(1.0 / (pow(vec3(0.5, 0.0, .1) + 1.61, vec3(4.0))));
    
    float grad = pow((r.y + r.y) * max(.0, uv.y) + .1, 4.0);
    color = ramp(grad);
    color /= (1.50 + max(vec3(0), color));
    
    if(color.b < .00000005)
        color = vec3(.0);
    
    return mix(col, color, color.b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = fragCoord / u_Resolution.xy;
    vec3 color = vec3(0.);
    color = getLine(color, fragCoord, mat2(1., 1., 0., 1.), 1.02);
    color = getLine(color, fragCoord, mat2(1., 1., 1., 0.), 1.02);
    color = getLine(color, fragCoord, mat2(1., 1., 0., 1.), -0.02);
    color = getLine(color, fragCoord, mat2(1., 1., 1., 0.), -0.02);

    fragColor += vec4(color, 0.) / min(u_Time, 1.0);
}

void main() {
    gl_FragColor = texture2D(u_Tex0, v_TexCoord);
    mainImage(gl_FragColor, gl_FragCoord.xy);
    if(gl_FragColor.a < 0.01)
        discard;
}