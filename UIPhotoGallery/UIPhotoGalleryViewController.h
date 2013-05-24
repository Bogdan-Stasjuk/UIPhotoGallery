//
//  UIPhotoGalleryViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@interface UIPhotoGalleryViewController : UIViewController<UIPhotoGalleryDataSource, UIPhotoGalleryDelegate> {
    UIPhotoGalleryView *vPhotoGallery;
}

@property (nonatomic, assign) id<UIPhotoGalleryDataSource> dataSource;

- (id)initWithGalleryMode:(UIPhotoGalleryMode)galleryMode;

@end
