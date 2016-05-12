//
//  BTNViewController.m
//  QQMessageBtn
//
//  Created by Mime97 on 16/5/12.
//  Copyright © 2016年 Mime. All rights reserved.
//

#import "BTNViewController.h"
#import "QQMessageBtn.h"
@interface BTNViewController ()
@property (nonatomic, strong)QQMessageBtn *QQbtn;
@end

@implementation BTNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.QQbtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (QQMessageBtn *)QQbtn
{
    if (!_QQbtn) {
        _QQbtn = [[QQMessageBtn alloc]initWithFrame:CGRectMake(150, 150, 50, 50)];
        [_QQbtn setTitle:@"100" forState:UIControlStateNormal];
        [_QQbtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        _QQbtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _QQbtn.backgroundColor = [UIColor lightGrayColor];
    }
    return _QQbtn;
}
@end
