//
//  GoogleDataProvider.swift
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

class GoogleDataProvider {
  let apiKey = "AIzaSyCnIoj_O7MX-MKUI7kGiBuNvmfqt1UtCGo"
  var photoCache = [String:UIImage]()
  var placesTask: NSURLSessionDataTask?
  var directionsTask: NSURLSessionDataTask?
  var session: NSURLSession {
    return NSURLSession.sharedSession()
  }
  weak var delegate : LocationDetailsViewControllerDelegate!
    
    func fetchDirection(myLat: Double, myLong: Double, theirLat: Double, theirLong: Double, completion: ((String) -> Void )) -> ()
  {
    
    var urlString = "http://localhost:10000/maps/api/directions/json?origin=\(myLat),\(myLong)&destination=\(theirLat),\(theirLong)&key=\(apiKey)"
    urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    //print(urlString)
    if let task = directionsTask where task.taskIdentifier > 0 && task.state == .Running {
        task.cancel()
    }
   
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let request = NSURLRequest(URL: NSURL(string:urlString)!)
    let session = NSURLSession.sharedSession()
    var g = ""
    var f = NSDictionary()
    session.dataTaskWithRequest(request,
        completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            if error == nil {
                if let object = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                
                //print(object)
                
                let routes = object["routes"] as! [NSDictionary]
                for route in routes {
                     g = ((route["overview_polyline"]!["points"]!)!) as! String
                    //print(g)
                    //self.delegate.vectored(self, encodedPolyline: g)

                    

                }
                dispatch_async(dispatch_get_main_queue()) {
                   completion(g)
                    }
            }
            else {
                print("Direction API error")
            }
            }
            
    }).resume()
  }
  
  func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([GooglePlace]) -> Void)) -> ()
  {
    var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
    let typesString = types.count > 0 ? types.joinWithSeparator("|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    
    if let task = placesTask where task.taskIdentifier > 0 && task.state == .Running {
      task.cancel()
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      var placesArray = [GooglePlace]()
      if let aData = data {
        let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error: nil)
        //print("Error message: \(json["error_message"])")
        if let results = json["results"].arrayObject as? [[String : AnyObject]] {
            //print(results)
          for rawPlace in results {
            let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
            placesArray.append(place)
             //print(placesArray)
            if let reference = place.photoReference {
              self.fetchPhotoFromReference(reference) { image in
                place.photo = image
                
              }
          
            }
            
            }
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        completion(placesArray)
      }
    }
    self.placesTask!.resume()
  }
  
  
  func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> () {
    if let photo = photoCache[reference] as UIImage? {
      completion(photo)
    } else {
      let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      session.downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let url = url {
          let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url)!)
          self.photoCache[reference] = downloadedPhoto
          dispatch_async(dispatch_get_main_queue()) {
            completion(downloadedPhoto)
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            completion(nil)
          }
        }
        }.resume()
    }
  }
}
