//
//  ViewController.m
//  HZInputTextView
//
//  Created by huangzhenyu on 2018/3/27.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "ViewController.h"
#import "HZInputTextView.h"

@interface ViewController ()<HZInputTextViewDelagete>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)show:(id)sender {
    [HZInputTextView showWithConfigurationBlock:^(HZInputTextView *inputTextView) {
        /** 请在此block中设置inputTextView属性 */
        inputTextView.delegate = self;
        
        inputTextView.placeholder = @"请输入评论文字...";
        
//        inputTextView.textViewBackgroundColor = [UIColor redColor];
        
        
    } sendBlock:^BOOL(NSString *text) {
        if(text.length){
            NSLog(@"输入的信息为:%@",text);
            return YES;//return YES,收起键盘
        }else{
            NSLog(@"显示提示框-请输入要评论的的内容");
            return NO;//return NO,不收键盘
        }
    }];
}

#pragma mark -- HZInputTextViewDelagete
- (void)hzInputTextViewWillShow:(HZInputTextView *)inputTextView{
    /** 如果你工程中有配置IQKeyboardManager,并对HZInputTextView造成影响,请在HZInputTextView将要显示时将其关闭 */
    
    //[IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //[IQKeyboardManager sharedManager].enable = NO;
}

- (void)hzInputTextViewWillHide:(HZInputTextView *)inputTextView{
    /** 如果你工程中有配置IQKeyboardManager,并对HZInputTextView造成影响,请在HZInputTextView将要影藏时将其打开 */
    
    //[IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    //[IQKeyboardManager sharedManager].enable = YES;
}

@end
