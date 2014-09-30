//
//  LYHCollectionViewLayout.m
//  DynamicsCollectionView
//
//  Created by Charles Leo on 14-9-30.
//  Copyright (c) 2014年 Charles Leo. All rights reserved.
//

#import "LYHCollectionViewLayout.h"

@implementation LYHCollectionViewLayout

-(id)init
{
    if (self = [super init]) {
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        self.itemSize = CGSizeMake(44, 44);
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithCollectionViewLayout:self];
    }
    return self;
}
-(void)prepareLayout
{
    [super prepareLayout];
    CGSize contentSize = self.collectionView.contentSize;
    NSArray * items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    if (self.dynamicAnimator.behaviors.count == 0) {
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIAttachmentBehavior * behaviour = [[UIAttachmentBehavior alloc]initWithItem:obj attachedToAnchor:[obj center]];
            behaviour.length = 0;
            behaviour.damping = 0.8;
            behaviour.frequency = 1;
            [self.dynamicAnimator addBehavior:behaviour];
        }];
    }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

//响应滚动事件
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView * scrollview= self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollview.bounds.origin.y;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        UICollectionViewLayoutAttributes * item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta * scrollResistance);
        }
        else
        {
            center.y += MIN(delta, delta * scrollResistance);
        }
        item.center = center;
        [self.dynamicAnimator updateItemUsingCurrentState:item];
        
    }];
    return NO;
}




@end
