//
//  InfoViewController.m
//  ooVooSample
//
//  Created by Udi on 6/3/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "InfoViewController.h"
#import "ParticipentCell.h"
#import "UserDefaults.h"

#define AppToken @"AppToken"
#define BaseURL @"BaseURL"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
   
    _lblConferenceID.text = [NSString stringWithFormat:@"%@ ",_strConferenceId];
 
    
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

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_arrParticipants count]; // no data .
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *uid=_arrParticipants[indexPath.row];
    
    
    ParticipentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.lblParticipentID.text= uid;
    
   [cell.switchShowOrHide setOn:[[_delegate InfoViewController_GetVisualListForId:uid] boolValue]];
    
    
    if (![[_delegate isAllowedToChangeUserStateForId:uid]boolValue] ) {
        cell.switchShowOrHide.on=false;
        cell.switchShowOrHide.enabled=false;
    }
    else
    {
        cell.switchShowOrHide.enabled=true;
    }
    
    cell.switchShowOrHide.tag = indexPath.row;
    

    return cell;
}


#pragma mark - IBACTION


- (IBAction)actValueChanged:(id)sender {
    
    
[_delegate InfoViewController_DidChangeVisualToUid:_arrParticipants[ [sender tag] ]];

}

@end
