////
////  Meal.swift
////  FoodTracker
////
////  Created by Jane Appleseed on 5/26/15.
////  Copyright © 2015 Apple Inc. All rights reserved.
////  See LICENSE.txt for this sample’s licensing information.
////
//
//
//import ObjectMapper
//import UIKit
//import Foundation
//import Alamofire
//import CoreData
//import SwiftyJSON
//
//public class MealController: MealBaseController {
//    // MARK: Properties
//    
//    var type: String
//    var photo: UIImage?
//    var date: NSDate
//    var mealBaseID: Int64?
//
//    override var route : NSURL {
//        get {
//            return AppConstants.apiURLWithPathComponents("meal")
//        }
//    }
//
//    // MARK: Initialization
//    
//    required public init?(_ map: Map) {
//        self.type = ""
//        self.photo = nil
//        self.date = NSDate()
//        super.init(map)
//    }
//    
//    required public init?(name: String, ingredients: [String], cookingMethods: [String], type: String, photo: UIImage?, date: NSDate) {
//        self.type = type
//        self.photo = photo
//        self.date = date
//        super.init(name:name,ingredients:ingredients,cookingMethods:cookingMethods)
//    }
//    
//    required convenience public init?(mealBase: MealBaseController, type: String, photo: UIImage?, date: NSDate) {
//        if mealBase.shouldDelete {
//            return nil
//        }
//        self.init(name: mealBase.name,ingredients: mealBase.ingredients,cookingMethods:mealBase.cookingMethods,
//            type:type,photo:photo,date:date)
//        self.id = nil
//        self.mealBaseID = mealBase.id
//        self.shouldSave = mealBase.shouldSave
//    }
//   
//    required public init?(name: String, ingredients: [String], cookingMethods: [String]) {
//        self.type = ""
//        self.photo = nil
//        self.date = NSDate()
//        super.init(name:name,ingredients:ingredients,cookingMethods:cookingMethods)
//    }
//    
//    init?(fromMealObject object:Meal) {
//
//
//        type = object.type!.name!
//        if let photo = object.photo {
//            self.photo = UIImage(data:photo,scale:1.0)
//        }
//        date = NSDate(timeIntervalSince1970: object.date)
//
//        if let mealBase = object.mealBase {
//            super.init(fromMealBaseObject:mealBase)
//        
//            id = object.uid
//            mealBaseID = mealBase.uid
//            shouldSave = object.shouldSave
//            shouldDelete = object.shouldDelete
//            if self.name.isEmpty {
//                return nil
//            }
//        } else {
//            super.init(name:"",ingredients:[],cookingMethods:[])
//            return nil
//        }
//    }
// 
//    override public func mapping(map: Map) {
//        super.mapping(map)
//        mealBaseID <- map["baseObjectId"]
//        type   <-  map["type"]
//        photo  <- (map["photo"],PhotoTransform())
//        date   <- (map["date"], OptionalDateTransform())
//    }
//
//    func loadMealBaseFromID(id: Int64) -> MealBase? {
//        let fetchRequest = NSFetchRequest(entityName: "MealBase")
//        fetchRequest.predicate = NSPredicate(format:"uid = %@", id)
//        fetchRequest.fetchLimit = 1
//        var result = [MealBase]()
//        do {
//            result = try managedContext.executeFetchRequest(fetchRequest) as! [MealBase]
//            return result[0]
//        } catch let error as NSError {
//            print("--->Can't find object \(error)")
//            return nil
//        }
//    }
//    
//    func loadTypeFromDisk(name:String) -> MealType? {
//        let fetchRequest = NSFetchRequest(entityName: "MealType")
//        fetchRequest.predicate = NSPredicate(format:"name = %@", name)
//        fetchRequest.fetchLimit = 1
//        var result = [MealType]()
//        do {
//            result = try managedContext.executeFetchRequest(fetchRequest) as! [MealType]
//            
//        } catch let error as NSError {
//            print("--->Could not fetch \(error), \(error.userInfo)")
//        }
//        if result.count == 0 {
//            return createTypeEntity(name)
//        } else {
//            return result[0]
//        }
//    }
//    
//    func createTypeEntity(name:String) -> MealType? {
//        let entityDesc = NSEntityDescription.entityForName("MealType", inManagedObjectContext: managedContext)
//        let entity = MealType(entity: entityDesc!, insertIntoManagedObjectContext: managedContext)
//        entity.name = name
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("--->Could not save \(error), \(error.userInfo)")
//            return nil
//        }
//        return entity
//    }
//
//    override func saveToDisk() -> Bool {
//        let mealId = self.id
//        self.id = self.mealBaseID
//        var foundMeal = false
//        if super.saveToDisk() {
//            // super.saveToDisk() saves self.id with mealBase id,
//            // we grab that so we can get the underlying meal base,
//            // and then set it to the meal id
//            var mealBase: MealBase? = nil
//            if let id = self.id {
//                mealBase = loadMealBaseFromID(id)
//            }
//            self.mealBaseID = self.id
//            self.id = mealId
//            var mealEntity: Meal
//            if let mealId = mealId {
//                let fetchRequest = NSFetchRequest(entityName: "Meal")
//                fetchRequest.predicate = NSPredicate(format:"uid = %@", mealId)
//                fetchRequest.fetchLimit = 1
//                do {
//                    let result = try managedContext.executeFetchRequest(fetchRequest) as! [Meal]
//                    mealEntity = result[0]
//                    foundMeal = true
//                } catch let error as NSError {
//                    print("--->Can't find object \(error)")
//                    let entity =  NSEntityDescription.entityForName("Meal", inManagedObjectContext:managedContext)
//                    mealEntity = Meal(entity: entity!, insertIntoManagedObjectContext: managedContext)
//                }
//            } else {
//                let entity =  NSEntityDescription.entityForName("Meal", inManagedObjectContext:managedContext)
//                mealEntity = Meal(entity: entity!, insertIntoManagedObjectContext: managedContext)
//            }
//            mealEntity.date = date.timeIntervalSince1970
//            mealEntity.type = loadTypeFromDisk(type)
//            if let photo = photo {
//                mealEntity.photo = UIImagePNGRepresentation(photo)
//            }
//            mealEntity.shouldDelete = shouldDelete
//            mealEntity.shouldSave = shouldSave
//            if let mealBase = mealBase {
//                mealEntity.mealBase = mealBase
//            } else {
//                return false
//            }
//            mealEntity.uid = Int64(-1)
//            if !foundMeal {
//                if let newId = Utils.generateNewID("Meal") {
//                    print("GENERATED NEW ID:",newId)
//                    mealEntity.uid = Int64(newId)
//                } else {
//                    return false
//                }
//            }
//            do {
//                try managedContext.save()
//                self.id = mealEntity.uid
//            } catch let error as NSError {
//                print("--->Could not save \(error), \(error.userInfo)")
//                return false
//            }
//            return true
//            
//        } else {
//            return false
//        }
//    }
//
//    override func removeFromDisk() -> Bool {
//        if let id = self.id {
//            let fetchRequest = NSFetchRequest(entityName: "Meal")
//            fetchRequest.predicate = NSPredicate(format:"uid = %@", id)
//            fetchRequest.fetchLimit = 1
//            do {
//                let result = try managedContext.executeFetchRequest(fetchRequest) as! [Meal]
//                let mealEntity = result[0]
//                managedContext.deleteObject(mealEntity)
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("--->Delete Error: \(error)")
//                    return false
//                }
//            } catch let error as NSError {
//                print("--->Can't find object \(error)")
//            }
//        }
//        return true
//    }
//    
//    func updateMealBaseShouldSave() -> Bool{
//        if let id = self.mealBaseID {
//            let mealBase = loadMealBaseFromID(id)
//            if let mealBase = mealBase {
//                mealBase.shouldSave = false
//                do {
//                    try managedContext.save()
//                    return true
//                } catch let error as NSError {
//                    print("--->Delete Error: \(error)")
//                }
//            }
//        }
//        return false
//    }
//    override func saveToServer(onCompletion: ServiceResponse) {
//        let serializedMeal = Mapper().toJSONString(self, prettyPrint: true)
//        let data = serializedMeal!.dataUsingEncoding(NSUTF8StringEncoding)!
//        
//        let mutableURLRequest = NSMutableURLRequest(URL: route)
//        mutableURLRequest.HTTPMethod = "PUT"
//        
//        mutableURLRequest.HTTPBody = data
//        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        mutableURLRequest.setAuthorizationHeader()
//        
//        
//        Alamofire.request(mutableURLRequest).responseJSON { response in
//            var statusCode: Int
//            if let httpError = response.result.error {
//                statusCode = httpError.code
//            } else { //no errors
//                statusCode = (response.response?.statusCode)!
//            }
//            
//            switch statusCode {
//            case 200:
//                self.shouldSave = false
//                self.updateMealBaseShouldSave()
//                self.saveToDisk()
//                onCompletion(nil, nil)
//            case -1004,-1002:
//                self.shouldSave = true
//                self.saveToDisk()
//                onCompletion(nil, NSError(domain:"No Response",code:statusCode,userInfo:nil))
//            default:
//                self.shouldSave = true
//                self.saveToDisk()
//                if let error = response.result.value {
//                    onCompletion(nil, NSError(domain:JSON(error)["message"].string!,code:statusCode,userInfo:nil))
//                } else {
//                    onCompletion(nil, NSError(domain:"Unknown Error",code:statusCode,userInfo:nil))
//                }
//            }
//        }
//    }
//
//    
//
//}