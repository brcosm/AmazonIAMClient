//
//  NSMutableURLRequest+TGAmazonSignature.m
//  TGAmazonV4Signer
//
//  Created by Smith, Brandon on 1/16/13.
//  Copyright (c) 2013 Smith, Brandon. All rights reserved.
//

#import "NSMutableURLRequest+TGAmazonSignature.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString * const kTGAmazonDateStampFormat = @"yyyyMMdd";
static NSString * const kTGAmazonDateTimeFormat  = @"yyyyMMdd'T'HHmmss'Z'";
static NSString * const kTGAmazonV4SignatureDesc = @"AWS4-HMAC-SHA256";

@implementation NSDate(TGAmazonDateUtil)

- (NSString *)tg_dateStamp {
    static NSDateFormatter *_dateStampFormatter;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _dateStampFormatter = [[NSDateFormatter alloc] init];
        _dateStampFormatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateStampFormatter.timeZone   = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        _dateStampFormatter.dateFormat = kTGAmazonDateStampFormat;
    });
    return [_dateStampFormatter stringFromDate:self];
}

- (NSString *)tg_dateTime {
    static NSDateFormatter *_dateTimeFormatter;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        _dateTimeFormatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateTimeFormatter.timeZone   = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        _dateTimeFormatter.dateFormat = kTGAmazonDateTimeFormat;
    });
    return [_dateTimeFormatter stringFromDate:self];
}

@end

@implementation NSData(TGAmazonDataUtil)

- (NSData *)tg_SHA256Hash {
    uint8_t hash[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(self.bytes, self.length, hash);
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)tg_SHA256Hash:(NSData *)key {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA256, key.bytes, key.length);
    CCHmacUpdate(&hmacContext, self.bytes, self.length);
    CCHmacFinal(&hmacContext, digest);
    NSData *hash = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return hash;
}

- (NSString *)tg_hexEncodedString {
    NSMutableString *hexString = [NSMutableString stringWithCapacity:self.length*2];
    const char *bytes = self.bytes;
    for (int i = 0; i < self.length; i++) {
        [hexString appendFormat:@"%02x", (unsigned char)bytes[i]];
    }
    return hexString;
}

@end

@implementation NSString(TGAmazonStringUtil)

- (NSString *)tg_hexEncodedString {
    return [[[self dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash] tg_hexEncodedString];
}

- (NSString *)tg_urlEncodedString {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
}

@end

@implementation NSMutableURLRequest(TGAmazonRequestUtil)

- (NSString *)tg_canonicalPath {
    return self.URL.path.length == 0 ? @"/" : [self.URL.path stringByStandardizingPath];
}

- (NSString *)tg_canonicalQueryString {
    NSString *urlString = @"";
    NSArray *params = [self.URL.query componentsSeparatedByString:@"&"];
    if (params.count > 0) {
        NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
        for (NSString *param in params) {
            NSArray *paramSet = [param componentsSeparatedByString:@"="];
            NSMutableArray *vals = [NSMutableArray array];
            if ([paramDictionary objectForKey:[paramSet objectAtIndex:0]]) {
                vals = [paramDictionary objectForKey:[paramSet objectAtIndex:0]];
            }
            if (paramSet.count > 1) {
                [vals addObject:[paramSet objectAtIndex:1]];
            } else {
                [vals addObject:@""];
            }
            [paramDictionary setObject:vals forKey:[paramSet objectAtIndex:0]];
        }
        NSMutableString *newString = [NSMutableString string];
        int i = [[paramDictionary allKeys] count];
        NSArray *sortedKeys = [[paramDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a compare:b options:NSLiteralSearch];
        }];
        for (NSString *key in sortedKeys) {
            NSArray *vals =
            [[paramDictionary valueForKey:key] sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
                return [a compare:b options:NSLiteralSearch];
            }];
            for (NSString *val in vals) {
                // AFNetworking URL encoding does not encode commas
                [newString appendFormat:@"%@=%@", key , [val stringByReplacingOccurrencesOfString:@"," withString:@"%2C"]];
                if (val != [vals lastObject]) {
                    [newString appendFormat:@"&"];
                }
            }
            --i > 0 ? [newString appendFormat:@"&"] : nil;
        }
        urlString = [NSString stringWithString:newString];
    }
    return urlString;
}

- (NSString *)tg_canonicalHeaderString {
    NSMutableArray *sortedHeaders = [NSMutableArray arrayWithArray:self.allHTTPHeaderFields.allKeys];
    [sortedHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *headerString = [NSMutableString string];
    for (NSString *header in sortedHeaders) {
        [headerString appendString:[header lowercaseString]];
        [headerString appendString:@":"];
        [headerString appendString:[self.allHTTPHeaderFields valueForKey:header]];
        [headerString appendString:@"\n"];
    }
    
    NSCharacterSet *whitespaceChars = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings     = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [headerString componentsSeparatedByCharactersInSet:whitespaceChars];
    NSArray *nonWhitespace = [parts filteredArrayUsingPredicate:noEmptyStrings];
    return [nonWhitespace componentsJoinedByString:@" "];
}

- (NSString *)tg_headerSignature {
    NSMutableArray *sortedHeaders = [NSMutableArray arrayWithArray:self.allHTTPHeaderFields.allKeys];
    [sortedHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *headerString = [NSMutableString string];
    for (NSString *header in sortedHeaders) {
        if ([headerString length] > 0) {
            [headerString appendString:@";"];
        }
        [headerString appendString:[header lowercaseString]];
    }
    return headerString;
}

- (NSString *)tg_payloadHash {
    NSData *payload = self.HTTPBody ? self.HTTPBody : [@"" dataUsingEncoding:NSUTF8StringEncoding];
    return [[payload tg_SHA256Hash] tg_hexEncodedString];
}

- (NSString *)tg_canonicalRequestString {
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",
            [self HTTPMethod],
            [self tg_canonicalPath],
            [self tg_canonicalQueryString],
            [self tg_canonicalHeaderString],
            [self tg_headerSignature],
            [self tg_payloadHash]];
}

- (NSMutableURLRequest *)signedCopyWithAccessKey:(NSString *)access
                                          secret:(NSString *)secret
                                          region:(NSString *)region
                                         service:(NSString *)service {
    NSDate *date        = [NSDate date];
    NSString *dateStamp = [date tg_dateStamp];
    NSString *dateTime  = [date tg_dateTime];
    
    NSMutableURLRequest *signedRequest = [self copy];
    [signedRequest setValue:dateTime forHTTPHeaderField:@"X-Amz-Date"];
    
    NSString *canonicalRequest = [signedRequest tg_canonicalRequestString];
    
    NSString *scope = [NSString stringWithFormat:@"%@/%@/%@/%@", dateStamp, region, service, @"aws4_request"];
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", kTGAmazonV4SignatureDesc, dateTime, scope, [canonicalRequest tg_hexEncodedString]];
    
    NSData *key           = [[NSString stringWithFormat:@"AWS4%@", secret] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signedScope   = [[dateStamp dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash:key];
    NSData *signedRegion  = [[region dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash:signedScope];
    NSData *signedService = [[service dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash:signedRegion];
    NSData *signingKey    = [[@"aws4_request" dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash:signedService];
    
    NSData *signature = [[stringToSign dataUsingEncoding:NSUTF8StringEncoding] tg_SHA256Hash:signingKey];
    NSString *token   = [NSString stringWithFormat:@"%@ Credential=%@/%@, SignedHeaders=%@, Signature=%@",
                         kTGAmazonV4SignatureDesc,
                         access,
                         scope,
                         [signedRequest tg_headerSignature],
                         [signature tg_hexEncodedString]];
    
    [signedRequest setValue:token forHTTPHeaderField:@"Authorization"];
    return signedRequest;
};

@end
