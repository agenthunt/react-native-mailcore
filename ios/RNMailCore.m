
#import "RNMailCore.h"
#import <MailCore/MailCore.h>
#import <React/RCTConvert.h>

@implementation RNMailCore

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(sendMail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
  smtpSession.hostname = [RCTConvert NSString:obj[@"hostname"]];
  smtpSession.port = [RCTConvert NSUInteger:obj[@"port"]];
  smtpSession.username = [RCTConvert NSString:obj[@"username"]];
  smtpSession.password = [RCTConvert NSString:obj[@"password"]];
  smtpSession.authType = MCOAuthTypeSASLPlain;
  smtpSession.connectionType = MCOConnectionTypeTLS;
  
  MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
  NSDictionary* fromObj = [RCTConvert NSDictionary:obj[@"from"]];
  MCOAddress *from = [MCOAddress addressWithDisplayName:[RCTConvert NSString:fromObj[@"addressWithDisplayName"]]
                                                mailbox:[RCTConvert NSString:fromObj[@"mailbox"]]];
  
  NSDictionary* toObj = [RCTConvert NSDictionary:obj[@"to"]];
  MCOAddress *to = [MCOAddress addressWithDisplayName:[RCTConvert NSString:toObj[@"addressWithDisplayName"]]
                                              mailbox:[RCTConvert NSString:toObj[@"mailbox"]]];
  [[builder header] setFrom:from];
  [[builder header] setTo:@[to]];
  [[builder header] setSubject:[RCTConvert NSString:obj[@"subject"]]];

  if (obj[@"attachment"] != nil) {
    NSDictionary* attachmentObj = [RCTConvert NSDictionary:obj[@"attachment"]];
    NSData *base64String = [RCTConvert NSData:attachmentObj[@"data"]];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    MCOAttachment *attachment = [MCOAttachment attachmentWithData:decodedData
                                                         filename:[RCTConvert NSString:attachmentObj[@"name"]]];
    [builder addAttachment:attachment];
  }

  [builder setHTMLBody:[RCTConvert NSString:obj[@"htmlBody"]]];
  NSData * rfc822Data = [builder data];
  
  MCOSMTPSendOperation *sendOperation =
  [smtpSession sendOperationWithData:rfc822Data];
  [sendOperation start:^(NSError *error) {
    if(error) {
      NSLog(@"Error sending email: %@", error);
      reject(@"Error", error.localizedDescription, error);
    } else {
      NSLog(@"Successfully sent email!");
      NSDictionary *result = @{@"status": @"SUCCESS"};
      resolve(result);
    }
  }];
  
}

@end
