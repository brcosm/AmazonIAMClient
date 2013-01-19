//
//  TGAmazonIAMClient.m
//  TGAmazonIAMClient
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

#import "TGAmazonIAMClient.h"
#import "AFKissXMLRequestOperation.h"
#import "NSMutableURLRequest+TGAmazonSignature.h"

typedef void (^SuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^FailureBlock)(AFHTTPRequestOperation *, NSError *);

NSString * const kTGAmazonIAMBaseURLString = @"https://iam.amazonaws.com";
NSString * const kTGAmazonIAMDefaulVersion = @"2010-05-08";

@interface TGAmazonIAMClient (/* Private */)
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secret;

@end

@implementation TGAmazonIAMClient

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFKissXMLRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"text/xml"];
        [self setDefaultHeader:@"Accept-Language" value:nil];
        [self setDefaultHeader:@"x-amz-algorithm" value:@"AWS4-HMAC-SHA256"];
        [self setDefaultHeader:@"host" value:@"iam.amazonaws.com"];
    }
    return self;
}

- (id)initWithAccessKeyID:(NSString *)accessKey secret:(NSString *)secret {
    self = [self initWithBaseURL:[NSURL URLWithString:kTGAmazonIAMBaseURLString]];
    if (self) {
        self.accessKey = accessKey;
        self.secret = secret;
        self.apiVersion = kTGAmazonIAMDefaulVersion;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *versionedParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [versionedParams addEntriesFromDictionary:@{@"Version" : self.apiVersion}];
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:versionedParams];
    if ([request respondsToSelector:@selector(signedCopyWithAccessKey:secret:region:service:)]) {
        request = [request signedCopyWithAccessKey:self.accessKey secret:self.secret region:@"us-east-1" service:@"iam"];
    }
    return request;
}

- (void)enqueueIAMRequestWithMethod:(NSString *)method
                               path:(NSString *)path
                         parameters:(NSDictionary *)parameters
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure
{
    SuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    };
    FailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    AFHTTPRequestOperation *requestOperation =
    [self HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];
    [self enqueueHTTPRequestOperation:requestOperation];
}

#pragma mark - API

- (void)getAccountSummaryWithSuccess:(void (^)(id responseObject))success
                             failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"Action" : @"GetAccountSummary" };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)addUser:(NSString *)userName
        toGroup:(NSString *)groupName
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"Action"    : @"AddUserToGroup",
                              @"GroupName" : groupName,
                              @"UserName"  : userName };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)createGroup:(NSString *)groupName
               path:(NSString *)path
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure
{
    NSString *defaultPath = path ? path : @"/";
    NSDictionary *params = @{ @"Action"    : @"CreateGroup",
                              @"GroupName" : groupName,
                              @"Path"      : defaultPath };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)createRole:(NSString *)roleName
              path:(NSString *)path
            policy:(NSDictionary *)policyInfo
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure
{
    NSString *defaultPath = path ? path : @"/";
    NSData *policyData = [NSJSONSerialization dataWithJSONObject:policyInfo options:0 error:nil];
    NSString *policyString = [[NSString alloc] initWithData:policyData encoding:NSUTF8StringEncoding];
    NSDictionary *params = @{ @"Action"                   : @"CreateRole",
                              @"RoleName"                 : roleName,
                              @"Path"                     : defaultPath,
                              @"AssumeRolePolicyDocument" : policyString };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)createUser:(NSString *)userName
              path:(NSString *)path
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure
{
    NSString *defaultPath = path ? path : @"/";
    NSDictionary *params = @{ @"Action"   : @"CreateUser",
                              @"UserName" : userName,
                              @"Path"     : defaultPath };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)deleteGroup:(NSString *)groupName
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"Action" : @"DeleteGroup",
                              @"GroupName" : groupName };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)deletePolicy:(NSString *)policyName
           fromGroup:(NSString *)groupName
             success:(void (^)(id responseObject))success
             failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"Action" : @"DelegeGroupPolicy",
                              @"GroupName" : groupName,
                              @"PolicyName" : policyName };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

- (void)deleteRole:(NSString *)roleName
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"Action"   : @"DeleteRole",
                              @"RoleName" : roleName };
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

@end
