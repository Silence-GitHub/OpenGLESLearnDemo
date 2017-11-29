attribute vec4 position;
attribute vec4 color;

varying vec4 fragColor;

uniform float elapsedTime;

void main(void) {
    fragColor = color;
    
    float angle = elapsedTime * 1.0;
    float x = position.x * cos(angle) - position.y * sin(angle);
    float y = position.x * sin(angle) + position.y * cos(angle);
    gl_Position = vec4(x, y, position.z, 1.0);
}
