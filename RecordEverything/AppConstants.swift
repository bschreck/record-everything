//
//  AppConstants.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 12/31/15.
//
//

import Foundation

public struct AppConstants {
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static var clientId = "hO4ZJSawqTXeDz0S7ZKAX0FD"
    static var clientSecret = "jmfB2ohtigTpo47f8BJmZIvP"
    static var apiBaseUrl = "http://localhost:8080/api/"
    //static var apiBaseUrl = "http://alfad8.csail.mit.edu:8080/api"
    
    static let mealBasesRoute = "meal_bases"
    
    public static func apiURLWithPathComponents(components: String) -> NSURL {
        let baseUrl = NSURL(string: AppConstants.apiBaseUrl)
        let APIUrl = NSURL(string: components, relativeToURL: baseUrl)!
        return APIUrl
    }
}