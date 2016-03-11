//
//  GameController.m
//  Blong
//
//  Created by Philip Ha on 2016-03-11.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

#import "GameController.h"

@interface GameController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *pongField;
@property (nonatomic, strong) UIView *ball;
@property (nonatomic, strong) UIDynamicItemBehavior *ballBehavior;

@end

@implementation GameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.autoresizesSubviews = NO;
    
    self.pongField = self.view;
    
}

-(IBAction)StartButton:(id)sender{
    
    // 50/50 chance for the ball to go up or down and left or right
    
    Y = arc4random() %11;
    Y = Y - 5;
    
    X = arc4random() %11;
    X = X - 5;
    
    if (Y == 0) {
        Y = 1;
    }
    
    if (X == 0) {
        X = 1;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(BallMovement) userInfo:nil repeats:YES];
    
}

-(void)BallMovement{
    
    Ball.center = CGPointMake(Ball.center.x + X, Ball.center.y + Y);
    
    //This creates the illusion of the ball bouncing off the side of the screen
    
    if (Ball.center.x < 15) {
        X = 0 - X;
    }
    
    if (Ball.center.x > 305) {
        X = 0 - X;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
