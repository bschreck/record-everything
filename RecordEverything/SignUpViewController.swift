//
//  SignUpViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/13/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
class SignUpViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var signUpTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBAction func signup(sender: AnyObject) {
        if let username = self.signUpTextField.text,
            let password = self.passwordTextField.text,
            let password_check = self.passwordCheckTextField.text {
            if username != "" && password != "" && password == password_check {
                LoginService.sharedInstance.signupWithCompletionHandler(username, password: password) { (error) -> Void in
                    
                    if ((error) != nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertController(title: "Why are you doing this to me?!?", message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Main" : "SignUp";
                            
                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(controllerId) as UIViewController
                            let navController = UINavigationController(rootViewController: initViewController)
                            self.presentViewController(navController, animated:true, completion: nil)
                        })
                    }
                }
            }
            
        }
    }
}