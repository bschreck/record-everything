//
//  MealBase.swift
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

class MealBase: Object,Mappable {
    dynamic var name:String = ""
    dynamic var id:String? = ""
    dynamic var jsonId: String? {
        get {
            return id
        }
        set(jsonIdString) {
            if id == "" {
                id = jsonIdString
            }
        }
    }
    dynamic var shouldDelete = false
    dynamic var shouldSave = true
    dynamic var getEdit: Bool {
        get {
            return edit
        }
        set(whatever) {
            //do nothing
        }
    }
    dynamic var edit = false
    let ingredients = List<Ingredient>()
    dynamic var ingredientNames: [String] {
        get {
            var _ingredientNames = [String]()
            for ingredient in ingredients {
                _ingredientNames.append(ingredient.name)
            }
            return _ingredientNames
        }
        set(_ingredientNames) {
            if ingredients.count == 0 {
                do {
                    let realm = try Realm()
                    try realm.write {
                        for name in _ingredientNames {
                            let result = realm.objects(Ingredient).filter("name == %@",name)
                            if result.count > 0 {
                                ingredients.append(result[0])
                            } else {
                                let newIngredient = realm.create(Ingredient.self,value: Ingredient(value:["name":name]))
                                ingredients.append(newIngredient)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking methods",error)
                }
            }
        }
    }
    let cookingMethods = List<CookingMethod>()
    dynamic var cookingMethodNames: [String] {
        get {
            var _cookingMethodNames = [String]()
            for cm in cookingMethods {
                _cookingMethodNames.append(cm.name)
            }
            return _cookingMethodNames
        }
        set(_cookingMethodNames) {
            if cookingMethods.count == 0 {
                do {
                    let realm = try Realm()
                    try realm.write {
                        for name in _cookingMethodNames {
                            let result = realm.objects(CookingMethod).filter("name == %@",name)
                            if result.count > 0 {
                                cookingMethods.append(result[0])
                            } else {
                                let newCookingMethod = realm.create(CookingMethod.self,value: CookingMethod(value:["name":name]))
                                cookingMethods.append(newCookingMethod)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("error setting cooking methods",error)
                }
            }
        }
        
    }
    dynamic var route : NSURL {
        get {
            return AppConstants.apiURLWithPathComponents("meal_base")
        }
    }
// Specify properties to ignore (Realm won't persist these)
    
  override static func ignoredProperties() -> [String] {
    return ["ingredientNames","cookingMethodNames","jsonId","edit","getEdit"]
  }
    override static func indexedProperties() -> [String] {
        return ["name", "id"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        jsonId <- map["jsonId"]
        if id == "" {
            id = jsonId!
        }
        name <- map["name"]
        ingredientNames <- map["ingredients"]
        cookingMethodNames <- map["cookingMethods"]
        getEdit <- map["edit"]
    }
    
    func saveToServer(edit:Bool=false,onCompletion: ServiceResponse) {
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
        mutableURLRequest.HTTPMethod = "PUT"
        
        mutableURLRequest.HTTPBody = data
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        mutableURLRequest.setAuthorizationHeader()
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
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
                    print("SERVER ERROR:",error)
                    onCompletion(nil, NSError(domain:JSON(error)["message"].string!,code:statusCode,userInfo:nil))
                } else {
                    print("no err")
                    onCompletion(nil, NSError(domain:"Unknown Error",code:statusCode,userInfo:nil))
                }
            }
        }
    }
    func removeFromServer(onCompletion: ServiceResponse) {
        if self.shouldSave {
            onCompletion(nil, NSError(domain:"MealBase not on server yet",code:200,userInfo:nil))
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
