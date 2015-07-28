//
//  TableListVC.m
//  ooVooSample
//
//  Created by Udi on 6/23/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "TableListVC.h"

@interface TableListVC ()

@end

@implementation TableListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UINavigationBar *myBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
//    myBar.topItem.title=@"fdsfds";
//    [self.view addSubview:myBar];
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
    
    return [_arrList count]; // no data .
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text=_arrList[indexPath.row];
    
    if (_selectedIndex==indexPath.row)
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    for (int i=0; i<[_arrList count]; i++) {
//        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
//        
//        [tableView deselectRowAtIndexPath:index animated:YES];
//
//    }
    _selectedIndex=indexPath.row;
    [tableView reloadData];
  
    
//    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    if (theCell.accessoryType == UITableViewCellAccessoryNone) {
//        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    
//    else if (theCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        theCell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    [_delegate tableListDidSelect:indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
