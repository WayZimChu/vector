//
//  Post.swift
//  vector
//
//  Created by EricDev on 3/10/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

class Post: NSObject {
    
    /**
     * Other methods
     */
     
     /**
     Method to add a user post to Parse (uploading image file)
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
//    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
//        // Create Parse object PFObject
//        let post = PFObject(className: "Post")
//        
//        // Add relevant fields to the object
//        post["media"] = getPFFileFromImage(image) // PFFile column type
//        post["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
//        post["caption"] = caption
//        post["likesCount"] = 0
//        post["commentsCount"] = 0
//        post["name"] = PFUser.currentUser()?.username!
//        
//        // Save object (following function will save the object in Parse asynchronously)
//        post.saveInBackgroundWithBlock(completion)
//    }
    
    class func postUserProfile(profile: PFObject, withCompletion completion: PFBooleanResultBlock?) {
        profile.saveInBackgroundWithBlock(completion)
    }
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    class func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func updateLocation(ID: String, long: Double, lat: Double) {
        let query = PFQuery(className:"Profile")
        query.getObjectInBackgroundWithId("\(ID)") {
            (profileObject: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let profileObject = profileObject {
                profileObject["longitude"] = long
                profileObject["latitutde"] = lat
                profileObject.saveInBackground()
            }
        }
    }
    
    class func updateProfile(ID: String, password: String?, firstname: String?,
        lastname: String?, phonenum: String?, profileImage: UIImage?) {
            let query = PFQuery(className: "Profile")
            query.getObjectInBackgroundWithId("\(ID)") {
                (profileObject: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let profileObject = profileObject {
                    
                    // Only update whatever is not nil
                    if password != nil {
                        profileObject["password"] = password
                    }
                    if firstname != nil {
                        profileObject["firstname"] = firstname
                    }
                    if lastname != nil {
                        profileObject["lastname"] = lastname
                    }
                    if phonenum != nil {
                        profileObject["phonenum"] = phonenum
                    }
                    if profileImage != nil {
                        profileObject["profilePic"] = Profile.getPFFileFromImage(profileImage) // PFFile column type
                    }
                    
                    profileObject.saveInBackground()
                }
            }
    }
}
