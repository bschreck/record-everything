//
//  MainViewController.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/9/16.
//
//

import Foundation
import UIKit
import RealmSwift
import CoreMotion
class MainViewController: UITableViewController  {

    let sections = ["Meal","Energy Level","Tiredness", "Stomach Pain","Sickness", "Bowel Movement"]
    let sectionViewControllerIDs = ["RecordMealViewController","EnergyLevelViewController","TirednessViewController","StomachPainViewController","SicknessViewController","BowelMovementViewController"]
    
    let manager: CMMotionManager = CMMotionManager()
    var rotation:Double = 0.0 {
        didSet {
            print(rotation)
        }
    }
    var accelX = "" {
        didSet {
            print(accelX)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.5
            let queue = NSOperationQueue()
            manager.startDeviceMotionUpdatesToQueue(queue) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                if let gravity = data?.gravity {
                    let rotation = atan2(gravity.x, gravity.y) - M_PI
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self?.rotation = rotation
                        //self?.imageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
                    }
                }
                
            }
        }
        
    }


    @IBAction func unwindCancel(sender: UIStoryboardSegue) {
        if let recordMealViewController = sender.sourceViewController as? RecordMealViewController {
            recordMealViewController.clearMeal()
        } else if let ratingViewController = sender.sourceViewController as? RatingViewController {
            ratingViewController.clearRating()
        } else if let bmController = sender.sourceViewController as? BowelMovementViewController {
            bmController.clearBM(false)
        }
    }

    @IBAction func unwind(sender: UIStoryboardSegue) {}
    
    @IBAction func signOut(sender: AnyObject) {
        LoginService.sharedInstance.signOut()
        
        let controllerId = "Login"
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(controllerId) as UIViewController
        self.presentViewController(initViewController, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RecordItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RecordItemTableViewCell
        cell.textLabel!.text = sections[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionViewControllerID = sectionViewControllerIDs[indexPath.row]
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier(sectionViewControllerID)
        let navController = UINavigationController(rootViewController: viewController)
        Utils.presentViewControllerAnimatedOnMainThread(self, toPresent: navController)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

}