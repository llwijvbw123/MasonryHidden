//
//  MASConstraint+Hidden.h
//
//
//  Created by sunny on 2018/5/25.
//  Copyright © 2018年 All rights reserved.
//

#import <Masonry/MASConstraint.h>

@interface MASConstraint (Hidden)
- (MASConstraint * (^)(UIView *))autoHidden;
/**
 * 约束优先级必须小于1000 大于1
 * @return
 */
- (MASConstraint * (^)(UIView *))autoLow;

@end
