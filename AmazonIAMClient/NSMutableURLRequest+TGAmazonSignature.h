//
//  NSMutableURLRequest=TGAmazonSignature.h
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

@interface NSMutableURLRequest (TGAmazonSignature)

- (NSMutableURLRequest *)signedCopyWithAccessKey:(NSString *)access secret:(NSString *)secret region:(NSString *)region service:(NSString *)service;

@end
