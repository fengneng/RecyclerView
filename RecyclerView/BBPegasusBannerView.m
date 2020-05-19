//
//  BBPegasusBannerView.m
//  Test
//
//  Created by bili233 on 2020/4/3.
//  Copyright © 2020 bili233. All rights reserved.
//

#import "BBPegasusBannerView.h"

@interface BBPegasusBannerItemCell : UICollectionViewCell <BBPegasusBannerItemProtocol>

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UIButton *pauseButton;
@property (nonatomic) UIButton *resumeButton;
@property (nonatomic) UIButton *resumeDelayButton;

@end

@implementation BBPegasusBannerItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.lightGrayColor;
        [self.contentView addSubview:self.pauseButton];
        [self.contentView addSubview:self.resumeButton];
        [self.contentView addSubview:self.resumeDelayButton];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 30)];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, 60, 36)];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseButton setBackgroundColor:UIColor.redColor];
    }
    return _pauseButton;
}

- (UIButton *)resumeButton {
    if (!_resumeButton) {
        _resumeButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 50, 60, 36)];
        [_resumeButton setTitle:@"恢复" forState:UIControlStateNormal];
        [_resumeButton setBackgroundColor:UIColor.greenColor];
    }
    return _resumeButton;
}

- (UIButton *)resumeDelayButton {
    if (!_resumeDelayButton) {
        _resumeDelayButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 50, 80, 36)];
        [_resumeDelayButton setTitle:@"2s后恢复" forState:UIControlStateNormal];
        [_resumeDelayButton setBackgroundColor:UIColor.orangeColor];
    }
    return _resumeDelayButton;
}

@synthesize container;

- (void)installWithItem:(id)item {
    [self.pauseButton addTarget:self.container action:@selector(pauseTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.resumeButton addTarget:self.container action:@selector(resumeTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.resumeDelayButton addTarget:self.container action:@selector(resumeAfterInterval) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [item stringValue];
}

@end

static NSString *reuseId = @"reuserId";
static CGFloat kScrollInterval = 2.f;

@interface BBPegasusBannerView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSArray *items;

@end

@implementation BBPegasusBannerView
{
    __weak NSTimer *_timer;
    UICollectionView *_collectionView;
    NSInteger _currentIndex;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentIndex = -1;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.itemSize = self.frame.size;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = nil;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        _collectionView.pagingEnabled = YES;
        
        [_collectionView registerClass:[BBPegasusBannerItemCell class] forCellWithReuseIdentifier:reuseId];
        
        [self addSubview:_collectionView];
    }
    return self;
}

#pragma mark - public

- (void)installWithItems:(NSArray *)items customItemCellClass:(__unsafe_unretained Class)customCls {
    Class cls;
    if ([customCls conformsToProtocol:@protocol(BBPegasusBannerItemProtocol)]) {
        cls = customCls;
    }
    [_collectionView registerClass:cls?:BBPegasusBannerItemCell.class forCellWithReuseIdentifier:reuseId];
    
    self.items = items;
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [self setupTimer];
    [self resumeAfterInterval];
}

- (void)pauseTimer {
    if (!_timer.isValid) return;
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    if (!_timer.isValid) return;
    [_timer setFireDate:[NSDate date]];
}

- (void)resumeAfterInterval {
    if (!_timer.isValid) return;
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kScrollInterval]];
}

#pragma mark - private

- (void)setupTimer {
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:kScrollInterval target:self selector:@selector(scorllToNextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [self pauseTimer];
}

- (NSInteger)pageIndexWithCellIndex:(NSInteger)cellIndex {
    NSInteger pageIndex;
    if (cellIndex == 0) {
        pageIndex = self.items.count - 1;
    } else if (cellIndex == self.items.count + 1) {
        pageIndex = 0;
    } else {
        pageIndex = cellIndex - 1;
    }
    return pageIndex;
}

- (void)scorllToNextPage {
    NSInteger index = _collectionView.contentOffset.x / _collectionView.bounds.size.width;
    if (index > self.items.count) {
        index = 1;
    } else {
        index ++;
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (void)resetOffsetIfNeeded {
    if (_collectionView.contentOffset.x == 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.items.count inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    } else if (_collectionView.contentOffset.x == (_collectionView.contentSize.width - _collectionView.bounds.size.width)) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource、UICollectionViewDelegate、UIScrollViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count + 2;    //第0个前、最后一个后 各多创建一个
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBPegasusBannerItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    NSInteger pageIndex = [self pageIndexWithCellIndex:indexPath.item];
    id item = self.items[pageIndex];
    cell.container = self;
    [cell installWithItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger scrollToIndex = [self pageIndexWithCellIndex:indexPath.item];
    if (scrollToIndex != _currentIndex) {
//        NSLog(@"当前展示第%ld帧，上一帧是%ld", scrollToIndex, _currentIndex);
        if (self.displayBlock) {
            self.displayBlock(scrollToIndex, _currentIndex);
        }
        _currentIndex = scrollToIndex;
    }
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetOffsetIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetOffsetIfNeeded];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self resumeAfterInterval];
}

@end
