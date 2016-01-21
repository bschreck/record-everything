//
//  AdditionalClasses.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/10/16.
//
//

import Foundation
import ObjectMapper

typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

public class PhotoTransform: TransformType {
    public func transformFromJSON(value: AnyObject?) -> UIImage? {
        if let photo_string = value {
            let decodedData = NSData(base64EncodedString: photo_string as! String, options: NSDataBase64DecodingOptions(rawValue: 0) )
            return UIImage(data: decodedData!)
        }
        return nil
    }
    public func transformToJSON(value: UIImage?) -> String? {
        var base64String:String = ""
        if value != nil {
            let imageData = UIImageJPEGRepresentation(value!,1.0)
            base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
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
    static func roundDateToNearest10Min(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year,.Month,.Day,.Hour,.Minute,.TimeZone], fromDate: date)
        let minuteUnit = ceil(Double(components.minute) / 10.0)
        let minutes = minuteUnit * 10.0
        components.minute = Int(minutes)
        return calendar.dateFromComponents(components)!
        
    }
}