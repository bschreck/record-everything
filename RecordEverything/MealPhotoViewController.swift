//
//  MealPhotoViewController.swift
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

class MealPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Properties
    

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var meal: Meal?
    var nonDefaultPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonDefaultPhoto = false
        if let meal = meal {
            print("got here")
            navigationItem.title = meal.name
            
        }
        print("photo meal:",meal)
    }
    
    
    func clearMeal() {
        meal = nil
        photoImageView.image = UIImage(named:"defaultPhoto")
        nonDefaultPhoto = false
    }
    
    // MARK: UIImagePickerControllerDelegate

    

    // MARK: Actions
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        nonDefaultPhoto = true
        if meal != nil {
            meal!.photo = photoImageView.image
        } else {
            meal = Meal(name:"", type:"", photo:photoImageView.image,rating:0,date:nil)
        }
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        print("in select image")
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
            animated: true,
            completion: nil)
    }
    


    
}