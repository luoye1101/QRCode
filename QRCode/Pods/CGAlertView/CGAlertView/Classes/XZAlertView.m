//
//  XZAlertView.m
//  XZAlertView
//
//  Created by 夏州 on 15-3-24.
//  Copyright (c) 2015年 夏州. All rights reserved.
//

#import "XZAlertView.h"

@interface XZAlertViewItem : UIAlertView

@property (nonatomic, copy) AlertActionBlock actionBlock;
@property (nonatomic, copy) NSString *name;

@end

@implementation XZAlertViewItem



@end

@interface XZAlertView ()
{
    NSMutableArray *alertViews;
}

@property (nonatomic, strong) XZAlertViewItem *alertView;
@end

@implementation XZAlertView

- (instancetype)init
{
    self = [super self];
    
    if (self)
    {
        alertViews = [[NSMutableArray alloc]init];
    }

    return self;
}

+ (instancetype)shareInstance
{
    static XZAlertView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[XZAlertView alloc]init];
    });
    
    instance.alertViewStyle = XZAlertViewStyleDefault;
    
    return instance;
}

- (void)showMessage:(NSString *)theMsg
{
    [self showTitle:@"提示" withMessage:theMsg withCancelButton:nil withOtherButton:nil withHanderBlock:nil withIsAutoDismiss:YES];
}

- (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(AlertActionBlock)theBlock
{
    [self showTitle:@"提示" withMessage:theMsg withCancelButton:nil withOtherButton:nil withHanderBlock:theBlock withIsAutoDismiss:YES];
}

- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn
{
    [self showTitle:@"提示" withMessage:theMsg withCancelButton:theCBtn withOtherButton:nil withHanderBlock:nil];
}

- (void)showMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withHanderBlock:(AlertActionBlock)theBlock
{
    [self showTitle:@"提示" withMessage:theMsg withCancelButton:theCBtn withOtherButton:nil withHanderBlock:theBlock];
}

- (void)showMessage:(NSString *)theMsg withHanderBlock:(AlertActionBlock)theBlock
{
    [self showTitle:@"提示" withMessage:theMsg withCancelButton:nil withOtherButton:nil withHanderBlock:theBlock];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(AlertActionBlock)theBlock
{
    [self showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withHanderBlock:theBlock withIsAutoDismiss:NO withMessageAlignmentLeft:NO];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(AlertActionBlock)theBlock withIsAutoDismiss:(BOOL)autoDismiss
{
    [self showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withHanderBlock:theBlock withIsAutoDismiss:autoDismiss withMessageAlignmentLeft:NO];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withMessageAlignmentLeft:(BOOL)messageAlignmentLeft withHanderBlock:(AlertActionBlock)theBlock
{
    [self showTitle:theTitle withMessage:theMsg withCancelButton:theCBtn withOtherButton:theOBtn withHanderBlock:theBlock withIsAutoDismiss:NO withMessageAlignmentLeft:messageAlignmentLeft];
}

- (void)showTitle:(NSString *)theTitle withMessage:(NSString *)theMsg withCancelButton:(NSString *)theCBtn withOtherButton:(NSString *)theOBtn withHanderBlock:(AlertActionBlock)theBlock withIsAutoDismiss:(BOOL)autoDismiss withMessageAlignmentLeft:(BOOL)messageAlignmentLeft
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        BOOL hasExsit = NO;
        
        for (XZAlertViewItem *tItem in alertViews)
        {
            if ([tItem.name isEqualToString:theMsg])
            {
                hasExsit = YES;
                break;
            }
        }
        
        if (!hasExsit)
        {
            self.messageAligmentLeft = messageAlignmentLeft;
            
            XZAlertViewItem *tAlertView = [[XZAlertViewItem alloc]initWithTitle:theTitle
                                                                        message:theMsg
                                                                       delegate:self
                                                              cancelButtonTitle:theCBtn
                                                              otherButtonTitles:theOBtn, nil];
            
            tAlertView.alertViewStyle = (UIAlertViewStyle)self.alertViewStyle;
            tAlertView.actionBlock = theBlock;
            tAlertView.name = theMsg;
            
            [alertViews addObject:tAlertView];
            self.alertView = messageAlignmentLeft ? tAlertView : nil; //对应version 版本框
            
            if (messageAlignmentLeft)
            {
                [self resizeMessageAlignmentLeft:tAlertView];
            }
            
            [tAlertView show];
            
            if (autoDismiss)
            {
                [self performSelector:@selector(autoDismissAlertView:) withObject:tAlertView afterDelay:1.5f];
            }
        }
    });
    
}

- (void)autoDismissAlertView:(XZAlertViewItem *)sender
{
    if (sender.actionBlock)
    {
        sender.actionBlock(sender, -1);
    }
    
    [sender dismissWithClickedButtonIndex:0 animated:YES];
    sender.delegate = nil;
    [alertViews removeObject:sender];
}

- (void)removeAllObject
{
    NSArray *tAlertViews = [[NSArray alloc]initWithArray:alertViews];
    
    for (UIAlertView *tAlertView in tAlertViews)
    {
        [tAlertView dismissWithClickedButtonIndex:0 animated:YES];
        tAlertView.delegate = nil;
        
        [alertViews removeObject:tAlertView];
    }
}

- (BOOL)isVisible
{
    return [alertViews count] == 0 ? NO : YES;
}

- (void)resizeMessageAlignmentLeft:(XZAlertViewItem *)theAlertView
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
    {
        NSString *tMessage = theAlertView.message;

        UITextView *tMessageTextView = [[UITextView alloc]init];
        tMessageTextView.backgroundColor = [UIColor clearColor];
        tMessageTextView.font = [UIFont systemFontOfSize:15.0f];
        tMessageTextView.contentInset = UIEdgeInsetsMake(-10.0f, 0, 0, 0);
        tMessageTextView.showsHorizontalScrollIndicator = NO;
        tMessageTextView.pagingEnabled = YES;
        tMessageTextView.editable = NO;
        tMessageTextView.selectable = NO;
        tMessageTextView.text = tMessage;
        [theAlertView setValue:tMessageTextView forKey:@"accessoryView"];
        theAlertView.message = @"";
        
        if ([UIDevice currentDevice].systemVersion.floatValue < 8.0f)
        {
            CGSize size = [tMessage boundingRectWithSize:CGSizeMake(240.0f, 300.0f)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}
                                                 context:nil].size;
            
            CGFloat tContentHeight = size.height > 120.0f ? 120.0f : size.height;
            tMessageTextView.frame = CGRectMake(0, 0, 240.0f, tContentHeight);
        }
    }
    else
    {
        NSInteger tCount = 0;
        
        for(UIView * tView in theAlertView.subviews)
        {
            if([tView isKindOfClass:[UILabel class]])
            {
                tCount ++;
                
                if (tCount == 2)
                {
                    UILabel *tLabel = (UILabel *)tView;
                    tLabel.textAlignment = NSTextAlignmentLeft;
                }
            }
        }
    }
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    XZAlertViewItem *tAlertViewItem = (XZAlertViewItem *)alertView;
    
    if (tAlertViewItem.actionBlock)
    {
        tAlertViewItem.actionBlock(alertView, buttonIndex);
        tAlertViewItem.delegate = nil;
    }
    
    [alertViews removeObject:tAlertViewItem];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (!self.messageAligmentLeft)
    {
        return;
    }
    
    
}

@end
