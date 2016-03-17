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
    var name: String?
    var profilePicture: UIImage?
    var phone: String?
    var latitude: Double?
    var longitude: Double?
    var destination: String?
    var friends: [String]?
    var friendRequest: [String]?
    var friendAdd: [String]?

    override init() {
        super.init()
    }
    
    
}



