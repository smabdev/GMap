
#import <Foundation/Foundation.h>
#import "CRSMSProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"

@interface CRNexmo : NSObject <CRSMSProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;

@end
