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
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shaderProgram);
    [self drawTriangle];
}

- (void)drawTriangle {
    static GLfloat vertexData[18] = {
        +0.0, +0.5, +0.0, +1.0, +0.0, +0.0,
        -0.5, -0.5, +0.0, +0.0, +1.0, +0.0,
        +0.5, -0.5, +0.0, +0.0, +0.0, +1.0
    };
    
    GLint position = glGetAttribLocation(self.shaderProgram, "position");
    glEnableVertexAttribArray(position);
    
    GLint color = glGetAttribLocation(self.shaderProgram, "color");
    glEnableVertexAttribArray(color);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)vertexData); // vertexData前必须加上类型转化
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)vertexData + 3 * sizeof(GLfloat));
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
