//
//  ViewController.m
//  Bellbird
//
//  Created by Mike Cohen on 11/3/17.
//  Copyright © 2017 Mike Cohen. All rights reserved.
//

#import "ViewController.h"

#import "ApiEndpoint.h"
@interface ViewController ()
@property (nonatomic,copy) NSArray *alarms;
@property (nonatomic,strong) ApiEndpoint *endpoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.endpoint = [[ApiEndpoint alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AlarmCreated:) name:@"AlarmCreated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AlarmUpdated:) name:@"AlarmUpdated" object:nil];
    
    [self fetchAlearms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)AlarmCreated:(NSNotification*)notification {
    id obj = notification.object;
    NSLog(@"notification object: %@",obj);
    int alarmId = [obj[@"id"] intValue];
    [self.endpoint push:alarmId];
    [self fetchAlearms];    // we should probably be smarter and just update the one we created
}

- (void)AlarmUpdated:(NSNotification*)notification {
    id obj = notification.object;
    NSLog(@"notification object: %@",obj);
    int alarmId = [obj[@"id"] intValue];
    [self.endpoint push:alarmId];
    [self fetchAlearms];    // we should just update the changed alarm
}

- (void)fetchAlearms {
    [self.endpoint getAlarms:^(NSArray *array) {
        self.alarms = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
            NSString *date1 = obj1[@"created_at"];
            NSString *date2 = obj2[@"created_at"];
            return [date2 compare:date1];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.alarms.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *alarm = self.alarms[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = alarm[@"body"];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Votes: %@ Created: %@",
                                 alarm[@"votes"],
                                 alarm[@"created_at"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // tapping cell upvotes
    NSDictionary *alarm = self.alarms[indexPath.row];
    int alarmId = [alarm[@"id"] intValue];
    int votes = [alarm[@"votes"] intValue] + 1;
    [self.endpoint updateAlarm:alarmId votes:votes];
}

- (IBAction)createAlarm:(id)sender {
//    [self.endpoint createAlarm:@"TEST ALARM BY MIKE"];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Create Alarm"
                                                        message: @"Enter AlarmText"
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Alarm Text";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField *alarmTextField = textfields[0];
        NSString *alarmText = [alarmTextField.text uppercaseString];
        [self.endpoint createAlarm:alarmText];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

@end
