//
//  MealNameViewController.swift
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

//TODO: add user log in screen and user code
//use 3 view controllers again instead of one
//use core data instead of files for meals
//add reminders
//add something for sleep (reminder when you go to bed, reminder in morning, save length of sleep, whether it took a long time to fall asleep, whether feel rested or not in morning)
//add something for bowel movement (rating for watery->hard scale, length of time it took, date when it happened, photo)
//add class for creating meal with ingredients, ability to select a meal class with those ingredients, plus modifications, and ability to select quantity of meal
class MealNameViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let pastMealsServerRoute = AppConstants.apiURLWithPathComponents("past_meals")
    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    //@IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var mealTypePicker: UIPickerView!
    @IBOutlet weak var autoCompleteTable: UITableView!
    //@IBOutlet weak var datePicker: UIDatePicker!
    //@IBOutlet weak var photoImageView: UIImageView!
    /*
        This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
        or constructed as part of adding a new meal.
    */
    var meal: Meal?
    var unsavedMeals = [Meal]()
    
    //var nonDefaultPhoto = false
    
    var mealTypePickerDataSource = ["Breakfast","Lunch","Dinner","Snack","Dessert"]
    var mealType :String?
    
    var autoCompleteMeals = [String]()

    var pastMeals = [String:[String:Int]]()

    
    @IBAction func unwindCancel(sender: UIStoryboardSegue) {
        clearMeal()
//        if let dateViewController = sender.sourceViewController as? MealDateViewController {
//            dateViewController.clearMeal()
//        }
//        else if let photoViewController = sender.sourceViewController as? MealPhotoViewController {
//            photoViewController.clearMeal()
//        }
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("Main") as UIViewController
        let navController = UINavigationController(rootViewController: initViewController)
        self.presentViewController(navController, animated:true, completion: nil)
    }
    
    @IBAction func unwindBack(sender: UIStoryboardSegue) {
    }
    
    @IBAction func save(sender: UIStoryboardSegue) {

        
        let name = nameTextField.text ?? ""
        //let date = datePicker.date
        
//        var photo: UIImage?
//        if nonDefaultPhoto {
//            photo = photoImageView.image
//        } else {
//            photo = nil
//        }

        let currentMealType = mealType!
        
        //meal = Meal(name: name, type: currentMealType, photo: photo, rating: 0, date:date)
        if let photoViewController = sender.sourceViewController as? MealPhotoViewController {
            meal = photoViewController.meal
        } else {
            return
        }
        
        
        let mealsToSave = unsavedMeals + [meal!]
        unsavedMeals = []
        clearMeal()
        
        for (index,unsavedMeal) in mealsToSave.enumerate() {
            unsavedMeal.saveToServer({
                (responseObject:NSDictionary?, error:NSError?) in
                if let _error = error {
                    print(_error)
                    if _error.code == 600 {
                        print("Meal already exists")
                    } else {
                        print("unable to save meal (\(unsavedMeal.type),\(unsavedMeal.name), \(unsavedMeal.date)) to server,",_error)
                        self.unsavedMeals.append(unsavedMeal)
                        unsavedMeal.saveToDisk()
                        if index == mealsToSave.count-1 {
                            self.savePastMeal(name, mealType: currentMealType)
                        }
                    }
                } else {
                    unsavedMeal.removeFromDisk()
                    print(responseObject, error)
                    print("successfully saved to server")
                    if index == mealsToSave.count-1 {
                        self.savePastMeal(name, mealType: currentMealType)
                    }


                    
                }
            })
        }
        self.performSegueWithIdentifier("unwindRecordMeal",sender:self)
//        //TODO: for some reason this goes to main view but then back to add meal
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("Main") as UIViewController
//        let navController = UINavigationController(rootViewController: initViewController)
//        self.presentViewController(navController, animated:true, completion: nil)
    }
    
    func loadUnsavedMealsFromDisk() {
        let mealsUrl =  Meal.ArchiveURLDirectory
        let manager = NSFileManager.defaultManager()
        if !(manager.fileExistsAtPath(mealsUrl.path!)) {
            do {
                try manager.createDirectoryAtPath(mealsUrl.path!, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        do {
            let directoryContents = try manager.contentsOfDirectoryAtURL(mealsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            for url in directoryContents {
                unsavedMeals.append((NSKeyedUnarchiver.unarchiveObjectWithFile(url.path!) as? Meal)!)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        mealTypePicker.delegate = self
        mealTypePicker.dataSource = self
        autoCompleteTable.delegate = self
        autoCompleteTable.dataSource = self
        mealType = mealTypePickerDataSource[0]
        
        autoCompleteTable.scrollEnabled = true
        autoCompleteTable.hidden = true
        //nonDefaultPhoto = false
        self.view.addSubview(autoCompleteTable)
        
        //resetDate()
        
        loadUnsavedMealsFromDisk()
        loadPastMealsFromServer()
        
//        // Set up views if editing an existing Meal.
//        if let meal = meal {
//            navigationItem.title = meal.name
//            mealTypePicker.selectRow(mealTypePickerDataSource.indexOf(meal.type)!,inComponent:0,animated:false)
//            mealType = meal.type
//            nameTextField.text   = meal.name
//            //ratingControl.rating = meal.rating
//        } else {
//            mealType = mealTypePickerDataSource[mealTypePicker.selectedRowInComponent(0)]
//        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
//    @IBAction func resetDate() {
//        datePicker.date = Utils.roundDateToNearest10Min(NSDate())
//    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        nextButton.enabled = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        self.searchAutocompleteEntriesWithSubstring(newString)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        let lcaseSubstring = substring.lowercaseString
        autoCompleteMeals = []
        var valuesToSort = [Int]()
        if pastMeals.count > 0 {
            
            if let mealTypeDict = pastMeals[mealType!] {
                for (meal, mealCount) in mealTypeDict {
                    let lcaseMeal = meal.lowercaseString
                    let asRange = lcaseMeal.rangeOfString(lcaseSubstring)
                    if let asRange = asRange where asRange.startIndex == meal.startIndex {
                        autoCompleteMeals.append(meal)
                        valuesToSort.append(mealCount)
                    }
                }
                let autoCompleteMealPairs = Zip2Sequence(valuesToSort.indices,autoCompleteMeals).sort({
                    valuesToSort[$0.0] > valuesToSort[$1.0]
                })
                autoCompleteMeals = autoCompleteMealPairs.map( { $0.1 } )
                autoCompleteTable.reloadData()
                
                autoCompleteTable.hidden = false
                
                // print("substring", substring)
                // print("pastMeals", pastMeals)
                // print("autocomplete:", autoCompleteMeals)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteMeals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let AutoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        cell = tableView.dequeueReusableCellWithIdentifier(AutoCompleteRowIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier:AutoCompleteRowIdentifier)
        }
        
        cell!.textLabel!.text = autoCompleteMeals[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        nameTextField.text = selectedCell!.textLabel!.text;
        nameTextField.resignFirstResponder()
        autoCompleteTable.hidden = true
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        nextButton.enabled = !text.isEmpty
    }

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealTypePickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealTypePickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mealType = mealTypePickerDataSource[row]
    }
    
    // MARK: Navigation
    
    func clearMeal() {
        meal = nil
        navigationItem.title = "New Meal"
        nameTextField.text = ""
        //ratingControl.rating = 0
        //resetDate()
        //nonDefaultPhoto = false
        //photoImageView.image = UIImage(named:"defaultPhoto")
        
    }
    
    
    func loadPastMealsFromServer() {
        let mutableURLRequest = NSMutableURLRequest(URL: MealNameViewController.pastMealsServerRoute)
        mutableURLRequest.HTTPMethod = "GET"
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
                if let value = response.result.value {
                    let json = JSON(value)
                    if json.count > 0 {
                        for (mealType,subJson):(String, JSON) in json {
                            self.pastMeals[mealType] = [String:Int]()
                            for (meal,subsubJson):(String,JSON) in subJson {
                                self.pastMeals[mealType]![meal] = subsubJson.int
                            }
                        }
                        print("pastMeals")
                        print(self.pastMeals)

                        self.savePastMealsToDisk(true)
                        break
                    }
                }
                print("No past meals on server")
                self.loadPastMealsFromDisk()
            case -1004,-1002:
                print("No response")
                self.loadPastMealsFromDisk()
            default:
                if let error = response.result.value {
                    print("Error:", error)
                } else {
                    print("Unknown error")
                }
                self.loadPastMealsFromDisk()
            }
        }
    }

    
    func loadPastMealsFromDisk() -> Bool {
        print("loading past meals from disk")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "MealType")
        fetchRequest.includesSubentities = true
        var result = [NSManagedObject]()
        
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
        
        var pastMealObjects = [NSManagedObject]()
        var pastMealTypeString = ""
        if result.count > 0 {
            for pastMealType in result {
                pastMealTypeString = pastMealType.valueForKey("name") as! String
                
                let keyNotExists = pastMeals[pastMealTypeString] == nil
                if keyNotExists {
                    pastMeals[pastMealTypeString] = [String:Int]()
                }
                pastMealObjects = pastMealType.valueForKey("meals")!.allObjects as! [NSManagedObject]
                for pastMeal in pastMealObjects {
                    pastMeals[pastMealTypeString]![pastMeal.valueForKey("name") as! String] = pastMeal.valueForKey("count") as? Int
                }
            }
        } else {
            for mealTypeString in mealTypePickerDataSource {
                pastMeals[mealTypeString] = [String:Int]()
            }
            saveEmptyMealTypes()
        }
        return true
    }
    
    func savePastMealsToDisk(overwrite: Bool) -> Bool {
        if overwrite == true {
            removeAllPastMealsFromDisk()
            saveEmptyMealTypes()
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("PastMeal", inManagedObjectContext:managedContext)
        for mealTypeString in mealTypePickerDataSource {
            let mealType = loadMealTypeEntity(mealTypeString, withSubentities: false)
            if let mealsForType = pastMeals[mealTypeString] {
                for (pastMealString,pastMealCount) in mealsForType {
                    let pastMealObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                    pastMealObject.setValue(pastMealString, forKey: "name")
                    pastMealObject.setValue(pastMealCount, forKey:"count")
                    pastMealObject.setValue(mealType, forKey: "mealType")
                }
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func removeAllPastMealsFromDisk() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName: "PastMeal")
        do {
            var pastMealList = try managedContext.executeFetchRequest(request)
            for pastMeal in pastMealList {
                managedContext.deleteObject(pastMeal as! NSManagedObject)
            }
            pastMealList.removeAll(keepCapacity: false)
        } catch let error as NSError {
            print("could not retrieve past meals to delete:", error)
            return false
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func saveEmptyMealTypes() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("MealType", inManagedObjectContext:managedContext)
        
        var mealTypeEntities = [NSManagedObject]()
        var mealTypeEntity: NSManagedObject
        for mealTypeString in mealTypePickerDataSource {
            
            mealTypeEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            mealTypeEntity.setValue(mealTypeString, forKey: "name")
            mealTypeEntities.append(mealTypeEntity)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func loadMealTypeEntity(name: String, withSubentities: Bool) -> NSManagedObject? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "MealType")
        fetchRequest.predicate = NSPredicate(format:"name = %@", name)
        fetchRequest.fetchLimit = 1
        fetchRequest.includesSubentities = withSubentities
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if result.count == 0 {
            return nil
        } else {
            return result[0]
        }
    }

    func savePastMeal(name: String, mealType: String) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "PastMeal")
        fetchRequest.predicate = NSPredicate(format:"name = %@ AND mealType.name = %@", name, mealType)
        fetchRequest.fetchLimit = 1
        var result = [NSManagedObject]()
        
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    
        if result.count == 0 {
            //if doesnt exist
            let entity =  NSEntityDescription.entityForName("PastMeal", inManagedObjectContext:managedContext)
            let pastMeal = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            pastMeal.setValue(name, forKey: "name")
            pastMeal.setValue(1, forKey: "count")
            let mealTypeObject = loadMealTypeEntity(mealType, withSubentities: false)!
            pastMeal.setValue(mealTypeObject, forKey: "mealType")
            pastMeals[mealType]![name] = 1
        } else {
        //if already exists
            let pastMeal = result[0]
            var count = pastMeal.valueForKey("count") as! Int
            count += 1
            pastMeal.setValue(count, forKey: "count")
            pastMeals[mealType]![name] = count
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
        return true
    }

    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        
        meal = nil
        clearMeal()
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        nameTextField.resignFirstResponder()
        if nextButton === sender {
            let name = nameTextField.text ?? ""
            //let rating = ratingControl.rating
            //let date = datePicker.date
            
            
            // Set the meal to be passed to MealDateViewController after the "next" segue.
            meal = Meal(name: name, type: mealType!, photo: nil, rating: 0, date:nil)
            
            if let dateViewController = segue.destinationViewController as? MealDateViewController {
                dateViewController.meal = meal
            }
        }
    }
    


}
