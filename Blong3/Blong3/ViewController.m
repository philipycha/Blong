//
//  ViewController.m
//  Blong3
//
//  Created by Philip Ha on 2016-03-17.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollisionBehaviorDelegate>


@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *ballBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *paddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *wallBehavior;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIPushBehavior *push;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIView *ball;
@property (nonatomic, strong) UIView *paddle;
@property (nonatomic, strong) UIView *computerPaddle;

@property (nonatomic, strong) UILabel *scoreboard;
@property (nonatomic, assign) NSInteger computerScore;
@property (nonatomic, assign) NSInteger playerOneScore;

@property (readwrite, assign) BOOL catapultMode;
@property (nonatomic, assign) CGPoint catapultEngage;
@property (nonatomic, assign) CGRect catapultArea;
@property (nonatomic, assign) CGVector anchorVector;
@property (nonatomic, strong) UIPushBehavior *catapultPush;

@property (readwrite, assign) float playerOne;
@property (readwrite, assign) float computer;
@property (readwrite, assign) float anchorX;
@property (readwrite, assign) float anchorY;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *countDownLabel;

@property (nonatomic, strong) NSTimer *timer2;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self createBall];
    [self createcomputerPaddle];
    [self createPaddle];
    [self createCollisions];
    
    CGRect scoreboardRectangle = CGRectMake(self.view.bounds.size.width/2.0 - 100.0, 100.0, 200.0, 25.0);
    self.scoreboard = [[UILabel alloc] initWithFrame:scoreboardRectangle];
    self.scoreboard.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.computerScore = 0;
    self.playerOneScore = 0;
    self.scoreboard.text = [NSString stringWithFormat:@"Top: %ld      Bottom: %ld", (long)self.computerScore, (long)self.playerOneScore];
    
    self.scoreboard.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.scoreboard];
    
    UIPanGestureRecognizer *catapultPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [catapultPanGesture setMinimumNumberOfTouches:1];
    [catapultPanGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:catapultPanGesture];
    

    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:.318 target:self selector:@selector(movecomputerPaddle:) userInfo:nil repeats:YES];
    [self startGame];
    
}

- (void)createCollisions {
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.paddle, self.computerPaddle]];
    
    self.collision.collisionMode = UICollisionBehaviorModeEverything;
    //self.collision.translatesReferenceBoundsIntoBoundary = YES;
    [self.collision addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, self.view.frame.size.height)];
    [self.collision addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.view.frame.size.width, 0) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height)];
    [self.collision addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, 1)];
    [self.collision addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(1, self.view.frame.size.height - 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];

    self.collision.collisionDelegate = self;
    [self.animator addBehavior:self.collision];

}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    
    NSString *boundary = (NSString *)identifier;
    if ([boundary isEqualToString:@"top"]) {
        self.computerPaddle.frame = CGRectMake((self.view.frame.size.width / 2) - 50, 30, 100, 10);
        NSLog(@"computerPaddleFrame before: %@",NSStringFromCGRect(self.computerPaddle.frame));
        self.playerOneScore = self.playerOneScore + 1;
        
        [self removeBall];
        [self createBall];
        [self startGame];
        NSLog(@"computerPaddleFrame after: %@",NSStringFromCGRect(self.computerPaddle.frame));
    }
    else if ([boundary isEqualToString:@"bottom"]) {
        self.computerScore = self.computerScore + 1;
     
        [self removeBall];
        [self createBall];
        [self startGame];
    }
    else if ([boundary isEqualToString:@"right"]) {
       // NSLog(@"right hit");
    }
    else if ([boundary isEqualToString:@"left"]) {
       // NSLog(@"left hit");
    }
    
    self.scoreboard.text = [NSString stringWithFormat:@"Top: %ld      Bottom: %ld", (long)self.computerScore, (long)self.playerOneScore];
    
}


- (void)createBall {
    CGRect ballRect = CGRectMake(self.view.center.x - 10, self.view.center.y - 10, 25, 25);
    self.ball = [[UIView alloc] initWithFrame:ballRect];
    self.ball.layer.cornerRadius = 12.5;
    self.ball.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.ball];
    self.ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    self.ballBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.ballBehavior];
    self.ballBehavior.elasticity = 1.00;
    self.ballBehavior.friction = 0.0;
    self.ballBehavior.resistance = 0.0;
    [self.collision addItem:self.ball];
    [self.animator addBehavior:self.ballBehavior];


}

- (void)removeBall {
    [self.animator removeBehavior:self.ballBehavior];
    [self.collision removeItem:self.ball];
    [self.ball removeFromSuperview];
    self.ball = nil;
}



- (void)createPaddle {
    CGRect paddleRect = CGRectMake((self.view.frame.size.width / 2) - 50, (self.view.frame.size.height - 30), 100, 10);
    self.paddle = [[UIView alloc] initWithFrame:paddleRect];
    self.paddle.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.paddle];
    
    self.paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle, self.computerPaddle]];
    self.paddleBehavior.allowsRotation = NO;
    self.paddleBehavior.density = 1000.0f;
    self.paddleBehavior.resistance = 100.0;
    [self.animator addBehavior:self.paddleBehavior];
    
    
}

- (void)createcomputerPaddle {
    CGRect paddleRect = CGRectMake((self.view.frame.size.width / 2) - 50, 30, 100, 10);
    self.computerPaddle = [[UIView alloc] initWithFrame:paddleRect];
    self.computerPaddle.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.computerPaddle];
}


- (void)dragged:(UIPanGestureRecognizer *)sender {
    if ((sender.state == UIGestureRecognizerStateBegan || sender.state ==UIGestureRecognizerStateChanged) && (sender.numberOfTouches == 1)) {
        
        CGPoint location = [sender locationInView:self.view];
        
        if (!self.catapultMode) {
            
            if (self.playerOne == 0) {
                self.playerOne = location.x - self.paddle.center.x;
            }
            
            CGPoint newLocation = CGPointMake(location.x - self.playerOne, self.paddle.center.y);
            CGRect newRect = CGRectMake(newLocation.x - (self.paddle.frame.size.width / 2), self.paddle.frame.origin.y, self.paddle.frame.size.width, self.paddle.frame.size.height);
            
            if (CGRectContainsRect(self.view.frame, newRect)) {
                self.paddle.center = newLocation;
            }
            
            [self.animator updateItemUsingCurrentState:self.paddle];
        }
 
}
}


- (void)movecomputerPaddle:(NSTimer *)timer {
    
    if (self.ball) {
        [UIView animateWithDuration:0.3295 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.computerPaddle.center = CGPointMake(self.ball.center.x, self.computerPaddle.center.y);
            // NSLog(@"computerPaddle.center.x = %f, ball.center.x = %f",self.computerPaddle.center.x,self.ball.center.x);
            [self.collision removeBoundaryWithIdentifier:@"computerPaddle"];
            [self.collision addBoundaryWithIdentifier:@"computerPaddle" forPath:[UIBezierPath bezierPathWithRect:self.computerPaddle.frame]];
            [self.animator updateItemUsingCurrentState:self.computerPaddle];
        } completion:nil];
    }
}

- (void) restartTimerFired {
    static int countDown = 0;
    
    countDown++;
    self.countDownLabel.text = [NSString stringWithFormat:@"Starting in %d seconds",3 - countDown];
    if (countDown == 3) {
        countDown = 0;
        [self.animator addBehavior:self.push];
        [self.timer invalidate];
        self.timer = nil;
        [self.countDownLabel removeFromSuperview];
        self.countDownLabel = nil;
    }
}

- (void) startGame {
    NSLog(@"computerPaddleFrame at startGame: %@",NSStringFromCGRect(self.computerPaddle.frame));
    // reset scores
    // push ball
    // Start ball off with a push
    self.push = [[UIPushBehavior alloc] initWithItems:@[self.ball]
                                                   mode:UIPushBehaviorModeInstantaneous];
    self.push.pushDirection = CGVectorMake(1.0, 1.0);
    self.push.active = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(restartTimerFired) userInfo:nil repeats:YES];
    [self.push setMagnitude:0.26];
    self.countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 100.0, 200.0, 200.0, 25.0)];
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    self.countDownLabel.text = [NSString stringWithFormat:@"Starting in 3 seconds"];
    self.countDownLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.countDownLabel];
    // Because push is instantaneous, it will only happen once
}

@end
