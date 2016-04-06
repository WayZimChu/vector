//
//  ProfileViewController.swift
//  vector
//
//  Created by David Wayman on 4/5/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phonenumTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var myOwnObject: PFObject? //All update functions revolve around this object.
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        firstnameTextField.text = myOwnObject!["firstname"] as? String
        lastnameTextField.text = myOwnObject!["lastname"] as? String
        phonenumTextField.text = myOwnObject!["phonenum"] as? String
        
        if let profile = myOwnObject!.valueForKey("profilePic")! as? PFFile {
            profile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    self.profileImageView.image = image
                    
                    print("Profile Picture Loaded")
                }
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveProfile(sender: AnyObject) {
        let password: String? = passwordTextField.text
        let firstname: String? = firstnameTextField.text
        let lastname: String? = lastnameTextField.text
        let phonenum: String? = phonenumTextField.text
        
        Post.updateProfile((myOwnObject?.objectId!)!, password: password, firstname: firstname, lastname: lastname, phonenum: phonenum, profileImage: profileImageView.image)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onTakePicture(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onChooseFromLib(sender: AnyObject) {
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
