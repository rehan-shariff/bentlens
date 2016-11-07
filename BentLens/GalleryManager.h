//
//  GalleryManager.h
//  BentLens
//
//  Created by Rehan Shariff on 5/21/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWPhotoBrowser;

@interface GalleryManager : NSObject

- (void)loadImagesFromLibrary;
- (UIViewController*)createGallery;

@end