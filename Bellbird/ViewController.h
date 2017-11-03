//
//  ViewController.h
//  Bellbird
//
//  Created by Mike Cohen on 11/3/17.
//  Copyright © 2017 Mike Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UIButton *composeButton;

- (IBAction)createAlarm:(id)sender;

@end

