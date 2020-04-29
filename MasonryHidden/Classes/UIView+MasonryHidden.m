//
//  UIView+MasonryHidden.m
//  
//
//  Created by sunny on 2018/5/23.
//  Copyright © 2018年  All rights reserved.
//

#import "UIView+MasonryHidden.h"
#import <objc/runtime.h>

static char *NSLayoutConstraintOriginConstant = "NSLayoutConstraintOriginConstant";
static char *NSLayoutConstraintOriginPriority = "NSLayoutConstraintOriginPriority";
static char *UIViewCanHiddenConstraintsSet = "UIViewCanHiddenConstraintsSet";
static char *UIViewCanLowConstraintsSet = "UIViewCanLowConstraintsSet";
static char *MasonryHidden = "MasonryHidden";

@implementation NSLayoutConstraint (OriginConstant)

- (void)setOriginConstant:(CGFloat)originConstant {
    objc_setAssociatedObject(self, NSLayoutConstraintOriginConstant, @(originConstant), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)getOriginConstant {
    return [objc_getAssociatedObject(self, NSLayoutConstraintOriginConstant) floatValue];
}
- (void)setOriginPriority:(CGFloat)originConstant {
    objc_setAssociatedObject(self, NSLayoutConstraintOriginPriority, @(originConstant), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)getOriginPriority {
    return [objc_getAssociatedObject(self, NSLayoutConstraintOriginPriority) floatValue];
}

@end

@implementation UIView (MasonryHidden)

- (NSMutableSet *)canHiddenConstraintsSet
{
    NSMutableSet *constraintsSet = objc_getAssociatedObject(self, UIViewCanHiddenConstraintsSet);
    if (!constraintsSet) {
        constraintsSet = [NSMutableSet set];
        objc_setAssociatedObject(self, UIViewCanHiddenConstraintsSet, constraintsSet, OBJC_ASSOCIATION_RETAIN);
    }
    return constraintsSet;
}

- (void)setCanHiddenConstraintsSet:(NSMutableSet *)canHiddenConstraintsSet {
    objc_setAssociatedObject(self, UIViewCanHiddenConstraintsSet, canHiddenConstraintsSet, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableSet *)canLowConstraintsSet
{
    NSMutableSet *constraintsSet = objc_getAssociatedObject(self, UIViewCanLowConstraintsSet);
    if (!constraintsSet) {
        constraintsSet = [NSMutableSet set];
        objc_setAssociatedObject(self, UIViewCanLowConstraintsSet, constraintsSet, OBJC_ASSOCIATION_RETAIN);
    }
    return constraintsSet;
}

- (void)setCanLowConstraintsSet:(NSMutableSet *)canLowConstraintsSet {
    objc_setAssociatedObject(self, UIViewCanLowConstraintsSet, canLowConstraintsSet, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)masonry_hidden {
    return [objc_getAssociatedObject(self, MasonryHidden) boolValue];
}

- (void)setMasonry_hidden:(BOOL)masonry_hidden {
    
    if (masonry_hidden == [self masonry_hidden]) {
        return;
    }
    
    NSMutableSet *set = self.canHiddenConstraintsSet;
    NSMutableSet *setLow = self.canLowConstraintsSet;

    if (masonry_hidden) {
        [set enumerateObjectsUsingBlock:^(MASViewConstraint * _Nonnull constraint, BOOL * _Nonnull stop) {
            
            MASLayoutConstraint *originConstraint = [constraint valueForKey:@"layoutConstraint"];
            if (originConstraint) {
                [originConstraint setOriginConstant:originConstraint.constant];
                originConstraint.constant = 0.0;
            }
            
        }];
        [setLow enumerateObjectsUsingBlock:^(MASViewConstraint * _Nonnull constraint, BOOL * _Nonnull stop) {

            MASLayoutConstraint *originConstraint = [constraint valueForKey:@"layoutConstraint"];
            if (originConstraint) {
                [originConstraint setOriginPriority:originConstraint.priority];
                originConstraint.priority = 1;
            }

        }];
    } else {
        [set enumerateObjectsUsingBlock:^(MASViewConstraint * _Nonnull constraint, BOOL * _Nonnull stop) {
            MASLayoutConstraint *originConstraint = [constraint valueForKey:@"layoutConstraint"];
            if (originConstraint) {
                originConstraint.constant = [originConstraint getOriginConstant] ? : 0.0;
            }
        }];
        [setLow enumerateObjectsUsingBlock:^(MASViewConstraint * _Nonnull constraint, BOOL * _Nonnull stop) {
            MASLayoutConstraint *originConstraint = [constraint valueForKey:@"layoutConstraint"];
            if (originConstraint) {
                originConstraint.priority = [originConstraint getOriginPriority] ? : UILayoutPriorityDefaultLow;
            }
        }];
    }
    
    objc_setAssociatedObject(self, MasonryHidden, @(masonry_hidden), OBJC_ASSOCIATION_ASSIGN);
}

- (void)addWillHiddenConstraint:(NSArray<MASConstraint *> *)willHiddenConstraintArray {

    NSMutableSet *set = self.canHiddenConstraintsSet;
    
    [willHiddenConstraintArray enumerateObjectsUsingBlock:^(MASConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([constraint isKindOfClass:[MASViewConstraint class]]) {
            [set addObject:constraint];
        }
        
    }];
    
}
- (void)addWillLowConstraint:(NSArray<MASConstraint *> *)willLowConstraintArray {

    NSMutableSet *set = self.canLowConstraintsSet;

    [willLowConstraintArray enumerateObjectsUsingBlock:^(MASConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([constraint isKindOfClass:[MASViewConstraint class]]) {
            [set addObject:constraint];
        }

    }];

}

/*
- (void)autoCreateCanHiddenConstraintArray {
    if (self.canHiddenConstraintsSet.count) {
        return;
    }
    NSArray *installedConstraints = self.constraints;
    [installedConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight ||
            constraint.firstAttribute == NSLayoutAttributeTop ||
            constraint.firstAttribute == NSLayoutAttributeCenterY) {
            [self.canHiddenConstraintsSet addObject:constraint];
        }
    }];
}
 */
@end
