#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef enum {
    STRUploadRequestOne = 0,
    STRUploadRequestTwo,
    STRUploadRequestThree,
    STRUploadRequestFour
}STRUploadRequest;

typedef void(^success)(id responseObject);
typedef void (^failure)(NSError *error);
@interface CSUploadMultipleFileApi : NSObject

-(void)hitFileUploadAPIWithDictionaryPath:(NSString*)dictPath actionName:(STRUploadRequest)action idValue:(NSDictionary*)idValue successBlock:(success)successBlock failureBlock:(failure)failureBlock;
-(void)hitFileUploadAPIWithDictionaryPath2:(NSString *)dictPath actionName:(NSString*)action idValue:(NSDictionary*)idValue successBlock:(success)successBlock failureBlock:(failure)failureBlock;
-(void)hitFileUploadAPIWithDictionaryPath3:(NSString *)dictPath actionName:(NSString*)action idValue:(NSDictionary*)idValue successBlock:(success)successBlock failureBlock:(failure)failureBlock;
@property(nonatomic,assign)STRUploadRequest uploadType;
@end
