//
//  RecordMealViewController.swift
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import ObjectMapper

//TODO:
//
//When saving, also save locally, but only keep last week's worth of meals

//add sleep thing as a reminder in morning to set how "awake" you felt when you woke up
//add something for sleep (reminder when you go to bed, reminder in morning, save length of sleep, whether it took a long time to fall asleep, whether feel rested or not in morning)



class RecordMealViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate  {

    static let pastMealsServerRoute = AppConstants.apiURLWithPathComponents("past_meals")
    // MARK: Properties
    
    //@IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealTypePicker: UIPickerView!
    //@IBOutlet weak var autoCompleteTable: UITableView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var cookingMethodLabel: UILabel!  

    @IBOutlet weak var cookingMethodsText: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ingredientsText: UILabel!
    @IBOutlet weak var setDifferentTimeButton: UIButton!
    @IBOutlet weak var selectMeal: UIButton!
    @IBOutlet weak var selectDifferentMeal: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var editIngredientsButton: UIButton!
    @IBOutlet weak var editCookingMethodsButton: UIButton!
    var realm = try! Realm()
    
    var meal: Meal?
    var mealBase: MealBase?
    var unsavedMeals = [Meal]()

    var mealTypePickerDataSource = ["Breakfast","Lunch","Dinner","Snack","Dessert"]
    var mealType : String?
    var date = Utils.roundDateToNearest10Min(NSDate()) {
        didSet {
            setDifferentTimeButton.setTitle(dateFormatter(date) + " >",forState: .Normal)
        }
    }
    var cookingMethods = [String]() {
        didSet {
            if cookingMethods.count > 0 {
                cookingMethodsText.text = convertStringArrayToString(cookingMethods)
            }
        }
    }
    var ingredients = [String]() {
        didSet {
            if ingredients.count > 0 {
                ingredientsText.text = convertStringArrayToString(ingredients)
            }
        }
    }

    var nonDefaultPhoto = false

    func dateSetter(date:NSDate) {
        self.date = date
    }
    
    func dateFormatter(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        return formatter.stringFromDate(date)
    }
    func setLabelsToShowState() {
        selectMeal.hidden = true
        saveButton.hidden = false
        ingredientsLabel.hidden = false
        ingredientsText.hidden = false
        cookingMethodLabel.hidden = false
        cookingMethodsText.hidden = false
        editIngredientsButton.hidden = false
        editCookingMethodsButton.hidden = false
    }
    func setLabelsToClearedState() {
        selectMeal.hidden = false
        saveButton.hidden = true
        ingredientsLabel.hidden = true
        ingredientsText.hidden = true
        cookingMethodLabel.hidden = true
        cookingMethodsText.hidden = true
        editIngredientsButton.hidden = true
        editCookingMethodsButton.hidden = true
    }
    
    func setMealVariable(mealBase:MealBase) {
        print("setting meal variable")
        self.mealBase = mealBase
        navigationItem.title = mealBase.name

        for cm in mealBase.cookingMethods {
            self.cookingMethods.append(cm.name)
        }
        for ing in mealBase.ingredients {
            self.ingredients.append(ing.name)
        }
        setLabelsToShowState()
        print("finished setting meal variable")
    }
    func convertStringArrayToString(arr:[String])->String {
        var arrString = ""
        for (index,elt) in arr.enumerate() {
            arrString += "\(elt)"
            if index < arr.count-1 {
                arrString += ", "
            }
        }
        return arrString
    }
    
    @IBAction func unwindCancel(sender: UIStoryboardSegue) {
        clearMeal()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("Main") as UIViewController
        let navController = UINavigationController(rootViewController: initViewController)
        self.presentViewController(navController, animated:true, completion: nil)
    }
    @IBAction func selectMealBase(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initViewController: MealBaseTableViewController = storyboard.instantiateViewControllerWithIdentifier("SelectMealBase") as! MealBaseTableViewController
        initViewController.mealBaseCallback = setMealVariable
        let navController = UINavigationController(rootViewController: initViewController)
        self.presentViewController(navController, animated:true, completion: nil)
    }
    
    @IBAction func unwindBack(sender: UIStoryboardSegue) {
    }
    
    
    @IBAction func save(sender: AnyObject) {
        //TODO: 1. figure out why meals aren't being saved
        //2. Figure out how to send meals in bulk at once, and asynchronously
        //3. Delete meals after a week?
        if let mealBase = mealBase {
            do {
                try realm.write {
                  
                    meal = Meal(value: ["id": Utils.newUUID(), "mealBase":mealBase,"type":self.mealType!,"date":self.date])
                    meal!.setIngredientModifications(ingredients)
                    meal!.setCookingMethodModifications(cookingMethods)

                    if nonDefaultPhoto {
                        meal!.photo = UIImageJPEGRepresentation(photoImageView.image!,1.0)
                    }
                    realm.add(meal!)
                }
            } catch let error as NSError {
                print("error saving mealbase to disk:",error)
                showAlertWithMessage("Unable to save meal", title: "Save Error")
                return
            }
      
            //get rid of this
//            do {
//                try self.realm.write {
//                    for meal in unsavedMeals {
//                        meal.mealBase!.shouldSave = false
//                        self.realm.delete(meal)
//                    }
//                }
//            } catch _ as NSError {
//                print("error deleting or saving meals from disk")
//            }

            let mealsToSave = unsavedMeals + [meal!]
         
            unsavedMeals = []
            clearMeal()
            saveUnsavedMealsToServer(mealsToSave) {
                (responseObject:[String:[Meal]]?, error:NSError?) in
                var mealsToWrite = [Meal]()
                var mealsToDelete = [Meal]()
                if let _ = error {
                    
                    mealsToWrite = mealsToSave
                } else if let responseObject = responseObject {
                    mealsToWrite = responseObject["mealsToWrite"]!
                    mealsToDelete = responseObject["mealsToDelete"]!
                }
                do {
                    try self.realm.write {
                        print("writing \(mealsToWrite.count) meals")
                        for meal in mealsToWrite {
                            meal.shouldSave = true
                        }
                        print("deleting \(mealsToDelete.count) meals")
                        for meal in mealsToDelete {
                            meal.mealBase!.shouldSave = false
                            self.realm.delete(meal)
                        }
                    }
                } catch _ as NSError {
                    print("error deleting or saving meals from disk")
                }
            }
            self.performSegueWithIdentifier("UnwindRecordMeal",sender:self)
        } else {
            showAlertWithMessage("No Meal Selected", title: "No Meal")
            return
        }
    }
    func saveUnsavedMealsToServer(unsavedMeals: [Meal], onCompletion: ([String:[Meal]]?, NSError?) -> Void) {
        print("serializing \(unsavedMeals.count) meals")
        let serializedMeals = Mapper().toJSONString(unsavedMeals, prettyPrint: true)
        print("serialized meals")
        let data = serializedMeals!.dataUsingEncoding(NSUTF8StringEncoding)!
        print("encoded data")
        let route = AppConstants.apiURLWithPathComponents("meal")
        let mutableURLRequest = NSMutableURLRequest(URL: route)
        print("saving to server on:",route)
        mutableURLRequest.HTTPMethod = "POST"
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
                var mealResponseDict = [String:[Meal]]()
                mealResponseDict["mealsToWrite"] = [Meal]()
                mealResponseDict["mealsToDelete"] = [Meal]()
                for (_,subJson):(String, JSON) in JSON(response.result.value!)["savedMeals"] {
                    if let mealId = subJson.string {
                        let meal = self.realm.objectForPrimaryKey(Meal.self, key: mealId)
                        if let meal = meal {
                            mealResponseDict["mealsToDelete"]!.append(meal)
                        } else {
                            print("could not find meal with id \(mealId) return from server!")
                        }
                    }
                }
                
                for (_,subJson):(String, JSON) in JSON(response.result.value!)["unsavedMeals"] {
                    if let mealId = subJson.string {
                        let meal = self.realm.objectForPrimaryKey(Meal.self, key: mealId)
                        if let meal = meal {
                            mealResponseDict["mealsToWrite"]!.append(meal)
                        } else {
                            print("could not find meal with id \(mealId) return from server!")
                        }
                    }
                }
                onCompletion(mealResponseDict, nil)
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
    
    func loadUnsavedMealsFromDisk() {
        let result = realm.objects(Meal).filter("shouldSave == true")
        unsavedMeals = []
        for m in result {
            unsavedMeals.append(m)
        }
    }
    func removeSavedMealsFromDisk() {
        let result = realm.objects(Meal).filter("shouldSave == false")
        do {
            try self.realm.write {
                for m in result {
                    self.realm.delete(m)
                }
            }
        } catch let error as NSError {
            print("error removing saved meals:",error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        //nameTextField.delegate = self
        mealTypePicker.delegate = self
        mealTypePicker.dataSource = self
        //autoCompleteTable.delegate = self
        //autoCompleteTable.dataSource = self
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        var mtPickerIndex:Int
      
        if hour < 10 {
            //breakfast
            mtPickerIndex = 0
        } else if hour < 12 {
            //snack
            mtPickerIndex = 3
        } else if hour < 14 {
            //lunch
            mtPickerIndex = 1
        } else if hour < 17 {
            //snack
            mtPickerIndex = 3
        } else if hour < 21 {
            //dinner
            mtPickerIndex = 2
        } else if hour < 23 {
            //dessert
            mtPickerIndex = 4
        } else {
            //snack
            mtPickerIndex = 3
        }
        mealType = mealTypePickerDataSource[mtPickerIndex]
        mealTypePicker.selectRow(mtPickerIndex, inComponent: 0, animated: false)
        
        //autoCompleteTable.scrollEnabled = true
        //autoCompleteTable.hidden = true
        //self.view.addSubview(autoCompleteTable)
        nonDefaultPhoto = false
        
        date = Utils.roundDateToNearest10Min(NSDate())

        
        setLabelsToClearedState()

        
        if AppConstants.visitedRecordMealViewController == false {
            print("loading unsaved meals:",self.unsavedMeals.count)
            loadUnsavedMealsFromDisk()
            removeSavedMealsFromDisk()
            print("loading unsaved meals:",self.unsavedMeals.count)
            var lowestDate = NSDate()
            if unsavedMeals.count > 0 {
                var meal = unsavedMeals[0]
                for m in unsavedMeals {
                    if m.date < lowestDate {
                        lowestDate = m.date
                        meal = m
                    }
                }
                print("earliest unsaved meal date:",lowestDate)
                print("earliest unsaved meal:",meal.id, meal.mealBaseID, meal.mealBase!.name, meal.type)
            }
            AppConstants.visitedRecordMealViewController = true
        } else {
        }
        
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
    

    
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
        saveButton.enabled = false
    }
    

    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        //let text = nameTextField.text ?? ""
        //saveButton.enabled = !text.isEmpty
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
        //nameTextField.text = ""
        photoImageView.image = UIImage(named:"defaultPhoto")
        setLabelsToClearedState()
    }
    


    
    @IBAction func cancel(sender: UIBarButtonItem) {
        clearMeal()
    }
    
    @IBAction func doneModifying(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ModifyIngredientsTableViewController {
            var newIngredients = [String]()
            for ing in sourceViewController.ingredients {
                newIngredients.append(ing.text)
            }
            
            ingredients = newIngredients
        }
        else if let sourceViewController = sender.sourceViewController as? ModifyCookingMethodsTableViewController {
            var newCookingMethods = [String]()
            for cm in sourceViewController.cookingMethods {
                newCookingMethods.append(cm.text)
            }
            
            cookingMethods = newCookingMethods
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //nameTextField.resignFirstResponder()
//        if saveButton === sender {
//            let name = mealBase!.name//nameTextField.text ?? ""
//            
//            // Set the meal to be passed to MealDateViewController after the "next" segue.
//            meal = Meal(name: name, type: mealType!, photo: nil, rating: 0, date:nil)
//            
//            if let dateViewController = segue.destinationViewController as? MealDateViewController {
//                dateViewController.meal = meal
//            }
//        }
        if setDifferentTimeButton === sender {
            if let dateViewController = segue.destinationViewController as? DateViewController {
                dateViewController.dateCallback = dateSetter
            }
        } else if editCookingMethodsButton === sender {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            if let controller = destinationNavigationController.topViewController as? ModifyCookingMethodsTableViewController {
                controller.cookingMethodNames = cookingMethods
            }
            
        } else if editIngredientsButton === sender {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            if let controller = destinationNavigationController.topViewController as? ModifyIngredientsTableViewController {
                controller.ingredientNames = ingredients
            }
        }
    }
    

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        Utils.dismissViewControllerAnimatedOnMainThread(self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        nonDefaultPhoto = true

        
        // Dismiss the picker.
        Utils.dismissViewControllerAnimatedOnMainThread(self)
    }
    
    func selectImageFromPhotoLibrary(){
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }

    @IBAction func photoPressed(sender: UITapGestureRecognizer) {
        selectImageFromPhotoLibrary()

    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
            animated: true,
            completion: nil)
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
