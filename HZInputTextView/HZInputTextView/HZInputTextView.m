//
//  HZInputTextView.m
//  HZInputTextView
//
//  Created by huangzhenyu on 2018/3/27.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZInputTextView.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kInputViewDefaultMinH 56
#define kTextViewMaxH 80

@interface HZInputTextView()<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIView *textContentView;
@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UILabel *placeholderLab;
@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,assign) CGFloat keyboardAnimationDuration;//键盘动画时间
@property (nonatomic,assign) CGFloat keyboardHeight;//键盘高度

@property (nonatomic,assign) CGRect inputViewDefaultFrame;
@property (nonatomic,assign) CGRect inputViewShowDefaultFrame;
@property (nonatomic,assign) CGRect textViewDefaultFrame;
@property (nonatomic,assign) CGRect contentViewDefaultFrame;
@property (nonatomic,assign) CGRect sendBtnDefaultFrame;
@property (nonatomic,assign) CGRect placeHolderDefaultFrame;

//发布按钮点击后的回调
@property (nonatomic, copy) BOOL(^sendBlcok)(NSString *text);
@end
@implementation HZInputTextView

- (void)dealloc{
    NSLog(@"textInputView销毁");
    [_textView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //UI
        [self setupUI];
        //键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
#pragma mark UI
- (void)setupUI{
    NSLog(@"setupUI");
    _keyboardAnimationDuration = 0.5;
    _keyboardHeight = 0;
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTap)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    //添加View
    [self addSubview:self.inputView];
    [self.inputView addSubview:self.textContentView];
    [self.textContentView addSubview:self.textView];
    [self.textView addSubview:self.placeholderLab];
    [self.inputView addSubview:self.sendButton];
    //设置frame
    [self autoSetInputViewHeight:kInputViewDefaultMinH];
    
    self.textContentView.layer.cornerRadius = 17;
    self.textContentView.clipsToBounds = YES;
    
    self.inputViewDefaultFrame = _inputView.frame;
    self.contentViewDefaultFrame = _textContentView.frame;
    self.textViewDefaultFrame = _textView.frame;
    self.sendBtnDefaultFrame = _sendButton.frame;
    self.placeHolderDefaultFrame = _placeholderLab.frame;
    
    NSLog(@"设置初始化frame");
    UIView *seperateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 1.0/[UIScreen mainScreen].scale)];
    seperateView.backgroundColor = [UIColor lightGrayColor];
    seperateView.alpha = 0.5;
    [self.inputView addSubview:seperateView];
    [self.textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)autoSetInputViewHeight:(CGFloat)inputViewH{
    CGFloat contentViewLSeperate = 20;//contentView左间距
    CGFloat contentViewRSeperate = 5;//contentView右间距
    CGFloat textViewLRSeparate = 10;//textView左右间距
    CGFloat placeHolderLRSeperate = 8;//placeHolder左右间距
    
    //inputView
//    CGFloat inputViewH = 100;
    CGFloat inputViewW = kScreenW;
    CGFloat inputViewX = 0;
    CGFloat inputViewY;
    if (_keyboardHeight > 0) {
         inputViewY = kScreenH - _keyboardHeight - inputViewH;
    } else {
        inputViewY = kScreenH;
    }
    
    //sendButton
    CGFloat sendBtnW = 44;
    CGFloat sendBtnY = 0;
    CGFloat sendBtnX = kScreenW - sendBtnW;
    CGFloat sendBtnH = inputViewH;
    
    
    //contentView
    CGFloat contentViewX = contentViewLSeperate;
    CGFloat contentViewH = inputViewH - 20;
    CGFloat contentViewY = (inputViewH - contentViewH) * 0.5;
    CGFloat contentViewW = kScreenW - contentViewLSeperate - contentViewRSeperate - sendBtnW;
    
    //textView
    CGFloat textViewX = textViewLRSeparate;
    CGFloat textViewY = 0;
    CGFloat textViewW = contentViewW - textViewLRSeparate * 2;
    CGFloat textViewH = contentViewH;
    
    //placeHolder
    CGFloat placeHolderX = placeHolderLRSeperate;
    CGFloat placeHolderY = 0;
    CGFloat placeHolderW = textViewW - placeHolderLRSeperate * 2;
    CGFloat placeHolderH = textViewH;
    
    self.inputView.frame = CGRectMake(inputViewX, inputViewY, inputViewW, inputViewH);
    self.textContentView.frame = CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH);
    self.textView.frame = CGRectMake(textViewX, textViewY, textViewW, textViewH);
    self.placeholderLab.frame = CGRectMake(placeHolderX, placeHolderY, placeHolderW, placeHolderH);
    self.sendButton.frame = CGRectMake(sendBtnX, sendBtnY, sendBtnW, sendBtnH);
}

#pragma mark 键盘监听
- (void)keyboardWillAppear:(NSNotification *)noti{
    NSLog(@"键盘出现");
    if(_textView.isFirstResponder){
        NSDictionary *info = [noti userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        _keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGSize keyboardSize = [value CGRectValue].size;
        _keyboardHeight = keyboardSize.height;
        [UIView animateWithDuration:_keyboardAnimationDuration animations:^{
            CGRect frame = self.inputViewDefaultFrame;
            frame.origin.y = kScreenH - _keyboardHeight - frame.size.height;
            self.inputView.frame = frame;
            self.inputViewShowDefaultFrame = self.inputView.frame;
        }];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)noti{
    if(_textView.isFirstResponder){
        [UIView animateWithDuration:_keyboardAnimationDuration animations:^{
            self.inputView.frame = self.inputViewDefaultFrame;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:_inputView]) {
        return NO;
    }
    return YES;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"KVO");
    if (object == _textView && [keyPath isEqualToString:@"contentSize"]) {
        CGFloat textViewActualHeight = _textView.contentSize.height;
        CGFloat textViewDefaultHeight = self.textViewDefaultFrame.size.height;
        if (textViewActualHeight > kTextViewMaxH) {
            textViewActualHeight = kTextViewMaxH;
        }
        if (textViewActualHeight > textViewDefaultHeight) {
            
            CGFloat inputViewH = self.inputViewDefaultFrame.size.height + textViewActualHeight - textViewDefaultHeight;
            [UIView animateWithDuration:0.3 animations:^{
                [self autoSetInputViewHeight:inputViewH];
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self resertFrameDefault];//恢复到,键盘弹出时,视图初始位置
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)resertFrameDefault{
    self.inputView.frame = self.inputViewShowDefaultFrame;
    self.textContentView.frame = self.contentViewDefaultFrame;
    self.textView.frame = self.textViewDefaultFrame;
    self.sendButton.frame = self.sendBtnDefaultFrame;
    self.placeholderLab.frame = self.placeHolderDefaultFrame;
}

#pragma mark set
-(void)setTextViewBackgroundColor:(UIColor *)textViewBackgroundColor{
    _textViewBackgroundColor = textViewBackgroundColor;
    _textContentView.backgroundColor = textViewBackgroundColor;
}
-(void)setFont:(UIFont *)font{
    _font = font;
    _textView.font = font;
    _placeholderLab.font = _textView.font;
}
-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    _placeholderLab.text = placeholder;
}
-(void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
    _placeholderLab.textColor = placeholderColor;
}
-(void)setSendButtonBackgroundColor:(UIColor *)sendButtonBackgroundColor{
    _sendButtonBackgroundColor = sendButtonBackgroundColor;
    _sendButton.backgroundColor = sendButtonBackgroundColor;
}
-(void)setSendButtonTitle:(NSString *)sendButtonTitle{
    _sendButtonTitle = sendButtonTitle;
    [_sendButton setTitle:sendButtonTitle forState:UIControlStateNormal];
}
-(void)setSendButtonCornerRadius:(CGFloat)sendButtonCornerRadius{
    _sendButtonCornerRadius = sendButtonCornerRadius;
    _sendButton.layer.cornerRadius = sendButtonCornerRadius;
}
-(void)setSendButtonFont:(UIFont *)sendButtonFont{
    _sendButtonFont = sendButtonFont;
    _sendButton.titleLabel.font = sendButtonFont;
}

#pragma mark get
- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15.0];
//        _textView.backgroundColor = [UIColor redColor];
    }
    return _textView;
}

- (UIView *)textContentView{
    if (!_textContentView) {
        _textContentView = [[UIView alloc] init];
        _textContentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _textContentView;
}

- (UIView *)inputView{
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.backgroundColor = [UIColor whiteColor];
    }
    return _inputView;
}

- (UILabel *)placeholderLab{
    if (!_placeholderLab) {
        _placeholderLab = [[UILabel alloc] init];
        _placeholderLab.font = [UIFont systemFontOfSize:14.0];
        _placeholderLab.textColor = [UIColor grayColor];
        _placeholderLab.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        _placeholderLab.backgroundColor = [UIColor blueColor];
    }
    return _placeholderLab;
}

- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"发布" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

#pragma mark actions
- (void)bgViewTap{
    [self hide];
}

- (void)sendButtonClick{
    if(self.sendBlcok){
        BOOL hideKeyBoard = self.sendBlcok(self.textView.text);
        if(hideKeyBoard){
            [self hide];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"%@ --- %@",textView.text ,text);
    if (([textView.text isEqualToString:@""] || textView.text.length == 1) && [text isEqualToString:@""]) {
        self.placeholderLab.hidden = NO;
    } else {
        self.placeholderLab.hidden = YES;
    }
    return YES;
}

//- (void)textViewDidChange:(UITextView *)textView{
//    NSLog(@"%@",textView.text);
//    if (textView.text.length > 0) {
//        self.placeholderLab.hidden = YES;
//    } else {
//        self.placeholderLab.hidden = NO;
//    }
//}

#pragma mark private
-(void)show{
    if([self.delegate respondsToSelector:@selector(hzInputTextViewWillShow:)]){
        [self.delegate hzInputTextViewWillShow:self];
    }
    self.textView.text = nil;
    self.placeholderLab.hidden = NO;
    [self.textView becomeFirstResponder];
}

-(void)hide{
    
    if([self.delegate respondsToSelector:@selector(hzInputTextViewWillHide:)]){
        [self.delegate hzInputTextViewWillHide:self];
    }
    [_textView resignFirstResponder];
}

#pragma mark public
+ (void)showWithConfigurationBlock:(void (^)(HZInputTextView *inputTextView))configurationBlock sendBlock:(BOOL (^)(NSString *))sendBlock{
    HZInputTextView *inputView = [[HZInputTextView alloc] init];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:inputView];
    if (configurationBlock) {
        configurationBlock(inputView);
    }
    inputView.sendBlcok = [sendBlock copy];
    [inputView show];
}
@end
