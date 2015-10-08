//
//  VideoPanelWithLabel.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/6/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "UIView-Extensions.h"
#import "UserVideoPanel.h"
#import "ActiveUserManager.h"

@implementation UserVideoPanel

- (instancetype)init 
{
    if (self = [super init]) {
        
    }
    
    return self;
}
-(void)didMoveToWindow{
    
    [super didMoveToWindow];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(touchUpInsideEvent)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:tapRecognizer];
    
}
- (instancetype)initWithFrame:(CGRect)frame WithName:(NSString *)strUserName 
{
    self = [super initWithFrame:frame];
    _strUserId = strUserName;
    _isAllowedToChangeImage=true;
    return self;
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
    lblUserName=nil;
    imgView=nil;
    lblVideoAlert=nil;
    _strUserId=nil;
    _delegate=nil;
  
}

-(void)dealloc{
    
    lblUserName=nil;
    imgView=nil;
    lblVideoAlert=nil;
    _strUserId=nil;
    _delegate=nil;
}

-(void) didMoveToSuperview{
    [super didMoveToSuperview] ;
    _isAllowedToChangeImage=YES;
    [self showAvatar:YES];
    [self setUserName];
}

- (void)layoutIfNeeded {
}

- (void)strUserId {
    lblUserName.text = _strUserId;
}



-(void)touchUpInsideEvent{
    [_delegate UserVideoPanel_Touched:self];
    
}
- (void)setUserName {
    
    if (!lblUserName) {
        
        UIView *viewGrayBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        viewGrayBackground.backgroundColor = [UIColor grayColor];
        viewGrayBackground.alpha = 0.5;
        viewGrayBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:viewGrayBackground];
        
        lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        
        if (_strUserId) {
            lblUserName.text = _strUserId;
        }
        else{
             lblUserName.text = @"Me";
        }
        
        [self addSubview:lblUserName];
        lblUserName.textColor = [UIColor whiteColor];
        lblUserName.textAlignment = NSTextAlignmentCenter;
        
        [lblUserName setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraint:[self constraintToTopFor:lblUserName]];
        [self addConstraint:[self constraintToLeftFor:lblUserName]];
        [self addConstraint:[self constraintToRightFor:lblUserName]];
        
        [viewGrayBackground addConstraints:lblUserName.constraints];
    }
   }

- (void)setAvatarImage{
  
    if (!imgView) {
        imgView = [[UIImageView alloc] init];
        [imgView setImage:[UIImage imageNamed:@"Avatar"]];
        [self addSubview:imgView];
        [self addConstraint:[self constraintToTopFor:imgView]];
        [self addConstraint:[self constraintToBottomFor:imgView]];
        [self addConstraint:[self constraintToLeftFor:imgView]];
        [self addConstraint:[self constraintToRightFor:imgView]];
        [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
}

- (void)setLabelVideoAlert{
 
    if (!lblVideoAlert) {
        lblVideoAlert = [[UILabel alloc] init];
        [self addSubview:lblVideoAlert];
        lblVideoAlert.backgroundColor=[UIColor clearColor];
        lblVideoAlert.text=@"Video cannot be viewed";
        lblVideoAlert.textAlignment=NSTextAlignmentCenter;
        [lblVideoAlert setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
        lblVideoAlert.adjustsFontSizeToFitWidth=YES;
        [self addConstraint:[self constraintToTopFor:lblVideoAlert]];
        [self addConstraint:[self constraintToBottomFor:lblVideoAlert]];
        [self addConstraint:[self constraintToLeftFor:lblVideoAlert]];
        [self addConstraint:[self constraintToRightFor:lblVideoAlert]];
        [lblVideoAlert setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
}


-(void) didVideoRenderStart 
{
     [self showAvatar:NO] ;
}
-(void) didVideoRenderStop 
{
    [self showAvatar:YES] ;
}

-(void)showAvatar:(bool)show{
    
//    if (!_isAllowedToChangeImage)
//    {
//        return;
//    }
    
    [self setAvatarImage];
    
    imgView.hidden=!show;
    
    if (imgView.hidden)
        self.backgroundColor=[UIColor clearColor];
    else
        self.backgroundColor=[UIColor whiteColor];
}

-(void)showVideoAlert:(bool)show{
    [self setLabelVideoAlert];
    lblVideoAlert.hidden=!show;
}

#pragma mark - Constraint 

-(NSLayoutConstraint*)constraintToTopFor:(UIView*)someView{
    
    return  [NSLayoutConstraint constraintWithItem:someView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:0];
    
}

-(NSLayoutConstraint*)constraintToBottomFor:(UIView*)someView{
    
    return  [NSLayoutConstraint constraintWithItem:someView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0];
    
}
-(NSLayoutConstraint*)constraintToLeftFor:(UIView*)someView{
    
    return [NSLayoutConstraint constraintWithItem:someView
                                        attribute:NSLayoutAttributeLeading
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:NSLayoutAttributeLeading
                                       multiplier:1.0
                                         constant:0];
}

-(NSLayoutConstraint*)constraintToRightFor:(UIView*)someView{
    
    return [NSLayoutConstraint constraintWithItem:someView
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0
                                         constant:0];
}


-(void)animateImageFrame:(CGRect)frame{
[UIView animateWithDuration:0.5 animations:^{
    imgView.frame = frame;
}];
}


@end
