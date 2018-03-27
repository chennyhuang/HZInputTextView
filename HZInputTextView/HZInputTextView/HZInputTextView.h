//
//  HZInputTextView.h
//  HZInputTextView
//
//  Created by huangzhenyu on 2018/3/27.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HZInputTextView;
@protocol HZInputTextViewDelagete <NSObject>
@optional

/**
 //如果你工程中有配置IQKeyboardManager,并对HZInputView造成影响,
 请在hzInputTextViewWillShow将要显示代理方法里 将IQKeyboardManager的enableAutoToolbar及enable属性 关闭
 请在hzInputTextViewWillHide将要消失代理方法里 将IQKeyboardManager的enableAutoToolbar及enable属性 打开
 如下:
 
 //HZInputTextView 将要显示
-(void)hzInputTextViewWillShow:(HZInputTextView *)inputTextView{
 [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
 [IQKeyboardManager sharedManager].enable = NO;
 }
 
 //HZInputTextView 将要隐藏
-(void)hzInputTextViewWillHide:(HZInputTextView *)inputTextView{
 [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
 [IQKeyboardManager sharedManager].enable = YES;
 }
 */

/**
 HZInputView 将要显示
 @param inputTextView inputTextView
 */

-(void)hzInputTextViewWillShow:(HZInputTextView *)inputTextView;

/**
 HZInputView 将要隐藏
 @param inputTextView inputTextView
 */
-(void)hzInputTextViewWillHide:(HZInputTextView *)inputTextView;
@end



@interface HZInputTextView : UIView
@property (nonatomic, assign) id<HZInputTextViewDelagete> delegate;
/** 字体 */
@property (nonatomic, strong) UIFont * font;
/** 占位符 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位符颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;
/** 输入框背景颜色 */
@property (nonatomic, strong) UIColor* textViewBackgroundColor;
/** 发送按钮背景色 */
@property (nonatomic, strong) UIColor *sendButtonBackgroundColor;
/** 发送按钮Title */
@property (nonatomic, copy) NSString *sendButtonTitle;
/** 发送按钮圆角大小 */
@property (nonatomic, assign) CGFloat sendButtonCornerRadius;
/** 发送按钮字体 */
@property (nonatomic, strong) UIFont * sendButtonFont;


/**
 显示输入框
 @param configurationBlock 请在此block中设置HZInputView属性
 @param sendBlock 发送按钮点击回调
 */
+(void)showWithConfigurationBlock:(void(^)(HZInputTextView *inputTextView))configurationBlock sendBlock:(BOOL(^)(NSString *text))sendBlock;
@end
