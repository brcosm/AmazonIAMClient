//
//  TGAmazonIAMClient.h
//  TGAmazonIAMClient
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TGAmazonIAMClient : AFHTTPClient

- (id)initWithAccessKeyID:(NSString *)accessKey
                   secret:(NSString *)secret;

- (void)getAccountSummaryWithSuccess:(void (^)(id responseObject))success
                             failure:(void (^)(NSError *error))failure;

@end