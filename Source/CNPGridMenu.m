//
//  CNPGridMenu.m
//  CNPGridMenu
//
//  Created by Carson Perrotti on 2014-10-18.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import "CNPGridMenu.h"
#import <objc/runtime.h>
#import <float.h>
#import <Accelerate/Accelerate.h>

#define CNP_IS_IOS8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@protocol CNPGridMenuButtonDelegate <NSObject>

- (void)didTapOnGridMenuItem:(CNPGridMenuItem *)item;

@end

@interface UIImage (CNPGridMenu)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;

@end

@interface CNPGridMenuFlowLayout : UICollectionViewFlowLayout

@end

@interface CNPGridMenuCell : UICollectionViewCell

@property (nonatomic, strong) CNPGridMenuItem *menuItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *vibrancyView;
@property (nonatomic, assign) CNPBlurEffectStyle blurEffectStyle;

@property (nonatomic, weak) id <CNPGridMenuButtonDelegate> delegate;

@end

@interface CNPGridMenuItem ()

@end

@interface CNPGridMenu () <CNPGridMenuButtonDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) CNPGridMenuFlowLayout *flowLayout;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;

@end

@implementation CNPGridMenu

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.flowLayout = [[CNPGridMenuFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:self.flowLayout];
    if (self) {
      _blurEffectStyle = CNPBlurEffectStyleDark;
      _buttons = [NSMutableArray new];
    }
    return self;
  }
  return self;
}

- (instancetype)initWithMenuItems:(NSArray *)items {
  self = [self init];
  if (self) {
    _menuItems = items;
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delaysContentTouches = NO;
    [self.collectionView registerClass:[CNPGridMenuCell class] forCellWithReuseIdentifier:@"GridMenuCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (CNP_IS_IOS8) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:(UIBlurEffectStyle)self.blurEffectStyle];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.collectionView.backgroundView = self.blurView;
    }
    else {
        UIImageView *backgroundBlurImage = ((UIImageView *)self.collectionView.backgroundView);
        switch (self.blurEffectStyle) {
            case CNPBlurEffectStyleDark:
                backgroundBlurImage.image = [backgroundBlurImage.image applyDarkEffect];
                break;
            case CNPBlurEffectStyleExtraLight:
                backgroundBlurImage.image = [backgroundBlurImage.image applyExtraLightEffect];
                break;
            case CNPBlurEffectStyleLight:
                backgroundBlurImage.image = [backgroundBlurImage.image applyLightEffect];
                break;
            default:
                break;
        }
    }
    
    self.backgroundTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnBackgroundView:)];
    self.backgroundTapGestureRecognizer.numberOfTapsRequired = 1;
    self.collectionView.backgroundView.userInteractionEnabled = YES;
    [self.collectionView.backgroundView addGestureRecognizer:self.backgroundTapGestureRecognizer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.blurEffectStyle == CNPBlurEffectStyleDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setMenuItems:(NSArray *)menuItems
{
  _menuItems = menuItems;
  [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate & DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CNPGridMenuCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridMenuCell" forIndexPath:indexPath];
    CNPGridMenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.blurEffectStyle = self.blurEffectStyle;
    cell.menuItem = item;
    [cell.menuItem addObserver:cell forKeyPath:@"disabled" options:NSKeyValueObservingOptionNew context:NULL];
    cell.iconView.image = [item.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.titleLabel.text = item.title;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
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
    if (CNP_IS_IOS8) {
        UIVisualEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyle)self.blurEffectStyle]];
        self.vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    }
    else {
        self.vibrancyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    [self.contentView addSubview:self.vibrancyView];
    
    self.circleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.circleButton setBackgroundColor:[UIColor clearColor]];
    self.circleButton.layer.borderColor = self.blurEffectStyle == CNPBlurEffectStyleDark?[UIColor whiteColor].CGColor:[UIColor darkGrayColor].CGColor;
    [self.circleButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.circleButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleButton addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    if (CNP_IS_IOS8) {
        [((UIVisualEffectView *)self.vibrancyView).contentView addSubview:self.circleButton];
    }
    else {
        [self.vibrancyView addSubview:self.circleButton];
    }
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconView.tintColor = self.blurEffectStyle == CNPBlurEffectStyleDark?[UIColor whiteColor]:[UIColor darkGrayColor];
    [self.iconView setContentMode:UIViewContentModeScaleAspectFit];
    if (CNP_IS_IOS8) {
        [((UIVisualEffectView *)self.vibrancyView).contentView addSubview:self.iconView];
    }
    else {
        [self.vibrancyView addSubview:self.iconView];
    }
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setTextColor:self.blurEffectStyle == CNPBlurEffectStyleDark?[UIColor whiteColor]:[UIColor darkGrayColor]];
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if (CNP_IS_IOS8) {
        [((UIVisualEffectView *)self.vibrancyView).contentView addSubview:self.titleLabel];
    }
    else {
        [self.vibrancyView addSubview:self.titleLabel];
    }
}

- (void)setBlurEffectStyle:(CNPBlurEffectStyle)blurEffectStyle {
    _blurEffectStyle = blurEffectStyle;
    if (self.vibrancyView == nil) {
        [self setupCell];
    }
}

- (void)setMenuItem:(CNPGridMenuItem *)menuItem{
    _menuItem = menuItem;
    [self applyConditionalStyle:menuItem.disabled];
}

- (void)applyConditionalStyle:(BOOL)disabled{
    
    if (disabled) {
        //Apply disabled apperance
        self.circleButton.layer.borderWidth = 0.1f;
        self.iconView.alpha = 0.3f;
        self.titleLabel.alpha = 0.3f;
        self.circleButton.enabled = false;
    }
    else{
        self.circleButton.layer.borderWidth = 1.0f;
        self.iconView.alpha = 1.0f;
        self.titleLabel.alpha = 1.0f;
        self.circleButton.enabled = true;
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
    if (self.blurEffectStyle == CNPBlurEffectStyleDark) {
        self.iconView.tintColor = [UIColor blackColor];
        button.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.iconView.tintColor = [UIColor whiteColor];
        button.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)buttonTouchUpInside:(UIButton *)button {

    if (self.blurEffectStyle == CNPBlurEffectStyleDark) {
        self.iconView.tintColor = [UIColor whiteColor];
        button.backgroundColor = [UIColor clearColor];
    }
    else {
        self.iconView.tintColor = [UIColor darkGrayColor];
        button.backgroundColor = [UIColor clearColor];
    }
    if ([self.delegate respondsToSelector:@selector(didTapOnGridMenuItem:)]) {
        [self.delegate didTapOnGridMenuItem:self.menuItem];
    }
    if (self.menuItem.selectionHandler) {
        self.menuItem.selectionHandler(self.menuItem);
    }
}

- (void)buttonTouchUpOutside:(UIButton *)button {
    if (self.blurEffectStyle == CNPBlurEffectStyleDark) {
        self.iconView.tintColor = [UIColor whiteColor];
        button.backgroundColor = [UIColor clearColor];
    }
    else {
        self.iconView.tintColor = [UIColor darkGrayColor];
        button.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"disabled"]) {
        [self applyConditionalStyle:[[change objectForKey:NSKeyValueChangeNewKey] boolValue]];
    }
}

#pragma mark - Life Cycle
- (void)dealloc{
    [self.menuItem removeObserver:self forKeyPath:@"disabled"];
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
    [menu setModalPresentationStyle:CNP_IS_IOS8?UIModalPresentationOverCurrentContext:UIModalPresentationCurrentContext];
    [menu setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    menu.modalPresentationCapturesStatusBarAppearance = YES;
    
    if (CNP_IS_IOS8 == NO) {
        CGRect windowBounds = self.view.window.bounds;
        UIGraphicsBeginImageContextWithOptions(windowBounds.size, YES, 0.0);
        [self.view.window drawViewHierarchyInRect:windowBounds afterScreenUpdates:NO];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        menu.collectionView.backgroundView = [[UIImageView alloc] initWithImage:snapshot];
    }
    
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

@implementation UIImage (CNPGridMenu)

- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // check pre-conditions
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        BOOL resultImageAtInputBuffer = YES;
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            for (int i = 0; i+1 < 3; i+=2) {
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            }
            if (3 % 2) {
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
                resultImageAtInputBuffer = NO;
            }
        }
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur ^ resultImageAtInputBuffer) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!resultImageAtInputBuffer)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (resultImageAtInputBuffer)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // set up output context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // draw base image
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // draw effect image
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // add in color tint
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // output image is ready
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
