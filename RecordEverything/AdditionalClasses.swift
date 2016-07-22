//
//  AdditionalClasses.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/10/16.
//
//

import Foundation
import ObjectMapper
import SwiftyJSON
import CoreData

typealias ServiceResponse = (NSDictionary?, NSError?) -> Void


public class PhotoTransform: TransformType {
    public func transformFromJSON(value: AnyObject?) -> NSData? {
        if let photo_string = value {
            let decodedData = NSData(base64EncodedString: photo_string as! String, options: NSDataBase64DecodingOptions(rawValue: 0) )
            return decodedData
            //return UIImage(data: decodedData!)
        }
        return nil
    }
    public func transformToJSON(value: NSData?) -> String? {
        var base64String:String = ""
        if value != nil {
            //let imageData = UIImageJPEGRepresentation(value!,1.0)
            base64String = value!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        }
        return base64String
    }
}


public class OptionalDateTransform: TransformType {
    public func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let date_int = value as? Double {
            
            return NSDate(timeIntervalSince1970: date_int)
        }
        return NSDate()
    }
    public func transformToJSON(value: NSDate?) -> Double? {
        return value!.timeIntervalSince1970
    }
}


public class Utils {
    static func dismissViewControllerAnimatedOnMainThread(caller: UIViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            caller.dismissViewControllerAnimated(true, completion:{print("completed dismiss")})
            return
        })
    }
    static func presentViewControllerAnimatedOnMainThread(caller: UIViewController, toPresent: UIViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            caller.presentViewController(toPresent, animated:true, completion: nil)
            return
        })
    }

    
    static func roundDateToNearest10Min(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year,.Month,.Day,.Hour,.Minute,.TimeZone], fromDate: date)
        let minuteUnit = ceil(Double(components.minute) / 10.0)
        let minutes = minuteUnit * 10.0
        components.minute = Int(minutes)
        return calendar.dateFromComponents(components)!
        
    }
    
//    static func generateNewID(objectType: String) -> Int? {
//    
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        let fetchRequest = NSFetchRequest(entityName: objectType)
//        fetchRequest.fetchLimit = 1
//        let highestSortDescriptor = NSSortDescriptor(key: "uid", ascending: false)
//        fetchRequest.sortDescriptors = [highestSortDescriptor]
//        fetchRequest.propertiesToFetch = ["uid"]
//        
//        var result = [NSManagedObject]()
//        do {
//            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
//            if result.count > 0 {
//                let maxID = result[0].valueForKey("uid") as! Int
//                print("maxID:",maxID)
//                return maxID + 1
//            } else {
//                return 0
//            }
//        } catch let error as NSError {
//            print("--->Could not fetch \(error), \(error.userInfo)")
//        }
//        return nil
//        
//    }
    
    static func newUUID() -> String {
        return NSUUID().UUIDString
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }