attribute vec4 position;
attribute vec4 color;

varying vec4 fragColor;

uniform float elapsedTime;
uniform mat4 transform;

void main(void) {
    fragColor = color;
    gl_Position = transform * position;
}
