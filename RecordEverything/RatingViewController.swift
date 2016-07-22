//
//  RatingViewController.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/9/16.
//
//

import Foundation
import UIKit
import RealmSwift

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
    var realm = try! Realm()
    
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
        print("realm:",realm.path)
        
        
        loadUnsavedRatingsFromDisk()
        
        
        // Enable the Save button only if rating is greater than 0
        checkValidRating()
    }

    @IBAction func save(sender: AnyObject) {
        let date = Utils.roundDateToNearest10Min(datePicker.date)
        let rating = Rating(value: ["id": Utils.newUUID(), "rating": ratingControl.rating, "date": date, "type": self.type])
        print("after creating rating")
        print(rating.id)
        let ratingsToSave = unsavedRatings + [rating]
        print("ratings to save:",ratingsToSave)
        unsavedRatings = []
        clearRating()
        
        for (index,unsavedRating) in ratingsToSave.enumerate(){
            print("saving rating:",unsavedRating.id)
            unsavedRating.saveToServer({
                (responseObject:NSDictionary?, error:NSError?) in
                if let _error = error {
                    if _error.code == 600 {
                        print("Rating already exists")
                    } else {
                        print("unable to save rating (\(unsavedRating.rating),\(unsavedRating.date)) to server,",_error)
                        do {
                            let realm = try Realm()
                            try realm.write {
                                realm.add(unsavedRating)
                            }
                        } catch let error as NSError{
                            print("realm save error:",error)
                        }
                    }
                } else {
                    print(responseObject, error)
                    print("successfully saved to server")
                    if index < ratingsToSave.count-1 {
                        do {
                            let realm = try Realm()
                            try realm.write {
                                realm.delete(unsavedRating)
                            }
                        } catch let error as NSError{
                            print("realm save error:",error)
                        }
                    }
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
    
    func loadUnsavedRatingsFromDisk(){
        unsavedRatings = []
        let unsavedRatingsResult = realm.objects(Rating)
        print("--->loading unsaved ratings")
        for rating in unsavedRatingsResult {
            print("loading rating:",rating)
            unsavedRatings.append(rating)
        }
    }
    
    func removeAllRatingsFromDisk() {
        do {
            try realm.write {
                realm.delete(realm.objects(BowelMovement))
            }
        } catch let error as NSError{
            print("realm delete all error:",error)
        }
    }

}