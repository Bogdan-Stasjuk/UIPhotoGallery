//
//  UIPhotoItemView.h
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@interface UIPhotoItemView : UIScrollView <UIScrollViewDelegate> {
@private
    UIImageView *mainImageView;
}

@property (nonatomic, assign) id<UIPhotoItemDelegate> galleryDelegate;

- (id)initWithFrame:(CGRect)frame andSubView:(UIView*)subView;

@end
