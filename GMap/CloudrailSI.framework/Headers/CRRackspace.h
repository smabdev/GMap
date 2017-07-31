
#import <Foundation/Foundation.h>
#import "CRBusinessCloudStorageProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"

@interface CRRackspace : NSObject <CRBusinessCloudStorageProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithUsername:(NSString *)username apiKey:(NSString *)apiKey region:(NSString *)region;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;

@end
