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

#pragma mark - Account API

- (void)getAccountSummaryWithSuccess:(void (^)(id responseObject))success
                             failure:(void (^)(NSError *error))failure;
#pragma mark - Group API

- (void)addUser:(NSString *)userName
        toGroup:(NSString *)groupName
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)createGroup:(NSString *)groupName
               path:(NSString *)path
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

- (void)deleteGroup:(NSString *)groupName
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

- (void)getGroup:(NSString *)groupName
          marker:(NSString *)marker
        maxItems:(NSUInteger)maxItems
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;

- (void)listGroupsWithPrefix:(NSString *)pathPrefix
                      marker:(NSString *)marker
                    maxItems:(NSUInteger)maxItems
                     Success:(void (^)(id responseObject))success
                     failure:(void (^)(NSError *error))failure;

- (void)listGroupsForUser:(NSString *)userName
                   marker:(NSString *)marker
                 maxItems:(NSUInteger)maxItems
                  Success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure;

- (void)removeUser:(NSString *)userName
         fromGroup:(NSString *)groupName
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

#pragma mark - Role API

- (void)createRole:(NSString *)roleName
              path:(NSString *)path
            policy:(NSDictionary *)policyInfo
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)deleteRole:(NSString *)roleName
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)getRole:(NSString *)roleName
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

#pragma mark - User API

- (void)createUser:(NSString *)userName
              path:(NSString *)path
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)deleteUser:(NSString *)userName
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

- (void)getUser:(NSString *)userName
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)listUsersWithPrefix:(NSString *)pathPrefix
                     marker:(NSString *)marker
                   maxItems:(NSUInteger)maxItems
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

#pragma mark - Policy API

- (void)deletePolicy:(NSString *)policyName
           fromGroup:(NSString *)groupName
             success:(void (^)(id responseObject))success
             failure:(void (^)(NSError *error))failure;

- (void)deletePolicy:(NSString *)policyName
            fromRole:(NSString *)roleName
             success:(void (^)(id responseObject))success
             failure:(void (^)(NSError *error))failure;

- (void)getPolicy:(NSString *)policyName
         forGroup:(NSString *)groupName
          success:(void (^)(id responseObject))success
          failure:(void (^)(NSError *error))failure;

- (void)getPolicy:(NSString *)policyName
          forRole:(NSString *)roleName
          success:(void (^)(id responseObject))success
          failure:(void (^)(NSError *error))failure;

- (void)getPolicy:(NSString *)policyName
          forUser:(NSString *)userName
          success:(void (^)(id responseObject))success
          failure:(void (^)(NSError *error))failure;

- (void)listRolesWithPrefix:(NSString *)pathPrefix
                     marker:(NSString *)marker
                   maxItems:(NSUInteger)maxItems
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

- (void)applyPolicy:(NSString *)policyName
            toGroup:(NSString *)groupName
             policy:(NSDictionary *)policyInfo
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

- (void)applyPolicy:(NSString *)policyName
             toUser:(NSString *)userName
             policy:(NSDictionary *)policyInfo
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

@end