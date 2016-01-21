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
                    
                    if ((error) != nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertController(title: "Why are you doing this to me?!?", message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        
                    } else {
                        
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