//
//  RatingViewController.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/9/16.
//
//

import Foundation
import UIKit
import CoreData
class RatingViewController: UIViewController  {
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl! {
        willSet(ratingControlInstance) {
            ratingControlInstance.buttonTapped = {self.ratingButtonTapped()}
        }
    }

    @IBOutlet weak var datePicker: UIDatePicker!
    var unsavedRatings = [Rating]()
    var type: String
    
    init(type: String) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.type = ""
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadUnsavedRatingsFromDisk()
        
        
        // Enable the Save button only if rating is greater than 0
        checkValidRating()
    }

    @IBAction func save(sender: AnyObject) {
        let date = Utils.roundDateToNearest10Min(datePicker.date)
        let rating = Rating(rating: ratingControl.rating, date: date, type: self.type)!
        let ratingsToSave = unsavedRatings + [rating]
        unsavedRatings = []
        clearRating()
        
        for unsavedRating in ratingsToSave {
            unsavedRating.saveToServer({
                (responseObject:NSDictionary?, error:NSError?) in
                if let _error = error {
                    if _error.code == 600 {
                        print("Rating already exists")
                    } else {
                        print("unable to save rating (\(unsavedRating.rating),\(unsavedRating.date)) to server,",_error)
                        self.unsavedRatings.append(unsavedRating)
                        unsavedRating.saveToDisk()
                    }
                } else {
                    print(responseObject, error)
                    print("successfully saved to server")
                    unsavedRating.removeFromDisk()
                }
            })
        }
    }
    
    func ratingButtonTapped() {
        checkValidRating()
    }
    
    func checkValidRating() {
        if ratingControl.rating > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    func clearRating() {
        ratingControl.rating = 0
        checkValidRating()
    }
    
    @IBAction func resetDate() {
        datePicker.date = Utils.roundDateToNearest10Min(NSDate())
    }
    
    func loadUnsavedRatingsFromDisk() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Rating")
        var result = [NSManagedObject]()
        
        do {
            result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
        
        if result.count > 0 {
            for ratingItem in result {
                let ratingObject = Rating(rating: ratingItem.valueForKey("rating") as! Int,date: ratingItem.valueForKey("date") as? NSDate,type:ratingItem.valueForKey("type") as! String)
                print(ratingObject!.rating, ratingObject!.date, ratingObject!.type)
                self.unsavedRatings.append(ratingObject!)
            }
        }
        return true
    }
    
    func removeAllRatingsFromDisk() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName: "Rating")
        do {
            var ratingList = try managedContext.executeFetchRequest(request)
            for rating in ratingList {
                managedContext.deleteObject(rating as! NSManagedObject)
            }
            ratingList.removeAll(keepCapacity: false)
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

}