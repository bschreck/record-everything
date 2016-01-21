//
//  MainViewController.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/9/16.
//
//

import Foundation
import UIKit
class MainViewController: UIViewController  {



    @IBAction func unwindAddMealCancel(sender: UIStoryboardSegue) {
        if let mealNameViewController = sender.sourceViewController as? MealNameViewController {
            mealNameViewController.clearMeal()
        }
    }
    @IBAction func unwindAddEnergyLevelCancel(sender: UIStoryboardSegue) {
        if let ratingViewController = sender.sourceViewController as? RatingViewController {
            ratingViewController.clearRating()
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
}