//
//  BBPegasusBannerView.h
//  Test
//
//  Created by bili233 on 2020/4/3.
//  Copyright © 2020 bili233. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BBPegasusBannerDisplayBlock)(NSInteger scrollToIndex, NSInteger previousIndex);
@interface BBPegasusBannerView : UIView
@property (nonatomic, copy) BBPegasusBannerDisplayBlock displayBlock;
- (void)installWithItems:(NSArray *)items customItemCellClass:(Class)itemCls;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeAfterInterval;
@end

@protocol BBPegasusBannerItemProtocol <NSObject>
@required
@property (nonatomic, weak) BBPegasusBannerView *container;
- (void)installWithItem:(id)item;
@end
