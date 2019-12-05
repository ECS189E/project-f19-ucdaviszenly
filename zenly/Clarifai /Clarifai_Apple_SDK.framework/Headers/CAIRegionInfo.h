//
//  CAIRegionInfo.h
//  Clarifai-Apple-SDK
//
//  Copyright © 2018 Clarifai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAIBoundingBox;

/** Contains the box defining the area where an interest was detected.
 */
NS_SWIFT_NAME(RegionInfo)
@interface CAIRegionInfo : NSObject <NSCopying>

/// Bounding box of the area of interest
@property(nonatomic, strong, nullable, readonly) CAIBoundingBox *boundingBox;

@end
