



//
//  KTDropMenu.h
//
//  Created by xingbin
//  Copyright (c) 2015年 ktplay. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface KTDropMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic) id tag;
@property (readwrite, nonatomic) BOOL selected;
@property (readwrite, nonatomic) BOOL enabled;

@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                     tag:(id)tag;

@end

typedef enum{
    KTDropMenuStyle_Normal,
    KTDropMenuStyle_Select
}KTDropMenuStyle;

@protocol KTDropMenuDelegate <NSObject>
-(void)ktDropMenuStyle:(KTDropMenuStyle)style ItemSelected:(KTDropMenuItem *)item index:(NSInteger)index;
@end
@interface KTDropMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
               delegate:(id<KTDropMenuDelegate>)delegate
                  style:(KTDropMenuStyle)style
              menuItems:(NSArray *)menuItems;

+ (void) showMenuInView:(UIView *)view
               fromView:(UIView *)fromView
               delegate:(id<KTDropMenuDelegate>)delegate
                  style:(KTDropMenuStyle)style
              menuItems:(NSArray *)menuItems;

+ (void) dismissMenu;

+ (UIColor *) selectedColor;
+ (void) setSelectedColor: (UIColor *) selectedColor;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

+ (UIColor *) splitLineColor;
+ (void)setSplitLineColor:(UIColor *)splitLineColor;

+ (NSInteger) maxDisplayCount;
+ (void)setMaxDisplayCount:(NSInteger)maxDisplayCount;

+ (CGFloat) margin;
+ (void)setMargin:(CGFloat)margin;

+ (CGFloat) arrowSize;
+ (void)setArrowSize:(CGFloat)arrowSize;

+ (CGFloat) cornerRadius;
+ (void) setCornerRadius:(CGFloat)cornerRadius;

@end
