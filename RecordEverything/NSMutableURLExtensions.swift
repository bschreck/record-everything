//
//  NSMutableURLExtensions.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/20/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    func setAuthorizationHeader() -> Bool {
        if LoginService.sharedInstance.isLoggedIn() {
            let username = LoginService.sharedInstance.username!
            let password = LoginService.sharedInstance.password!
            guard let data = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding) else { return false }
            
            let base64 = data.base64EncodedStringWithOptions([])
            setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            
            setValue(AppConstants.clientId, forHTTPHeaderField: "Client-ID")
            return true
        } else {
            //TODO: go back to login page here
            return false
        }
    }
}