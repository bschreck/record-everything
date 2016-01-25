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
    
    var dateCallback: ((NSDate)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetDate()
    }
    
    @IBAction func unwindBackToDate(sender: UIStoryboardSegue) {
    }
    
    
    @IBAction func resetDate() {
        datePicker.date = Utils.roundDateToNearest10Min(NSDate())
    }

    @IBAction func selectDate(sender: UIButton) {
        if let dateCallback = dateCallback {
            dateCallback(datePicker.date)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelSelectDate(sender: AnyObject) {
        resetDate()
        dismissViewControllerAnimated(true, completion: nil)
    }
    func clearMeal() {
        resetDate()
    }
    
    
}