//
//  MealDateViewController.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/2/16.
//
//

import Foundation
import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class MealDateViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    


    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetDate()
        if let meal = meal {
            navigationItem.title = meal.name
        }
    }
    
    @IBAction func unwindBackToDate(sender: UIStoryboardSegue) {
    }
    
    
    @IBAction func resetDate() {
        datePicker.date = Utils.roundDateToNearest10Min(NSDate())
    }

    
    func clearMeal() {
        meal = nil
        resetDate()
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if nextButton === sender {
            let date = datePicker.date
            meal!.date = date
            if let photoViewController = segue.destinationViewController as? MealPhotoViewController {
                photoViewController.meal = meal
            }
        }
    }
    
    
}