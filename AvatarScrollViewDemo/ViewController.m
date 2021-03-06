//
//  ViewController.m
//  AvatarScrollViewDemo
//
//  Created by Looping on 14/10/25.
//  Copyright (c) 2014年 RidgeCorn. All rights reserved.
//

#import "ViewController.h"
#import <iCarousel.h>
#import <POP.h>
#import <UIImageView+WebCache.h>

@interface ViewController () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic) iCarousel *avatarScrollView;
@property (nonatomic) CGFloat lastOffset;
@property (nonatomic) NSArray *avatars;
@property (nonatomic) NSArray * dataSource;
@property (nonatomic) NSInteger updateCount;
@property (nonatomic) NSTimer *updateTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _avatars = @[@"http://f.hiphotos.baidu.com/image/pic/item/eaf81a4c510fd9f9022a1618262dd42a2834a486.jpg", @"http://pic1a.nipic.com/2008-12-02/200812210427444_2.jpg", @"http://pic11.nipic.com/20101105/2284021_141455259000_2.jpg", @"http://images.yoka.com/pic/cr/2009/1103/1102732392.jpg", @"http://pic5.nipic.com/20100202/3760162_130224079498_2.jpg", @"http://image.tianjimedia.com/uploadImages/2012/229/38/9Q12A8375E44.jpg", @"http://images.yoka.com/pic/star/topic/2011/U288P1T117D370126F2577DT20110726103250.jpg", @"http://fashion.168xiezi.com/attachments/2009/10/19/123837_2009101909135926gt6.jpg", @"http://img1.imgtn.bdimg.com/it/u=121329706,3257609001&fm=23&gp=0.jpg", @"http://www.lady8844.com/h012/h51/img201009271201039.jpg", @"http://news.youth.cn/yl/201301/W020130126470585666343.png", @"http://www.hers.cn/uploadfile/2010/1224/20101224040846670.jpg", @"http://ent.qingdaonews.com/images/attachement/jpg/site1/20140218/201a065afbea146d42ca14.jpg", @"http://img.sdchina.com/news/20110208/c01_50201539-d8c7-4fd5-8899-035351fdceb7_3.jpg", @"http://img2.iqilu.com/ed/11/09/02/31/206_110902164225_1.jpg", @"http://h.hiphotos.baidu.com/image/pic/item/1ad5ad6eddc451dadeaf4f9ab5fd5266d0163261.jpg"];
    
    _dataSource = [_avatars objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_avatars.count, 0)]];
    
    [self.view addSubview:({
        _avatarScrollView = [[iCarousel alloc] initWithFrame:self.view.frame];
        _avatarScrollView.center = self.view.center;
        _avatarScrollView.backgroundColor = [UIColor lightGrayColor];
        _avatarScrollView.delegate = self;
        _avatarScrollView.bounceDistance = 0.8f;
        _avatarScrollView.decelerationRate = 0.8f;
        _avatarScrollView;
    })];
    
    [self.view addSubview:({
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 120.f, self.view.frame.size.width / 2, 50.f)];
        titleLabel.tag = 306;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:36];
        titleLabel.text = @"0";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel;
    })];
    
    [self.view addSubview:({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 120.f, 80.f, 80.f)];
        imageView.tag = 1024;
        imageView;
    })];
    
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];
}

- (void)reloadData {
    _updateCount = _dataSource.count;
    
    NSInteger newIndex = _avatars.count - _dataSource.count - 1;
    newIndex = newIndex >= 0 ? newIndex : 0;
    
    _dataSource = [_avatars objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newIndex, _avatars.count - newIndex)]];
    
    _updateCount = _dataSource.count - _updateCount;
    
    if (_updateCount) {
        if ( !_avatarScrollView.dataSource) {
            _avatarScrollView.dataSource = self;
            [self performSelector:@selector(handleAnimationWithScrollOffset:) withObject:nil afterDelay:0];
        } else {
            [_avatarScrollView insertItemAtIndex:0 animated:YES];
            [self performSelector:@selector(handleAnimationAfterReload) withObject:nil afterDelay:0];
        }
    } else {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }

}

- (void)handleAnimationAfterReload {
    [_avatarScrollView scrollToOffset:_lastOffset + _updateCount duration:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _dataSource.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIImageView *imageView = [self imageViewAtIndex:index];
    
    if ( !imageView.image) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.layer.masksToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_dataSource[index]] placeholderImage:[UIImage imageNamed:@"avatar"]];
    }
    
    [self scaleView:imageView to:CGPointMake(1.f, 1.f)];
    
    return imageView;
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [self handleAnimationWithScrollOffset:carousel.scrollOffset];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (carousel.currentItemIndex == index) {
        [[[UIAlertView alloc] initWithTitle:@"请我吃饭" message:[NSString stringWithFormat:@"%@", @(index)] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"哦，好吧", nil] show];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (_dataSource.count) {
        [(UILabel *)[self.view viewWithTag:306] setText:[NSString stringWithFormat:@"%@", @(carousel.currentItemIndex)]];
        [(UIImageView *)[self.view viewWithTag:1024] sd_setImageWithURL:[NSURL URLWithString:_dataSource[carousel.currentItemIndex]] placeholderImage:[UIImage imageNamed:@"avatar"]];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionSpacing:
            value *= 1.8f;
            break;
        case iCarouselOptionFadeMin:
            value = 0.1f;
            break;
        case iCarouselOptionFadeMax:
            value = -.1f;
            break;
        case iCarouselOptionFadeRange:
            value = 1.6f;
            break;
        default:
            break;
    }
    return value;
}

- (UIImageView *)imageViewAtIndex:(NSInteger)index {
    return (UIImageView *)[_avatarScrollView itemViewAtIndex:index];
}

- (void)handleAnimationWithScrollOffset:(CGFloat)offset {
    _lastOffset = offset;

    NSInteger currentIndex = ceil(offset);
    
    CGFloat factor = offset - currentIndex;
    
    CGFloat scaleFactor = .6f;
    CGFloat baseScale = 1.f;
    
    [self scaleView:[self imageViewAtIndex:currentIndex - 2] to:CGPointMake(1.f, 1.f)];
    [self scaleView:[self imageViewAtIndex:currentIndex - 1] to:CGPointMake(baseScale - scaleFactor * factor, baseScale - scaleFactor * factor)];
    [self scaleView:[self imageViewAtIndex:currentIndex] to:CGPointMake(baseScale + scaleFactor *(factor + 1), baseScale + scaleFactor *(factor + 1))];
    [self scaleView:[self imageViewAtIndex:currentIndex + 1] to:CGPointMake(1.f, 1.f)];
}

- (void)scaleView:(UIView *)view to:(CGPoint)point {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 0;
    
    [view pop_addAnimation:animation forKey:@"scaleAnimation"];
}

@end
