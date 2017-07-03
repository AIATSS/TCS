//
//  ViewController.m
//  tcs
//
//  Copyright © 2017 aia. All rights reserved.
//

#import "ViewController.h"

#import <AFNetworking/AFHTTPSessionManager.h>

@interface ViewController ()
@property (strong) AFHTTPSessionManager *manager;
@property (weak) IBOutlet NSTextField *usernameTF;
@property (weak) IBOutlet NSTextField *passwordTF;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://cigp3r8cweb01.aia.biz/tcs/"]];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (IBAction)check:(id)sender {
    [self checkForUsername:self.usernameTF.stringValue password:self.passwordTF.stringValue completion:nil];
}

- (void)checkForUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL result))completion {
    if (username.length == 0 || password.length == 0) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    [self.manager GET:@"clock_checkrec.asp" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.manager POST:@"clock_logrec.asp" parameters:@{ @"Tuserid": username, @"B1": @"Check" } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.alertStyle = NSAlertStyleInformational;
            alert.messageText = username;
            
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if ([string containsString:@"Check Successfully!"]) {
                alert.informativeText = @"Check Successfully!";
            } else {
                alert.informativeText = @"Check Failed!";
            }
            [alert runModal];
            
            if (completion) {
                completion(YES);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[NSAlert alertWithError:error] runModal];
            
            if (completion) {
                completion(NO);
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[NSAlert alertWithError:error] runModal];
        
        if (completion) {
            completion(NO);
        }
    }];
    
    [self.manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNegotiate]) {
            return NSURLSessionAuthChallengeRejectProtectionSpace;
        } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM]) {
            *credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
            return NSURLSessionAuthChallengeUseCredential;
        } else {
            return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }];
}

@end
