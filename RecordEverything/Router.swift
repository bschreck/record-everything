////
////  Router.swift
////  RecordEverything
////
////  Created by Benjamin Schreck on 1/21/16.
////  Copyright © 2016 Benjamin Schreck. All rights reserved.
////
//
//import Foundation
//import Alamofire
//
//enum Router: URLRequestConvertible {
//    static let baseUrlString = AppConstants.apiBaseUrl
//    
//    case GetMeals()
//    case PostMeals(NSData)
//    case PutMeals(NSData)
//    case PutMeal(NSData)
//    case PostMeal(NSData)
//    case DestroyMeal()
//    case Login()
//    case Signup()
//    case PastMeals()
//    case GetEnergyLevels()
//    case PostEnergyLevels(NSData)
//    case PutEnergyLevels(NSData)
//    case PutEnergyLevel(NSData)
//    case PostEnergyLevel(NSData)
//    case DestroyEnergyLevel(NSData)
//    
//    var method: Alamofire.Method {
//        switch self {
//        case .GetMeals:
//            return .GET
//        case .PostMeals:
//            return .POST
//        case .PutMeals:
//            return .PUT
//        case .PutMeal:
//            return .PUT
//        case .PostMeal:
//            return .POST
//        case .DestroyMeal:
//            return .DELETE
//        case .Login:
//            return .POST
//        case .Signup:
//            return .POST
//        case .PastMeals:
//            return .GET
//        case .PostEnergyLevels:
//            return .GET
//        case .PostEnergyLevels:
//            return .POST
//        case .PutEnergyLevels:
//            return .PUT
//        case .PutEnergyLevel:
//            return .PUT
//        case .PostEnergyLevel:
//            return .POST
//        case .DestroyEnergyLevel:
//            return .DELETE
//        }
//    }
//    
//    
//    var path: String {
//        switch self {
//        case .Login:
//            return "/login"
//        case .Signup:
//            return "/signup"
//        case .GetMeals,.PostMeals,.PutMeals:
//            return "/meals"
//        case .PutMeal,.PostMeal,.DestroyMeal:
//            return "/meal"
//        case .PastMeals():
//            return "/past_meals"
//        case .PutEnergyLevel,.PostEnergyLevel,.DestroyEnergyLevel:
//            return "/energy_level"
//        case .GetEnergyLevels,.PostEnergyLevels,.PutEnergyLevels:
//            return "/energy_levels"
//        }
//    }
//    
//    var URLRequest: NSMutableURLRequest {
//        
//
//        
//        let URL = NSURL(string: Router.baseUrlString)!
//        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
//        URLRequest.HTTPMethod = method.rawValue
//        // set header fields
//        if LoginService.sharedInstance.isLoggedIn() {
//            URLRequest.setAuthorizationHeader()
//        }
//
//        switch self {
//        case .PostEnergyLevels,.PutEnergyLevels,.PutEnergyLevel,.PostEnergyLevel,.DestroyEnergyLevel,.PostMeals,.PutMeals,.PostMeal,.DestroyEnergyLevel(let data):
//            URLRequest.HTTPBody = data
//        default(let data):
//            break
//        }
//
//        URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
////        switch self {
////        case .CreateUser(let parameters):
////            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
////        case .UpdateUser(_, let parameters):
////            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
////        default:
////            return mutableURLRequest
////        }
//        //let encoding = Alamofire.ParameterEncoding.URL
//        //return encoding.encode(URLRequest, parameters: parameters).0
//        return URLRequest
//    }
//}