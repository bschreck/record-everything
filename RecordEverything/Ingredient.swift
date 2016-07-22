//
//  Ingredient.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/29/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import RealmSwift

class Ingredient: Object {
    dynamic var name:String = ""
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
