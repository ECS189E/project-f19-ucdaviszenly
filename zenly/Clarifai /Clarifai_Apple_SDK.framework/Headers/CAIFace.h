//
//  CAIFace.h
//  Clarifai-Apple-SDK
//
//  Copyright © 2018 Clarifai. All rights reserved.
//

#import "CAIConcept.h"

@class CAIFaceIdentity;
@class CAIAge;
@class CAIGender;
@class CAIMultiCulturalAffinity;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Face)
@interface CAIFace : NSObject <NSCopying>

@property(nonatomic, strong, nullable, readonly) CAIFaceIdentity *faceIdentity;
@property(nonatomic, strong, nullable, readonly) CAIAge *age;
@property(nonatomic, strong, nullable, readonly) CAIGender *gender;
@property(nonatomic, strong, nullable, readonly)
    CAIMultiCulturalAffinity *multiCulturalAffinity;

@end

NS_ASSUME_NONNULL_END
