//
//  GooglePlace.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GooglePlace {
  let name: String
  let address: String
  let coordinate: CLLocationCoordinate2D
  let placeType: String
  let phoneNum: String
  let rating: String
  let priceLevel: Int
  var categories: [String] = []
  let openNow: Bool
  var photoReference: String?
  var photo: UIImage?
  
  init(dictionary:[String : AnyObject], acceptedTypes: [String]) {
    // Let's use a dictionary to nicely format the strings in categories
    let typesDict: [String : String] = [
        "bakery" : "Bakery",
        "bar" : "Bar",
        "cafe" : "Cafe",
        "grocery_or_supermarket" : "Grocery",
        "restaurant" : "Restaurant"
    ]
    
    let json = JSON(dictionary)
    //print(json)
    rating = json["rating"].stringValue
    name = json["name"].stringValue
    address = json["formatted_address"].stringValue
    phoneNum = json["formatted_phone_number"].stringValue
    openNow = json["opening_hours"]["open_now"].boolValue
    priceLevel = json["price_level"].intValue
    
    let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
    let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
    coordinate = CLLocationCoordinate2DMake(lat, lng)
    
    photoReference = json["photos"][0]["photo_reference"].string
    
    var foundType = "restaurant"
    let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    for type in json["types"].arrayObject as! [String] {
      if possibleTypes.contains(type) {
        categories.append(typesDict[type]!)
        foundType = type
        break
      }
    }
    placeType = foundType
    }
}


