//
//  FriendsListVC.m
//  ooVooSample
//
//  Created by Udi on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "FriendsListVC.h"
#import "MessageManager.h"
#import "ActiveUserManager.h"
#import "UserDefaults.h"

#define TimeOut 30

@interface FriendsListVC () <UIAlertViewDelegate>
{
    NSMutableArray *arrFriends ; // we create friend list in this view only
    NSTimer *timer;
    int secCounter;
}

@end

@implementation FriendsListVC{
    UIAlertView *myAlertView ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sdk = [ooVooClient sharedInstance];
    
    secCounter=0;
    // arrFriends=[[NSMutableArray alloc]initWithObjects:@"iphone6",@"android",@"ipadipad", nil];
    arrFriends=[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AnswerDecline:) name:@"AnswerDecline" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AnswerAccept) name:@"AnswerAccept" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(otherUserbusy:) name:@"Busy" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(remoteUserIsOffLine:) name:@"OffLine" object:nil];
    
    
    _isForCall?[self.btnCallOrSendMessage setTitle:@"Call" forState:UIControlStateNormal]:[self.btnCallOrSendMessage setTitle:@"Send Message" forState:UIControlStateNormal];
    
    if ([ActiveUserManager activeUser].token.length) {
        _isForCall?@"":[self setNavigationBarRightButton];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    arrFriends=nil;
    [timer invalidate];
    timer=nil;
}


-(void)setNavigationBarRightButton{
    
    self.navigationItem.rightBarButtonItem=nil;
    
    UIBarButtonItem *btnSubscribe ;
    if ([ActiveUserManager activeUser].isSubscribed) {
        btnSubscribe = [[UIBarButtonItem alloc] initWithTitle:@"Unsubscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(unsubscribe)];
    }
    else
    {
        btnSubscribe = [[UIBarButtonItem alloc] initWithTitle:@"subscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(subscribe)];

    }
    
    self.navigationItem.rightBarButtonItem=btnSubscribe;
    self.navigationController.navigationBar.translucent = NO;
    

}

-(void)unsubscribe{
    
    NSString * uuid = [[NSUUID UUID] UUIDString] ;
    NSString * token = [ActiveUserManager activeUser].token;
    if(token && token.length > 0){
        [self.sdk.PushService unSubscribe:token deviceUid:uuid completion:^(SdkResult *result)
        {

            NSString *msg ;
            if (result.Result == sdk_error_OK) {
                
                // delete userid token
                
                
                  [UserDefaults setObject:nil ForKey:[ActiveUserManager activeUser].userId];
                
                msg = @"Unsubscribe Succeeded";
                [ActiveUserManager activeUser].isSubscribed = false;
                [self setNavigationBarRightButton];
            }
            else
            {
                msg = @"Unsubscribe Failed";

            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unsubscribe" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}

-(void)subscribe{
    
    NSString * uuid = [[NSUUID UUID] UUIDString] ;
    NSString * token = [ActiveUserManager activeUser].token;

    if(token && token.length > 0)
    {
        [self.sdk.PushService subscribe:token deviceUid:uuid completion:^(SdkResult *result){
            
            NSString *msg ;
            if (result.Result == sdk_error_OK) {
                msg = @"Subscribe Succeeded";
                [ActiveUserManager activeUser].isSubscribed = true;
                 [self setNavigationBarRightButton];
            }
            else
            {
                msg = @"Subscribe Failed";
                
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Subscribe" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
        
}

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [arrFriends count]; // no data .
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text=arrFriends[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [arrFriends removeObjectAtIndex:[indexPath row]];
        // Delete row using the cool literal version of [NSArray arrayWithObject:indexPath]
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - IBAction

- (IBAction)actSendOrCall:(id)sender {
    
    _isForCall?[self actCall:nil]:[self actSendPushMsg:nil];
}

- (IBAction)actAddFriends:(id)sender {
    
    if ([arrFriends count]<3)
    {
        [self showAlertWithTitle:@"Add Friend Name" WithMessage:@"What is your friend name?" CancelButton:@"Cancel" OkButton:@"Ok"];
    }
    else
    {
        [self showAlertWithTitle:@"Max 3 Friends" WithMessage:@"You can't add more than 3 friends"CancelButton:@"Cancel" OkButton:nil];
    }
}


-(BOOL)canSend{
    
    if ([arrFriends count]==0) {
        [self showAlertWithTitle:@"No Friends" WithMessage:@"You must have friends in list to make a call !" CancelButton:@"Ok" OkButton:nil];
        return NO;
    }
    return YES;
    
}
- (IBAction)actCall:(id)sender {
    
    if (![self canSend]) {
        [self showAlertWithTitle:@"No Friends" WithMessage:@"You must have friends in list to make a call !" CancelButton:@"Ok" OkButton:nil];
        return;
    }
    
    myAlertView = [[UIAlertView alloc] initWithTitle:@"Calling" message:@""
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:nil, nil];
    myAlertView.tag=100; // call alert
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.frame=CGRectMake(0, 0, 16, 16);
    [myAlertView setValue:loading forKey:@"accessoryView"];
    [loading startAnimating];
    [myAlertView show];
    
    [self callToFriends];
}


- (IBAction)actSendPushMsg:(id)sender {
    if (![self canSend]) {
//        [self showAlertWithTitle:@"No Friends" WithMessage:@"You must have friends in list to make a call !" CancelButton:@"Ok" OkButton:nil];
        return;
    }
    
    UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"Send Msg" message:@"Add Your Msg here ! " delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Ok",nil];
    
    alertViewChangeName.alertViewStyle=UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alertViewChangeName textFieldAtIndex:0];
    textField.text = @"your text";
    
    alertViewChangeName.tag = 200 ;
    
    [alertViewChangeName show];
    
    
}


#pragma  mark - Call Methods CNMESSAGE

int callAmount = 0 ; // saving the calling amount so if one of then rejects , the call alert conyinue to show for the other friends call
-(void)callToFriends{
    
    callAmount=[arrFriends count];
    __block index=0;
    
  //  for (int i=0; i<[arrFriends count]; i++)
    {
      //  NSString *userName = arrFriends[i];
        
    //    NSLog(@"Calling friend %@",userName);
        // sending a message of calling BUT if something is wrong cancel the call alert
        [[MessageManager sharedMessage]messageOtherUsers:arrFriends WithMessageType:Calling WithConfID:[ActiveUserManager activeUser].randomConference Compelition:^(BOOL CallSuccess) {
            
          
            
            if (!CallSuccess) {
                [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            else
            {
                [self stopTimer];
                timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer_Tick:) userInfo:nil repeats:YES];

            }
            
        }];
        
        
        
        
        
//        [[MessageManager sharedMessage]messageOtherUser:userName WithMessageType:Calling WithConfID:[ActiveUserManager activeUser].randomConference Compelition:^(BOOL CallSuccess)
//        {
//            index++;
//            
//            if (!CallSuccess) {
//                 callAmount -- ;
//            }
//            
//            if (index==[arrFriends count])
//            {
//
//                if (!callAmount)
//                {
//                    
//                    [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
//                }
//                else
//                {
//                    [self stopTimer];
//                    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer_Tick:) userInfo:nil repeats:YES];
//                }
//                
//            }
//            
//            
//        }];
       
    }
    
    
}

-(void)sendMsgToFriends:(NSString*)message{
    NSLog(@"msg = %@",message);
    
    //no need for sending push for each user becuase message receives array of users and send the push to all of them
    //for (NSString *userName in arrFriends) {
        
        ooVooPushNotificationMessage * msg = [[ooVooPushNotificationMessage alloc] initMessageWithUsersArray:arrFriends message:message property:@"Im optional" timeToLeave:1000];
        
        [self.sdk.PushService sendPushMessage:msg completion:^(SdkResult *result){
            if(result.Result == sdk_error_OK)
            {
                NSLog(@"Send succeeded");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sent Msg" message:@"Your msg has been sent ,Thanks ! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
        }];
        
    //}
    
}

-(void)timer_Tick:(NSTimer*)timer{
    secCounter++;
    NSLog(@"Counter Timer %d",secCounter);
    
    if (secCounter>=TimeOut) {
        [self callCancelFriends];
        [timer invalidate];
        secCounter=0;
        if (myAlertView) {
            [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
            
        }
    }
}

// if the caller canceled his call
-(void)callCancelFriends{
    
    [self stopTimer];
    
    callAmount=0;
    
   // for (NSString *userName in arrFriends) {
   //     NSLog(@"Calling friend %@",userName);
        [[MessageManager sharedMessage]messageOtherUsers:arrFriends WithMessageType:Cancel WithConfID:[ActiveUserManager activeUser].randomConference Compelition:^(BOOL CallSuccess) {
            
        }];
  //  }
    
}


-(void)stopTimer{
    if (timer.valid) {
        [timer invalidate];
        secCounter=0;
    }
}

-(void)remoteUserIsOffLine:(NSNotification*)notif{
    // some one rejected the call
    
    NSLog(@"notification %@",notif.userInfo);
    NSString *userName=[notif object];
    
    callAmount--;
    
    if (!callAmount) // if there are other friends we call to than dont remove the call spinner alert
    {
        [self stopCallAndDismissView];
    }
    
    [self showAlertWithTitle:@"OffLine" WithMessage:[NSString stringWithFormat:@"Your friend %@ \n is Offline.",userName]  CancelButton:@"Ok" OkButton:nil];
    
}


-(void)AnswerDecline:(NSNotification*)notif{
    // some one rejected the call
    
    NSLog(@"notification %@",notif.userInfo);
    CNMessage *message=[notif object];
    
    callAmount--;
    
    if (!callAmount) // if there are other friends we call to than dont remove the call spinner alert
    {
        [self stopCallAndDismissView];
    }
    
    [self showAlertWithTitle:@"Rejected" WithMessage:[NSString stringWithFormat:@"Your friend %@ \n rejected the call.",message.displayName]  CancelButton:@"Ok" OkButton:nil];
    
}

-(void)otherUserbusy:(NSNotification*)notif{
    // some one rejected the call
    
    NSLog(@"notification %@",notif.userInfo);
    CNMessage *message=[notif object];
    
    callAmount--;
    
    if (!callAmount) // if there are other friends we call to than dont remove the call spinner alert
    {
        [self stopCallAndDismissView];
    }
    
    [self showAlertWithTitle:@"Busy" WithMessage:[NSString stringWithFormat:@"Your friend %@ \n is busy with another call.",message.displayName]  CancelButton:@"Ok" OkButton:nil];
    
}

-(void)stopCallAndDismissView{
    [self stopTimer];
    [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [[MessageManager sharedMessage]stopCallSound];

}

-(void)AnswerAccept{
    [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [self stopTimer];
}



-(void)showAlertWithTitle:(NSString*)title WithMessage:(NSString*)message CancelButton:(NSString*)cancel OkButton:(NSString*)Ok{
    
    UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:Ok,nil];
    
    if (Ok!=nil) {
        alertViewChangeName.alertViewStyle=UIAlertViewStylePlainTextInput;
    }
    
    [alertViewChangeName show];
    
    
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==100) // call alert
    {
        if (alertView.cancelButtonIndex == buttonIndex)
        {
            // cancell the call Send to the users
            [self callCancelFriends];
            
            return;
        }
    }
    
    if (alertView.tag==200) // call alert
    {
        if (alertView.cancelButtonIndex != buttonIndex)
        {
            // cancell the call Send to the users
            UITextField *text = [alertView textFieldAtIndex:0];
            
            [self sendMsgToFriends:text.text];
            
            return;
        }
    }
    
    if (buttonIndex!=alertView.cancelButtonIndex) {
        
        NSString *friendName = [[alertView textFieldAtIndex:0] text];
        if (![[friendName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""])
        {
            [arrFriends addObject:friendName];
            //   NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[arrFriends count] inSection:0];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:[arrFriends count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    
}


@end
