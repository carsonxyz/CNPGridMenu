//
//  CNPGridMenu.m
//  CNPGridMenu
//
//  Created by Carson Perrotti on 2014-10-18.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import "CNPGridMenu.h"
#import <objc/runtime.h>

#define CNP_IS_IOS8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@protocol CNPGridMenuButtonDelegate <NSObject>

- (void)didTapOnGridMenuItem:(CNPGridMenuItem *)item;

@end

@interface CNPGridMenuFlowLayout : UICollectionViewFlowLayout

@end

@interface CNPGridMenuCell : UICollectionViewCell

@property (nonatomic, strong) CNPGridMenuItem *menuItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyView;
@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle;

@property (nonatomic, weak) id <CNPGridMenuButtonDelegate> delegate;

@end

@interface CNPGridMenuItem ()

@end

@interface CNPGridMenu () <CNPGridMenuButtonDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) CNPGridMenuFlowLayout *flowLayout;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;

@end

@implementation CNPGridMenu

- (instancetype)initWithMenuItems:(NSArray *)items {
    self.flowLayout = [[CNPGridMenuFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:self.flowLayout];
    if (self) {
        _blurEffectStyle = UIBlurEffectStyleDark;
        _buttons = [NSMutableArray new];
        _menuItems = items;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delaysContentTouches = NO;
    [self.collectionView registerClass:[CNPGridMenuCell class] forCellWithReuseIdentifier:@"GridMenuCell"];
    
    self.backgroundTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnBackgroundView:)];
    self.backgroundTapGestureRecognizer.numberOfTapsRequired = 1;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.view.bounds;
    [self.blurView addGestureRecognizer:self.backgroundTapGestureRecognizer];
    self.collectionView.backgroundView = self.blurView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.blurEffectStyle == UIBlurEffectStyleDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - UICollectionView Delegate & DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CNPGridMenuCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridMenuCell" forIndexPath:indexPath];
    CNPGridMenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.blurEffectStyle = self.blurEffectStyle;
    cell.menuItem = item;
    cell.iconView.image = item.icon;
    cell.titleLabel.text = item.title;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuItems.count;
}

#pragma mark - UITapGestureRecognizer Delegate 

-(void) didTapOnBackgroundView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gridMenuDidTapOnBackground:)]) {
        [self.delegate gridMenuDidTapOnBackground:self];
    }
}

#pragma mark - CNPGridMenuItem Delegate

- (void)didTapOnGridMenuItem:(CNPGridMenuItem *)item {
    if ([self.delegate respondsToSelector:@selector(gridMenu:didTapOnItem:)]) {
        [self.delegate gridMenu:self didTapOnItem:item];
    }
}

@end

@implementation CNPGridMenuItem

@end

@implementation CNPGridMenuCell

- (void)setupCell {
    UIVisualEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:self.blurEffectStyle]];
    self.vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [self.contentView addSubview:self.vibrancyView];
    
    self.circleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.circleButton setBackgroundColor:[UIColor clearColor]];
    self.circleButton.layer.borderWidth = 1.0f;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.circleButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleButton addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.vibrancyView.contentView addSubview:self.circleButton];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconView.tintColor = [UIColor whiteColor];
    [self.iconView setContentMode:UIViewContentModeScaleAspectFit];
    [self.vibrancyView.contentView addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.vibrancyView.contentView addSubview:self.titleLabel];
}

- (void)setBlurEffectStyle:(UIBlurEffectStyle)blurEffectStyle {
    _blurEffectStyle = blurEffectStyle;
    if (self.vibrancyView == nil) {
        [self setupCell];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.vibrancyView.frame = self.contentView.bounds;
    [self.circleButton setFrame:CGRectMake(10, 0, self.contentView.bounds.size.width-20, self.contentView.bounds.size.width-20)];
    [self.circleButton.layer setCornerRadius:self.circleButton.bounds.size.width/2];
    [self.iconView setFrame:CGRectMake(0, 0, 40, 40)];
    self.iconView.center = self.circleButton.center;
    [self.titleLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.circleButton.bounds), self.contentView.bounds.size.width, self.contentView.bounds.size.height - CGRectGetMaxY(self.circleButton.bounds))];
}

- (void)buttonTouchDown:(UIButton *)button {
    self.iconView.tintColor = [UIColor blackColor];
    button.backgroundColor = [UIColor whiteColor];
}

- (void)buttonTouchUpInside:(UIButton *)button {
    self.iconView.tintColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor clearColor];
    if ([self.delegate respondsToSelector:@selector(didTapOnGridMenuItem:)]) {
        [self.delegate didTapOnGridMenuItem:self.menuItem];
    }
    if (self.menuItem.selectionHandler) {
        self.menuItem.selectionHandler(self.menuItem);
    }
}

- (void)buttonTouchUpOutside:(UIButton *)button {
    self.iconView.tintColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor clearColor];
}

@end

#pragma mark - CNPGridMenuFlowLayout 

@implementation CNPGridMenuFlowLayout

- (id)init
{
    if (self = [super init])
    {
        self.itemSize = CGSizeMake(90, 110);
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    
    UICollectionViewLayoutAttributes* att = [array lastObject];
    if (att){
        CGFloat lastY = att.frame.origin.y + att.frame.size.height;
        CGFloat diff = self.collectionView.frame.size.height - lastY;
        
        if (diff > 0){
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(diff/2, 0.0, 0.0, 0.0);
            self.collectionView.contentInset = contentInsets;
        }
    }
    return array;
}

@end

#pragma mark - CNPGridMenu Categories

@implementation UIViewController (CNPGridMenu)

@dynamic gridMenu;

- (void)presentGridMenu:(CNPGridMenu *)menu animated:(BOOL)flag completion:(void (^)(void))completion {
    [menu setModalPresentationStyle:UIModalPresentationCustom];
    [menu setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    menu.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:menu animated:flag completion:completion];
}

- (void)dismissGridMenuAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissViewControllerAnimated:flag completion:completion];
}

- (void)setGridMenu:(CNPGridMenu *)gridMenu {
    objc_setAssociatedObject(self, @selector(gridMenu), gridMenu, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CNPGridMenu *)gridMenu {
    return objc_getAssociatedObject(self, @selector(gridMenu));
}

@end
