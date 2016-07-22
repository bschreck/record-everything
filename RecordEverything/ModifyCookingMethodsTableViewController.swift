//
//  ModifyCookingMethodsTableViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 2/18/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import UIKit

class ModifyCookingMethodsTableViewController: UITableViewController {

    var cookingMethods = [ListItem]()
    var cookingMethodNames = [String]() {
        didSet {
            for cm in cookingMethodNames {
                cookingMethods.append(ListItem(text: cm))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        navigationItem.leftBarButtonItem = editButtonItem()
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
        return cookingMethods.count + 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        if (indexPath.row < cookingMethods.count) {
            let cellIdentifier = "ModifyCookingMethodsTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ModifyCookingMethodTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            let cm = cookingMethods[indexPath.row]
            cell.textLabelNew.text = cm.text
            cell.tableView = self
            cell.callback = modifyCookingMethodCallback(indexPath)
            return cell
        } else {
            let cellIdentifier = "ModifyCookingMethodsAddNewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddCookingMethodTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.callback = addNewCookingMethodCallback
            cell.tableView = self
            return cell
        }
    }

    func addNewCookingMethodCallback(text: String) {
        if !cookingMethods.contains({ cm in cm.text == text }) {
            cookingMethods.append(ListItem(text:text))
        }
        doTableRefresh()
    }
    
    func modifyCookingMethodCallback(indexPath: NSIndexPath)-> (text:String)->Void {
        func innerCallback(text:String) {
            if !cookingMethods.contains({ cm in cm.text == text }) {
                cookingMethods[indexPath.row] = ListItem(text:text)
            } else if text != cookingMethods[indexPath.row].text {
                cookingMethods.removeAtIndex(indexPath.row)
            }
            doTableRefresh()
        }
        
        return innerCallback
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
            cookingMethods.removeAtIndex(indexPath.row)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func refreshSpecificIndex(indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        })
    }
    func doTableRefresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }

}
