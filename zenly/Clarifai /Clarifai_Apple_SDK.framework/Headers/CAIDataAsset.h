//
//  CAIDataAsset.h
//  Clarifai-Apple-SDK
//
//  Copyright © 2017 Clarifai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAIConcept;
@class CAIEmbedding;
@class CAIImage;
@class CAIRegion;
@class CAIFace;

typedef NS_ENUM(NSUInteger, CAIDataAssetType) {
  CAIDataAssetTypeImage = 0,
  CAIDataAssetTypeVideo,
} NS_SWIFT_NAME(DataAssetType);

/** DataAsset is not only a container for an asset (e.g. image, video) in a
   prediction or training, but also contains the relationship between the asset
   and its concepts, other metadata, and operations that can applied on the
   asset.
 */
NS_SWIFT_NAME(DataAsset)
@interface CAIDataAsset : NSObject <NSCoding, NSCopying>

/// Concepts associated with an asset. Those can be concepts from a prediction
/// or concepts for training a model on.
@property(nonatomic, strong, nullable, readonly)
    NSArray<CAIConcept *> *concepts;

/// In Classification models the concepts array will be populated with results.
/// When using Detection models, the regions array will be populated with
/// results.
@property(nonatomic, strong, nullable, readonly) NSArray<CAIRegion *> *regions;

/// Some classification models have a face property, in the face property we may
/// find information on identity, age, gender, and cultural appearance.
@property(nonatomic, strong, nullable, readonly) CAIFace *face;

/// Image in question, either for prediction or training
@property(nonatomic, strong, null_resettable) CAIImage *image;

/// Further information about the asset
@property(nonatomic, strong, nullable, readonly)
    NSDictionary<NSString *, id> *metadata;

/// Type of the asset
@property(nonatomic) CAIDataAssetType type;

/** Initializes an instance of DataAsset with an image
 @param image Instance of Image
 @returns An instance of DataAsset
 */
- (nonnull instancetype)initWithImage:(nullable CAIImage *)image
    NS_SWIFT_NAME(init(image:));

/** Add concepts to the DataAsset. Trying to add the same concept more than once
 will only add the first of the identical concepts of the list. The remaining
 identical concepts will be discarded.

 @param concepts An array of Concepts
 */
- (void)addConcepts:(nonnull NSArray<CAIConcept *> *)concepts
    NS_SWIFT_NAME(add(concepts:));

/** Add metadata to the DataAsset. Trying to add metadata with the same key will
 cause any existing value under that key to be overriden.

 @param metadata A dictionary with key (string)/value (anyobject) pairs
 */
- (void)addMetadata:(nonnull NSDictionary<NSString *, id> *)metadata
    NS_SWIFT_NAME(add(metadata:));

/// Removes all concepts associated with this DataAsset instance.
- (void)clearConcepts;

/// Removes all metadata associated with this DataAsset instance.
- (void)clearMetadata;

- (void)embeddings:
    (void (^_Nonnull)(NSArray<CAIEmbedding *> *_Nullable embeddings))
        completionHandler;

/** Removes specified concepts from the DataAsset.

 @param concepts Array of concepts to be removed
 */
- (void)removeConcepts:(nonnull NSArray<CAIConcept *> *)concepts
    NS_SWIFT_NAME(remove(concepts:));

/** Removes specified metadata from the DataAsset.

 @param metadata Dictionary of metadata with items to be removed
 */
- (void)removeMetadata:(nonnull NSDictionary<NSString *, id> *)metadata
    NS_SWIFT_NAME(remove(metadata:));

@end
