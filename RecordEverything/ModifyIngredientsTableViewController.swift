//
//  ModifyIngredientsTableViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 2/18/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import UIKit

class ModifyIngredientsTableViewController: UITableViewController {

    var ingredients = [ListItem]()
    var ingredientNames = [String]() {
        didSet {
            for ing in ingredientNames {
                ingredients.append(ListItem(text: ing))
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
        return ingredients.count + 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        if (indexPath.row < ingredients.count) {
            let cellIdentifier = "ModifyIngredientsTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ModifiableTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            let ingredient = ingredients[indexPath.row]
            cell.listItem = ingredient
            return cell
        } else {
            let cellIdentifier = "ModifyIngredientsAddNewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddTextTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.callback = addNewIngredientCallback
            return cell
        }
    }

    func addNewIngredientCallback(text: String) {
        ingredients.append(ListItem(text:text))
        print(ingredients)
        doTableRefresh()
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
            ingredients.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
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
