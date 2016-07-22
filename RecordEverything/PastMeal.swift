//
//  PastMeal.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/29/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import RealmSwift

class PastMeal: Object {
    dynamic var id: String? = ""
    dynamic var mealType: String = ""
    dynamic var name: String = ""
    dynamic var num: Int = 0
    override static func indexedProperties() -> [String] {
        return ["mealType", "name"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
