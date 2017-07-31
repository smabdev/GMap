
#import <Foundation/Foundation.h>
#import "CRPointsOfInterestProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"

@interface CRFoursquare : NSObject <CRPointsOfInterestProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;

@end
