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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.delegate = self;
    view.context = _context;
    
    [EAGLContext setCurrentContext:_context];
}

- (void)update {
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
