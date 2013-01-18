//
//  TGAmazonIAMClient.m
//  TGAmazonIAMClient
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

#import "TGAmazonIAMClient.h"
#import "AFKissXMLRequestOperation.h"
#import "TGAmazonV4Signer.h"

typedef void (^SuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^FailureBlock)(AFHTTPRequestOperation *, NSError *);

NSString * const kTGAmazonIAMBaseURLString = @"https://iam.amazonaws.com";

@interface TGAmazonIAMClient (/* Private */)
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, readonly, copy) NSString *signerClassName;
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
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
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
    NSDictionary *params = @{@"Action" : @"GetAccountSummary", @"Version" : @"2010-05-08"};
    [self enqueueIAMRequestWithMethod:@"GET" path:@"/" parameters:params success:success failure:failure];
}

@end
