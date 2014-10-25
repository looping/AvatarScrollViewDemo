//
//  ViewController.m
//  AvatarScrollViewDemo
//
//  Created by Looping on 14/10/25.
//  Copyright (c) 2014年 RidgeCorn. All rights reserved.
//

#import "ViewController.h"
#import <iCarousel.h>
#import <GPUImage.h>
#import <AMSmoothAlertView.h>
#import <GPUImage.h>
#import <POP.h>

@interface ViewController () <iCarouselDataSource, iCarouselDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:({
       iCarousel *view = [[iCarousel alloc] initWithFrame:self.view.frame];
        view.center = self.view.center;
        view.backgroundColor = [UIColor lightGrayColor];
        view.delegate = self;
        view.dataSource = self;
//        view.pagingEnabled = YES;
        [self performSelector:@selector(carouselDidScroll:) withObject:view afterDelay:0];
        view;
    })];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 10;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
        view.layer.borderWidth = 2.f;
        view.layer.cornerRadius = view.frame.size.width / 2;
        view.layer.masksToBounds = YES;
    }
    
    [self addBlurInView:(UIImageView *)view atIndex:index progress:1.2f];

    [self scaleView:view to:CGPointMake(1.f, 1.f)];

    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"请他吃饭" andText:@"" andCancelButton:NO forAlertType:AlertSuccess];
    [alert show];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    NSInteger currentIndex = ceil(carousel.scrollOffset);
 
    CGFloat factor = carousel.scrollOffset - currentIndex;
    
    CGFloat scaleFactor = .6f;
    CGFloat baseScale = 1.f;
    CGFloat blurFactor = 5.0f;

    NSInteger prePreIndex = currentIndex - 2 < 0 ? [self numberOfItemsInCarousel:nil] + (currentIndex - 2): currentIndex - 2;

    if ([carousel itemViewAtIndex:prePreIndex]) {
        [self addBlurInView:(UIImageView *)[carousel itemViewAtIndex:prePreIndex] atIndex:prePreIndex progress:blurFactor * 1.f];
        [self scaleView:(UIImageView *)[carousel itemViewAtIndex:prePreIndex] to:CGPointMake(1.f, 1.f)];
    }
    
    NSInteger preIndex = currentIndex - 1 < 0 ? [self numberOfItemsInCarousel:nil] + (currentIndex - 1): currentIndex - 1;

    if ([carousel itemViewAtIndex:preIndex]) {
        [self addBlurInView:(UIImageView *)[carousel itemViewAtIndex:preIndex] atIndex:preIndex progress: blurFactor * (1 + factor)];
      
        [self scaleView:[carousel itemViewAtIndex:preIndex] to:CGPointMake(baseScale - scaleFactor * factor, baseScale - scaleFactor * factor)];
    }

    NSInteger index = currentIndex >= [self numberOfItemsInCarousel:nil] ? 0 : currentIndex;

    [self addBlurInView:(UIImageView *)[carousel itemViewAtIndex:index] atIndex:index progress: -blurFactor * factor];

    [self scaleView:[carousel itemViewAtIndex:index] to:CGPointMake(baseScale + scaleFactor *(factor + 1), baseScale + scaleFactor *(factor + 1))];
    
    NSInteger nextIndex =  currentIndex + 1 >= [self numberOfItemsInCarousel:nil] ? currentIndex + 1 - [self numberOfItemsInCarousel:nil] : currentIndex + 1;

    if ([carousel itemViewAtIndex:nextIndex]) {
        [self addBlurInView:(UIImageView *)[carousel itemViewAtIndex:nextIndex] atIndex:nextIndex progress:blurFactor * 1.f];
        [self scaleView:(UIImageView *)[carousel itemViewAtIndex:nextIndex] to:CGPointMake(1.f, 1.f)];
    }
    
#ifdef DEBUG
    [carousel itemViewAtIndex:prePreIndex].layer.borderColor = [UIColor orangeColor].CGColor;
    [carousel itemViewAtIndex:preIndex].layer.borderColor = [UIColor blueColor].CGColor;
    [carousel itemViewAtIndex:index].layer.borderColor = [UIColor redColor].CGColor;
    [carousel itemViewAtIndex:nextIndex].layer.borderColor = [UIColor grayColor].CGColor;
    NSLog(@"%ld : %ld, %ld, %ld, %ld", (long)currentIndex, (long)prePreIndex, (long)preIndex, (long)index, (long)nextIndex);
#endif
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionSpacing:
            value *= 1.6;
            break;
            case iCarouselOptionWrap:
            value = 1.f;
            break;
        default:
            break;
    }
    return value;
}

- (void)addBlurInView:(UIImageView *)imageView atIndex:(NSInteger)index progress:(CGFloat)progress {
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
    GPUImageGaussianBlurFilter *stillImageFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    stillImageFilter.blurRadiusInPixels = 2.f * progress;
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    imageView.image = [stillImageFilter imageFromCurrentFramebuffer];
}

- (void)scaleView:(UIView *)view to:(CGPoint)point {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 0;
    
    [view pop_addAnimation:animation forKey:@"scaleAnimation"];
}

@end
