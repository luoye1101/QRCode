//
//  CGAlertView.h
//  CenturyGuard
//
//  Created by 黄国刚 on 16/3/14.
//  Copyright © 2016年 sjyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CGAlertView;
/**
 *  分享选择类型
 */
typedef NS_ENUM(NSInteger, CGAlertViewSelectType) {
    /**
     *  班级
     */
    CGAlertViewSelectType_class = 1,
    /**
     *  好友
     */
    CGAlertViewSelectType_friends,
    /**
     *  成长足迹
     */
    CGAlertViewSelectType_growup,
    /**
     *  更多
     */
    CGAlertViewSelectType_more,
};

typedef void (^CGAlertActionBlock)(CGAlertView *alertView, NSInteger buttonIndex);
typedef void (^CGSelectAlertActionBlock)(CGAlertView *alertView, NSInteger buttonIndex, NSInteger selectIndex);
typedef void (^CGSelectAlertShareActionBlock)(CGAlertView *alertView, CGAlertViewSelectType selectType);

@interface CGAlertView : UIWindow
{
    CGAlertActionBlock _actionBlock; 
    CGSelectAlertActionBlock _selectBlock;
}

+ (instancetype)shareInstance;

//自动消失
- (void)showMessage:(NSString *)theMsg;

- (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(CGAlertActionBlock)theBlock;

//非自动消失
- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn;

- (void)showMessage:(NSString *)theMsg withHanderBlock:(CGAlertActionBlock)theBlock;

- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withHanderBlock:(CGAlertActionBlock)theBlock;

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGAlertActionBlock)theBlock;
/**
 * 勾选框(不再提示)
 */
- (void)showCheckBoxTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGSelectAlertActionBlock)theBlock;
/**
 * 选择器(选择短信类型)
 */
- (void)showSelectWithTitle:(NSString *)theTitle withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(CGSelectAlertActionBlock)theBlock;

/**
 *  分享选择器
 *
 *  @param theBlock CGAlertViewSelectType
 */
- (void)showShareViewWithHanderBlock:(CGSelectAlertShareActionBlock)theBlock;


/**
 消失
 */
- (void)hideAlertView;

@end
