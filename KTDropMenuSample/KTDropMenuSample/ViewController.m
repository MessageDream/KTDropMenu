//
//  ViewController.m
//  KTDropMenuSample
//
//  Created by jayden on 15/7/17.
//  Copyright © 2015年 jayden. All rights reserved.
//

#import "ViewController.h"
#import "KTDropMenu.h"

@interface ViewController ()<KTDropMenuDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ktDropMenuItemSelected:(KTDropMenuItem *)item index:(NSInteger)index{

}

- (IBAction)button_click:(id)sender {
    KTDropMenuItem *item = [KTDropMenuItem menuItem:@"hahhaha" image:nil tag:nil];
    KTDropMenuItem *item1 = [KTDropMenuItem menuItem:@"hahhcscscaha" image:nil tag:nil];
    [KTDropMenu showMenuInView:self.view fromView:sender delegate:self menuItems:@[item,item1]];
}

@end
