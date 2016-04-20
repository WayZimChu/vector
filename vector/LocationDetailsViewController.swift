//
//  LocationDetailsViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse
import MapKit

protocol LocationDetailsViewControllerDelegate : class {
	func vectored(controller: LocationDetailsViewController, encodedPolyline: String)
}

class LocationDetailsViewController: UIViewController, GMSPanoramaViewDelegate {
	
	@IBOutlet weak var locationName: UILabel!
	@IBOutlet weak var locationCategory: UILabel!
	@IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var locationDistFromYou: UILabel!
	
	@IBOutlet weak var locationPhoneNum: UITextView!
    @IBOutlet weak var openNowLabel: UILabel!
	
	@IBOutlet weak var locationIcon: UIImageView!
	@IBOutlet weak var phoneIcon: UIImageView!
	@IBOutlet weak var clockIcon: UIImageView!
	
	
	@IBOutlet weak var panoV: GMSPanoramaView!
	
	var placeHolder: GooglePlace!
	var myObject: PFObject?
	var dataMachine: GoogleDataProvider!
	weak var delegate : LocationDetailsViewControllerDelegate!
    var locationManager = CLLocationManager()
	var m = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		panoV.moveNearCoordinate(placeHolder.coordinate)
		panoV.delegate = self
		
		locationName.text = placeHolder.name
		locationAddress.text = placeHolder.address
		locationPhoneNum.text = placeHolder.phoneNum
		dataMachine = GoogleDataProvider()
		let myLat = myObject!.valueForKey("latitude") as! Double
		let myLong = myObject!.valueForKey("longitude") as! Double
		let friendLat = placeHolder.coordinate.latitude
		let friendLong = placeHolder.coordinate.longitude
        
        let distance = calcDistTwoPoints(CLLocationCoordinate2DMake(myLat, myLong), point2: placeHolder.coordinate)
        locationDistFromYou.text = NSString(format: "%.2f miles away", distance) as String
        
        // Logic to turn bool into some text for if place is currently open
        placeHolder.openNow ? (openNowLabel.text = "Open Now") : (openNowLabel.text = "Closed")
        
        locationCategory.text = ""
        for type in placeHolder.categories {
            locationCategory.text = locationCategory.text! + "\(type) "
        }
		
		self.dataMachine?.fetchDirection(myLat, myLong: myLong,theirLat: friendLat,theirLong: friendLong) {
			g in
			print("inside locations view from closure \(g)")
			self.m = g
		}
		
		
	}
	
	@IBAction func vectorMe(sender: AnyObject) {
		//print(myObject)
		//print(placeHolder)
		//print("this is g: \(m)")
		delegate.vectored(self, encodedPolyline: m)
	}
    
    /* MARK: - Distance between two coordinates function
    *          Returns a Double: distance in miles between two coordinates
    *          Parameters: CLLocationCoordinate2D, CLLocationCoordinate2D
    */
    func calcDistTwoPoints(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        let a: MKMapPoint = MKMapPointForCoordinate(point1)
        let b: MKMapPoint = MKMapPointForCoordinate(point2)
        let distance: Double = MKMetersBetweenMapPoints(a, b)
        
        //print("DISTANCE IN MILES::::::: \(distance/1609.34)")
        return distance/1609.34 // Convert meters to miles
    }
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
	}
	
}