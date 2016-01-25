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

//TODO: autocomplete ingredients
let NAME_TEXT_FIELD_TAG = 0
let INGREDIENT_TEXT_FIELD_TAG = 1

class CreateMealBaseViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    var mealBase: MealBase?
    var unsavedMealBases = [MealBase]()
    var cookingMethod = "Bake" {
        didSet {
            updateCookingMethodButton()
        }
    }
    var ingredients = [String]() {
        didSet {
            doTableRefresh()
        }
    }
    var editingRow: NSIndexPath?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    

    @IBOutlet weak var cookingMethodButton: UIButton!
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
        updateCookingMethodButton()
        self.view.addSubview(ingredientsTableView)
        
        loadUnsavedMealBasesFromDisk()
        
        
        if let mealBase = mealBase {
            navigationItem.title = mealBase.name
            nameTextField.text = mealBase.name
            cookingMethod = mealBase.cookingMethod[0]
            ingredients = mealBase.ingredients
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }

    
    
    @IBAction func selectCookingMethod(sender: UIStoryboardSegue) {
        if let cookingMethodViewController = sender.sourceViewController as? CookingMethodViewController {
            cookingMethod = cookingMethodViewController.cookingMethod
        }
    }
    
    func updateCookingMethodButton() {
        cookingMethodButton.setTitle(cookingMethod, forState:.Normal)
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
        mealBase = nil
        navigationItem.title = "New Type of Food"
        nameTextField.text = ""
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        print("presenting view controller:", presentingViewController)
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("preparing for segue")
        if saveButton === sender,let tableViewController = segue.destinationViewController as? MealBaseTableViewController {
            print("savebutton sender")
            let name = nameTextField.text ?? ""
            mealBase = MealBase(name:name,ingredients:ingredients,cookingMethod:[cookingMethod])
            if let mealBase = mealBase {
                mealBase.saveToDisk()
                mealBase.saveToServer(){response,error in
                    if let _ = error {
                        tableViewController.unsavedMealBases.addObject(self.editingRow!)
                    }
                }
            }
        }
    }
    func doTableRefresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.ingredientsTableView.reloadData()
            return
        })
    }
    
}
