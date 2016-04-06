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
    
    class func updateLocation(ID: String, long: Double, lat: Double) {
        let query = PFQuery(className:"Profile")
        query.getObjectInBackgroundWithId("\(ID)") {
            (profileObject: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let profileObject = profileObject {
                profileObject["longitude"] = long
                profileObject["latitude"] = lat
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
