//
//  ColorManager.m
//  BentLens
//
//  Created by Rehan Shariff on 11/6/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

#import "ColorManager.h"

NSString* const backgroundColorKey = @"backgroundColor";
NSString* const linesColorKey = @"linesColor";

using namespace cv;

@implementation ColorManager

- (instancetype)init {
    self = [super init];
    if(self) {
        self.linesColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)loadColors {
    NSData* linesData = [[NSUserDefaults standardUserDefaults] objectForKey:linesColorKey];
    NSData* backgroundData = [[NSUserDefaults standardUserDefaults] objectForKey:backgroundColorKey];
    UIColor* linesColor = [NSKeyedUnarchiver unarchiveObjectWithData:linesData];
    UIColor* backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:backgroundData];
    if(linesColor) {
        self.linesColor = linesColor;
    }
    if(backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
}

- (void)saveLinesColor:(UIColor*)linesColor AndBackgroundColor:(UIColor*)backgroundColor  {
    self.linesColor = linesColor;
    self.backgroundColor = backgroundColor;
    NSData* linesData = [NSKeyedArchiver archivedDataWithRootObject:linesColor];
    NSData* backgroundData = [NSKeyedArchiver archivedDataWithRootObject:backgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:linesData forKey:linesColorKey];
    [[NSUserDefaults standardUserDefaults] setObject:backgroundData forKey:backgroundColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end