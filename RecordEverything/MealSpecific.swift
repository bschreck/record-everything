//
//  MealSpecific.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/23/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit
import Foundation
import Alamofire
import CoreData

class MealSpecific: MealBase {
    var ingredientMods = ["Additions":[String](), "Subtractions":[String]()]
    var cookingMethodMods = ["Additions":[String](), "Subtractions":[String]()]

    required init?(name: String, ingredients: [String], cookingMethod: [String]) {
        super.init(name:name,ingredients:ingredients,cookingMethod:cookingMethod)
    }
    
    
    required init?(name: String, ingredients: [String], cookingMethod: [String], ingredientMods: [String:[String]], cookingMethodMods: [String:[String]]) {
        
        super.init(name:name, ingredients:ingredients, cookingMethod:cookingMethod)
        self.ingredientMods = ingredientMods
        self.cookingMethodMods = cookingMethodMods
    }

    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        name   <-  map["name"]
        ingredients <- map["ingredients"]
        cookingMethod <- map["cookingMethod"]
        ingredientMods <- map["ingredientMods"]
        cookingMethodMods <- map["cookingMethodMods"]
        
    }
}