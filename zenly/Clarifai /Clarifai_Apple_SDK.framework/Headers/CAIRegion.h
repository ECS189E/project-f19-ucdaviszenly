//
//  CAIRegion.h
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

@class CAIConcept;
@class CAIDataAsset;
@class CAIRegionInfo;

/** Region describes the area where a detection took place.
 */
NS_SWIFT_NAME(Region)
@interface CAIRegion : NSObject <NSCopying>

/// Contains the relationship between the asset and its concepts, other
/// metadata, and operations that can applied on the asset.
@property(nonatomic, strong, nullable, readonly) CAIDataAsset *dataAsset;

/// Detailed information about the retection region
@property(nonatomic, strong, nullable, readonly) CAIRegionInfo *regionInfo;

/// Unique identifier for the region
@property(nonatomic, strong, nonnull, readonly) NSString *regionId;

@end
