//
//  InternetActivityVC.m
//  ooVooSample
//
//  Created by Udi on 6/22/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "InternetActivityVC.h"

@interface InternetActivityVC ()

@end

@implementation InternetActivityVC


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setIndicatorsBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setIndicatorsBorder {
    // Do any additional setup after loading the view.
    
    
    for (int i=1; i<5; i++) {
        UIView *view=[self.view viewWithTag:i];
        view.layer.borderColor=[UIColor blackColor].CGColor;
        view.layer.borderWidth=0.5f;
        view.backgroundColor=[UIColor clearColor];
    }
}

-(void)setInternetActivityLevel:(NSNumber *)level{
    
     _score = [level integerValue];
    if (_score)
    {
        [self setIndicatorsBorder];
        
        for (int i=1; i<=_score; i++) {
            UIView *view=[self.view viewWithTag:i];
            view.backgroundColor=[UIColor yellowColor];
        }

    }
    else{
        [self setIndicatorsBorder];
    }
    
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
