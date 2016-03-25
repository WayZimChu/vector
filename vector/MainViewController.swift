//
//  MainViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import GoogleMaps

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate{
    var placeArray: GooglePlace?
    var dataMachine = GoogleDataProvider()
    var placesClient = GMSPlacesClient()
    var time: NSDate?
    
    let searchRadius: Double = 1000
    
	@IBOutlet weak var mapView: GMSMapView!
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBAction func onFriends(sender: AnyObject) {
		// GO TO FRIENDS LIST VIEW CONTROLLER
	}
	@IBAction func onCalcPoint(sender: AnyObject) {
		// GO TO LOCATION DETAILS VIEW
        print((locationManager.location?.coordinate)!)
        fetchLocations((locationManager.location?.coordinate)!)
	}
	
	let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		tableView.delegate = self
		tableView.dataSource = self
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
        
       // fetchLocations()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Replace this with number of friends!
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MainViewCell", forIndexPath: indexPath) as! MainViewCell
		
		// cell.user = users![indexPath.row] // USE SOMETHING LIKE THIS TO GET THE LIST OF FRIENDS DATA
		
		return cell
	}
    
    func fetchLocations(xy: CLLocationCoordinate2D) {
        dataMachine.fetchPlacesNearCoordinate(xy, radius: searchRadius, types: ["food", "pets", "coffee", "car repair"]){places in
            for place: GooglePlace in places {
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
            }
            
        }
    }
    
    func calculateMidpoint(arrayOfCoordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        // Get lat/long of all friends online, store into an array
        //    Do this in cellForRowAtIndexPath I think...
        // TEST DATA:::
        //let yourLocation = CLLocationCoordinate2DMake(37.7258391,-122.4507056) // CCSF Coordinates
        //let friend1Loc = CLLocationCoordinate2DMake(37.8049393,-122.4233581) // David's old address
        //let onlineCoordinates = [yourLocation, friend1Loc]
        let onlineCoordinates = arrayOfCoordinates
        
        // Let's calculate the center of gravity of everything in the onlineCoordinates array
        let π = M_PI
        var numCoordinates: Int = 0
        var combinedCartesianX: Double = 0.0
        var combinedCartesianY: Double = 0.0
        var combinedCartesianZ: Double = 0.0
        
        // Iterate through all online friends' coordinates
        for (location) in onlineCoordinates {
            numCoordinates++
            print("Lat: \(location.latitude) | Long: \(location.longitude)")
            let latRadians = location.latitude * (π/180)   // Convert Latitude to Radians
            let longRadians = location.longitude * (π/180) // Convert Longitude to Radians
            print("latRadians: \(latRadians)")
            print("longRadians: \(longRadians)")
            
            // Convert latitude and longitude to cartesian coordinates
            combinedCartesianX += (cos(latRadians) * cos(longRadians)) // Combined X Coordinate
            combinedCartesianY += (cos(latRadians) * sin(longRadians)) // Combined Y Coordinate
            combinedCartesianZ += sin(latRadians)
        }
        
        combinedCartesianX /= Double(numCoordinates)
        combinedCartesianY /= Double(numCoordinates)
        combinedCartesianZ /= Double(numCoordinates)
        print("combinedCartesianX: \(combinedCartesianX)")
        print("combinedCartesianY: \(combinedCartesianY)")
        print("combinedCartesianZ: \(combinedCartesianZ)")
        
        let midpointX = atan2(combinedCartesianZ, (sqrt(pow(combinedCartesianX, 2) + pow(combinedCartesianY, 2))))
        let midpointY = atan2(combinedCartesianY, combinedCartesianX)
        
        let midpointLatitude = (180/π) * midpointX  // Convert from radians to degrees
        let midpointLongitude = (180/π) * midpointY // Convert from radians to degrees
        
        print("Midpoint | Lat: \(midpointLatitude) | Long: \(midpointLongitude)")
        let midpoint = CLLocationCoordinate2DMake(midpointLatitude, midpointLongitude)
    
        return midpoint
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

extension MainViewController: CLLocationManagerDelegate {

	// called with authorization is granted or revoked
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
	// checks for location authorization
		if status == .AuthorizedWhenInUse {
			
			// updates live location
			locationManager.startUpdatingLocation()
			
			// enables blue loc dot & center on loc button
			mapView.myLocationEnabled = true
			mapView.settings.myLocationButton = true
		}
	}
	
	// called when new location data is received
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
		if let location = locations.last {
			time = NSDate()
			// center camera on user location
			mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
			//fetchLocations(location.coordinate)
            
			// turns off location updates
			// TODO: probably want to set this on a timer
			locationManager.stopUpdatingLocation()
            //print("Got IT")
        }
        
	}
}

