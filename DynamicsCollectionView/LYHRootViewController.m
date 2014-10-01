//
//  LYHRootViewController.m
//  DynamicsCollectionView
//
//  Created by Charles Leo on 14-9-30.
//  Copyright (c) 2014年 Charles Leo. All rights reserved.
//

#import "LYHRootViewController.h"
static NSString * cellIdentifier = @"CellIdentifier";
@interface LYHRootViewController ()

@end

@implementation LYHRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //方法二的时候下面这句代码就不需要了
    //[self.collectionViewLayout invalidateLayout];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10000;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger colorValue = arc4random() %10+1;
    
    cell.backgroundColor = [UIColor colorWithRed:1* colorValue green:0.03*colorValue blue:0.26 * colorValue  alpha:0.4];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
