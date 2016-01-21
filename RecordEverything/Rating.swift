//
//  Rating.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/10/16.
//
//


import ObjectMapper
import UIKit
import Foundation
import Alamofire
import CoreData

class Rating: NSObject, Mappable {
    // MARK: Properties
    
    //TODO: move unsaved to core data instead of files
    
    var rating: Int
    var date: NSDate
    var type: String
    
    
    var ratingRoute: NSURL {
        get {
            return AppConstants.apiURLWithPathComponents("\(type)")
        }
    }
    var ratingsRoute: NSURL {
        get {
            return AppConstants.apiURLWithPathComponents("\(type)s")
        }
    }
    
    
    // MARK: Initialization
    
    required init?(_ map: Map) {
        self.rating = 0
        self.date = NSDate()
        self.type = ""
    }
    
    required init?(rating: Int, date: NSDate?, type: String) {
        self.rating = rating
        if let unwrappedDate = date {
            self.date = unwrappedDate
        } else {
            self.date = NSDate()
        }
        self.type = type
        super.init()
        // Initialization should fail if there is no name or if the rating is negative.n
        if rating < 0 {
            return nil
        }
    }
    
    func mapping(map: Map) {
        type <-  map["type"]
        rating <-  map["rating"]
        date   <- (map["date"], OptionalDateTransform())
    }
    
    

    func saveToDisk() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
    
        
        
        let fetchRequest = NSFetchRequest(entityName: "Rating")
        fetchRequest.predicate = NSPredicate(format:"date = %@ AND type = %@", date,type)
        print(fetchRequest.predicate)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if result.count == 0 {
            let entity =  NSEntityDescription.entityForName("Rating", inManagedObjectContext:managedContext)
            let ratingObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            ratingObject.setValue(self.rating, forKey: "rating")
            ratingObject.setValue(self.date, forKey:"date")
            ratingObject.setValue(self.type, forKey:"type")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
        } else {
            print("object exists")
        }
        return true
    }
    
    func removeFromDisk() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let fetchRequest = NSFetchRequest(entityName: "Rating")
        fetchRequest.predicate = NSPredicate(format:"date = %@ && type = %@", date,type)
        fetchRequest.fetchLimit = 1
        do {
            var ratingList = try managedContext.executeFetchRequest(fetchRequest)
            for rating in ratingList {
                managedContext.deleteObject(rating as! NSManagedObject)
            }
            ratingList.removeAll(keepCapacity: false)
        } catch let error as NSError {
            print("could not retrieve rating to delete:", error)
            return false
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    
    func saveToServer(onCompletion: ServiceResponse) {
        let serializedRating = Mapper().toJSONString(self, prettyPrint: true)
        let data = serializedRating!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: ratingsRoute)
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