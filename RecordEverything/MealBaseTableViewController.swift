//
//  BaseMealTableViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/23/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//
import Foundation
import ObjectMapper
import UIKit
import CoreData
import SwiftyJSON
import Alamofire
import AlamofireObjectMapper
import RealmSwift
//TODO: 
//filter to type in name at top

class MealBaseTableViewController: UITableViewController {
    // MARK: Properties
    
    var mealBases = [MealBase]()
    var mealBaseIDs = [String:Int]()
    var unsavedMealBases = Set<String>()
    var mealBasesToDelete = Set<String>()
    var selected = 0
    var mealBaseCallback: ((mealBase:MealBase)->())?
    var editingRow: NSIndexPath?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var realm = try! Realm()
    let sections = ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved meals, otherwise load sample data.
        print("loading meal bases")
        loadMealBasesFromDisk()
        enforceLexicalConstraint()
        if AppConstants.visitedMealBaseTableViewController == false {
            loadMealBasesFromServer() {response,error in
                self.enforceLexicalConstraint()
                self.doTableRefresh()
                self.saveUnsavedMealBasesToServer()
            }
            AppConstants.visitedMealBaseTableViewController = true
        } else {
        }
        

    }
    
    func enforceLexicalConstraint() {
        self.mealBases.sortInPlace({ $0.name < $1.name })
        reinitializeMealBaseIDs()
    }
    
    func reinitializeMealBaseIDs() {
        self.mealBaseIDs = [String:Int]()
        for (index,mb) in self.mealBases.enumerate() {
            mealBaseIDs[mb.id!] = index
        }
    }
    func insertIntoMealBasesAndSort(mealBase: MealBase) -> Int {
        //insertion sort routine for a single element addition to sorted mealBases array
        var j = mealBases.count
        mealBases.append(mealBase)
        var tmp: MealBase
        while j > 0 && mealBases[j-1].name > mealBases[j].name {
            tmp = mealBases[j-1]
            mealBases[j-1] = mealBases[j]
            mealBases[j] = tmp
            j-=1
        }
        reinitializeMealBaseIDs()
        return j
    }


    func loadMealBasesFromServer(onCompletion:ServiceResponse) {
        let url = AppConstants.apiURLWithPathComponents(AppConstants.mealBaseRoute)
        let mutableURLRequest = NSMutableURLRequest(URL: url)
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
                        for (_,mealBaseJSON) in json {
                            if let mealBaseObject = Mapper<MealBase>().map(String(mealBaseJSON)) {
                            //mealBaseNames is [String:Int] mapping currently stored names to their indices
                                if let mbIndex = self.mealBaseIDs[mealBaseObject.id!] {
                                    //this method should update the mealBaseObject on the server with the local updates (assumes server knows which user I am, and makes sure only I am changing my mealBases
                                    self.compareAndUpdateFromServer(mbIndex, mealBase: mealBaseObject)
                                } else {
                                    self.mealBases.append(mealBaseObject)
                                    self.saveMealBaseToDisk(withObject: mealBaseObject, shouldSave:false)
                                }
                            }
                        }
                    }
                    onCompletion(nil,nil)
                }
            case -1004,-1002:
                print("--->No response")
            default:
                if let error = response.result.value {
                    print("--->Error:", error)
                } else {
                    print("--->Unknown error")
                }
            }
        }
    }
    func compareAndUpdateFromServer(index:Int, mealBase:MealBase) {
        let localMealBase = self.mealBases[index]
        if mealBase.cookingMethods.count > 0 && localMealBase.cookingMethods.count > 0 && localMealBase.cookingMethods[0] != mealBase.cookingMethods[0] {
            saveMealBaseToServer(index, edit:true)
            return
        }
        if localMealBase.ingredients.count != mealBase.ingredients.count {
            saveMealBaseToServer(index,edit:true)
            return
        }
        for (index,ingredient) in localMealBase.ingredients.enumerate() {
            if ingredient != mealBase.ingredients[index] {
                saveMealBaseToServer(index,edit:true)
                return
            }
        }
    }
    func saveMealBaseToServer(index:Int,edit:Bool = false) {
        self.mealBases[index].saveToServer(edit){response,error in
            if let _error = error {
                print("--->unable to save meal \(self.mealBases[index].id!) to server,",_error)
                do {
                    try self.realm.write {
                        self.mealBases[index].shouldSave = true
                    }
                } catch let error as NSError {
                    print("error saving mealbase to disk:",error)
                }
                
                self.unsavedMealBases.insert(self.mealBases[index].id!)
            } else {
                do {
                    try self.realm.write {
                        self.mealBases[index].shouldSave = false
                    }
                } catch let error as NSError {
                    print("error saving mealbase to disk:",error)
                }
            }
        }
    }
    func saveMealBaseToDisk(index:Int)->Bool {
        return saveMealBaseToDisk(withObject: mealBases[index])
    }
    func saveMealBaseToDisk(withObject mealBase:MealBase, shouldSave:Bool = true,shouldDelete:Bool = false)->Bool {
        if mealBase.cookingMethods.count == 0 {
            return false
        }
        if mealBase.ingredients.count == 0 {
            return false
        }
        do {
            try realm.write {
                if shouldSave == false {
                    mealBase.shouldSave = false
                }
                if shouldDelete == true {
                    mealBase.shouldDelete = true
                }
                realm.add(mealBase,update:true)
            }
            return true
        } catch let error as NSError {
            print("error saving mealbase to disk:",error)
            return false
        }
        
    }
    func removeMealBaseFromDisk(withObject mealBase: MealBase) {
        do {
            try realm.write {
                realm.delete(mealBase)
            }
        } catch let error as NSError {
            print("error saving mealbase to disk:",error)
        }
    }
    func saveUnsavedMealBasesToServer() {
        for id in unsavedMealBases {
            saveMealBaseToServer(mealBaseIDs[id]!)
        }
    }
    func loadMealBasesFromDisk() {
        let mealBaseObjects = self.realm.objects(MealBase)
        for mb in mealBaseObjects {
            if mb.shouldDelete && !mb.shouldSave {
                mb.removeFromServer(){response,error in
                    if let _ = error {
                        do {
                            try self.realm.write {
                                mb.shouldDelete = true
                            }
                        } catch let error as NSError {
                            print("error saving mealbase to disk:",error)
                        }
                        self.mealBasesToDelete.insert(mb.id!)
                    } else {
                        self.removeMealBaseFromDisk(withObject:mb)
                    }
                }
            } else if mb.shouldDelete {
                self.removeMealBaseFromDisk(withObject:mb)
            } else {
                mealBases.append(mb)
                if mb.shouldSave {
                    unsavedMealBases.insert(mb.id!)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 27
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredMealBases = mealBases.filter() {
            $0.name.hasPrefix(sections[section])
        }
        return filteredMealBases.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sections
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
        atIndex index: Int) -> Int {
            return index
            
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return sections[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealBaseTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MealBaseTableViewCell
        //cell.tableView = self
        
        
        let mealBase = mealBaseFromIndexPath(indexPath)
        //cell.mealBase = mealBase
        
        cell.nameLabel.text = mealBase.name
        var ingredients = [String]()

        for ing in mealBase.ingredients {
            ingredients.append(ing.name)
        }
        cell.ingredientsDataSource = ingredients

        var cookingMethods = [String]()
        for cm in mealBase.cookingMethods {
            cookingMethods.append(cm.name)
        }
        cell.cookingMethodsDataSource = cookingMethods


        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMealBase = mealBaseFromIndexPath(indexPath)
        mealBaseCallback!(mealBase: selectedMealBase)
        Utils.dismissViewControllerAnimatedOnMainThread(self)

    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: error when server is down and try to delete (array index out of range on line 230)
        if editingStyle == .Delete {
            // Delete the row from the data source
            mealBases[indexPath.row].removeFromServer(){response,error in
                let mb = self.mealBases[indexPath.row]
                if error == nil || error!.code != 200 {
                    self.removeMealBaseFromDisk(withObject: mb)

                } else {
                    do {
                        try self.realm.write {
                            mb.shouldDelete = true
                        }
                    } catch let error as NSError {
                        print("could not save meal base shouldDelete",error)
                    }
                    self.mealBasesToDelete.insert(mb.id!)
                    self.unsavedMealBases.remove(mb.id!)
                }
                self.mealBases.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.reinitializeMealBaseIDs()
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    func mealBaseFromIndexPath(indexPath: NSIndexPath)->MealBase {
        let section = sections[indexPath.section]
        let filteredMealBases = mealBases.filter() {
            $0.name.hasPrefix(section)
        }
        return filteredMealBases[indexPath.row]
    }
    func mealBaseIndexFromIndexPath(indexPath: NSIndexPath)->Int? {
        let section = sections[indexPath.section]
        if let firstMBInSection = mealBases.indexOf({$0.name.hasPrefix(section)}) {
            return firstMBInSection + indexPath.row
        } else {
            return nil
        }
    }
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segIndentifier = segue.identifier {
            if segIndentifier == "EditMealBaseSegue" {
                var indexPath: NSIndexPath?
                
                if let button = sender as? UIButton {
                    if let superview = button.superview {
                        if let cell = superview.superview as? MealBaseTableViewCell {
                            indexPath = tableView.indexPathForCell(cell)
                        }
                    }
                }
                if let indexPath = indexPath {
                    let navigationController = segue.destinationViewController as! UINavigationController
                    let mealBaseDetailViewController = navigationController.topViewController as! CreateMealBaseViewController
                    


                    let selectedMealBase = mealBaseFromIndexPath(indexPath)
                    mealBaseDetailViewController.mealBase = selectedMealBase
                    editingRow = indexPath
                    mealBaseDetailViewController.editingRow = indexPath
                }
            } else if segIndentifier == "AddNewMealBaseSegue" {
                //print("Adding new meal base.")
            }
        }
    }
    
    
    @IBAction func unwindToMealBaseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CreateMealBaseViewController, mealBase = sourceViewController.mealBase {
            if let editingRow = editingRow {
                if self.saveMealBaseToDisk(withObject: mealBase) {
                    // Update an existing meal.
                    let oldIndex = mealBaseIndexFromIndexPath(editingRow)
                    if let oldIndex = oldIndex {
                        mealBases.removeAtIndex(oldIndex)
                    }
                    let newIndex = insertIntoMealBasesAndSort(mealBase)
                    doTableRefresh()
                    self.editingRow = nil
                    self.saveMealBaseToServer(newIndex)
                } else {
                    print("ERROR SAVING TO DISK")
                }
            } else {
                if checkNewMealBaseNameUnique(mealBase.name) {
                    if self.saveMealBaseToDisk(withObject: mealBase) {
                    

                        // Add a new meal.
                        let newIndex = insertIntoMealBasesAndSort(mealBase)
              
                        doTableRefresh()
               
                        self.saveMealBaseToServer(newIndex)
        
                    } else {
                        print("ERROR SAVING TO DISK")
                    }
                } else {
                    showAlertWithMessage("A meal with that name already exists")
                }
            }
        }
    }
    func checkNewMealBaseNameUnique(name:String) ->Bool {
        for mb in mealBases {
            if mb.name == name {
                return false
            }
        }
        return true
    }
    
    func showAlertWithMessage(message:String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    



    
    @IBAction func unwindCreateNewFoodCancel(sender: UIStoryboardSegue) {
    }
    
    
    func doTableRefresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
}
