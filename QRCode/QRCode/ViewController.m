//
//  ViewController.m
//  QRCode
//
//  Created by huangyueqi on 2017/5/11.
//  Copyright © 2017年 sjyt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)buttonAction:(id)sender {
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"QRCode" bundle:nil] instantiateViewControllerWithIdentifier:@"CGQRCodeViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
