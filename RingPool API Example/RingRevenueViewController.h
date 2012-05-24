//
//  RingRevenueViewController.h
//  RingPool API Example
//
//  Copyright (c) 2012 RingRevenue, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RingRevenueViewController : UIViewController <UITextFieldDelegate>
- (IBAction)fetchRingPoolNumber:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *responseField;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, retain) NSMutableData *ringPoolResponseData;
@property (nonatomic) int ringPoolStatusCode;

@end
