#import "TyvanSongsUtil.h"

@implementation TyvanSongsUtil

+(UIColor *)colorWithHex:(int)hex{
    float r = ((hex & 0xFF000000) >> 24) / 255.0;
    float g = ((hex & 0xFF0000) >> 16) / 255.0;
    float b = ((hex & 0xFF00) >> 8) / 255.0;
    float a = ((hex & 0xFF)) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


+ (void)alertPopup:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Харылзаа үзүлген"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Чаа"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
