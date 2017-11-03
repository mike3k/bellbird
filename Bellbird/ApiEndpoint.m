//
//  ApiEndpoint.m
//  Bellbird
//
//  Created by Mike Cohen on 11/3/17.
//  Copyright © 2017 Mike Cohen. All rights reserved.
//

#import "ApiEndpoint.h"

@implementation ApiEndpoint

- (instancetype)init {
    if (self = [super init]) {
        self.baseUrlString = @"https://hs-bellbird.herokuapp.com/";
    }
    return self;
}

- (void)sendRequest:(NSString*)urlString method:(NSString*)method body:(NSData*)body completion:(void (^)(NSData *data))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (method.length) {
        urlRequest.HTTPMethod = method;
    }
    if (body) {
        urlRequest.HTTPBody = body;
        urlRequest.allHTTPHeaderFields = @{@"Content-Type": @"application/json; charset=utf-8"};
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // handle completion
        if (completion && data) {
            completion(data);
        }
    }];
    [dataTask resume];
}

- (void)getAlarms: (void (^)(NSArray *array))completion; {
    [self sendRequest:[NSString stringWithFormat:@"%@alarms.json",self.baseUrlString] method:@"GET" body:nil
           completion:^(NSData *data) {
               id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
               if (completion) {
                   completion(result);
               }
           }];
}

-(void)createAlarm: (NSString*)body {
    NSMutableDictionary *alarm = [NSMutableDictionary dictionary];
    alarm[@"alarm"] = [NSDictionary dictionaryWithObjectsAndKeys:@(0),@"votes",body,@"body", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:alarm
                                                   options:0 error:nil];
    [self sendRequest:[NSString stringWithFormat:@"%@alarms.json",self.baseUrlString]
               method:@"POST" body:data completion:^(NSData *data) {
                   id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                   NSLog(@"create result: %@",result);

                   [[NSNotificationCenter defaultCenter] postNotificationName:@"AlarmCreated" object:result];
               }];
}

- (void)updateAlarm:(int)alarmId votes:(int)votes {
    NSString *requestUrl = [NSString stringWithFormat:@"%@alarms/%d.json",self.baseUrlString,alarmId];
    NSMutableDictionary *alarm = [NSMutableDictionary dictionary];
    alarm[@"alarm"] = [NSDictionary dictionaryWithObjectsAndKeys:@(votes),@"votes", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:alarm
                                                   options:0 error:nil];
    [self sendRequest:requestUrl
               method:@"PUT" body:data completion:^(NSData *data) {
                   id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                   NSLog(@"update result: %@",result);

                   [[NSNotificationCenter defaultCenter] postNotificationName:@"AlarmUpdated" object:result];
               }];


}

- (void)push:(int)alarmId {
    NSString *requestUrl = [NSString stringWithFormat:@"%@push",self.baseUrlString];
    NSMutableDictionary *alarm = [NSMutableDictionary dictionary];
    alarm[@"alarm_id"] = @(alarmId);
    NSData *data = [NSJSONSerialization dataWithJSONObject:alarm
                                                   options:0 error:nil];
    [self sendRequest:requestUrl method:@"POST" body:data
           completion:^(NSData *data) {
               id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

               NSLog(@"push result:%@",result);
           }];
}


@end
