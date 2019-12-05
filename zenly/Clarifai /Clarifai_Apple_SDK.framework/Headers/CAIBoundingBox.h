//
//  CAIBoundingBox.h
//  Clarifai-Apple-SDK
//
//  Copyright © 2018 Clarifai. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

/** Define an are of interest. All coordinates are a percentage of the asset's
 * dimensions, anchored at the top-left corner
 */
NS_SWIFT_NAME(BoundingBox)
@interface CAIBoundingBox : NSObject <NSCopying>

/// Top of the box, expressed as a percentage from the top margin of the asset
@property(nonatomic, assign) CGFloat top;

/// Left of the box, expressed as a percentage from the left margin of the asset
@property(nonatomic, assign) CGFloat left;

/// Bottom of the box, expressed as a percentage from the top margin of the
/// asset
@property(nonatomic, assign) CGFloat bottom;

/// Right of the box, expressed as a percentage from the left margin of the
/// asset
@property(nonatomic, assign) CGFloat right;

@end
