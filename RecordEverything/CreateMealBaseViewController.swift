//
//  CreateMealBaseViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import RealmSwift

let NAME_TEXT_FIELD_TAG = 0
let INGREDIENT_TEXT_FIELD_TAG = 1

class CreateMealBaseViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    var mealBase: MealBase?
    var unsavedMealBases = [MealBase]()
    var cookingMethods = [String]() {
        didSet {
            updateCookingMethodLabel()
        }
    }
    var cookingMethodString = ""
    var ingredients = [String]() {
        didSet {
            doTableRefresh()
        }
    }
    var editingRow: NSIndexPath?
    var realm = try! Realm()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    

    @IBOutlet weak var cookingMethodAddButton: UIButton!

    @IBOutlet weak var cookingMethodLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    //@IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ingredientsTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        nameTextField.tag = NAME_TEXT_FIELD_TAG
        ingredientTextField.delegate = self
        ingredientTextField.tag = INGREDIENT_TEXT_FIELD_TAG
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.scrollEnabled = true
        cookingMethods = [String]()
        self.view.addSubview(ingredientsTableView)
        
        loadUnsavedMealBasesFromDisk()
        
        
        if let mealBase = mealBase {
            navigationItem.title = mealBase.name
            nameTextField.text = mealBase.name
            
            var _cookingMethods = [String]()
            for cm in mealBase.cookingMethods {
                _cookingMethods.append(cm.name)
            }
            cookingMethods = _cookingMethods
            for ing in mealBase.ingredients {
                ingredients.append(ing.name)
            }
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }

    
    
    @IBAction func selectCookingMethod(sender: AnyObject) {
        let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("SelectCookingMethod") as! CookingMethodViewController
        
        VC1.callback = addCookingMethod
        self.presentViewController(VC1, animated:true, completion: nil)
    }
    func addCookingMethod(newCM: String) {
        if !cookingMethods.contains(newCM) {
            cookingMethods.append(newCM)
        }
    }

    @IBAction func removeLastCookingMethod(sender: AnyObject) {
        cookingMethods.removeLast()
    }
    func updateCookingMethodLabel() {
        cookingMethodString = ""
        for (i, cm) in cookingMethods.enumerate() {
            if cookingMethods.count > 1 && i < cookingMethods.count - 1 {
                cookingMethodString += "\(cm), "
            } else {
                cookingMethodString += cm
            }
        }
        cookingMethodLabel.text = cookingMethodString
    }

    func loadUnsavedMealBasesFromDisk() {

    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        if textField.tag == INGREDIENT_TEXT_FIELD_TAG {
            addIngredient()
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == NAME_TEXT_FIELD_TAG {
            checkValidMealName()
            navigationItem.title = "Create: \(textField.text!)"
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.enabled = false
        
    }
    
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    


    @IBAction func addIngredient() {
        if ingredientTextField.text != "" {
            ingredients.append(ingredientTextField.text!)
        }
        ingredientTextField.text = ""
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let IngredientTableIdentifier = "IngredientTableIdentifier"
        cell = tableView.dequeueReusableCellWithIdentifier(IngredientTableIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier:IngredientTableIdentifier)
        }
        
        cell!.textLabel!.text = ingredients[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            if (editingStyle == UITableViewCellEditingStyle.Delete) {
                ingredients.removeAtIndex(indexPath.row)
            }
    }
    
    
    
    // MARK: Navigation
    
    func clearMealBase() {
        if let _ = mealBase {
            self.mealBase = nil
        }
        navigationItem.title = "New Type of Food"
        nameTextField.text = ""
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            Utils.dismissViewControllerAnimatedOnMainThread(self)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    func getRealmIngredients(mealBase: MealBase) -> [Ingredient] {
        var realmIngredients = [Ingredient]()
        let existingIngredients = mealBase.ingredients
        var found: Bool
        for ing in ingredients {
            found = false
            for ex in existingIngredients {
                if ing == ex.name {
                    realmIngredients.append(ex)
                    found = true
                    break
                }
            }
            if !found {
                let ingObject = Ingredient(value:["name":ing])
                realmIngredients.append(ingObject)
            }
        }
        return realmIngredients
    }
    
    func getRealmCookingMethods(mealBase: MealBase) -> [CookingMethod] {
        var realmCookingMethods = [CookingMethod]()
        let existingCookingMethods = mealBase.cookingMethods
        var found: Bool
        for cm in cookingMethods {
            found = false
            for ex in existingCookingMethods {
                if cm == ex.name {
                    realmCookingMethods.append(ex)
                    found = true
                    break
                }
            }
            if !found {
                let cmObject = CookingMethod(value:["name":cm])
                realmCookingMethods.append(cmObject)
            }
        }
        return realmCookingMethods
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let ident = identifier {
            if ident == "saveMealBaseIdentifier" {
                if ingredients.count == 0 {
                    showAlertWithMessage("You cannot save a new type of meal with no ingredients", title:"Error: No Ingredients")
                    return false
                } else if cookingMethods.count == 0 {
                    showAlertWithMessage("You cannot save a new type of meal with no cooking methods", title:"Error: No Cooking Methods")
                    return false
                }
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {

            let name = nameTextField.text ?? ""
            if let mealBase = mealBase {
                
                let realmIngredients = getRealmIngredients(mealBase)
                let realmCookingMethods = getRealmCookingMethods(mealBase)
                
                do {
                    try realm.write {
                        mealBase.name = name
                        mealBase.ingredients.removeAll()
                        mealBase.ingredients.appendContentsOf(realmIngredients)
                        mealBase.cookingMethods.removeAll()
                        mealBase.cookingMethods.appendContentsOf(realmCookingMethods)
                    }
                } catch let error as NSError {
                    print("error saving mealbase edits:",error)
                }
                print("new mealbase:",mealBase)
            } else {
                var ingredientDict: [[String:String]] = []
                for ing in ingredients{
                    ingredientDict.append(["name":ing])
                }
                var cmDict: [[String:String]] = []
                for cm in cookingMethods{
                    cmDict.append(["name":cm])
                }
                mealBase = MealBase(value: ["id": Utils.newUUID(), "name":name,"ingredients":ingredientDict,"cookingMethods":cmDict])
            }

        }
    }
    func doTableRefresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.ingredientsTableView.reloadData()
            return
        })
    }
    
    func showAlertWithMessage(message:String, title:String?) {
        var _title = title
        if _title == nil {
            _title = "Alert"
        }
        let alert = UIAlertController(title: _title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
}
