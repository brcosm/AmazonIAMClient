//
//  TGAmazonIAMClient.h
//  TGAmazonIAMClient
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TGAmazonIAMClient : AFHTTPClient

@property (nonatomic, copy) NSString *apiVersion;

- (id)initWithAccessKeyID:(NSString *)accessKey
                   secret:(NSString *)secret;

- (void)getAccountSummaryWithSuccess:(void (^)(id responseObject))success
                             failure:(void (^)(NSError *error))failure;

- (void)addUser:(NSString *)userName
        toGroup:(NSString *)groupName
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)createGroup:(NSString *)groupName
               path:(NSString *)path
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

- (void)createRole:(NSString *)roleName
              path:(NSString *)path
            policy:(NSDictionary *)policyInfo
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)createUser:(NSString *)userName
              path:(NSString *)path
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)deleteGroup:(NSString *)groupName
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

- (void)deletePolicy:(NSString *)policyName
           fromGroup:(NSString *)groupName
             success:(void (^)(id responseObject))success
             failure:(void (^)(NSError *error))failure;

- (void)deleteRole:(NSString *)roleName
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;
@end