// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


@import ZMTransport;
@import ZMUtilities;
#import "MockTransportSession+PushToken.h"
#import "MockTransportSession+internal.h"
#import "MockTransportSession.h"
#import "MockUser.h"
#import "MockConnection.h"


@implementation MockTransportSession (PushToken)

/// handles /push/tokens/
- (ZMTransportResponse *)processPushTokenRequest:(TestTransportSessionRequest *)sessionRequest;
{
    if ((sessionRequest.method == ZMMethodPOST) && (sessionRequest.pathComponents.count == 0)) {
        return [self processPostPushes:sessionRequest];
    }
    
    return [ZMTransportResponse responseWithPayload:nil HTTPstatus:404 transportSessionError:nil];
}

- (ZMTransportResponse *)processPostPushes:(TestTransportSessionRequest *)sessionRequest;
{
    NSDictionary *payload = [sessionRequest.payload asDictionary];
    if (payload != nil) {
        NSString *token = [payload stringForKey:@"token"];
        NSString *app = [payload stringForKey:@"app"];
        NSString *transport = [payload stringForKey:@"transport"];
        if ((token != nil) && (0 < app.length) && ([transport isEqualToString:@"APNS"] || [transport isEqualToString:@"APNS_VOIP"])) {
            [self addPushToken:@{@"token": token, @"app": app,  @"transport" : transport}];
            return [ZMTransportResponse responseWithPayload:@{@"token": token, @"app": app, @"transport": transport} HTTPstatus:201 transportSessionError:nil];
        }
    }
    return [ZMTransportResponse responseWithPayload:@{@"code": @400} HTTPstatus:400 transportSessionError:nil];
}

@end
