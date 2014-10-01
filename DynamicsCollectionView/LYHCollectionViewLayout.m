//
//  LYHCollectionViewLayout.m
//  DynamicsCollectionView
//
//  Created by Charles Leo on 14-9-30.
//  Copyright (c) 2014年 Charles Leo. All rights reserved.
//

#import "LYHCollectionViewLayout.h"

@interface LYHCollectionViewLayout()
@property (strong,nonatomic) UIDynamicAnimator * dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@end

@implementation LYHCollectionViewLayout

-(id)init
{
    if (self = [super init]) {
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        self.itemSize = CGSizeMake(44, 44);
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithCollectionViewLayout:self];
        self.visibleIndexPathsSet = [NSMutableSet set];
    }
    return self;
}
-(void)prepareLayout
{
    [super prepareLayout];
    //方法一:
    
    //这种方法在cell非常多得情况下会显得效率很低.
    /*
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
     */
    
    //方法二:
    
    //我们可以平铺dynamic Behaviors 来优化性能
    //就是说,只加载显示和即将显示的cell
    
    CGRect originalRect = (CGRect){.origin = self.collectionView.bounds.origin,.size = self.collectionView.frame.size};
    //在实际显示矩形的每个方向都扩大100像素
    CGRect visibleRect = CGRectInset(originalRect, -100, -100);
    //收集在显示范围内的collection view layout attributes 和他们的index paths
    NSArray * itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    NSSet * itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    /*
     遍历dynamic animator 的behaviors 过滤掉那些已经在 itemsIndexPathsInVisibleRectSet 中的item.
     因为我们已经过滤掉我们的behavior,所以我们将要遍历的这些item都是不在显示范围内的,我们就可以将这些item从
     animtor中删除掉.
     */
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior * behaviour , NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject]indexPath]];
        return !currentlyVisible;
    }];
    
    NSArray * noLongerVisibleBehaviors = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:predicate];
    
    [noLongerVisibleBehaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    /*
     得到新出现的item,一旦有新的layout attribute 出现,我们就可以遍历他们
     来创建新的behavior并且将他们的index path 添加到visibleIndexPathsSet中.
     */
    NSPredicate * newlyPredicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath]!=nil;
        return !currentlyVisible;
    }];
    NSArray * newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:newlyPredicate];
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior * springBehaviour = [[UIAttachmentBehavior alloc]initWithItem:item attachedToAnchor:center];
        springBehaviour.length = 0.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 1.0f;
        //如果有滑动collection View
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
            
            if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            }
            else {
                center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            }
            item.center = center;
        }
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
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
//这个方法在collection view 的bound发生改变的时候调用

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView * scrollview= self.collectionView;
    //得出垂直偏移量
    CGFloat delta = newBounds.origin.y - scrollview.bounds.origin.y;
    NSLog(@"delta is %f",delta);
    self.latestDelta = delta;
    //获取触屏的位置
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    //这样我们就可以使那些里触屏位置近的item移动的更迅速,而较远的item运动的滞后些.
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehaviour.anchorPoint.x);
        //获取滑动阻力系数,1500使设置的一个经验值,分母越小弹簧效果越好
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
