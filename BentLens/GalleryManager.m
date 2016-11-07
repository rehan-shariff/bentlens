//
//  GalleryManager.m
//  BentLens
//
//  Created by Rehan Shariff on 5/21/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

//Copyright (c) 2010 Michael Waterfall <michaelwaterfall@gmail.com>
//Copyright (c) 2016 Stackhall Learning Services, LLC <contact@stackhall.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "GalleryManager.h"
#import <MWPhotoBrowser/MWPhoto.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface GalleryManager() <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray* rawImages;
@property (nonatomic, strong) NSMutableArray* galleryImages;
@property (nonatomic, strong) NSMutableArray* galleryThumbnails;

@end

@implementation GalleryManager

- (instancetype)init {
    self = [super init];
    if(self) {
        self.rawImages = [[NSMutableArray alloc]init];
        self.galleryImages = [[NSMutableArray alloc]init];
        self.galleryThumbnails = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadImagesFromLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self load];
            }
        }];
    }
    else if(status == PHAuthorizationStatusAuthorized) {
        [self load];
    }
}

- (UIViewController*)createGallery {
    [self createGalleryImages:^(NSMutableArray* images, NSMutableArray *thumbnails) {
        self.galleryImages = images;
        self.galleryThumbnails = thumbnails;
    }];
    
    MWPhotoBrowser* browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.startOnGrid = YES;
    [browser setCurrentPhotoIndex:0];
    return browser;
}

- (void)load {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(_rawImages) {
            [_rawImages removeAllObjects];
            PHFetchOptions* options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult* fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_rawImages addObject:obj];
            }];
        }
    });
}

#pragma MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser*)photoBrowser {
    return self.galleryImages.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser*)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.galleryImages.count) {
        return [self.galleryImages objectAtIndex:index];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser*)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < self.galleryThumbnails.count) {
        return [self.galleryThumbnails objectAtIndex:index];
    }
    return nil;
}

- (void)createGalleryImages:(void (^)(NSMutableArray* images, NSMutableArray* thumbnails))gallery {
    NSMutableArray* localImages = [[NSMutableArray alloc] init];
    NSMutableArray* localThumbnails = [[NSMutableArray alloc] init];
    
    @synchronized(_rawImages) {
        NSMutableArray* copy = [_rawImages copy];
        UIScreen* screen = [UIScreen mainScreen];
        CGFloat scale = screen.scale;
        CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
        CGSize thumbnailTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
        for(PHAsset *asset in copy) {
            [localImages addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
            [localThumbnails addObject:[MWPhoto photoWithAsset:asset targetSize:thumbnailTargetSize]];
        }
        
        gallery(localImages, localThumbnails);
    }
}

@end