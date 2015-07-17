

//
//  KTDropMenu.m
//
//  Created by xingbin
//  Copyright (c) 2015年 ktplay. All rights reserved.
//


#import "KTDropMenu.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface KTDropMenuView : UIView
@property(nonatomic,weak) id<KTDropMenuDelegate> delegate;
- (void)dismissMenu:(BOOL) animated;
@end

@interface KTDropMenuOverlay : UIView
@end

@implementation KTDropMenuOverlay

// - (void) dealloc { NSLog(@"dealloc %@", self); }

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIView *touched = [[touches anyObject] view];
    if (touched == self) {
        
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[KTDropMenuView class]]) {
                [(KTDropMenuView *)v dismissMenu:YES];
            }
        }
    }
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation KTDropMenuItem

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                      tag:(id)tag{
    return [[KTDropMenuItem alloc] init:title
                                  image:image tag:tag];
}

- (id) init:(NSString *) title
      image:(UIImage *) image
        tag:(id)tag{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _tag = tag;
    }
    return self;
}

- (BOOL) enabled{
    return !self.isSelected;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef enum {
    
    KTDropMenuViewArrowDirectionNone,
    KTDropMenuViewArrowDirectionUp,
    KTDropMenuViewArrowDirectionDown,
    KTDropMenuViewArrowDirectionLeft,
    KTDropMenuViewArrowDirectionRight,
    
} KTDropMenuViewArrowDirection;

@implementation KTDropMenuView {
    
    KTDropMenuViewArrowDirection    _arrowDirection;
    CGFloat                     _arrowPosition;
    UIView                      *_contentView;
    NSArray                     *_menuItems;
    NSInteger                    _displayMaxCount;
}

- (id)init{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        _displayMaxCount = [KTDropMenu maxDisplayCount];
    }
    
    return self;
}

// - (void) dealloc { NSLog(@"dealloc %@", self); }

- (void) setupFrameInView:(UIView *)view
                 fromRect:(CGRect)fromRect{
    const CGSize contentSize = _contentView.frame.size;
    
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat outerHeight = view.bounds.size.height;
    
    const CGFloat rectX0 = fromRect.origin.x;
    const CGFloat rectX1 = fromRect.origin.x + fromRect.size.width;
    const CGFloat rectXM = fromRect.origin.x + fromRect.size.width * 0.5f;
    const CGFloat rectY0 = fromRect.origin.y;
    const CGFloat rectY1 = fromRect.origin.y + fromRect.size.height;
    const CGFloat rectYM = fromRect.origin.y + fromRect.size.height * 0.5f;;
    
    const CGFloat widthPlusArrow = contentSize.width + [KTDropMenu arrowSize];
    const CGFloat heightPlusArrow = contentSize.height + [KTDropMenu arrowSize];
    const CGFloat widthHalf = contentSize.width * 0.5f;
    const CGFloat heightHalf = contentSize.height * 0.5f;
    
    CGFloat kMargin = [KTDropMenu margin];
    
    if (heightPlusArrow < (outerHeight - rectY1)) {
        
        _arrowDirection = KTDropMenuViewArrowDirectionUp;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY1
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        //_arrowPosition = MAX(16, MIN(_arrowPosition, contentSize.width - 16));
        _contentView.frame = (CGRect){0, [KTDropMenu arrowSize], contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + [KTDropMenu arrowSize]
        };
        
    } else if (heightPlusArrow < rectY0) {
        
        _arrowDirection = KTDropMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - heightPlusArrow
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + [KTDropMenu arrowSize]
        };
        
    } else if (widthPlusArrow < (outerWidth - rectX1)) {
        
        _arrowDirection = KTDropMenuViewArrowDirectionLeft;
        CGPoint point = (CGPoint){
            rectX1,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){[KTDropMenu arrowSize], 0, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width + [KTDropMenu arrowSize],
            contentSize.height
        };
        
    } else if (widthPlusArrow < rectX0) {
        
        _arrowDirection = KTDropMenuViewArrowDirectionRight;
        CGPoint point = (CGPoint){
            rectX0 - widthPlusArrow,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + 5) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width  + [KTDropMenu arrowSize],
            contentSize.height
        };
        
    } else {
        
        _arrowDirection = KTDropMenuViewArrowDirectionNone;
        
        self.frame = (CGRect) {
            
            (outerWidth - contentSize.width)   * 0.5f,
            (outerHeight - contentSize.height) * 0.5f,
            contentSize,
        };
    }
}

- (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems{
    _menuItems = menuItems;
    
    _contentView = [self mkContentView];
    [self addSubview:_contentView];
    
    [self setupFrameInView:view fromRect:rect];
    
    KTDropMenuOverlay *overlay = [[KTDropMenuOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    
    _contentView.hidden = YES;
    const CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL completed) {
                         _contentView.hidden = NO;
                     }];
    
}

- (void)dismissMenu:(BOOL) animated{
    if (self.superview) {
        
        if (animated) {
            
            _contentView.hidden = YES;
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            
            [UIView animateWithDuration:0.2
                             animations:^(void) {
                                 
                                 self.alpha = 0;
                                 self.frame = toFrame;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 if ([self.superview isKindOfClass:[KTDropMenuOverlay class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
            
        } else {
            
            if ([self.superview isKindOfClass:[KTDropMenuOverlay class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
    }
}

- (void)performAction:(id)sender{
    [self dismissMenu:YES];
    
    UIButton *button = (UIButton *)sender;
    KTDropMenuItem *menuItem = _menuItems[button.tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ktDropMenuItemSelected:index:)]) {
        [self.delegate ktDropMenuItemSelected:menuItem index:button.tag];
    }
}

- (UIView *) mkContentView{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count)
        return nil;
    
    const CGFloat kMinMenuItemHeight = 32.f;
    const CGFloat kMinMenuItemWidth = 32.f;
    CGFloat kMarginX = [KTDropMenu margin] * 2;
    CGFloat kMarginY = [KTDropMenu margin];
    
    UIFont *titleFont = [KTDropMenu titleFont];
    if (!titleFont) titleFont = [UIFont boldSystemFontOfSize:16];
    
    CGFloat maxImageWidth = 0;
    CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    for (KTDropMenuItem *menuItem in _menuItems) {
        
        const CGSize imageSize = menuItem.image.size;
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;
    }
    
    for (KTDropMenuItem *menuItem in _menuItems) {
        
        const CGSize titleSize = [menuItem.title sizeWithFont:titleFont];
        const CGSize imageSize = menuItem.image.size;
        
        const CGFloat itemHeight = MAX(titleSize.height, imageSize.height) + kMarginY * 2;
        const CGFloat itemWidth = (menuItem.image ? maxImageWidth + kMarginX : 0) + titleSize.width + kMarginX * 4;
        
        if (itemHeight > maxItemHeight)
            maxItemHeight = itemHeight;
        
        if (itemWidth > maxItemWidth)
            maxItemWidth = itemWidth;
    }
    
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);
    maxItemWidth  = MIN(maxItemWidth, 200);
    
    const CGFloat titleX = kMarginX * 2 + (maxImageWidth > 0 ? maxImageWidth + kMarginX : 0);
    const CGFloat titleWidth = maxItemWidth - titleX - kMarginX;
    
    UIImage *selectedImage = [KTDropMenuView selectedImage:(CGSize){maxItemWidth, maxItemHeight + 2}];
    UIImage *gradientLine = [KTDropMenuView gradientLine: (CGSize){maxItemWidth - kMarginX * 4, 1}];
    
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    
    CGFloat itemY = kMarginY * 2;
    NSUInteger itemNum = 0;
    
    // int index= 0 ;
    CGFloat maxViewitemY= itemY ;
    
    for (KTDropMenuItem *menuItem in _menuItems) {
        
        const CGRect itemFrame = (CGRect){0, itemY, maxItemWidth, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];
        itemView.opaque = NO;
        
        [contentView addSubview:itemView];
        
        if (menuItem.enabled) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = itemNum;
            button.frame = itemView.bounds;
            button.enabled = menuItem.enabled;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            
            [button addTarget:self
                       action:@selector(performAction:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
            
            [itemView addSubview:button];
        }
        
        if (menuItem.title.length) {
            
            CGRect titleFrame;
            
            if (!menuItem.enabled && !menuItem.image) {
                
                titleFrame = (CGRect){
                    kMarginX * 2,
                    kMarginY,
                    maxItemWidth - kMarginX * 4,
                    maxItemHeight - kMarginY * 2
                };
                
            } else {
                
                titleFrame = (CGRect){
                    titleX,
                    kMarginY,
                    titleWidth,
                    maxItemHeight - kMarginY * 2
                };
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment;
            titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            //titleLabel.backgroundColor = [UIColor greenColor];
            [itemView addSubview:titleLabel];
        }
        
        if (menuItem.image) {
            
            const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
        }
        
        if (itemNum < _menuItems.count - 1) {
            
            UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
            gradientView.frame = (CGRect){kMarginX * 2, maxItemHeight + 1, gradientLine.size};
            gradientView.contentMode = UIViewContentModeLeft;
            [itemView addSubview:gradientView];
            
            itemY += 2;
        }
        
        itemY += maxItemHeight;
        ++itemNum;
        //index++;
        if(itemNum <=_displayMaxCount){
            maxViewitemY = itemY;
        }
        
    }
    
    contentView.frame = (CGRect){0, 0, maxItemWidth, maxViewitemY + kMarginY * 2};
    contentView.contentSize = CGSizeMake(maxItemWidth, itemY + kMarginY * 2);
    
    return contentView;
}

- (CGPoint) arrowPoint{
    CGPoint point;
    
    if (_arrowDirection == KTDropMenuViewArrowDirectionUp) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionDown) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionLeft) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionRight) {
        
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else {
        
        point = self.center;
    }
    
    return point;
}
+ (UIImage *)imageWithColor:(UIColor *)color size: (CGSize) size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *) selectedImage: (CGSize) size{
    
    return   [self imageWithColor:[KTDropMenu selectedColor] size:size];
    //    const CGFloat locations[] = {0,1};
    //    const CGFloat components[] = {
    //        0.216, 0.471, 0.871, 1,
    //        0.059, 0.353, 0.839, 1,
    //    };
    //
    //    return [self gradientImageWithSize:size locations:locations components:components count:2];
}

+ (UIImage *) gradientLine: (CGSize) size{
    
    
    return   [self imageWithColor:[KTDropMenu splitLineColor] size:size];
    
    //    const CGFloat locations[5] = {0,0.2,0.5,0.8,1};
    //
    //    const CGFloat R = 0.44f, G = 0.44f, B = 0.44f;
    //
    //    const CGFloat components[20] = {
    //        R,G,B,0.1,
    //        R,G,B,0.4,
    //        R,G,B,0.7,
    //        R,G,B,0.4,
    //        R,G,B,0.1
    //    };
    //
    // return [self gradientImageWithSize:size locations:locations components:components count:5];
}

+ (UIImage *) gradientImageWithSize:(CGSize) size locations:(const CGFloat []) locations components:(const CGFloat []) components count:(NSUInteger)count{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, colorGradient, (CGPoint){0, 0}, (CGPoint){size.width, 0}, 0);
    CGGradientRelease(colorGradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) drawRect:(CGRect)rect{
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame inContext:(CGContextRef) context{
    CGFloat R0 = 0xe6/255.0, G0 = 0xe4/255.0, B0 =  0xe4/255.0;
    CGFloat R1 = 0xe6/255.0, G1 = 0xe4/255.0, B1 = 0xe4/255.0;
    
    UIColor *tintColor = [KTDropMenu tintColor];
    if (tintColor) {
        
        CGFloat a;
        [tintColor getRed:&R0 green:&G0 blue:&B0 alpha:&a];
    }
    
    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // fix the issue with gap of arrow's base if on the edge
    const CGFloat kEmbedFix = 3.f;
    
    if (_arrowDirection == KTDropMenuViewArrowDirectionUp) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - [KTDropMenu arrowSize];
        const CGFloat arrowX1 = arrowXM + [KTDropMenu arrowSize];
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + [KTDropMenu arrowSize] + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        Y0 += [KTDropMenu arrowSize];
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionDown) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - [KTDropMenu arrowSize];
        const CGFloat arrowX1 = arrowXM + [KTDropMenu arrowSize];
        const CGFloat arrowY0 = Y1 - [KTDropMenu arrowSize] - kEmbedFix;
        const CGFloat arrowY1 = Y1;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY1}];
        
//        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        Y1 -= [KTDropMenu arrowSize];
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionLeft) {
        
        const CGFloat arrowYM = _arrowPosition;
        const CGFloat arrowX0 = X0;
        const CGFloat arrowX1 = X0 + [KTDropMenu arrowSize] + kEmbedFix;
        const CGFloat arrowY0 = arrowYM - [KTDropMenu arrowSize];;
        const CGFloat arrowY1 = arrowYM + [KTDropMenu arrowSize];
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        X0 += [KTDropMenu arrowSize];
        
    } else if (_arrowDirection == KTDropMenuViewArrowDirectionRight) {
        
        const CGFloat arrowYM = _arrowPosition;
        const CGFloat arrowX0 = X1;
        const CGFloat arrowX1 = X1 - [KTDropMenu arrowSize] - kEmbedFix;
        const CGFloat arrowY0 = arrowYM - [KTDropMenu arrowSize];;
        const CGFloat arrowY1 = arrowYM + [KTDropMenu arrowSize];
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
//        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        X1 -= [KTDropMenu arrowSize];
    }
    
    [arrowPath fill];
    
    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:[KTDropMenu cornerRadius]];
    
    const CGFloat locations[] = {0, 1};
    const CGFloat components[] = {
        R0, G0, B0, 1,
        R0, G0, B0, 1,
//        R1, G1, B1, 1,
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 components,
                                                                 locations,
                                                                 sizeof(locations)/sizeof(locations[0]));
    CGColorSpaceRelease(colorSpace);
    
    
    [borderPath addClip];
    
    CGPoint start, end;
    
    if (_arrowDirection == KTDropMenuViewArrowDirectionLeft ||
        _arrowDirection == KTDropMenuViewArrowDirectionRight) {
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X1, Y0};
        
    } else {
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X0, Y1};
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    CGGradientRelease(gradient);
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static KTDropMenu *gMenu;
static UIColor *gSelectedColor;
static UIColor *gTintColor;
static UIFont *gTitleFont;
static UIColor *gSplitLineColor;
static NSInteger gMaxDisplayCount;
static CGFloat gMargin;
static CGFloat gArrowSize;
static CGFloat gCornerRadius;

@implementation KTDropMenu {
    
    KTDropMenuView *_menuView;
    BOOL        _observing;
}

+ (instancetype) sharedMenu{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        gMenu = [[KTDropMenu alloc] init];
    });
    return gMenu;
}

- (id) init{
    NSAssert(!gMenu, @"singleton object");
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc{
    if (_observing) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect delegate:(id<KTDropMenuDelegate>)delegate menuItems:(NSArray *)menuItems{
    NSParameterAssert(view);
    NSParameterAssert(menuItems.count);
    
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }
    
    if (!_observing) {
        
        _observing = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    
    
    _menuView = [[KTDropMenuView alloc] init];
    _menuView.delegate = delegate;
    [_menuView showMenuInView:view fromRect:rect menuItems:menuItems];
}

- (void) dismissMenu{
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }
    
    if (_observing) {
        
        _observing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) orientationWillChange: (NSNotification *) n{
    [self dismissMenu];
}

+ (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect delegate:(id<KTDropMenuDelegate>)delegate menuItems:(NSArray *)menuItems{
    [[self sharedMenu] showMenuInView:view fromRect:rect delegate:delegate menuItems:menuItems];
}

+ (void)showMenuInView:(UIView *)view fromView:(UIView *)fromView delegate:(id<KTDropMenuDelegate>)delegate menuItems:(NSArray *)menuItems{
    CGRect rect = fromView.frame;
    if (![fromView.superview isEqual:view]) {
        rect = [fromView convertRect:fromView.frame fromView:view];
    }
    [self showMenuInView:view fromRect:rect delegate:delegate menuItems:menuItems];
}

+ (void) dismissMenu{
    [[self sharedMenu] dismissMenu];
}

+ (UIColor *) selectedColor{
    if (!gSelectedColor) {
        gSelectedColor = [UIColor whiteColor];
    }
    return gSelectedColor;
}

+ (void) setSelectedColor: (UIColor *) selectedColor{
    if (selectedColor != gSelectedColor) {
        gSelectedColor = selectedColor;
    }
}

+ (UIColor *) tintColor{
    if (!gTintColor) {
        gTintColor = [UIColor whiteColor];
    }
    return gTintColor;
}

+ (void) setTintColor: (UIColor *) tintColor{
    if (tintColor != gTintColor) {
        gTintColor = tintColor;
    }
}

+ (UIFont *) titleFont{
    if (!gTitleFont) {
        gTitleFont = [UIFont systemFontOfSize:15];
    }
    return gTitleFont;
}

+ (void) setTitleFont: (UIFont *) titleFont{
    if (titleFont != gTitleFont) {
        gTitleFont = titleFont;
    }
}

+ (UIColor *) splitLineColor{
    if (!gSplitLineColor) {
        gSplitLineColor = [UIColor lightGrayColor];
    }
    return gSplitLineColor;
}

+ (void)setSplitLineColor:(UIColor *)splitLineColor{
    if (splitLineColor != gSplitLineColor) {
        gSplitLineColor = splitLineColor;
    }
}

+ (NSInteger) maxDisplayCount{
    if (!gMaxDisplayCount) {
        gMaxDisplayCount = 6;
    }
    return gMaxDisplayCount;
}

+ (void)setMaxDisplayCount:(NSInteger)maxDisplayCount{
    if (maxDisplayCount != gMaxDisplayCount) {
        gMaxDisplayCount = maxDisplayCount;
    }
}

+ (CGFloat) margin{
    if (!gMargin) {
        gMargin = 4.f;
    }
    return gMargin;
}

+ (void)setMargin:(CGFloat)margin{
    if (margin != gMargin) {
        gMargin = margin;
    }
}

+ (CGFloat) arrowSize{
    if (!gArrowSize) {
        gArrowSize = 8.f;
    }
    return gArrowSize;
}

+ (void)setArrowSize:(CGFloat)arrowSize{
    if (arrowSize != gArrowSize) {
        gArrowSize = arrowSize;
    }
}

+ (CGFloat) cornerRadius{
    if (!gCornerRadius) {
        gCornerRadius = 2.f;
    }
    return gCornerRadius;
}

+ (void) setCornerRadius:(CGFloat)cornerRadius{
    if (cornerRadius != gCornerRadius) {
        gCornerRadius = cornerRadius;
    }
}

@end
