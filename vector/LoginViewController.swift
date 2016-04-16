//
//  LoginViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse
import VideoSplashKit

class LoginViewController: VideoSplashViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var signUpButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource(nil, ofType: "mp4")!)
        
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = true
        self.startTime = 0.0
        self.duration = 12.0
        self.alpha = 1
        self.backgroundColor = UIColor.blackColor()
        self.contentURL = url
        self.restartForeground = true

        // Do any additional setup after loading the view.
        
        // Round the edges of the buttons
        loginButtonView.layer.cornerRadius = 3
        loginButtonView.clipsToBounds = true
        signUpButtonView.layer.cornerRadius = 3
        signUpButtonView.clipsToBounds = true
        
        //displayKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayKeyboard() {
        self.usernameTextField.becomeFirstResponder()
    }

    @IBAction func onLogin(sender: AnyObject) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("Logging in user: \(PFUser.currentUser()!.username!)")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else {
                print("Username is required")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
