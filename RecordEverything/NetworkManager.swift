//
//  NetworkManager.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 3/15/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import Foundation
import Alamofire

class NetworkManager {
    
    var manager: Manager?
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 5 // seconds
        manager = Alamofire.Manager(configuration: configuration)
    }
}