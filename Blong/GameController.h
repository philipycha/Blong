//
//  GameController.h
//  Blong
//
//  Created by Philip Ha on 2016-03-11.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

int Y;
int X;

@interface GameController : UIViewController
{
    
    IBOutlet UIImageView *Ball;
    IBOutlet UIButton *StartButton;
    
    NSTimer *timer;
    

}

-(IBAction)StartButton:(id)sender;
-(void)BallMovement;

@end
