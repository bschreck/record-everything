//
//  BowelMovement.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 3/7/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Alamofire

class BowelMovement: Object, Mappable {
    dynamic var id :String? = ""
    dynamic var jsonId: String? {
        get {
            return id
        }
        set(jsonIdString) {
        }
    }
    dynamic var bsScale: Int = 0
    dynamic var date = NSDate(timeIntervalSince1970: 1)
    dynamic var duration: Int = 0

    dynamic var bowelMovementsRoute: NSURL {
        get {
            return AppConstants.apiURLWithPathComponents("bowel_movements")
        }
    }
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        do {
            let realm = try Realm()
            try realm.write {
                jsonId <- map["jsonId"]
                if id == nil {
                    id = jsonId!
                }
                duration <- map["duration"]
                bsScale <-  map["bsScale"]
                date   <- (map["date"], OptionalDateTransform())
            }
        } catch let error as NSError {
            print("error setting cooking method removals",error)
        }
        
    }
    // Specify properties to ignore (Realm won't persist these)
    
//      override static func ignoredProperties() -> [String] {
//        return []
//      }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func saveToServer(onCompletion: ServiceResponse) {
        var serializedBM: String?
        serializedBM = Mapper().toJSONString(self, prettyPrint: true)
        
        let data = serializedBM!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: bowelMovementsRoute)
        mutableURLRequest.HTTPMethod = "PUT"
        
        mutableURLRequest.HTTPBody = data
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setAuthorizationHeader()
        
        Alamofire.request(mutableURLRequest).responseString { response in
            var statusCode: Int
            if let httpError = response.result.error {
                statusCode = httpError.code
                print("Status Code:",statusCode)
            } else { //no errors
                statusCode = (response.response?.statusCode)!
                print("Status Code:", statusCode)
            }
            
            switch statusCode {
            case 200:
                onCompletion(nil, nil)
            case -1004,-1002:
                onCompletion(nil, NSError(domain:"No Response",code:statusCode,userInfo:nil))
            default:
                if let error = response.result.value {
                    onCompletion(nil, NSError(domain:error,code:statusCode,userInfo:nil))
                } else {
                    onCompletion(nil, NSError(domain:"Unknown Error",code:statusCode,userInfo:nil))
                }
            }
        }
    }
}
