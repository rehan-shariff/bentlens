//
//  ColorManager.h
//  BentLens
//
//  Created by Rehan Shariff on 11/6/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

#import <opencv2/imgcodecs/ios.h>

using namespace cv;

@interface ColorManager : NSObject

@property (nonatomic, strong) UIColor* linesColor;
@property (nonatomic, strong) UIColor* backgroundColor;

- (void)loadColors;
- (void)saveLinesColor:(UIColor*)linesColor AndBackgroundColor:(UIColor*)backgroundColor;
- (UIColor*)linesColor;
- (UIColor*)backgroundColor;

@end