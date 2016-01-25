//
//  BaseMealTableViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/23/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//
//TODO: deal with sorting upon loading or saving to server/disk
import Foundation
import ObjectMapper
import UIKit
import CoreData
import Alamofire
import AlamofireObjectMapper

class MealBaseTableViewController: UITableViewController {
    // MARK: Properties
    
    var mealBases = [MealBase]()
    var mealBaseNames = [String:Int]()
    var unsavedMealBases = NSMutableSet()
    var selected = 0
    var mealBaseCallback: ((mealBase:MealBase)->())?
    var editingRow: NSIndexPath?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved meals, otherwise load sample data.
        self.loadMealBasesFromDisk()
        loadMealBasesFromServer()
        
        
    }
    
    
    func loadMealBasesFromServer() {
        let mutableURLRequest = NSMutableURLRequest(URL: AppConstants.mealBasesRoute)
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
                        for mealBaseJSON in json {
                            let mealBaseObject = Mapper<MealBase>().map(mealBaseJSON)
                            //mealBaseNames is [String:Int] mapping currently stored names to their indices
                            if let mbName = mealBaseNames[mealBaseObject.name] {
                                //this method should update the mealBaseObject on the server with the local updates (assumes server knows which user I am, and makes sure only I am changing my mealBases
                                compareAndUpdateFromServer(mbName, mealBaseObject)
                            } else {
                                mealBaseNames[mealBaseObject.name] = mealBases.count
                                mealBases.append(mealBaseObject)
                                mealBaseObject.saveToDisk()
                            }
                        }
                    }
                }
            case -1004,-1002:
                print("No response")
            default:
                if let error = response.result.value {
                    print("Error:", error)
                } else {
                    print("Unknown error")
                }
            }
        }
    }
    func loadMealBasesFromDisk() {
        let fetchRequest = NSFetchRequest(entityName: "MealBase")
        var result = [NSManagedObject]()
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if result.count > 0 {
            for r in result {
                if let mb = MealBase(fromManagedObject:r) {
                    mealBaseNames[mb.name] = mealBases.count
                    mealBases.append(mb)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealBases.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealBaseTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MealBaseTableViewCell
        // Fetches the appropriate meal for the data source layout.
        let mealBase = mealBases[indexPath.row]
        cell.nameLabel.text = mealBase.name
        cell.ingredientsDataSource = mealBase.ingredients
        cell.cookingMethodLabel.text = mealBase.cookingMethod[0]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mealBaseCallback!(mealBase: mealBases[indexPath.row])
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            mealBaseNames[mealBases[indexPath.row].name] = nil
            mealBases[indexPath.row].removeFromDisk()
            mealBases[indexPath.row].removeFromServer(){response,error in
                print("server delete response:",response)
                print("server delete error:",error)
            }
            mealBases.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("unsaved meal bases:",unsavedMealBases)
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
                    let selectedMealBase = mealBases[indexPath.row]
                    mealBaseDetailViewController.mealBase = selectedMealBase
                    editingRow = indexPath
                    mealBaseDetailViewController.editingRow = indexPath
                }
            } else if segIndentifier == "AddNewMealBaseSegue" {
                print("Adding new meal base.")
            }
        }
    }
    
    
    @IBAction func unwindToMealBaseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CreateMealBaseViewController, mealBase = sourceViewController.mealBase {
            if let editingRow = editingRow {
                // Update an existing meal.
                mealBases[editingRow.row] = mealBase
                tableView.reloadRowsAtIndexPaths([editingRow], withRowAnimation: .None)
                self.editingRow = nil
                print("unsavedMealBases:",unsavedMealBases)
            } else {
                // Add a new meal.
                print("adding new meal")
                print("mealBase:",mealBase.name)
                let newIndexPath = NSIndexPath(forRow: mealBases.count, inSection: 0)
                mealBaseNames[mealBase.name] = mealBases.count
                mealBases.append(mealBase)
                print("at 0:",mealBases[0].name)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }
    

    func saveUnsavedMealBasesToServer() {
        for indexPath in unsavedMealBases {
            let unsavedMealBase = mealBases[indexPath.row]
            unsavedMealBase.saveToServer({
                (responseObject:NSDictionary?, error:NSError?) in
                if let _error = error {
                    print("unable to save meal \(unsavedMealBase.name) to server,",_error)
                    self.unsavedMealBases.addObject(indexPath)
                }
            })
        }
    }


    
    @IBAction func unwindCreateNewFoodCancel(sender: UIStoryboardSegue) {
        print("triggered")
    }
    
    
    func doTableRefresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
}
