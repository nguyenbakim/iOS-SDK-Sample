//
//  TableListVC.h
//  ooVooSample
//
//  Created by Udi on 6/23/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableList_DELEGATE <NSObject>

-(void)tableListDidSelect:(int)index;

@end


@interface TableListVC : UIViewController
@property (retain, nonatomic) NSArray *arrList;
@property (assign)int selectedIndex;
@property (weak,nonatomic)id <TableList_DELEGATE>delegate;

@end
