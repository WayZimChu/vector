//
//  SignUpViewController.swift
//  vector
//
//  Created by David Wayman on 3/22/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phonenumTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
        // TODO: Add firstname, lastname, phonenum to Parse backend
        //       Also upload profile photo to Parse backend
        
        let username = usernameTextField.text! ?? ""
        let password = passwordTextField.text! ?? ""
        let firstname = firstnameTextField.text! ?? ""
        let lastname = lastnameTextField.text! ?? ""
        let phonenum = phonenumTextField.text! ?? ""
        
        if username != "" && password != "" &&
           firstname != "" && lastname != "" && phonenum != "" {
            // sign up user
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            
            newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Yay created a user")
                    let profilePic = self.profileImageView.image!
                    let image = Profile.resize(profilePic, newSize: CGSize(width: 200, height: 200))
                    
                    Profile.postNewProfile(image, withFirstname: firstname, withLastname: lastname, withPhoneNum: phonenum) { (success: Bool, error: NSError?) -> Void in
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        self.performSegueWithIdentifier("signUpComplete", sender: nil) // TODO: Change segue to actual segue
                    }
                } else {
                    print(error?.localizedDescription)
                    if error?.code == 202 {
                        print("Username is taken")
                    }
                }
            }
        } else {
            print("Please enter a username and password to sign up")
        }
        
    }
    
    func onTakePicture() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func onChooseFromLib() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onProfilePicCancel(sender: AnyObject) {
        // TODO: Animate Take Picture, Choose Library, and Cancel button
        //       to disappear off screen. Keyboard should come up maybe?
        self.dismissViewControllerAnimated(true, completion:  nil)
    }
    
    func imageTapped(img: AnyObject) {
        print("Profile pic image tapped")
        // TODO: Animate Take Picture, Choose from Library, and Cancel buttons
        //       To slide up on screen. Make sure to dismiss keyboard too.
        
        view.endEditing(true) // Gets rid of keyboard
        
        openActionSheet()
    }
    
    func openActionSheet() {
        // UIAlertController Action Sheet
        let alertController = UIAlertController(title: nil, message: "Set Profile Picture", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        
        let choosePicAction = UIAlertAction(title: "Choose From Library", style: .Default) { (action) in
            self.onChooseFromLib()
        }
        
        let takePicAction = UIAlertAction(title: "Take Picture", style: .Default) { (action) in
            self.onTakePicture()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(choosePicAction)
        alertController.addAction(takePicAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            // Get the image captured by the UIImagePickerController
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            
            // Do something with the images (based on your use case)
            profileImageView.image =  editedImage
            
            // Dismiss UIImagePickerController to go back to your original view controller
            dismissViewControllerAnimated(true, completion: nil)
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
