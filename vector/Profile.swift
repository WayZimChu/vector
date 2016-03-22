//
//  Profile.swift
//  vector
//
//  Created by David Wayman on 3/22/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

class Profile: NSObject {
    /**
     * Other methods
     */
     
     /**
     Method to add a user profile to Parse (uploading a profile)
     
     - parameter image: Profile Image that the user wants upload to parse
     - parameter firstname: firstname of user
     - parameter lastname: lastname of user
     - parameter phonenum: phonenum of user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postNewProfile(image: UIImage?, withFirstname firstname: String?, withLastname lastname: String?, withPhoneNum phonenum: String?, withCompletion completion: PFBooleanResultBlock?) {
        let latitude: Double = 0.0 // TODO: GET CURRENT LOCATION AND SET THIS NUMBER
        let longitude: Double = 0.0 // TODO: GET CURRENT LOCATION AND SET THIS NUMBER
        let destination: String = ""
        let friends: [String] = [""]
        let friendRequest: [String] = [""]
        let friendAdd: [String] = [""]
        
        // Create Parse object PFObject
        let profile = PFObject(className: "Profile")
        
        // Add relevant fields to the object
        profile["username"] = PFUser.currentUser()?.username!
        profile["firstname"] = firstname
        profile["lastname"] = lastname
        profile["phonenum"] = phonenum
        profile["profilePic"] = getPFFileFromImage(image) // PFFile column type
        profile["latitude"] = latitude
        profile["longitude"] = longitude
        profile["destination"] = destination
        profile["friends"] = friends
        profile["friendRequest"] = friendRequest
        profile["friendAdd"] = friendAdd
        
        // Save object (following function will save the object in Parse asynchronously)
        profile.saveInBackgroundWithBlock(completion)
    }
    
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

}
