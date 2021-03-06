//
//  UIScrollView+SegmentHeader.m
//  SegmentHeaderView
//
//  Created by Vũ Trường Giang on 5/17/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "UIScrollView+SegmentHeader.h"
#import <objc/runtime.h>

#define DEFAULT_REFRESH_VIEW_HEIGHT 50

static char kenableSegmentKey;
static char kisShowingSegment;
static char kSegmentHeaderViewKey;
static char kDefaultInsetsKey;

@implementation UIScrollView (SegmentHeader)

#pragma mark -
#pragma mark Getter/Setter Method

//Get set Enable Refresh
-(BOOL)enabledSegment{
    NSNumber *enabledSegmentNumber = objc_getAssociatedObject(self, &kenableSegmentKey);
    return [enabledSegmentNumber boolValue];
}
-(void)setEnabledSegment:(BOOL)enabledSegment{
    SegmentHeaderView *_headerView=self.segmentHeaderView;
    if(!_headerView){
        _headerView=[[SegmentHeaderView alloc] initWithFrame:CGRectMake(0.0, 0, self.frame.size.width, DEFAULT_REFRESH_VIEW_HEIGHT)];
        [self setSegmentHeaderView:_headerView];
    }
    if (self.segmentHeaderView) {
        [self.segmentHeaderView setHidden:!enabledSegment];
    }
    objc_setAssociatedObject(self, &kenableSegmentKey, @(enabledSegment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.defaultInset = self.contentInset;
}


//Get Set isLoading
-(BOOL)isShowingSegment{
    NSNumber *isShowingSegment = objc_getAssociatedObject(self, &kisShowingSegment);
    return [isShowingSegment boolValue];
}
-(void)setIsShowingSegment:(BOOL)isShowingSegment{
    objc_setAssociatedObject(self, &kisShowingSegment, @(isShowingSegment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Get Set Header View

-(SegmentHeaderView *)segmentHeaderView{
    return objc_getAssociatedObject(self, &kSegmentHeaderViewKey);
}
-(void)setSegmentHeaderView:(SegmentHeaderView *)segmentHeaderView{
    if (self.segmentHeaderView) {
        [self.segmentHeaderView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &kSegmentHeaderViewKey,
                             segmentHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [segmentHeaderView setFrame:CGRectMake(0.0, -segmentHeaderView.frame.size.height, self.frame.size.width, segmentHeaderView.frame.size.height)];
    [segmentHeaderView setHidden:!self.enabledSegment];
    [self addSubview:segmentHeaderView];
}

//Get Set Default Insets
-(UIEdgeInsets)defaultInset{
    NSValue *value = objc_getAssociatedObject(self, &kDefaultInsetsKey);
    if(value) {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}
-(void)setDefaultInset:(UIEdgeInsets)defaultInset{
    NSValue *insetsValue = [NSValue valueWithUIEdgeInsets:defaultInset];
    objc_setAssociatedObject(self, &kDefaultInsetsKey, insetsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Public Method
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [self checkToShowSegment];
}

- (void)checkToShowSegment
{
    CGFloat offset = self.segmentHeaderView.frame.size.height + self.defaultInset.top;
    CGFloat topOffset = [self topContentOffset];
    if (topOffset <= -offset-20 && self.enabledSegment) {
        //Show the segment
        if (!self.isShowingSegment) {
            if(!self.segmentHeaderView.isShowSegment){
                NSLog(@"Show segment");
                self.segmentHeaderView.isShowSegment = YES;
                self.isShowingSegment = YES;
                UIEdgeInsets inset = UIEdgeInsetsMake(self.segmentHeaderView.frame.size.height+self.defaultInset.top, self.defaultInset.left, self.defaultInset.bottom, self.defaultInset.right);
                [self setContentInset:inset];
            }
        }
        
    }
    if (topOffset > 1.5*offset && self.enabledSegment) {
        //Hide the segment
        if(self.segmentHeaderView.isShowSegment){
            self.segmentHeaderView.isShowSegment = NO;
            self.isShowingSegment = NO;
            NSLog(@"Hide segment");
                [self setContentInset:self.defaultInset];
        }

        
    }
    
}

- (CGFloat)topContentOffset
{
    return self.contentOffset.y;
}

@end
