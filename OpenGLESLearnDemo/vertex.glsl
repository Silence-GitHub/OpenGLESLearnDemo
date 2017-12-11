attribute vec4 position;
attribute vec3 normal;

varying vec3 fragNormal;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

void main(void) {
    fragNormal = normal;
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    gl_Position = mvp * position;
}
