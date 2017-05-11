//
//  XZAlertView.h
//  XZAlertView
//
//  Created by 夏州 on 15-3-24.
//  Copyright (c) 2015年 夏州. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XZAlertViewStyle)
{
    XZAlertViewStyleDefault = 0,
    XZAlertViewStyleSecureTextInput,
    XZAlertViewStylePlainTextInput,
    XZAlertViewStyleLoginAndPasswordInput
};

typedef void (^AlertActionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@interface XZAlertView : NSObject <UIAlertViewDelegate>
{
    AlertActionBlock actionBlock;
}

@property (nonatomic, assign) XZAlertViewStyle alertViewStyle;

@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, assign) BOOL messageAligmentLeft;

+ (instancetype)shareInstance;

//移除所有alertview
- (void)removeAllObject;

//自动消失
- (void)showMessage:(NSString *)theMsg;

- (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(AlertActionBlock)theBlock;

//非自动消失
- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn;

- (void)showMessage:(NSString *)theMsg withHanderBlock:(AlertActionBlock)theBlock;

- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withHanderBlock:(AlertActionBlock)theBlock;

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(AlertActionBlock)theBlock;

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withMessageAlignmentLeft:(BOOL)messageAlignmentLeft withHanderBlock:(AlertActionBlock)theBlock;

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(AlertActionBlock)theBlock withIsAutoDismiss:(BOOL)autoDismiss withMessageAlignmentLeft:(BOOL)messageAlignmentLeft;
@end
