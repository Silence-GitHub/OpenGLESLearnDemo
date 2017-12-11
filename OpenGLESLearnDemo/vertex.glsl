attribute vec4 position;
attribute vec4 color;

varying vec4 fragColor;

uniform float elapsedTime;

void main(void) {
    fragColor = color;
    gl_Position = position;
    gl_PointSize = 25.0; // 必须写小数点
}
