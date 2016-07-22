//
//  CookingMethodViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
class CookingMethodViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    let cookingMethodEnumRoute = AppConstants.apiURLWithPathComponents("meal_base/cooking_method_enums")
    var cookingMethodPickerDataSource = ["Bake","Roast","Broil","Grill","Microwave","Raw","Stir-Fry","Fry","Pan-Fry","Saute","Boil","Simmer","Ferment"]
    var realm = try! Realm()
    
    var callback: ((text: String)-> Void)?
    
    @IBOutlet weak var cookingMethodPicker: UIPickerView!
    var cookingMethod = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCookingMethodEnumFromServer()
        cookingMethodPicker.delegate = self
        cookingMethodPicker.dataSource = self
        cookingMethod = cookingMethodPickerDataSource[0]
        
    }
    
    @IBAction func selectCookingMethod(sender: AnyObject) {
        if let callback = callback {
            print(cookingMethod)
            callback(text: cookingMethod)
            
        }
        Utils.dismissViewControllerAnimatedOnMainThread(self)
    }
    func loadCookingMethodEnumFromServer() {
            let mutableURLRequest = NSMutableURLRequest(URL: cookingMethodEnumRoute)
            mutableURLRequest.HTTPMethod = "GET"
            mutableURLRequest.setAuthorizationHeader()
            
            Alamofire.request(mutableURLRequest).responseJSON { response in
                var oldCookingMethods:Set<String> = Set()
                for cm in self.realm.objects(CookingMethod) {
                    oldCookingMethods.insert(cm.name)
                }
                
                switch response.result {
                case .Failure(let error):
                    print("Error retrieving potential cooking methods, falling back on saved methods. Error:",error)
                    self.setCookingMethodDataSource(Array(oldCookingMethods))
                case .Success(let responseObject):
                    
                    let allCookingMethodArray = responseObject as! [String]
                    let allCookingMethodSet:Set<String> = Set(allCookingMethodArray)
                    var newCookingMethodObjects = [CookingMethod]()
                    for cm in allCookingMethodSet {
                        if !oldCookingMethods.contains(cm) {
                            newCookingMethodObjects.append(CookingMethod(value:["name":cm]))
                        }
                    }
                    defer {
                        print("setting new cooking methods")
                        self.setCookingMethodDataSource(allCookingMethodArray)
                    }
                    do {
                        try self.realm.write {
                            self.realm.add(newCookingMethodObjects)
                        }
                    } catch let error as NSError {
                        print("error saving cooking method enum:",error)
                        self.setCookingMethodDataSource(Array(oldCookingMethods))
                        return
                    }
                    
                }
            }
    }
    func setCookingMethodDataSource(arr: [String]) {
        cookingMethodPickerDataSource = Array(arr)
        cookingMethodPicker.dataSource = self
        cookingMethod = self.cookingMethodPickerDataSource[0]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cookingMethodPickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cookingMethodPickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cookingMethod = cookingMethodPickerDataSource[row]
    }
}