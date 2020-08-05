#import "RNMailCore.h"
#import <MailCore/MailCore.h>
#import <React/RCTConvert.h>

@implementation RNMailCore


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()



RCT_EXPORT_METHOD(loginSmtp:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = [RCTConvert NSString:obj[@"hostname"]];
    smtpSession.port = [RCTConvert int:obj[@"port"]];
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    int authType = [RCTConvert int:obj[@"authType"]];
    [smtpSession setAuthType:authType];
    if (authType == MCOAuthTypeXOAuth2) {
        [smtpSession setOAuth2Token:[RCTConvert NSString:obj[@"password"]]];
    } else {
        smtpSession.password = [RCTConvert NSString:obj[@"password"]];
    }
    [smtpSession setUsername:[RCTConvert NSString:obj[@"username"]]];
    
    _smtpObject = smtpSession;
    MCOSMTPOperation *smtpOperation = [_smtpObject loginOperation];
    [smtpOperation start:^(NSError *error) {
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

RCT_EXPORT_METHOD(loginImap:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = [RCTConvert NSString:obj[@"hostname"]];
    imapSession.port = [RCTConvert int:obj[@"port"]];
    imapSession.connectionType = MCOConnectionTypeTLS;
    
    int authType = [RCTConvert int:obj[@"authType"]];
    [imapSession setAuthType:authType];
    if (authType == MCOAuthTypeXOAuth2) {
        [imapSession setOAuth2Token:[RCTConvert NSString:obj[@"password"]]];
    } else {
        imapSession.password = [RCTConvert NSString:obj[@"password"]];
    }
    [imapSession setUsername:[RCTConvert NSString:obj[@"username"]]];
    
    _imapSession = imapSession;
    MCOIMAPOperation *imapOperation = [_imapSession checkAccountOperation];
    [imapOperation start:^(NSError *error) {
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

RCT_EXPORT_METHOD(createFolder:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOIMAPOperation *imapOperation = [_imapSession createFolderOperation: [RCTConvert NSString:obj[@"folder"]]];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(renameFolder:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOIMAPOperation *imapOperation = [_imapSession renameFolderOperation:[RCTConvert NSString:obj[@"folderOldName"]] otherName:[RCTConvert NSString:obj[@"folderNewName"]]];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(deleteFolder:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOIMAPOperation *imapOperation = [_imapSession deleteFolderOperation: [RCTConvert NSString:obj[@"folder"]]];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(getFolders:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOIMAPFetchFoldersOperation *imapOperation = [_imapSession fetchAllFoldersOperation];
    [imapOperation start:^(NSError *error, NSArray * fetchedFolders) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSMutableArray *folders = [[NSMutableArray alloc] init];
            for(int i=0;i < fetchedFolders.count;i++) {
                NSMutableDictionary *folderObject = [[NSMutableDictionary alloc] init];
                MCOIMAPFolder *folder = fetchedFolders[i];
                
                int flags = folder.flags;
                [folderObject setObject:[NSString stringWithFormat:@"%d",flags] forKey:@"flags"];
                [folderObject setObject:folder.path forKey:@"path"];
                [folderObject setObject:folder.path forKey:@"folder"];
                NSDictionary *mapFolder = @{@"path": folder.path};
                
                [folders addObject:folderObject];
                
                
            }
            resolve(folders);
        }
    }];
}

RCT_EXPORT_METHOD(actionFlagMessage:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    NSNumber *flagsRequestKind = [RCTConvert NSNumber:obj[@"flagsRequestKind"]];
    NSNumber *messageFlag = [RCTConvert NSNumber:obj[@"messageFlag"]];
    MCOIMAPOperation *imapOperation = [_imapSession storeFlagsOperationWithFolder:folder uids:uid kind:flagsRequestKind.unsignedLongLongValue flags:messageFlag.unsignedLongLongValue];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}


RCT_EXPORT_METHOD(actionLabelMessage:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    NSNumber *flagsRequestKind = [RCTConvert NSNumber:obj[@"flagsRequestKind"]];
    NSArray *tags = [RCTConvert NSArray:obj[@"tags"]];
    MCOIMAPOperation *imapOperation = [_imapSession storeLabelsOperationWithFolder:folder uids:uid kind:flagsRequestKind.unsignedLongLongValue labels:tags];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(moveEmail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folderFrom = [RCTConvert NSString:obj[@"folderFrom"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    NSString *folderTo = [RCTConvert NSString:obj[@"folderTo"]];
    MCOIMAPCopyMessagesOperation *imapOperation = [_imapSession copyMessagesOperationWithFolder:folderFrom uids:uid destFolder:folderTo];
    [imapOperation start:^(NSError *error, NSDictionary * uidMapping) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            MCOIMAPOperation *deleteOperation = [_imapSession storeFlagsOperationWithFolder:folderFrom uids:uid kind:0 flags:8];
            [deleteOperation start:^(NSError *error) {
                if(error) {
                    reject(@"Error", error.localizedDescription, error);
                }
            }];
            MCOIMAPOperation *expungeOperation = [_imapSession expungeOperation:folderTo];
            [expungeOperation start:^(NSError * error) {
                if(error) {
                    reject(@"Error", error.localizedDescription, error);
                } else {
                    NSDictionary *result = @{@"status": @"SUCCESS"};
                    resolve(result);
                }
            }];
        }
    }];
}

RCT_EXPORT_METHOD(permantDeleteEmail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    MCOIMAPOperation *imapOperation = [_imapSession storeFlagsOperationWithFolder:folder uids:uid kind:0 flags:8];
    [imapOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
        }
    }];
    imapOperation = [_imapSession expungeOperation:folder];
    [imapOperation start:^(NSError * error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

- (void)sendEmail:(MCOMessageBuilder *)messageBuilder reject:(RCTPromiseRejectBlock)reject resolve:(RCTPromiseResolveBlock)resolve {
    MCOSMTPSendOperation *sendOperation = [_smtpObject sendOperationWithData:[messageBuilder data]];
    [sendOperation start:^(NSError *error) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{@"status": @"SUCCESS"};
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(sendMail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    MCOMessageBuilder *messageBuilder = [[MCOMessageBuilder alloc] init];
    if([obj objectForKey:@"headers"]) {
        NSDictionary *headerObj = [RCTConvert NSDictionary:obj[@"headers"]];
        for(id key in headerObj) {
            [[messageBuilder header] setExtraHeaderValue:[headerObj objectForKey:key] forName:key];
        }
    }
    
    NSDictionary *fromObj = [RCTConvert NSDictionary:obj[@"from"]];
    [[messageBuilder header] setFrom:[MCOAddress addressWithDisplayName:[fromObj objectForKey:@"addressWithDisplayName"] mailbox:[fromObj objectForKey:@"mailbox"]]];
    
    NSDictionary *toObj = [RCTConvert NSDictionary:obj[@"to"]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    for(id toKey in toObj) {
        [toArray addObject:[MCOAddress addressWithDisplayName:[toObj objectForKey:toKey] mailbox:toKey]];
    }
    [[messageBuilder header] setTo:toArray];
    
    if([obj objectForKey:@"cc"]) {
        NSDictionary *ccObj = [RCTConvert NSDictionary:obj[@"cc"]];
        NSMutableArray *ccArray = [[NSMutableArray alloc] init];
        for(id ccKey in ccObj) {
            [ccArray addObject:[MCOAddress addressWithDisplayName:[ccObj objectForKey:ccKey] mailbox:ccKey]];
        }
        [[messageBuilder header] setCc:ccArray];
    }
    
    if([obj objectForKey:@"bcc"]) {
        NSDictionary *bccObj = [RCTConvert NSDictionary:obj[@"bcc"]];
        NSMutableArray *bccArray = [[NSMutableArray alloc] init];
        for(id bccKey in bccObj) {
            [bccArray addObject:[MCOAddress addressWithDisplayName:[bccObj objectForKey:bccKey] mailbox:bccKey]];
        }
        [[messageBuilder header] setBcc:bccArray];
    }
    
    if([obj objectForKey:@"subject"]) {
        [[messageBuilder header] setSubject:[RCTConvert NSString:obj[@"subject"]]];
    }
    
    if([obj objectForKey:@"body"]) {
        [messageBuilder setHTMLBody:[RCTConvert NSString:obj[@"body"]]];
    }
    
    if([obj objectForKey:@"attachments"]) {
        NSArray *attachmentObj = [RCTConvert NSArray:obj[@"attachments"]];
        for(id attachment in attachmentObj) {
            if ([attachment objectForKey:@"uniqueId"])
                continue;
            
            NSURL *documentsURL = [NSURL URLWithString:attachment[@"uri"]];
            NSData *fileData = [NSData dataWithContentsOfURL:documentsURL];
            MCOAttachment *attach = [MCOAttachment attachmentWithData:fileData filename:attachment[@"filename"]];
            [messageBuilder addAttachment:attach];
        }
    }
    
    if([obj objectForKey:@"original_id"] == [NSNull null]) {
        [self sendEmail:messageBuilder reject:reject resolve:resolve];
    } else {
        // this should only occur during a mail forward
        NSNumber *original_id = [RCTConvert NSNumber:obj[@"original_id"]];
        NSString *original_folder = [RCTConvert NSString:obj[@"original_folder"]];
        
        MCOIMAPFetchContentOperation * fetchOriginalMessageOperation = [_imapSession fetchMessageOperationWithFolder:original_folder uid:original_id.unsignedLongLongValue];
        [fetchOriginalMessageOperation start:^(NSError * error, NSData * messageData) {
            if (!messageData) {
                reject(@"Error", error.localizedDescription, error);
                return;
            }
            MCOMessageParser * parser = [MCOMessageParser messageParserWithData:messageData];
            
            // https://github.com/MailCore/mailcore2/blob/master/src/core/abstract/MCMessageHeader.cpp#L1197
            if (parser.header.messageID) {
                messageBuilder.header.inReplyTo = @[parser.header.messageID];
            }
            
            NSMutableArray *newReferences = [NSMutableArray arrayWithArray:parser.header.references];
            if (parser.header.messageID) {
                [newReferences addObject:parser.header.messageID];
            }
            messageBuilder.header.references = newReferences;
            
            // set original attachments if they were any left
            if([obj objectForKey:@"attachments"]) {
                NSArray *attachmentObj = [RCTConvert NSArray:obj[@"attachments"]];
                for(id attachment in attachmentObj) {
                    if ([attachment objectForKey:@"uniqueId"] == nil)
                        continue;
                    
                    for (MCOAttachment *original_attachment in parser.attachments) {
                        if (original_attachment.uniqueID != attachment[@"uniqueId"])
                            continue;
                        
                        [messageBuilder addAttachment:original_attachment];
                    }
                }
            }
            
            [self sendEmail:messageBuilder reject:reject resolve:resolve];
        }];
    }
}

RCT_EXPORT_METHOD(getMail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    int requestKind = [RCTConvert int:obj[@"requestKind"]];
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [_imapSession fetchMessagesOperationWithFolder:folder requestKind:requestKind uids:uid];
    
    NSArray *extraHeadersRequest = [RCTConvert NSArray:obj[@"headers"]];
    if (extraHeadersRequest != nil && extraHeadersRequest.count > 0) {
        [fetchOperation setExtraHeaders:extraHeadersRequest];
    }
    
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages)
     {
         if(error) {
             reject(@"Error", error.localizedDescription, error);
         } else {
             MCOIMAPMessage *message = fetchedMessages[0];
             NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
             NSString *messageUid = [NSString stringWithFormat:@"%d",message.uid];
             [result setValue:messageUid forKey:@"id"];
             int flags = message.flags;
             [result setObject:[NSString stringWithFormat:@"%d",flags] forKey:@"flags"];
             //mailData.putString("date", message.header().date().toString());
             
             NSMutableDictionary *fromData = [[NSMutableDictionary alloc] init];
             [fromData setValue:message.header.from.mailbox forKey:@"mailbox"];
             [fromData setValue:message.header.from.displayName forKey:@"displayName"];
             [result setObject:fromData forKey:@"from"];
             
             if(message.header.cc != nil) {
                 NSMutableDictionary *toData = [[NSMutableDictionary alloc] init];
                 for(MCOAddress *toAddress in message.header.to) {
                     [toData setValue:[toAddress displayName] forKey:[toAddress mailbox]];
                 }
                 [result setObject:toData forKey:@"to"];
             }
             
             if(message.header.cc != nil) {
                 NSMutableDictionary *ccData = [[NSMutableDictionary alloc] init];
                 for(MCOAddress *ccAddress in message.header.cc) {
                     [ccData setValue:[ccAddress displayName] forKey:[ccAddress mailbox]];
                 }
                 [result setObject:ccData forKey:@"cc"];
             }
             
             if(message.header.bcc != nil) {
                 NSMutableDictionary *bccData = [[NSMutableDictionary alloc] init];
                 for(MCOAddress *bccAddress in message.header.bcc) {
                     [bccData setValue:[bccAddress displayName] forKey:[bccAddress mailbox]];
                 }
                 [result setObject:bccData forKey:@"bcc"];
             }
             
             [result setValue:message.header.subject forKey:@"subject"];
             
             if ([message.attachments count] > 0){
                 NSMutableDictionary *attachmentsData = [[NSMutableDictionary alloc] init];
                 for(MCOIMAPPart *part in message.attachments) {
                     NSMutableDictionary *attachmentData = [[NSMutableDictionary alloc] init];
                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                     NSString *saveDirectory = [paths objectAtIndex:0];
                     NSString *attachmentPath = [saveDirectory stringByAppendingPathComponent:part.filename];
                     int encod = part.encoding;
                     int size = part.size;
                     NSString *sizeS = [NSString stringWithFormat:@"%d",size];
                     [attachmentData setValue:attachmentPath forKey:@"filename"];
                     [attachmentData setValue:sizeS forKey:@"size"];
                     [attachmentData setValue:[NSString stringWithFormat:@"%d",encod] forKey:@"encoding"];
                     [attachmentData setValue:part.uniqueID forKey:@"uniqueId"];
                     
                     [attachmentsData setObject:attachmentData forKey:part.partID];
                 }
                 [result setObject:attachmentsData forKey:@"attachments"];
             }
             
             NSMutableArray *headers = [[NSMutableArray alloc] init];
             NSArray *extraHeaderNames = [message.header allExtraHeadersNames];
             NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
             [header setValue:[NSString stringWithFormat:@"%llu", message.gmailMessageID] forKey:@"gmailMessageID"];
             [headers addObject:header];
             NSMutableDictionary *header2 = [[NSMutableDictionary alloc] init];
             [header2 setValue:[NSString stringWithFormat:@"%llu", message.gmailThreadID] forKey:@"gmailThreadID"];
             [headers addObject:header2];
             if (extraHeaderNames != nil && extraHeaderNames.count > 0){
                 for(NSString *headerKey in extraHeaderNames) {
                     NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
                     [header setObject:[message.header extraHeaderValueForName:headerKey] forKey:headerKey];
                     [headers addObject:header];
                 }
             }
             [result setObject: headers forKey: @"headers"];
             
             MCOIMAPFetchContentOperation *operation = [_imapSession fetchMessageOperationWithFolder:folder uid:message.uid];
             [operation start:^(NSError *error, NSData *data) {
                 if(error) {
                     reject(@"Error", error.localizedDescription, error);
                 } else {
                     NSString *inlineData = [NSString stringWithFormat:@"data:image/jpg;base64,%@",
                                             [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
                     MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
                     NSString *msgHTMLBody = [messageParser htmlBodyRendering];
                     NSArray *inlineAttachments = [messageParser htmlInlineAttachments];
                     NSMutableArray *inlines = [[NSMutableArray alloc] init];
                     for(MCOAttachment *inlineAttachment in inlineAttachments) {
                         NSMutableDictionary *inlinesObject = [[NSMutableDictionary alloc] init];
                         [inlinesObject setObject:[NSString stringWithFormat:@"data:%@;base64,%@",inlineAttachment.mimeType,[inlineAttachment.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]] forKey:@"data"];
                         [inlinesObject setObject:[NSString stringWithFormat:@"%@",inlineAttachment.contentID] forKey:@"cid"];
                         [inlines addObject:inlinesObject];
                     }
                     
                     [result setValue:msgHTMLBody forKey:@"body"];
                     [result setObject:inlines forKey:@"inline"];
                     [result setValue:@"SUCCESS" forKey:@"status"];
                     resolve(result);
                 }
             }];
         }
     }];
}

RCT_EXPORT_METHOD(getMails:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    int requestKind = [RCTConvert int:obj[@"requestKind"]];
    NSString *lastUId = [RCTConvert NSString:obj[@"threadId"] ? : nil];
    if(lastUId == nil) {
        MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
        MCOIMAPFetchMessagesOperation * fetchMessagesOperationWithFolderOperation = [_imapSession fetchMessagesOperationWithFolder:folder
                                                                                                                      requestKind:requestKind uids:uids];
        
        NSArray *extraHeadersRequest = [RCTConvert NSArray:obj[@"headers"]];
        if (extraHeadersRequest != nil && extraHeadersRequest.count > 0) {
            [fetchMessagesOperationWithFolderOperation setExtraHeaders:extraHeadersRequest];
        }
        
        [fetchMessagesOperationWithFolderOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
            if(error) {
                reject(@"Error", error.localizedDescription, error);
            } else {
                
                NSMutableArray *mails = [[NSMutableArray alloc] init];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                
                for(MCOIMAPMessage * message in messages) {
                    NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
                    
                    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
                    NSArray *extraHeaderNames = [message.header allExtraHeadersNames];
                    
                    [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailMessageID] forKey:@"gmailMessageID"];
                    [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailThreadID] forKey:@"gmailThreadID"];
                    if (extraHeaderNames != nil && extraHeaderNames.count > 0){
                        for(NSString *headerKey in extraHeaderNames) {
                            [headers setObject:[message.header extraHeaderValueForName:headerKey] forKey:headerKey];
                        }
                    }
                    [mail setObject: headers forKey: @"headers"];
                    
                    [mail setObject:[NSString stringWithFormat:@"%d",[message uid]] forKey:@"id"];
                    int flags = message.flags;
                    [mail setObject:[NSString stringWithFormat:@"%d",flags] forKey:@"flags"];
                    [mail setObject:message.header.from.displayName ? : @"" forKey:@"from"];
                    [mail setObject:message.header.subject forKey:@"subject"];
                    [mail setObject:[dateFormat stringFromDate:message.header.date] forKey:@"date"];
                    if (message.attachments != nil) {
                        [mail setObject:[NSString stringWithFormat:@"%lu", message.attachments.count] forKey:@"attachments"];
                    } else {
                        [mail setObject:[NSString stringWithFormat:@"%d",0] forKey:@"attachments"];
                    }
                    [mails addObject:mail];
                }
                
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                [result setObject: @"SUCCESS" forKey: @"status"];
                [result setObject: mails forKey: @"mails"];
                resolve(result);
            }
        }];
    }
    else
    {
        long *testLong = [lastUId longLongValue];
        MCOIMAPSearchOperation *op = [_imapSession searchExpressionOperationWithFolder:folder expression:[MCOIMAPSearchExpression searchGmailThreadID:testLong]];
        [op start:^(NSError * _Nullable error, MCOIndexSet * _Nullable searchResult) {
            if(error) {
                reject(@"Error", error.localizedDescription, error);
            }
            
            MCOIMAPSearchOperation *uids = searchResult;
            MCOIMAPFetchMessagesOperation * fetchMessagesOperationWithFolderOperation = [_imapSession fetchMessagesOperationWithFolder:folder
                                                                                                                          requestKind:requestKind uids:uids];
            [fetchMessagesOperationWithFolderOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
                if(error) {
                    reject(@"Error", error.localizedDescription, error);
                } else {
                    
                    NSMutableArray *mails = [[NSMutableArray alloc] init];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                    
                    for(MCOIMAPMessage * message in messages) {
                        NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
                        
                        NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
                        NSArray *extraHeaderNames = [message.header allExtraHeadersNames];
                        NSMutableDictionary *headerGmailId = [[NSMutableDictionary alloc] init];
                        [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailMessageID] forKey:@"gmailMessageID"];
                        [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailThreadID] forKey:@"gmailThreadID"];
                        if (extraHeaderNames != nil && extraHeaderNames.count > 0){
                            for(NSString *headerKey in extraHeaderNames) {
                                
                                [headers setObject:[message.header extraHeaderValueForName:headerKey] forKey:headerKey];
                                
                            }
                        }
                        [mail setObject: headers forKey: @"headers"];
                        
                        [mail setObject:[NSString stringWithFormat:@"%d",[message uid]] forKey:@"id"];
                        int flags = message.flags;
                        [mail setObject:[NSString stringWithFormat:@"%d",flags] forKey:@"flags"];
                        [mail setObject:message.header.from.displayName ? : @"" forKey:@"from"];
                        [mail setObject:message.header.subject forKey:@"subject"];
                        [mail setObject:[dateFormat stringFromDate:message.header.date] forKey:@"date"];
                        if (message.attachments != nil) {
                            [mail setObject:[NSString stringWithFormat:@"%lu", message.attachments.count] forKey:@"attachments"];
                        } else {
                            [mail setObject:[NSString stringWithFormat:@"%d",0] forKey:@"attachments"];
                        }
                        [mails addObject:mail];
                    }
                    
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    [result setObject: @"SUCCESS" forKey: @"status"];
                    [result setObject: mails forKey: @"mails"];
                    resolve(result);
                }
            }];
            
        }];
        
    }
}



RCT_EXPORT_METHOD(getMailsThread:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    int requestKind = [RCTConvert int:obj[@"requestKind"]];
    //int lastUId = [RCTConvert int:obj[@"lastUId"] ? : 1];
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    MCOIMAPFetchMessagesOperation * fetchMessagesOperationWithFolderOperation = [_imapSession fetchMessagesOperationWithFolder:folder
                                                                                                                  requestKind:requestKind uids:uids];
    
    NSArray *extraHeadersRequest = [RCTConvert NSArray:obj[@"headers"]];
    if (extraHeadersRequest != nil && extraHeadersRequest.count > 0) {
        [fetchMessagesOperationWithFolderOperation setExtraHeaders:extraHeadersRequest];
    }
    
    [fetchMessagesOperationWithFolderOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            
            NSMutableArray *mails = [[NSMutableArray alloc] init];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            NSArray* reversedArray = [[messages reverseObjectEnumerator] allObjects];
            NSMutableArray * listThreads = [[NSMutableArray alloc] init];
            
            for(MCOIMAPMessage * message in reversedArray) {
                if([listThreads indexOfObject:message.header.messageID] == NSNotFound) {
                    [listThreads addObject:message.header.messageID];
                    NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
                    
                    if(message.header.references != nil) {
                        for(NSString *refs in message.header.references) {
                            [listThreads addObject:refs];
                        }
                        [mail setObject:[NSNumber numberWithInt:message.header.references.count] forKey:@"thread"];
                    }
                    
                    
                    NSArray *extraHeaderNames = [message.header allExtraHeadersNames];
                    
                    [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailMessageID] forKey:@"gmailMessageID"];
                    [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailThreadID] forKey:@"gmailThreadID"];
                    if (extraHeaderNames != nil && extraHeaderNames.count > 0){
                        for(NSString *headerKey in extraHeaderNames) {
                            
                            [headers setObject:[message.header extraHeaderValueForName:headerKey] forKey:headerKey];
                            
                        }
                    }
                    [mail setObject: headers forKey: @"headers"];
                    
                    [mail setObject:[NSString stringWithFormat:@"%d",[message uid]] forKey:@"id"];
                    int flags = message.flags;
                    [mail setObject:[NSString stringWithFormat:@"%d",flags] forKey:@"flags"];
                    [mail setObject:message.header.from.displayName ? : @"" forKey:@"from"];
                    [mail setObject:message.header.subject forKey:@"subject"];
                    [mail setObject:[dateFormat stringFromDate:message.header.date] forKey:@"date"];
                    if (message.attachments != nil) {
                        [mail setObject:[NSString stringWithFormat:@"%lu", message.attachments.count] forKey:@"attachments"];
                    } else {
                        [mail setObject:[NSString stringWithFormat:@"%d",0] forKey:@"attachments"];
                    }
                    [mails addObject:mail];
                }
            }
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setObject: @"SUCCESS" forKey: @"status"];
            [result setObject: mails forKey: @"mails"];
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(getAttachment:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *filename = [RCTConvert NSString:obj[@"filename"]];
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    NSNumber *messageId = [RCTConvert NSNumber:obj[@"messageId"]];
    unsigned long long valueUInt64 = messageId.unsignedLongLongValue;
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:valueUInt64];
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindFlags;
    MCOIMAPFetchMessagesOperation *fetchOperation = [_imapSession fetchMessagesOperationWithFolder:folder requestKind:requestKind uids:uid];
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            MCOIMAPMessage *message = [fetchedMessages objectAtIndex:0];
            MCOIMAPFetchContentOperation *op = [_imapSession fetchMessageOperationWithFolder:folder uid:message.uid];
            [op start:^(NSError * error, NSData * data) {
                if(error || !data) {
                    reject(@"Error", error.localizedDescription, error);
                }
                
                
                if ([message.attachments count] > 0)
                {
                    for (int k = 0; k < [message.attachments count]; k++) {
                        MCOIMAPPart *part = [message.attachments objectAtIndex:k];
                        if([part.filename isEqualToString:filename]) {
                            
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *saveDirectory = [paths objectAtIndex:0];
                            NSString *attachmentPath = [saveDirectory stringByAppendingPathComponent:part.filename];
                            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                            [result setValue:attachmentPath forKey:@"url"];
                            MCOIMAPFetchContentOperation * op = [_imapSession fetchMessageAttachmentOperationWithFolder:folder
                                                                                                                   uid:message.uid
                                                                                                                partID:part.partID
                                                                                                              encoding:part.encoding];
                            
                            [op start:^(NSError * error, NSData * messageData) {
                                if (error) {
                                    [result setObject:@"ERROR" forKey:@"status"];
                                    resolve(result);
                                }else{
                                    [result setObject:@"FILE SAVE WITH SUCCESS!" forKey:@"status"];
                                    [messageData writeToFile:attachmentPath atomically:YES];
                                    resolve(result);
                                }
                            }];
                        }
                        
                    }
                } else {
                    NSDictionary *result = @{@"status": @"Could not be found!"};
                    resolve(result);
                }
            }];
        }
    }];
}

RCT_EXPORT_METHOD(statusFolder:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    [[_imapSession folderStatusOperation:folder] start:^(NSError * _Nullable error, MCOIMAPFolderStatus * _Nullable status) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
        } else {
            NSDictionary *result = @{
                                     @"status": @"SUCCESS",
                                     @"unseenCount": [NSNumber numberWithInt:status.unseenCount],
                                     @"messageCount": [NSNumber numberWithInt:status.messageCount],
                                     @"recentCount": [NSNumber numberWithInt:status.recentCount]
                                     };
            resolve(result);
        }
    }];
}

RCT_EXPORT_METHOD(getMailsByRange:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // HOW TO USE:
    // https://github.com/MailCore/mailcore2/blob/aaddeaf20e520d66d8a9821fde9fb09ed77d4526/example/ios/iOS%20UI%20Test/iOS%20UI%20Test/MasterViewController.m#L190
    
    // Get arguments
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    int requestKind = [RCTConvert int:obj[@"requestKind"]];
    int from = [RCTConvert int:obj[@"from"]];
    int length = [RCTConvert int:obj[@"length"]];;
    
    // Build operation
    MCOIndexSet *fetchRange = [MCOIndexSet indexSetWithRange:MCORangeMake(from, length)];
    MCOIMAPFetchMessagesOperation *operation = [_imapSession
                                                fetchMessagesByNumberOperationWithFolder:folder
                                                requestKind:requestKind
                                                numbers:fetchRange];
    
    NSArray *extraHeadersRequest = [RCTConvert NSArray:obj[@"headers"]];
    if (extraHeadersRequest != nil && extraHeadersRequest.count > 0) {
        [operation setExtraHeaders:extraHeadersRequest];
    }
    
    // Start operation
    [operation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        [self parseMessages:error messages:messages reject:reject resolve:resolve];
    }];
}

RCT_EXPORT_METHOD(getMailsByThread:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *folder = [RCTConvert NSString:obj[@"folder"]];
    int requestKind = [RCTConvert int:obj[@"requestKind"]];
    NSString *threadUID = [RCTConvert NSString:obj[@"threadId"]];
    
    MCOIMAPSearchOperation *searchOperation = [_imapSession
                                               searchExpressionOperationWithFolder:folder
                                               expression:[MCOIMAPSearchExpression searchGmailThreadID:[threadUID longLongValue]]];
    
    [searchOperation start:^(NSError * _Nullable error, MCOIndexSet * _Nullable searchResult) {
        if(error) {
            reject(@"Error", error.localizedDescription, error);
            return;
        }
        
        MCOIMAPFetchMessagesOperation * fetchMessagesFromFolderOperation = [_imapSession
                                                                            fetchMessagesOperationWithFolder:folder
                                                                            requestKind:requestKind uids:searchResult];
        
        NSArray *extraHeadersRequest = [RCTConvert NSArray:obj[@"headers"]];
        if (extraHeadersRequest != nil && extraHeadersRequest.count > 0) {
            [fetchMessagesFromFolderOperation setExtraHeaders:extraHeadersRequest];
        }
        
        [fetchMessagesFromFolderOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
            [self parseMessages:error messages:messages reject:reject resolve:resolve];
        }];
        
    }];
}

- (void)parseMessages:(NSError *)error messages:(NSArray *)messages reject:(RCTPromiseRejectBlock)reject resolve:(RCTPromiseResolveBlock)resolve {
    if(error) {
        reject(@"Error", error.localizedDescription, error);
    } else {
        // Setup dateFormat
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        
        // Process fetched mails
        NSMutableArray *mails = [[NSMutableArray alloc] init];
        for(MCOIMAPMessage * message in messages) {
            
            // Process fetched headers from mail
            NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
            [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailMessageID] forKey:@"gmailMessageID"];
            [headers setObject:[NSString stringWithFormat:@"%llu", message.gmailThreadID] forKey:@"gmailThreadID"];
            
            NSArray *extraHeaderNames = [message.header allExtraHeadersNames];
            if (extraHeaderNames != nil && extraHeaderNames.count > 0){
                for(NSString *headerKey in extraHeaderNames) {
                    [headers setObject:[message.header extraHeaderValueForName:headerKey] forKey:headerKey];
                }
            }
            
            // Process fetched data from mail
            NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
            [mail setObject: headers forKey: @"headers"];
            [mail setObject:[NSString stringWithFormat:@"%d",[message uid]] forKey:@"id"];
            [mail setObject:[NSString stringWithFormat:@"%d",(int)message.flags] forKey:@"flags"];
            [mail setObject:message.header.from.displayName ? : @"" forKey:@"from"];
            [mail setObject:message.header.subject forKey:@"subject"];
            [mail setObject:[dateFormat stringFromDate:message.header.date] forKey:@"date"];
            if (message.attachments != nil) {
                [mail setObject:[NSString stringWithFormat:@"%lu", message.attachments.count] forKey:@"attachments"];
            } else {
                [mail setObject:[NSString stringWithFormat:@"%d",0] forKey:@"attachments"];
            }
            
            // Append mail to mails result
            [mails addObject:mail];
        }
        
        // Return mails
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        [result setObject: @"SUCCESS" forKey: @"status"];
        [result setObject: mails forKey: @"mails"];
        resolve(result);
    }
}


- (instancetype)initSmtp:(MCOSMTPSession *)smtpObject {
    self = [super init];
    if (self) {
        _smtpObject = smtpObject;
    }
    return self;
}


- (MCOSMTPSession *)getSmtpObject {
    return _smtpObject;
}

- (instancetype)initImap:(MCOIMAPSession *)imapObject {
    self = [super init];
    if (self) {
        _imapSession = imapObject;
    }
    return self;
}

- (MCOIMAPSession *)getImapObject {
    return _imapSession;
}

@end
