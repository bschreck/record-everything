//
//  HomeViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/11/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation

import UIKit
class LoginViewController: UIViewController {
    //TODO: FIGURE OUT LOGIC FOR WHEN CAN'T ACCESS SERVER (one thing to do is to save username and password last used)
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func login(sender: AnyObject) {
        if let username = self.loginTextField.text,
            let password = self.passwordTextField.text {
                if username != "" && password != "" {
        
                LoginService.sharedInstance.loginWithCompletionHandler(username, password: password) { (error) -> Void in
                    if ((error) != nil && (error! != "No Response")) {
                        print(error)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertController(title: "User or password not found", message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        
                    } else {
                        LoginService.sharedInstance.setDefaultRealmForUser(username)
                        //TODO: redo notifications
                       //Notification.scheduleNotifications()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Main" : "Login";
                            
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
    @IBAction func cancelSignOut(sender: UIStoryboardSegue) {
        LoginService.sharedInstance.signOut()
    }
}