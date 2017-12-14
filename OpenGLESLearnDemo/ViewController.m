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
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;
@property (nonatomic, assign) GLKVector3 lightDirection;
@property (nonatomic, strong) GLKTextureInfo *opaqueTexture;
@property (nonatomic, strong) GLKTextureInfo *redTransparencyTexture;
@property (nonatomic, strong) GLKTextureInfo *greenTransparencyTexture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupShader];
    [self genTexture];
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.delegate = self;
    view.context = _context;
    
    [EAGLContext setCurrentContext:_context];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    _elapsedTime = 0;
    
    float aspect = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
    _projectionMatrix = GLKMatrix4MakePerspective(M_PI_2, aspect, 0.1, 100);
    
    _cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2, 0, 0, 0, 0, 1, 0);
    
    _modelMatrix = GLKMatrix4Identity;
    
    _lightDirection = GLKVector3Make(0, -1, -1);
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

- (void)genTexture {
    NSString *opaquePath = [NSBundle.mainBundle pathForResource:@"texture" ofType:@"jpg"];
    _opaqueTexture = [GLKTextureLoader textureWithContentsOfFile:opaquePath options:nil error:NULL];
    
    NSString *redPath = [NSBundle.mainBundle pathForResource:@"red" ofType:@"png"];
    _redTransparencyTexture = [GLKTextureLoader textureWithContentsOfFile:redPath options:nil error:NULL];
    
    NSString *greenPath = [NSBundle.mainBundle pathForResource:@"green" ofType:@"png"];
    _greenTransparencyTexture = [GLKTextureLoader textureWithContentsOfFile:greenPath options:nil error:NULL];
}

- (void)update {
    self.elapsedTime += self.timeSinceLastUpdate;
    
    float varyingFactor = (sinf(self.elapsedTime) + 1) / 2.0;
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2 * (varyingFactor + 1), 0, 0, 0, 0, 1, 0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(self.shaderProgram);
    
    GLint time = glGetUniformLocation(self.shaderProgram, "elapsedTime");
    glUniform1f(time, self.elapsedTime);
    
    GLint projection = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projection, 1, 0, self.projectionMatrix.m);
    
    GLint camera = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(camera, 1, 0, self.cameraMatrix.m);
    
    GLint light = glGetUniformLocation(self.shaderProgram, "lightDirection");
    glUniform3fv(light, 1, self.lightDirection.v);
    
    [self drawPlaneAt:GLKVector3Make(0, 0, -0.3) texture:self.opaqueTexture];
    
    glDepthMask(0);
    [self drawPlaneAt:GLKVector3Make(-0.2, 0.3, -0.5) texture:self.redTransparencyTexture];
    [self drawPlaneAt:GLKVector3Make(0.2, 0.2, 0) texture:self.greenTransparencyTexture];
    glDepthMask(1);
}

- (void)drawPlaneAt:(GLKVector3)position texture:(GLKTextureInfo *)texture {
    _modelMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLint model = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    glUniformMatrix4fv(model, 1, 0, _modelMatrix.m);
    
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(_modelMatrix, &canInvert);
    if (canInvert) {
        GLint normal = glGetUniformLocation(self.shaderProgram, "normalMatrix");
        glUniformMatrix4fv(normal, 1, 0, normalMatrix.m);
    }
    
    GLint diffuse = glGetUniformLocation(self.shaderProgram, "diffuseMap");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glUniform1i(diffuse, 0);
    
    [self drawRectangle];
}

- (void)bindAttribs:(GLfloat *)triangleData {
    GLint position = glGetAttribLocation(self.shaderProgram, "position");
    glEnableVertexAttribArray(position);
    
    GLint color = glGetAttribLocation(self.shaderProgram, "normal");
    glEnableVertexAttribArray(color);
    
    GLint uv = glGetAttribLocation(self.shaderProgram, "uv");
    glEnableVertexAttribArray(uv);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData);
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 3 * sizeof(GLfloat));
    glVertexAttribPointer(uv, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 6 * sizeof(GLfloat));
}

- (void)drawRectangle {
    static GLfloat vertexData[] = {
        -0.5, +0.5, +0.0, +0.0, +0.0, +1.0, +0.0, +0.0,
        -0.5, -0.5, +0.0, +0.0, +0.0, +1.0, +0.0, +1.0,
        +0.5, -0.5, +0.0, +0.0, +0.0, +1.0, +1.0, +1.0,
        +0.5, +0.5, +0.0, +0.0, +0.0, +1.0, +1.0, +0.0,
        -0.5, +0.5, +0.0, +0.0, +0.0, +1.0, +0.0, +0.0,
        +0.5, -0.5, +0.0, +0.0, +0.0, +1.0, +1.0, +1.0,
    };
    
    [self bindAttribs:vertexData];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertexData) / (sizeof(GLfloat) * 8));
}

@end
