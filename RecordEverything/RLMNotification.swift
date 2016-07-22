//
//  RLMNotification.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/31/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import RealmSwift

class RLMNotification: Object {
    dynamic var id:String? = ""
    dynamic var fireDate = NSDate(timeIntervalSince1970: 1)
    dynamic var type:String? = "Meal"
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
