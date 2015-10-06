//
//  CNPGridMenu.h
//  CNPGridMenu
//
//  Created by Carson Perrotti on 2014-10-18.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CNPBlurEffectStyle) {
    CNPBlurEffectStyleExtraLight,
    CNPBlurEffectStyleLight,
    CNPBlurEffectStyleDark
};

@class CNPGridMenuItem;
@protocol CNPGridMenuDelegate;

typedef void (^SelectionHandler)(CNPGridMenuItem *item);

@interface CNPGridMenu : UICollectionViewController

@property (nonatomic, assign) CNPBlurEffectStyle blurEffectStyle;

@property (nonatomic, weak) id <CNPGridMenuDelegate> delegate;
@property (nonatomic) NSArray *menuItems;

- (instancetype)initWithMenuItems:(NSArray *)items;

@end

@protocol CNPGridMenuDelegate <NSObject>

@optional
- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu;
- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item;

@end

@interface CNPGridMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) NSInteger menuItemTag;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, copy) SelectionHandler selectionHandler;

@end

@interface UIViewController (CNPGridMenu)

@property (nonatomic, strong) CNPGridMenu *gridMenu;

- (void)presentGridMenu:(CNPGridMenu *)menu animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissGridMenuAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end