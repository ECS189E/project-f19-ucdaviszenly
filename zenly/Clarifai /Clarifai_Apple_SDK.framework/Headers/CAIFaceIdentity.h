//
//  CAIFaceIdentity.h
//  Clarifai-Apple-SDK
//
//  Copyright © 2018 Clarifai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_SWIFT_NAME(FaceIdentity)
@interface CAIFaceIdentity : NSObject <NSCopying>

- (NSArray *)concepts;

@end
