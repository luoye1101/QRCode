//
//  CGAlertView.m
//  CenturyGuard
//
//  Created by 黄国刚 on 16/3/14.
//  Copyright © 2016年 sjyt. All rights reserved.
//

#import "CGAlertView.h"
#import <Masonry/Masonry.h>
#import "XZAlertView.h"

#ifndef RGB
    #define RGB(r, g, b) [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f]
#endif

#define AUTODISMISSTIME 1.5

#define IOS_7_0 ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)

typedef NS_ENUM(NSInteger, CGAlertViewType) {
    CGAlertViewType_moren, // 默认
    CGAlertViewType_gouxuan,
    CGAlertViewType_xuanzeqi,
    CGAlertViewType_feixiang,
};

@interface SelectLeftBtn : UIButton

@end
@implementation SelectLeftBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, self.bounds.size.height * 0.1, self.bounds.size.height * 0.8, self.bounds.size.height * 0.8);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.bounds.size.height * 0.8, self.bounds.size.height * 0.1, self.bounds.size.width - self.bounds.size.height * 0.8, self.bounds.size.height * 0.8);
}

@end

@interface CGAlertView ()

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) UIButton *signButton;
@property (nonatomic, strong) UIWindow *signKeyWindow;

@end

@implementation CGAlertView

+ (instancetype)shareInstance
{
    
    if (IOS_7_0)
    {
        CGAlertView *alertView = [[CGAlertView alloc] init];
        return alertView;
    }
    else
    {
        static CGAlertView *alertView = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            alertView = [[CGAlertView alloc] init];
        });
        
        if (alertView.isKeyWindow)
        {
            [alertView dismissSelf];
        }
        
        alertView.selectIndex = 0;
        alertView.windowLevel = UIWindowLevelAlert;
        return alertView;
    }
}

//自动消失
- (void)showMessage:(NSString *)theMsg
{
    [self showTitle:@"提 示" withMessage:theMsg withCancelButton:nil withOtherButton:nil withIsAutoDismiss:YES withHanderBlock:nil withSelectBlock:nil type:CGAlertViewType_moren];
}

- (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(CGAlertActionBlock)theBlock
{
    [self showTitle:@"提 示" withMessage:theMsg withCancelButton:nil withOtherButton:nil withIsAutoDismiss:YES withHanderBlock:theBlock withSelectBlock:nil type:CGAlertViewType_moren];
}

//非自动消失
- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn
{
    [self showTitle:@"提 示" withMessage:theMsg withCancelButton:theCBtn withOtherButton:nil withHanderBlock:nil];
}

- (void)showMessage:(NSString *)theMsg withHanderBlock:(CGAlertActionBlock)theBlock
{
    [self showTitle:@"提 示" withMessage:theMsg withCancelButton:@"确定" withOtherButton:nil withHanderBlock:theBlock];
}

- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withHanderBlock:(CGAlertActionBlock)theBlock
{
    [self showTitle:@"提 示" withMessage:theMsg withCancelButton:theCBtn withOtherButton:nil withHanderBlock:theBlock];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGAlertActionBlock)theBlock
{
    [self showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withIsAutoDismiss:NO withHanderBlock:theBlock withSelectBlock:nil type:CGAlertViewType_moren];
}

- (void)showSelectWithTitle:(NSString *)theTitle withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGSelectAlertActionBlock)theBlock
{
    [self showTitle:theTitle withMessage:nil withCancelButton:theCBtn withOtherButton:theOBtn withIsAutoDismiss:NO withHanderBlock:nil withSelectBlock:theBlock type:CGAlertViewType_xuanzeqi];
}

- (void)showCheckBoxTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGSelectAlertActionBlock)theBlock
{
    [self showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withIsAutoDismiss:NO withHanderBlock:nil withSelectBlock:theBlock type:CGAlertViewType_gouxuan];
}

- (void)showShareViewWithHanderBlock:(CGSelectAlertShareActionBlock)theBlock
{
    [self showTitle:nil withMessage:nil withCancelButton:nil withOtherButton:nil withIsAutoDismiss:NO withHanderBlock:theBlock withSelectBlock:nil type:CGAlertViewType_feixiang];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withIsAutoDismiss:(BOOL)autoDismiss withHanderBlock:(CGAlertActionBlock)theBlock withSelectBlock:(CGSelectAlertActionBlock)selectBlock type:(CGAlertViewType)type
{
    
    if (IOS_7_0)
    {
        [[XZAlertView shareInstance] showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withHanderBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (theBlock)
            {
                theBlock(self, buttonIndex);
            }
        } withIsAutoDismiss:autoDismiss withMessageAlignmentLeft:NO];
        return;
    }
    
    _actionBlock = theBlock;
    _selectBlock = selectBlock;
    
    //标记原有的keyWindow
    NSArray *arr = [UIApplication sharedApplication].windows;
    [arr enumerateObjectsUsingBlock:^(UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[UIWindow class]]) {
            _signKeyWindow = obj;
            UIViewController *rootViewContorller = obj.rootViewController;
            UIViewController *topVC;
            if ([rootViewContorller isKindOfClass:[UINavigationController class]]) {
                topVC = [(UINavigationController *)rootViewContorller topViewController];
                [topVC.view endEditing:YES];
            }else if([rootViewContorller isKindOfClass:[UITabBarController class]]){
                UIViewController *selectVC = [(UITabBarController *)rootViewContorller selectedViewController];
                if ([selectVC isKindOfClass:[UINavigationController class]]) {
                    topVC = [(UINavigationController *)selectVC topViewController];
                    [topVC.view endEditing:YES];
                }
            }
            [obj endEditing:YES];
            *stop = YES;
        }
    }];
    [_signKeyWindow endEditing:YES];
    
    if (self.bounds.size.width == 0) {
        self.frame = CGRectMake(0, 0, _signKeyWindow.bounds.size.width, _signKeyWindow.bounds.size.height);
    }
    
    //背景色改变动画
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
    }];
    
    //背景
    UIButton *tBackView = [UIButton new];
    tBackView.backgroundColor = [UIColor whiteColor];
    tBackView.layer.cornerRadius = 5;
    tBackView.layer.masksToBounds = YES;
    tBackView.tag = 500;
    [self addSubview:tBackView];
    [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(50));
        make.right.equalTo(@(-50));
        make.centerY.equalTo(self);
    }];
    
    //左上角橘色图标
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, 60, 40);
    shape.fillColor = RGB(255, 150, 131).CGColor;
    [tBackView.layer addSublayer:shape];
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(40, 0)];
    [path addLineToPoint:CGPointMake(0, 30)];
    [path closePath];
    shape.path = path.CGPath;
    
    if (theCBtn == nil && theOBtn)
    {
        theCBtn = [theOBtn copy];
        theOBtn = nil;
    }
    
    if (theCBtn) {
        //取消按钮
        UIButton *tCButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [tCButton setTitle:theCBtn forState:UIControlStateNormal];
        [tCButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        tCButton.tag = 100;
        [tCButton addTarget:nil action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
        [tBackView addSubview:tCButton];
        [tCButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tBackView);
            make.bottom.equalTo(tBackView);
            make.height.equalTo(@40);
        }];
        
        //横向分割线
        UIView *tLineOne = [UIView new];
        tLineOne.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        [tBackView addSubview:tLineOne];
        [tLineOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@(-40));
            make.height.equalTo(@0.5);
        }];
        
        if (theOBtn) {
            //其他按钮
            UIButton *tOButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [tOButton setTitle:theOBtn forState:UIControlStateNormal];
            [tOButton setTitleColor:RGB(255,153,0) forState:UIControlStateNormal];
            tOButton.tag = 101;
            [tOButton addTarget:nil action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
            [tBackView addSubview:tOButton];
            [tOButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(tCButton.mas_right).with.offset(10);
                make.right.equalTo(tBackView);
                make.bottom.equalTo(tBackView);
                make.height.equalTo(tCButton);
                make.width.equalTo(tCButton);
            }];
            [tCButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(tOButton.mas_left).with.offset(-10);
            }];
            
            //纵向分割线
            UIView *tLineTwo = [UIView new];
            tLineTwo.backgroundColor = tLineOne.backgroundColor;
            [tBackView addSubview:tLineTwo];
            [tLineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(tBackView);
                make.height.equalTo(@40);
                make.bottom.equalTo(@0);
                make.width.equalTo(@0.5);
            }];
            
        }else{
            [tCButton setTitleColor:RGB(255,153,0) forState:UIControlStateNormal];
            [tCButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(tBackView);
            }];
        }
    }
    
    //标题
    UILabel *tTLabel = [UILabel new];
    tTLabel.textAlignment = NSTextAlignmentCenter;
    tTLabel.textColor = [UIColor darkGrayColor];
    tTLabel.font = [UIFont systemFontOfSize:[UIScreen mainScreen].bounds.size.width == 320 ? 17 : 20];
    tTLabel.text = theTitle;
    tTLabel.adjustsFontSizeToFitWidth = YES;
    tTLabel. numberOfLines = 1;
    [tBackView addSubview:tTLabel];
    [tTLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@50);
        make.right.equalTo(@(-50));
        make.top.equalTo(@0);
        make.height.equalTo(@40);
    }];
    
    //内容
    if (!selectBlock && type != CGAlertViewType_feixiang) {
        //普通提示框
        UILabel *tMesLabel = [UILabel new];
        tMesLabel.textColor = tTLabel.textColor;
        tMesLabel.textAlignment = NSTextAlignmentCenter;
        tMesLabel.font = [UIFont systemFontOfSize:17];
        tMesLabel.text = theMsg;
        tMesLabel.numberOfLines = 0;
//        tMesLabel.bounces = NO;
//        tMesLabel.editable = NO;
        [tBackView addSubview:tMesLabel];
        
        UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 146, 0)];
        signLabel.font = tMesLabel.font;
        signLabel.text = theMsg;
        signLabel.numberOfLines = 0;
        [signLabel sizeToFit];
        
        CGFloat labelH = signLabel.bounds.size.height;
        if (signLabel.bounds.size.height < 60)
        {
            labelH = 60;
        }
        else if (signLabel.bounds.size.height > 310)
        {
            labelH = 310;
        }
        
        [tMesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.right.equalTo(@(-20));
            make.top.equalTo(@40);
            make.height.equalTo(@(labelH));
        }];
//        [tMesLabel setContentOffset:CGPointMake(0, 10)];
        
        if (autoDismiss) {
            [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(labelH + 52));
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTODISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissSelf:^{
                    if (theBlock) {
                        theBlock(self, 0);
                    }
                }];
            });
        }else{
            [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(labelH + 82));
            }];
        }
    }else if (type == CGAlertViewType_gouxuan){
        //勾选框（不再提示）
        UILabel *tMesLabel = [UILabel new];
        tMesLabel.textColor = tTLabel.textColor;
        tMesLabel.font = [UIFont systemFontOfSize:17];
        tMesLabel.text = theMsg;
        [tBackView addSubview:tMesLabel];
        [tMesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@40);
            make.right.equalTo(@(-10));
            make.top.equalTo(@40);
            make.height.equalTo(@30);
        }];
        
        SelectLeftBtn *tSelButton = [SelectLeftBtn new];
        [tSelButton setTitle:@" 不再提示" forState:UIControlStateNormal];
        [tSelButton setImage:[UIImage imageNamed:@"alect_notselected"] forState:UIControlStateNormal];
        [tSelButton setImage:[UIImage imageNamed:@"alect_selected"] forState:UIControlStateSelected];
        [tSelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        tSelButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        tSelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [tSelButton addTarget:self action:@selector(pressCheckBox:) forControlEvents:UIControlEventTouchUpInside];
        [tBackView addSubview:tSelButton];
        
        [tSelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@40);
            make.top.equalTo(@75);
            make.right.equalTo(@(-15));
            make.height.equalTo(@20);
        }];
        
        [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@150);
        }];
        
    }else if (type == CGAlertViewType_xuanzeqi){
        //选择器（短信方式选择）
        
        UIButton *tSysButton = [self makeSysButton:200];
        [tSysButton setTitle:@"系统短信" forState:UIControlStateNormal];
        [tSysButton setImage:[UIImage imageNamed:@"systemmessageselected"] forState:UIControlStateNormal];
        [tSysButton setImage:[UIImage imageNamed:@"systemmessagenotselected"] forState:UIControlStateSelected];
        tSysButton.selected = YES;
        tSysButton.backgroundColor = RGB(255,153,0);
        [tBackView addSubview:tSysButton];
        [tSysButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.top.equalTo(@55);
            make.height.equalTo([UIScreen mainScreen].bounds.size.width == 320 ? @30 : @35);
        }];
        
        UIButton *tZiyouButton = [self makeSysButton:201];
        [tZiyouButton setTitle:@"自有短信" forState:UIControlStateNormal];
        [tZiyouButton setImage:[UIImage imageNamed:@"ownmessageselected"] forState:UIControlStateNormal];
        [tZiyouButton setImage:[UIImage imageNamed:@"ownmessagenotselected"] forState:UIControlStateSelected];
        [tBackView addSubview:tZiyouButton];
        [tZiyouButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tSysButton.mas_right).with.offset(25);
            make.top.equalTo(tSysButton);
            make.height.equalTo(tSysButton);
            make.width.equalTo(tSysButton);
            make.right.equalTo(@(-20));
        }];
        
        [tSysButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(tZiyouButton.mas_left).with.offset(-25);
        }];
        
        [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo([UIScreen mainScreen].bounds.size.width == 320 ? @145 : @155);
        }];
        _signButton = tSysButton;
    }else if (type == CGAlertViewType_feixiang)
    {
        [tBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15));
            make.right.equalTo(@(-15));
            make.centerY.equalTo(self);
        }];
        
        NSInteger btnCount = 4;
        
        CGFloat buttonW = (([UIScreen mainScreen].bounds.size.width - 30) - 30 * btnCount) / btnCount;
        for (int i = 0; i < btnCount; i ++)
        {
            CGRect frame = CGRectMake(15 + i * (30 + buttonW), 60, buttonW, buttonW);
            
            [tBackView addSubview:[self makeButtonWithType:i frame:frame]];
        }
        
        [tBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(60 + buttonW + 20 + 60));
        }];
        
        UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 30) / 2 - 25, 60 + buttonW + 20 + 5, 50, 50)];
        cancelBut.tag = 300;
        [cancelBut setImage:[UIImage imageNamed:@"share_cancel"] forState:UIControlStateNormal];
        [cancelBut addTarget:self action:@selector(pressShareButton:) forControlEvents:UIControlEventTouchUpInside];
        [tBackView addSubview:cancelBut];
    }
    
    self.windowLevel = UIWindowLevelAlert;
    [self makeKeyAndVisible];
    
    tBackView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tBackView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             tBackView.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             
                         }];
    });
}

- (UIButton *)makeSysButton:(NSInteger)tag
{
    UIButton *button = [UIButton new];
    button.layer.cornerRadius = 6;
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = RGB(255,153,0).CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button setTitleColor:RGB(255,153,0) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:[UIScreen mainScreen].bounds.size.width == 320 ? 14 : 17];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.tag = tag;
    [button addTarget:self action:@selector(pressSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)makeButtonWithType:(NSInteger)type frame:(CGRect)frame
{
    UIButton *chengzhang = [[UIButton alloc] initWithFrame:frame];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(- 20, chengzhang.bounds.size.height, chengzhang.bounds.size.width + 40, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    [chengzhang addSubview:label];
    
    switch (type) {
        case 0:
            //拍摄
            [chengzhang setImage:[UIImage imageNamed:@"v3_contact_classiconrounded"] forState:UIControlStateNormal];
            chengzhang.tag = 301;
            label.text = @"班级";
            break;
        case 1:
            //发图片
            [chengzhang setImage:[UIImage imageNamed:@"v3_newContact_mygoodfriend"] forState:UIControlStateNormal];
            chengzhang.tag = 302;
            chengzhang.imageView.layer.cornerRadius = 3;
            chengzhang.imageView.layer.masksToBounds = YES;
            label.text = @"我的好友";
            break;
        case 2:
            //发成长足迹
            [chengzhang setImage:[UIImage imageNamed:@"share_growingfootprint"] forState:UIControlStateNormal];
            chengzhang.tag = 303;
            label.text = @"成长足迹";
            break;
        case 3:
            //更多
            [chengzhang setImage:[UIImage imageNamed:@"growthup_more"] forState:UIControlStateNormal];
            chengzhang.tag = 304;
            label.text = @"更多";
            break;
            
        default:
            break;
    }
    [chengzhang addTarget:self action:@selector(pressShareButton:) forControlEvents:UIControlEventTouchUpInside];
    return chengzhang;
}

#pragma mark -
#pragma mark - Other
/**
 消失
 */
- (void)hideAlertView
{
    [self dismissSelf];
}

- (void)dismissSelf
{
    [self dismissSelf:nil];
}

- (void)dismissSelf:(void (^)())block
{
    self.backgroundColor = [UIColor clearColor];
    [self viewWithTag:500].transform = CGAffineTransformMakeScale(0.001, 0.001);
    //移除控件
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [self resignKeyWindow];
    self.windowLevel = UIWindowLevelNormal - 100;
    [_signKeyWindow makeKeyAndVisible];
    
    if (block)
    {
        block();
    }
}

- (void)pressAlertButton:(UIButton *)button
{
    if (![button isKindOfClass:[UIButton class]]) {
        return;
    }
    self.backgroundColor = [UIColor clearColor];
    [self viewWithTag:500].transform = CGAffineTransformMakeScale(0.00001, 0.00001);

    //移除控件
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.windowLevel = UIWindowLevelNormal - 100;
    [self resignKeyWindow];
    [_signKeyWindow makeKeyAndVisible];
    
    CGAlertActionBlock action = [_actionBlock copy];
    CGSelectAlertActionBlock selcet = [_selectBlock copy];
    _actionBlock = nil;
    _selectBlock = nil;
    
    if (action) {
        action(self, button.tag - 100);
    }else if (selcet) {
        selcet(self, button.tag - 100, _selectIndex);
    }
}

- (void)pressCheckBox:(UIButton *)button
{
    button.selected = !button.isSelected;
    _selectIndex = button.isSelected ? 1 : 0;
}

- (void)pressSelectButton:(UIButton *)button
{
    _signButton.selected = NO;
    _signButton.backgroundColor = [UIColor whiteColor];
    button.backgroundColor = RGB(255,153,0);
    button.selected = YES;
    _signButton = button;
    _selectIndex = _signButton.tag - 200;
}

- (void)pressShareButton:(UIButton *)sender {
    
    self.backgroundColor = [UIColor clearColor];
    [self viewWithTag:500].transform = CGAffineTransformMakeScale(0.0, 0.0);
    
    //移除控件
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.windowLevel = UIWindowLevelNormal - 100;
    [self resignKeyWindow];
    [_signKeyWindow makeKeyAndVisible];
    
    CGAlertActionBlock action = [_actionBlock copy];
    _actionBlock = nil;
    
    if (action) {
        action(self, sender.tag - 300);
    }
}


@end


