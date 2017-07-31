
#import <Foundation/Foundation.h>
#import "CRPaymentProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"

@interface CRPayPal : NSObject <CRPaymentProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithUseSandbox:(BOOL)useSandbox clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;

@end
