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

class DateViewController: UIViewController, UINavigationControllerDelegate {


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
            Utils.dismissViewControllerAnimatedOnMainThread(self)
        }
    }
    
    @IBAction func cancelSelectDate(sender: AnyObject) {
        resetDate()
        Utils.dismissViewControllerAnimatedOnMainThread(self)
    }
    func clear() {
        resetDate()
    }
    
    
}