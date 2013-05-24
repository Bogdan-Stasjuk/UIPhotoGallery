//
//  UIPhotoGalleryView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import "UIPhotoGalleryView.h"
#import "UIPhotoItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kDefaultSubviewGap              30
#define kMaxSpareViews                  2

@interface UIPhotoGalleryView ()

- (void)initMainScrollView;
- (void)setupMainScrollView;
- (BOOL)reusableViewsContainViewAtIndex:(NSInteger)index;
- (void)populateSubviews;
- (void)populateCaptions;
- (UIPhotoItemView*)viewToBeAddedWithFrame:(CGRect)frame atIndex:(NSInteger)index;

@end

@implementation UIPhotoGalleryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self initMainScrollView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initMainScrollView];
}

- (void)layoutSubviews {
    [self setupMainScrollView];
}

#pragma get-set methods
- (void)setGalleryMode:(UIPhotoGalleryMode)galleryMode {
    _galleryMode = galleryMode;
    [self layoutSubviews];
}

- (void)setCaptionMode:(UIPhotoCaptionMode)captionMode {
    _captionMode = captionMode;
    [self populateCaptions];
}

- (void)setCaptionStyle:(UIPhotoCaptionStyle)captionStyle {
    _captionStyle = captionStyle;
}

- (void)setCircleScroll:(BOOL)circleScroll {
    _circleScroll = circleScroll;
    
//    if (_circleScroll) {
//        circleScrollViews = [NSMutableArray array];
//        
//        for (NSInteger index = -2; index < 2; index++) {
//            NSInteger indexToAdd = (dataSourceNumOfViews + index) % dataSourceNumOfViews;
//            UIView *viewToAdd = [self viewToBeAddedAtIndex:indexToAdd];
//            [circleScrollViews addObject:viewToAdd];
    
//            CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//            
//            if (_verticalGallery)
//                frame.origin.y = assertIndex * mainScrollView.frame.size.height;
//            else
//                frame.origin.x = assertIndex * mainScrollView.frame.size.width;
//            
//            UIView *viewToAdd = [self viewToBeAddedAtIndex:assertIndex];
//            
//            UIPhotoItemView *subView = [[UIPhotoItemView alloc] initWithFrame:frame andSubView:viewToAdd];
//            subView.tag = currentPage + index;
//            subView.galleryDelegate = self;
//        }
//    } else {
//        for (UIView *view in circleScrollViews)
//            [view removeFromSuperview];
//        
//        circleScrollViews = nil;
//    }
}

- (void)setPeakSubView:(BOOL)peakSubView {
    _peakSubView = peakSubView;
    mainScrollView.clipsToBounds = _peakSubView;
}

- (void)setVerticalGallery:(BOOL)verticalGallery {
    _verticalGallery = verticalGallery;
    [self setSubviewGap:_subviewGap];
    [self setInitialIndex:_initialIndex];
}

- (void)setSubviewGap:(CGFloat)subviewGap {
    _subviewGap = subviewGap;
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    mainScrollView.frame = frame;
    mainScrollView.contentSize = frame.size;
}

- (void)setInitialIndex:(NSInteger)initialIndex {
    _initialIndex = initialIndex;
    currentPage = _initialIndex;
    [self populateSubviews];
    
    CGPoint contentOffset = mainScrollView.contentOffset;
    
    if (_verticalGallery)
        contentOffset.y = currentPage * mainScrollView.frame.size.height;
    else
        contentOffset.x = currentPage * mainScrollView.frame.size.width;
    
    mainScrollView.contentOffset = contentOffset;
}

#pragma public methods
- (BOOL)scrollToPage:(NSInteger)page {
    if (page < 0 || page >= dataSourceNumOfViews || page == currentPage)
        return NO;
    
    currentPage = page;
    
    CGPoint contentOffset = mainScrollView.contentOffset;
    
    if (_verticalGallery)
        contentOffset.y = currentPage * mainScrollView.frame.size.height;
    else
        contentOffset.x = currentPage * mainScrollView.frame.size.width;
    
    [mainScrollView setContentOffset:contentOffset animated:YES];
    [self scrollViewDidScroll:mainScrollView];
    
    return YES;
}

- (BOOL)scrollToBesidePage:(NSInteger)delta {
    return [self scrollToPage:currentPage+delta];
}

#pragma UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger newPage;
    
    if (_verticalGallery)
        newPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    else
        newPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if (newPage != currentPage) {
        currentPage = newPage;
        [self populateSubviews];
    }
}

#pragma private methods
- (void)initMainScrollView {
    _galleryMode = UIPhotoGalleryModeImageLocal;
    _captionMode = UIPhotoCaptionModeShared;
    _subviewGap = kDefaultSubviewGap;
    _peakSubView = NO;
    _verticalGallery = NO;
    _initialIndex = 0;
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
    mainScrollView.autoresizingMask = self.autoresizingMask;
    mainScrollView.contentSize = frame.size;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.delegate = self;
    mainScrollView.showsHorizontalScrollIndicator = mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.clipsToBounds = NO;
    mainScrollView.tag = -1;
    
    [self addSubview:mainScrollView];
    
    reusableViews = [NSMutableSet set];
    currentPage = 0;
}

- (void)setupMainScrollView {
    NSAssert(_dataSource != nil, @"Missing dataSource");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfViewsInPhotoGallery:)],
             @"Missing dataSource method numberOfViewsInPhotoGallery:");
    
    switch (_galleryMode) {
        case UIPhotoGalleryModeImageLocal:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:localImageAtIndex:)],
                     @"UIPhotoGalleryModeImageLocal mode missing dataSource method photoGallery:localImageAtIndex:");
            break;
            
        case UIPhotoGalleryModeImageRemote:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:remoteImageURLAtIndex:)],
                     @"UIPhotoGalleryModeImageRemote mode missing dataSource method photoGallery:remoteImageURLAtIndex:");
            break;
            
        case UIPhotoGalleryModeCustomView:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:customViewAtIndex:)],
                     @"UIPhotoGalleryModeCustomView mode missing dataSource method photoGallery:viewAtIndex:");
            break;
            
        default:
            break;
    }
    
    dataSourceNumOfViews = [_dataSource numberOfViewsInPhotoGallery:self];
    
    NSInteger tmpCurrentPage = currentPage;
    [self setSubviewGap:_subviewGap];
    currentPage = tmpCurrentPage;
    
    CGSize contentSize = mainScrollView.contentSize;
    
    if (_verticalGallery)
        contentSize.height = mainScrollView.frame.size.height * dataSourceNumOfViews;
    else
        contentSize.width = mainScrollView.frame.size.width * dataSourceNumOfViews;
    
    mainScrollView.contentSize = contentSize;
    
    for (UIView *view in mainScrollView.subviews)
        [view removeFromSuperview];
    
    [reusableViews removeAllObjects];
    
    [self populateSubviews];
    [self setInitialIndex:currentPage];
}

- (BOOL)reusableViewsContainViewAtIndex:(NSInteger)index {
    for (UIView *view in reusableViews)
        if (view.tag == index)
            return YES;
    
    return NO;
}

- (void)populateSubviews {
    NSMutableSet *toRemovedViews = [NSMutableSet set];
    
    for (UIView *view in reusableViews)
        if (view.tag < currentPage - kMaxSpareViews || view.tag > currentPage + kMaxSpareViews) {
            [toRemovedViews addObject:view];
            [view removeFromSuperview];
        }
    
    [reusableViews minusSet:toRemovedViews];

    for (NSInteger index = -kMaxSpareViews; index <= kMaxSpareViews; index++) {
        NSInteger assertIndex = currentPage + index;
        if (assertIndex < 0 || assertIndex >= dataSourceNumOfViews ||
            [self reusableViewsContainViewAtIndex:assertIndex])
            continue;
        
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        if (_verticalGallery)
            frame.origin.y = assertIndex * mainScrollView.frame.size.height;
        else
            frame.origin.x = assertIndex * mainScrollView.frame.size.width;
        
        UIPhotoItemView *subView = [self viewToBeAddedWithFrame:frame atIndex:currentPage + index];
        [subView setCaptionWithPlainText:@"Vivamus ut nibh velit, sit amet ornare enim. Nulla facilisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit."];
        [subView setCaptionHide:YES withAnimation:NO];
        
        if (subView) {
            [mainScrollView addSubview:subView];
            [reusableViews addObject:subView];
        }
    }
}

- (void)populateCaptions {
    for (UIPhotoItemView *subView in mainScrollView.subviews)
        [subView setCaptionHide:(_captionMode == UIPhotoCaptionModeShared) withAnimation:YES];
}

- (UIPhotoItemView*)viewToBeAddedWithFrame:(CGRect)frame atIndex:(NSInteger)index {
    CGRect displayFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    switch (_galleryMode) {
        case UIPhotoGalleryModeImageLocal: {
            UIImage *image = [_dataSource photoGallery:self localImageAtIndex:index];
            
            UIPhotoItemView *subView =
            [[UIPhotoItemView alloc] initWithFrame:frame andLocalImage:image atFrame:displayFrame];
            
            subView.tag = index;
            subView.galleryDelegate = self;
            
            return subView;
        }
            
        case UIPhotoGalleryModeImageRemote: {
            NSURL *url = [_dataSource photoGallery:self remoteImageURLAtIndex:index];
            UIPhotoItemView *subView =
            [[UIPhotoItemView alloc] initWithFrame:frame andRemoteURL:url atFrame:displayFrame];
            
            subView.tag = index;
            subView.galleryDelegate = self;
            
            return subView;
        }
            
        case UIPhotoGalleryModeCustomView: {
            UIView *customView = [_dataSource photoGallery:self customViewAtIndex:index];
            UIPhotoItemView *subView =
            [[UIPhotoItemView alloc] initWithFrame:frame andCustomView:customView atFrame:displayFrame];
            
            subView.tag = index;
            subView.galleryDelegate = self;
            
            return subView;
        }

        default:
            return nil;
    }
}

@end
