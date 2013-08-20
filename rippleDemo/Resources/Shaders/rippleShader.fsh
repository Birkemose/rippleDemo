// Shader from http://www.iquilezles.org/apps/shadertoy/

#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 phaseShiftXY;
uniform sampler2D u_texture;
varying vec2 v_texCoord;

void main(void) {
    vec2 resolution = vec2(1.0,1.0);
    vec2 cPos = -1.0 + 2.0 * v_texCoord.xy / resolution.xy;
    float cLength = length(cPos);
    
    vec2 uv = v_texCoord.xy/resolution.xy+(cPos/cLength)*cos((cLength*12.0-time*4.0) + phaseShiftXY.x)*0.03;
    vec3 col = texture2D(u_texture,uv).xyz;
    gl_FragColor = vec4(col,1.0);
}