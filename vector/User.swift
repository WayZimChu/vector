//
//  User.swift
//  vector
//
//  Created by EricDev on 3/10/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import AFNetworking
import Parse

class User: NSObject {
    var owner: PFUser?
    var userName: String?
    var lowercaseUserName: String?
    var firstname: String?
    var lastname: String?
    var profilePicture: UIImage?
    var phone: String?
    var latitude: Double?
    var longitude: Double?
    var destination: String?
    var friends: [String]?
    var friendRequest: [String]?
    var friendAdd: [String]?

    init(dictionary: NSDictionary) {
        userName = dictionary["username"] as? String
        lowercaseUserName = dictionary["lowercaseUsername"] as? String
        firstname = dictionary["firstname"] as? String
        lastname = dictionary["lastname"] as? String
        phone = dictionary["phonenum"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        destination = dictionary["destination"] as? String
        friends = dictionary["friends"] as? [String]
        friendRequest = dictionary["friendRequest"] as? [String]
        friendAdd = dictionary["friendAdd"] as? [String]
    }
    
    
}



