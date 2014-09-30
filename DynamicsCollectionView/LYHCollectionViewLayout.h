//
//  LYHCollectionViewLayout.h
//  DynamicsCollectionView
//
//  Created by Charles Leo on 14-9-30.
//  Copyright (c) 2014年 Charles Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYHCollectionViewLayout : UICollectionViewFlowLayout
@property (strong,nonatomic) UIDynamicAnimator * dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
-(id)init;
@end
