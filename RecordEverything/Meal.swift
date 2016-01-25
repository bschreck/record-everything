//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 5/26/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//  See LICENSE.txt for this sample’s licensing information.
//


import ObjectMapper
import UIKit
import Foundation
import Alamofire

class Meal: NSObject, Mappable {
    // MARK: Properties
    
    var name: String
    var type: String
    var photo: UIImage?
    var rating: Int
    var date: NSDate
    var filename = ""
    
    let mealRoute = AppConstants.apiURLWithPathComponents("meal")
    let mealsRoute = AppConstants.apiURLWithPathComponents("meals")

    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURLDirectory = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey   = "name"
        static let typeKey   = "type"
        static let photoKey  = "photo"
        static let ratingKey = "rating"
        static let dateKey   = "date"
    }

    // MARK: Initialization
    
    required init?(_ map: Map) {
        self.name = ""
        self.type = ""
        self.photo = nil
        self.rating = 0
        self.date = NSDate()
        self.filename = ""
    }
    
    required init?(name: String, type: String, photo: UIImage?, rating: Int, date: NSDate?) {
        self.name = name
        self.type = type
        self.photo = photo
        self.rating = rating
        if let unwrappedDate = date {
            self.date = unwrappedDate
        } else {
            self.date = NSDate()
        }
        self.filename = Meal.ArchiveURLDirectory.URLByAppendingPathComponent("\(self.name)_\(self.type)\(self.date)").path!
        super.init()
        // Initialization should fail if there is no name or if the rating is negative.n
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
//    // MARK: NSCoding
//    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
    }
    
    func mapping(map: Map) {
        name   <-  map["name"]
        type   <-  map["type"]
        photo  <- (map["photo"],PhotoTransform())
        rating <-  map["rating"]
        date   <- (map["date"], OptionalDateTransform())
    }


    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let type = aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        
        // Must call designated initializer.
        
        self.init(name: name, type: type, photo: photo, rating: rating, date: date)
    }
    func saveToDisk() -> Bool {
        let manager = NSFileManager.defaultManager()
        if !(manager.fileExistsAtPath(filename)) {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: filename)
            if !isSuccessfulSave {
                return false
            }
        }
        return true
    }
    
    func removeFromDisk() -> Bool {
        let manager = NSFileManager.defaultManager()
        if (manager.fileExistsAtPath(filename)) {
            do {
                try manager.removeItemAtPath(filename)
            } catch let error as NSError {
                print("Could not delete, \(error), \(error.userInfo)")
                return false
            }
        }
        return true
    }
    
    func saveToServer(onCompletion: ServiceResponse) {
        
        let serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: mealsRoute)
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