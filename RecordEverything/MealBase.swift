//
//  MealBase.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit
import Foundation
import Alamofire
import CoreData

class MealBase: NSObject, Mappable {
    // MARK: Properties
    
    var name: String
    var ingredients = [String]()
    //TODO: add support for multiple cooking methods
    var cookingMethod = [String]()
    
    let baseMealRoute = AppConstants.apiURLWithPathComponents("base_meal")
    let baseMealsRoute = AppConstants.apiURLWithPathComponents("base_meals")
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    
    
    // MARK: Initialization
    
    required init?(_ map: Map) {
        self.name = ""
        self.ingredients = []
        self.cookingMethod = []
    }
    
    required init?(name: String, ingredients: [String], cookingMethod: [String]) {
        self.name = name
        self.ingredients = ingredients
        self.cookingMethod = cookingMethod
        super.init()
        // Initialization should fail if there is no name or if the rating is negative.n
        if name.isEmpty {
            return nil
        }
    }
    
    init?(fromManagedObject object:NSManagedObject) {
        self.name = ""
        if let name = object.valueForKey("name") as? String {
            self.name = name
        }
        if let cookingMethodEntity = object.valueForKey("cookingMethod") as? NSManagedObject {
            print("found cooking method")
            self.cookingMethod.append(cookingMethodEntity.valueForKey("name") as! String)
        }
        let ingredientsEntity = object.mutableOrderedSetValueForKey("ingredients")
        for ingredientEntity in ingredientsEntity {
            print("ingredient")
            self.ingredients.append(ingredientEntity.valueForKey("name") as! String)
        }
        super.init()
        if self.name.isEmpty {
            return nil
        }
    }
    
    
    func mapping(map: Map) {
        name   <-  map["name"]
        ingredients <- map["ingredients"]
        cookingMethod <- map["cookingMethod"]
    }
    
    func loadIngredientEntityFromDisk(ingredient: String) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: "Ingredient")
        fetchRequest.predicate = NSPredicate(format:"name = %@", ingredient)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if result.count == 0 {
            return createIngredientEntity(ingredient)
        } else {
            return result[0]
        }
    }
    
    func createIngredientEntity(ingredient: String) -> NSManagedObject? {
        let entityDesc = NSEntityDescription.entityForName("Ingredient", inManagedObjectContext: managedContext)
        let entity = NSManagedObject(entity: entityDesc!, insertIntoManagedObjectContext: managedContext)
        entity.setValue(ingredient, forKey: "name")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return nil
        }
        return entity
    }
    
    func loadCookingMethodEntityFromDisk() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: "CookingMethod")
        fetchRequest.predicate = NSPredicate(format:"name = %@", cookingMethod)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if result.count == 0 {
            return createCookingMethodEntity()
        } else {
            return result[0]
        }
    }
    
    func createCookingMethodEntity() -> NSManagedObject? {
        let entityDesc = NSEntityDescription.entityForName("CookingMethod", inManagedObjectContext: managedContext)
        let entity = NSManagedObject(entity: entityDesc!, insertIntoManagedObjectContext: managedContext)
        entity.setValue(cookingMethod[0], forKey: "name")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return nil
        }
        return entity
    }
    
    func loadIngredientEntitiesFromDisk() -> (NSMutableOrderedSet?,NSError?) {
        let ingredientEntities = NSMutableOrderedSet()
        for ingredientName in ingredients {
            if let ingredientEntity = loadIngredientEntityFromDisk(ingredientName) {
                ingredientEntities.addObject(ingredientEntity)
            } else {
                return (nil, NSError(domain: "Error, ingredient \(ingredientName) could not be created or loaded", code:0,userInfo:nil))
            }
        }
        
        return (ingredientEntities, nil)
    }
    

    func saveToDisk() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "MealBase")
        fetchRequest.predicate = NSPredicate(format:"name = %@", name)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if result.count == 0 {
            let entity =  NSEntityDescription.entityForName("MealBase", inManagedObjectContext:managedContext)
            let (ingredientEntities, error):(NSMutableOrderedSet?,NSError?) = loadIngredientEntitiesFromDisk()
            if error == nil {
                let mealBaseEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                mealBaseEntity.setValue(name, forKey: "name")
                mealBaseEntity.setValue(ingredientEntities, forKey: "ingredients")
                if let cookingMethodEntity = loadCookingMethodEntityFromDisk() {
                    mealBaseEntity.setValue(cookingMethodEntity, forKey: "cookingMethod")
                } else {
                    return false
                }
                
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                    return false
                }
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func removeFromServer(onCompletion: ServiceResponse) {
        let serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: baseMealsRoute)
        mutableURLRequest.HTTPMethod = "DELETE"
        
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
    
    func removeFromDisk() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "MealBase")
        fetchRequest.predicate = NSPredicate(format:"name = %@", name)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if result.count > 0 {
            let entity = result[0]
            managedContext.deleteObject(entity)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not remove meal base: \(error)")
            return false
        }
        return true
    }
    
    func saveToServer(onCompletion: ServiceResponse) {
        
        let serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mutableURLRequest = NSMutableURLRequest(URL: baseMealsRoute)
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