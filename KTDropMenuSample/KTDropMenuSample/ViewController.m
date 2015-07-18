//
//  ViewController.m
//  KTDropMenuSample
//
//  Created by jayden on 15/7/17.
//  Copyright © 2015年 jayden. All rights reserved.
//

#import "ViewController.h"
#import "KTDropMenu.h"

#define TAGONE @"TAGONE"
#define TAGTWO @"TAGTWO"

@interface ViewController ()<KTDropMenuDelegate>
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) NSMutableArray *menuItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage *img = [UIImage imageNamed:@"latest"];
    KTDropMenuItem *item = [KTDropMenuItem menuItem:@"全部分类" image:img tag:nil];
    item.selected = YES;
    KTDropMenuItem *item1 = [KTDropMenuItem menuItem:@"游戏竞技" image:img tag:nil];
    KTDropMenuItem *item2 = [KTDropMenuItem menuItem:@"喝酒闲聊" image:img tag:nil];
    KTDropMenuItem *item3 = [KTDropMenuItem menuItem:@"休闲娱乐" image:img tag:nil];
    KTDropMenuItem *item4 = [KTDropMenuItem menuItem:@"hahhcs" image:img tag:nil];
    KTDropMenuItem *item5 = [KTDropMenuItem menuItem:@"hahhaha" image:img tag:nil];
    KTDropMenuItem *item6 = [KTDropMenuItem menuItem:@"asdfgg" image:img tag:nil];
    KTDropMenuItem *item7 = [KTDropMenuItem menuItem:@"hahhaha" image:img tag:nil];
    KTDropMenuItem *item8 = [KTDropMenuItem menuItem:@"hahhcscscaha" image:img tag:nil];
    KTDropMenuItem *item9 = [KTDropMenuItem menuItem:@"hahhcscsa" image:img tag:nil];
    
     NSMutableArray *menuItems = [NSMutableArray arrayWithArray:@[item,item1,item2,item3,item4,item5,item6,item7,item8,item9]];
    self.menuItems = menuItems;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ktDropMenuStyle:(KTDropMenuStyle)style ItemSelected:(KTDropMenuItem *)item index:(NSInteger)index{
    if (style) {
        [self.selectButton setTitle:item.title forState:UIControlStateNormal];
    }else{
        switch (index) {
            case 0:
                NSLog(@"clicked %@",item.title);
                break;
                
            default:
                NSLog(@"clicked %ld",(long)index);
                break;
        }
    }
}

- (IBAction)selectButtonClick:(id)sender {
    [KTDropMenu showMenuInView:self.view fromView:sender delegate:self style:KTDropMenuStyle_Select menuItems:self.menuItems];

}

- (IBAction)button_click:(id)sender {
    UIImage *img = [UIImage imageNamed:@"latest"];
    KTDropMenuItem *item = [KTDropMenuItem menuItem:@"全部分类" image:img tag:nil];
    KTDropMenuItem *item1 = [KTDropMenuItem menuItem:@"游戏竞技" image:img tag:nil];
    KTDropMenuItem *item2 = [KTDropMenuItem menuItem:@"喝酒闲聊" image:img tag:nil];
    KTDropMenuItem *item3 = [KTDropMenuItem menuItem:@"休闲娱乐" image:img tag:nil];
    KTDropMenuItem *item4 = [KTDropMenuItem menuItem:@"hahhcs" image:img tag:nil];
    KTDropMenuItem *item5 = [KTDropMenuItem menuItem:@"hahhaha" image:img tag:nil];
    KTDropMenuItem *item6 = [KTDropMenuItem menuItem:@"asdfgg" image:img tag:nil];
    KTDropMenuItem *item7 = [KTDropMenuItem menuItem:@"hahhaha" image:img tag:nil];
    KTDropMenuItem *item8 = [KTDropMenuItem menuItem:@"hahhcscscaha" image:img tag:nil];
    KTDropMenuItem *item9 = [KTDropMenuItem menuItem:@"hahhcscsa" image:img tag:nil];
    [KTDropMenu showMenuInView:self.view fromView:sender delegate:self style:KTDropMenuStyle_Normal menuItems:@[item,item1,item2,item3,item4,item5,item6,item7,item8,item9]];
}

@end
