//
//  AppConstants.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 12/31/15.
//
//

import Foundation

public struct AppConstants {
    static var clientId = "hO4ZJSawqTXeDz0S7ZKAX0FD"
    static var clientSecret = "jmfB2ohtigTpo47f8BJmZIvP"
    static var apiBaseUrl = "http://localhost:8080/api/"
    //static var apiBaseUrl =  "http://ec2-54-213-229-13.us-west-2.compute.amazonaws.com/api/"
    
    static let mealBaseRoute = "meal_base"
    static let mealRoute = "meal"
    
    static var visitedRecordMealViewController = false
    static var visitedMealBaseTableViewController = false

    
    public static func apiURLWithPathComponents(components: String) -> NSURL {
        let baseUrl = NSURL(string: AppConstants.apiBaseUrl)
        let APIUrl = NSURL(string: components, relativeToURL: baseUrl)!
        return APIUrl
    }
}