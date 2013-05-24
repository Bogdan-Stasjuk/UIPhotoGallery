//
//  UIPhotoGalleryViewController.m
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import "UIPhotoGalleryViewController.h"

@interface UIPhotoGalleryViewController () {
    BOOL statusBarHidden;
    BOOL controlViewHidden;
    
    UIView *topView;
    UIView *bottomView;
}

- (void)setupTopBar;
- (void)setupBottomBar;

- (void)btnDonePressed;
- (void)btnPrevPressed;
- (void)btnNextPressed;

@end

@implementation UIPhotoGalleryViewController

- (id)initWithGalleryMode:(UIPhotoGalleryMode)galleryMode {
    if (self = [super init]) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor blackColor];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        vPhotoGallery = [[UIPhotoGalleryView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        vPhotoGallery.dataSource = self;
        vPhotoGallery.delegate = self;
        vPhotoGallery.galleryMode = galleryMode;
        
        [self.view addSubview:vPhotoGallery];
        
        statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        controlViewHidden = NO;
        [self setupTopBar];
        [self setupBottomBar];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.view.frame = [UIScreen mainScreen].bounds;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!statusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma get-set methods
- (void)setDataSource:(id<UIPhotoGalleryDataSource>)dataSource {
    _dataSource = dataSource;
    
    if (!dataSource)
        vPhotoGallery.dataSource = self;
    else
        vPhotoGallery.dataSource = _dataSource;
    
    [self setupTopBar];
    [self setupBottomBar];
}

#pragma UIPhotoGalleryDataSource methods
- (NSInteger)numberOfViewsInPhotoGallery:(UIPhotoGalleryView *)photoGallery {
    // Abstract method
    return 0;
}

- (UIImage*)photoGallery:(UIPhotoGalleryView *)photoGallery localImageAtIndex:(NSInteger)index {
    return nil;
}

- (NSURL*)photoGallery:(UIPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index {
    return nil;
}

- (UIView*)photoGallery:(UIPhotoGalleryView *)photoGallery customViewAtIndex:(NSInteger)index {
    return nil;
}

#pragma UIPhotoGalleryDelegate methods
- (void)photoGallery:(UIPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index {
    controlViewHidden = !controlViewHidden;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = topView.frame;
        frame.origin.y = (-controlViewHidden)*frame.size.height;
        topView.frame = frame;
        topView.alpha = !controlViewHidden;
        
        frame = bottomView.frame;
        
        if (controlViewHidden)
            frame.origin.y += frame.size.height;
        else
            frame.origin.y -= frame.size.height;
        
        bottomView.frame = frame;
        bottomView.alpha = !controlViewHidden;
    }];
}

#pragma private methods
- (void)setupTopBar {
    [topView removeFromSuperview];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(customTopViewForGalleryViewController:)]) {
        topView = [_dataSource customTopViewForGalleryViewController:self];
        topView.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);
        topView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:topView];
        return;
    }
    
    UIToolbar *topViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    topViewBar.barStyle = UIBarStyleBlackTranslucent;
    topViewBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(btnDonePressed)];
    [topViewBar setItems:@[btnDone] animated:YES];
    
    topView = [[UIView alloc] initWithFrame:topViewBar.frame];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [topView addSubview:topViewBar];
    [self.view addSubview:topView];
}

- (void)setupBottomBar {
    [bottomView removeFromSuperview];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(customBottomViewForGalleryViewController:)]) {
        bottomView = [_dataSource customBottomViewForGalleryViewController:self];
        bottomView.frame = CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height);
        [self.view addSubview:bottomView];
        return;
    }
    
    UIToolbar *bottomViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    bottomViewBar.barStyle = UIBarStyleBlackTranslucent;
    bottomViewBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithTitle:@"Prev"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnPrevPressed)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnNextPressed)];
    [bottomViewBar setItems:@[btnPrev, flexSpace, btnNext] animated:YES];
    
    bottomView = [[UIView alloc] initWithFrame:
                  CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [bottomView addSubview:bottomViewBar];
    [self.view addSubview:bottomView];
}

- (void)btnDonePressed {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)btnPrevPressed {
    [vPhotoGallery scrollToBesidePage:-1];
}

- (void)btnNextPressed {
    [vPhotoGallery scrollToBesidePage:1];
}

@end
