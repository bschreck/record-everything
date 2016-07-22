//
//  Meal.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/29/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import Alamofire
import SwiftyJSON

class Meal: Object,Mappable {
    dynamic var id:String? = ""
    dynamic var jsonId: String? {
        get {
            return id
        }
        set(jsonIdString) {
        }
    }
    dynamic var mealBaseID: String? {
        get {
            if let mealBase = mealBase {
                return mealBase.id
            }
            return nil
        }
        set(whatever) {
            //do nothing
        }
    }
    dynamic var name: String? {
        get {
            if let mealBase = mealBase {
                return mealBase.name
            } else {
                return nil
            }
        }
        set(_name) {
            //do nothing
        }
    }
    dynamic var ingredientNames: [String] {
        get {
            var _ingredientNames = [String]()
            if let mealBase = self.mealBase {
                for ingredient in mealBase.ingredients {
                    _ingredientNames.append(ingredient.name)
                }
            }
            return _ingredientNames
        }
        set(_ingredientNames) {
            if let mealBase = self.mealBase where mealBase.ingredients.count == 0 {
                do {
                    let realm = try Realm()
                    for name in _ingredientNames {
                        let result = realm.objects(Ingredient).filter("name == %@",name)
                        if result.count > 0 {
                            mealBase.ingredients.append(result[0])
                        } else {
                            let newIngredient = realm.create(Ingredient.self,value: Ingredient(value:["name":name]))
                            mealBase.ingredients.append(newIngredient)
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking methods",error)
                }
            }
        }
    }
    dynamic var cookingMethodNames: [String] {
        get {
            var _cookingMethodNames = [String]()
            if let mealBase = self.mealBase {
                for cookingMethod in mealBase.cookingMethods {
                    _cookingMethodNames.append(cookingMethod.name)
                }
            }
            return _cookingMethodNames
        }
        set(_cookingMethodNames) {
            if let mealBase = self.mealBase where mealBase.cookingMethods.count == 0 {
                do {
                    let realm = try Realm()
                    for name in _cookingMethodNames {
                        let result = realm.objects(CookingMethod).filter("name == %@",name)
                        if result.count > 0 {
                            mealBase.cookingMethods.append(result[0])
                        } else {
                            let newCookingMethod = realm.create(CookingMethod.self,value: CookingMethod(value:["name":name]))
                            mealBase.cookingMethods.append(newCookingMethod)
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking methods",error)
                }
            }
        }
    }
    let cookingMethodAdditions = List<CookingMethod>()
    dynamic var cookingMethodAdditionNames: [String] {
        get {
            var _cookingMethodAdditionNames = [String]()
            for cm in cookingMethodAdditions {
                _cookingMethodAdditionNames.append(cm.name)
            }
            return _cookingMethodAdditionNames
        }
        set(_cookingMethodAdditionNames) {
            if cookingMethodAdditions.count == 0 && _cookingMethodAdditionNames.count > 0 {
                do {
                    let realm = try Realm()
                    for name in _cookingMethodAdditionNames {
                        let result = realm.objects(CookingMethod).filter("name == %@",name)
                        if result.count > 0 {
                            cookingMethodAdditions.append(result[0])
                        } else {
                            let newCookingMethod = realm.create(CookingMethod.self,value: CookingMethod(value:["name":name]))
                            cookingMethodAdditions.append(newCookingMethod)
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking method additions",error)
                }
            }
        }
    }
    let cookingMethodRemovals = List<CookingMethod>()
    dynamic var cookingMethodRemovalNames: [String] {
        get {
            var _cookingMethodRemovalNames = [String]()
            for cm in cookingMethodRemovals {
                _cookingMethodRemovalNames.append(cm.name)
            }
            return _cookingMethodRemovalNames
        }
        set(_cookingMethodRemovalNames) {
            if cookingMethodRemovals.count == 0 && _cookingMethodRemovalNames.count > 0 {
                do {
                    let realm = try Realm()
                    for name in _cookingMethodRemovalNames {
                        let result = realm.objects(CookingMethod).filter("name == %@",name)
                        if result.count > 0 {
                            cookingMethodRemovals.append(result[0])
                        } else {
                            let newCookingMethod = realm.create(CookingMethod.self,value: CookingMethod(value:["name":name]))
                            cookingMethodRemovals.append(newCookingMethod)
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking method removals",error)
                }
            }
        }
    }
    let ingredientAdditions = List<Ingredient>()
    dynamic var ingredientAdditionNames: [String] {
        get {
            var _ingredientAdditionNames = [String]()
            for ingredient in ingredientAdditions {
                _ingredientAdditionNames.append(ingredient.name)
            }
            return _ingredientAdditionNames
        }
        set(_ingredientAdditionNames) {
            if ingredientAdditions.count == 0 && _ingredientAdditionNames.count > 0 {
                do {
                    let realm = try Realm()
                    for name in _ingredientAdditionNames {
                        let result = realm.objects(Ingredient).filter("name == %@",name)
                        if result.count > 0 {
                            ingredientAdditions.append(result[0])
                        } else {
                            let newIngredient = realm.create(Ingredient.self,value: Ingredient(value:["name":name]))
                            ingredientAdditions.append(newIngredient)
                        }
                    }
                } catch let error as NSError {
                    print("error setting ingredient additions",error)
                }
            }
        }
    }
    let ingredientRemovals = List<Ingredient>()
    dynamic var ingredientRemovalNames: [String] {
        get {
            var _ingredientRemovalNames = [String]()
            for ingredient in ingredientRemovals {
                _ingredientRemovalNames.append(ingredient.name)
            }
            return _ingredientRemovalNames
        }
        set(_ingredientRemovalNames) {
            if ingredientRemovals.count == 0 && _ingredientRemovalNames.count > 0 {
                do {
                    let realm = try Realm()
                    for name in _ingredientRemovalNames {
                        let result = realm.objects(Ingredient).filter("name == %@",name)
                        if result.count > 0 {
                            ingredientRemovals.append(result[0])
                        } else {
                            let newIngredient = realm.create(Ingredient.self,value: Ingredient(value:["name":name]))
                            ingredientRemovals.append(newIngredient)
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking method removals",error)
                }
            }
        }
    }
    
    dynamic var shouldDelete = false
    dynamic var shouldSave = true
    dynamic var type: String = ""
    dynamic var photo: NSData? = nil
    dynamic var date = NSDate(timeIntervalSince1970: 1)
    dynamic var mealBase:MealBase?

// Specify properties to ignore (Realm won't persist these)
    
    override static func ignoredProperties() -> [String] {
        return ["mealBaseID","name","ingredientNames","cookingMethodNames", "ingredientAdditionNames","ingredientRemovalNames",
        "cookingMethodAdditionNames", "cookingMethodRemovalNames"]
    }
    dynamic var route : NSURL {
        get {
            return AppConstants.apiURLWithPathComponents("meal")
        }
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func primaryKey() -> String? {
        return "id"
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
                type   <-  map["type"]
                photo  <- (map["photo"],PhotoTransform())
                date   <- (map["date"], OptionalDateTransform())
                mealBaseID <- map["baseObjectId"]
                name <- map["name"]
                cookingMethodNames <- map["cookingMethods"]
                ingredientNames <- map["ingredients"]
                cookingMethodAdditionNames <- map["cookingMethodAdditionNames"]
                cookingMethodRemovalNames <- map["cookingMethodRemovalNames"]
                ingredientAdditionNames <- map["ingredientAdditionNames"]
                ingredientRemovalNames <- map["ingredientRemovalNames"]
            }
        } catch let error as NSError {
            print("error setting cooking method removals",error)
        }
    }

    
    func setIngredientModifications(newIngredients: [String]) {
        (ingredientAdditionNames,ingredientRemovalNames) = findModifications(ingredientNames, newArray: newIngredients)
    }
    
    func setCookingMethodModifications(newCookingMethods: [String]) {
        (cookingMethodAdditionNames,cookingMethodRemovalNames) = findModifications(cookingMethodNames, newArray: newCookingMethods)
    }
    
    func findModifications(oldArray: [String], newArray: [String]) -> ([String],[String]) {
        var additions: [String]
        var removals = [String]()

        var foundVal = -1
        var valuesLeft = newArray
        for val in oldArray {
            foundVal = -1
            for (i,newVal) in valuesLeft.enumerate() {
                if val == newVal {
                    foundVal = i
                    break
                }
            }
            if foundVal > -1 {
                valuesLeft.removeAtIndex(foundVal)
            } else {
                removals.append(val)
            }
        }
        additions = valuesLeft
        return (additions, removals)
    }
    

    
    func saveToServer(onCompletion: ServiceResponse) {
        var serializedMeal: String?
        serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
        
        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: route)
        print("saving to server on:",route)
        mutableURLRequest.HTTPMethod = "PUT"
        
        mutableURLRequest.HTTPBody = data
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        mutableURLRequest.setAuthorizationHeader()
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            print("raw server response:",response)
            var statusCode: Int
            if let httpError = response.result.error {
                statusCode = httpError.code
            } else { //no errors
                statusCode = (response.response?.statusCode)!
            }
            print("status code:",statusCode)
          
            switch statusCode {
            case 200:
                onCompletion(nil, nil)
            case -1004,-1002:
                onCompletion(nil, NSError(domain:"No Response",code:statusCode,userInfo:nil))
            default:
                if let error = response.result.value {
                 
                    if let message = JSON(error)["errmsg"].string {
                        onCompletion(nil, NSError(domain:message,code:statusCode,userInfo:nil))
                    } else {
                        onCompletion(nil, NSError(domain:"Unknown error",code:statusCode,userInfo:nil))
                    }
                } else {
              
                    onCompletion(nil, NSError(domain:"Unknown Error",code:statusCode,userInfo:nil))
                }
            }
        }
    }
    func removeFromServer(onCompletion: ServiceResponse) {
        if self.shouldSave {
            onCompletion(nil, NSError(domain:"Meal not on server yet",code:200,userInfo:nil))
            return
        }
        var serializedMeal: String?
        do {
            let realm = try Realm()
            try realm.write{
                serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
            }
        } catch let error as NSError {
            print("realm write error:",error)
        }
        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: route)
        mutableURLRequest.HTTPMethod = "DELETE"
        
        mutableURLRequest.HTTPBody = data
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        mutableURLRequest.setAuthorizationHeader()
        
        
        Alamofire.request(mutableURLRequest).responseString { response in
            var statusCode: Int
            if let httpError = response.result.error {
                statusCode = httpError.code
            } else { //no errors
                statusCode = (response.response?.statusCode)!
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
