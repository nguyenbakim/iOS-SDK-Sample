//
//  UserInfoVc.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "UserInfoVc.h"

@interface UserInfoVc ()

@end

@implementation UserInfoVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"friend %@", _friendOfMine.displayName);

    _lblName.text = _friendOfMine.displayName;
    _lblStatus.text = _friendOfMine.status;

    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_friendOfMine.avatarUri]];

    if (data) {
        _imgFriend.image = [UIImage imageWithData:data];
    } else {
        _imgFriend.image = [UIImage imageNamed:@"Avatar"];
    }

    [self.view setNeedsLayout];
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
