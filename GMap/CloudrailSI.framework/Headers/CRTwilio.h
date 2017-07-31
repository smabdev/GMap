
#import <Foundation/Foundation.h>
#import "CRSMSProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"

@interface CRTwilio : NSObject <CRSMSProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithAccountSid:(NSString *)accountSid authToken:(NSString *)authToken;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;

@end
