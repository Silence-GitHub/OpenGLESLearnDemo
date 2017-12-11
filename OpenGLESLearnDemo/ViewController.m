//
//  ViewController.m
//  OpenGLESLearnDemo
//
//  Created by Kaibo Lu on 2017/11/28.
//  Copyright © 2017年 Kaibo Lu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint shaderProgram;
@property (nonatomic, assign) GLfloat elapsedTime;
@property (nonatomic, assign) GLKMatrix4 transformMatrix;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupShader];
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.delegate = self;
    view.context = _context;
    
    [EAGLContext setCurrentContext:_context];
    
    _elapsedTime = 0;
    _transformMatrix = GLKMatrix4Identity;
}

- (void)setupShader {
    NSString *vertexPath = [NSBundle.mainBundle pathForResource:@"vertex" ofType:@"glsl"];
    NSString *fragmentPath = [NSBundle.mainBundle pathForResource:@"fragment" ofType:@"glsl"];
    NSString *vertexShader = [NSString stringWithContentsOfFile:vertexPath encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentShader = [NSString stringWithContentsOfFile:fragmentPath encoding:NSUTF8StringEncoding error:nil];
    GLuint program;
    createProgram(vertexShader.UTF8String, fragmentShader.UTF8String, &program);
    _shaderProgram = program;
}

bool createProgram(const char *vertexShader, const char *fragmentShader, GLuint *pProgram) {
    GLuint vShader, fShader;
    const GLchar *vsource = (GLchar *)vertexShader;
    const GLchar *fsource = (GLchar *)fragmentShader;
    
    if (!compileShader(&vShader, GL_VERTEX_SHADER, vsource)) {
        printf("Fail to compile vertex shader");
        return false;
    }
    
    if (!compileShader(&fShader, GL_FRAGMENT_SHADER, fsource)) {
        printf("Fail to compile fragment shader");
        return false;
    }
    
    GLuint program = glCreateProgram();
    
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    
    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == 0) {
        printf("Fail to link program");
        
        if (vShader) {
            glDeleteShader(vShader);
            vShader = 0;
        }
        
        if (fShader) {
            glDeleteShader(fShader);
            fShader = 0;
        }
        
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return false;
    }
    
    if (vShader) {
        glDetachShader(program, vShader);
        glDeleteShader(vShader);
    }
    
    if (fShader) {
        glDetachShader(program, fShader);
        glDeleteShader(fShader);
    }
    
    *pProgram = program;
    printf("Succeed creating program");
    return true;
}

bool compileShader(GLuint *shader, GLenum type, const GLchar *source) {
    if (!source) {
        printf("Fail to load shader");
        return false;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }
    
    return true;
}

- (void)update {
    self.elapsedTime += self.timeSinceLastUpdate;
    
    float varyingFactor = self.elapsedTime;
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor, 0, 1, 0);
    
    BOOL usePerspective = YES;
    if (usePerspective) {
        // 透视投影
        float aspect = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
        GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(M_PI_2, aspect, 0.1, 10);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1.6);
        self.transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
        self.transformMatrix = GLKMatrix4Multiply(perspectiveMatrix, self.transformMatrix);
        
    } else {
        // 正交投影
        float viewWidth = CGRectGetWidth(self.view.bounds);
        float viewHeight = CGRectGetHeight(self.view.bounds);
        GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-viewWidth / 2, viewWidth / 2, -viewHeight / 2, viewHeight / 2, -10, 10);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(200, 200, 200);
        self.transformMatrix = GLKMatrix4Multiply(scaleMatrix, rotateMatrix);
        self.transformMatrix = GLKMatrix4Multiply(orthoMatrix, self.transformMatrix);
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shaderProgram);
    
    GLint time = glGetUniformLocation(self.shaderProgram, "elapsedTime");
    glUniform1f(time, self.elapsedTime);
    
    GLint transform = glGetUniformLocation(self.shaderProgram, "transform");
    glUniformMatrix4fv(transform, 1, 0, self.transformMatrix.m);
    
    [self drawTriangle];
}

- (void)bindAttribs:(GLfloat *)triangleData {
    GLint position = glGetAttribLocation(self.shaderProgram, "position");
    glEnableVertexAttribArray(position);
    
    GLint color = glGetAttribLocation(self.shaderProgram, "color");
    glEnableVertexAttribArray(color);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)triangleData);
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)triangleData + 3 * sizeof(GLfloat));
}

- (void)drawTriangle {
    static GLfloat vertexData[] = {
        -0.5, +0.5, +0.0, +1.0, +0.0, +0.0,
        -0.5, -0.5, +0.0, +0.0, +1.0, +0.0,
        +0.5, -0.5, +0.0, +0.0, +0.0, +1.0,
        +0.5, -0.5, +0.0, +0.0, +0.0, +1.0,
        +0.5, +0.5, +0.0, +0.0, +1.0, +0.0,
        -0.5, +0.5, +0.0, +1.0, +0.0, +0.0,
    };
    
    [self bindAttribs:vertexData];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertexData) / (sizeof(GLfloat) * 6));
}

@end
