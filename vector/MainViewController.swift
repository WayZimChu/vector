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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var placeArray: GooglePlace?
    var dataMachine = GoogleDataProvider()
    var placesClient: GMSPlacesClient?
    var time: NSDate?
    let searchRadius: Double = 1000
	@IBOutlet weak var mapView: GMSMapView!
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBAction func onFriends(sender: AnyObject) {
		// GO TO FRIENDS LIST VIEW CONTROLLER
	}
	@IBAction func onCalcPoint(sender: AnyObject) {
		// GO TO LOCATION DETAILS VIEW
        //print((locationManager.location?.coordinate)!)
        fetchLocations((locationManager.location?.coordinate)!)
        placesClient?.currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
         //   self.nameLabel.text = "No current place"
           // self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                  //  self.nameLabel.text = place.name
                   // self.addressLabel.text = place.formattedAddress!.componentsSeparatedByString(", ")
                       // .joinWithSeparator("\n")
                    print("\(place.name) \(place.formattedAddress!.componentsSeparatedByString(", ").joinWithSeparator("\n"))")
                }
            }
        })
    }

	let locationManager = CLLocationManager()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		tableView.delegate = self
		tableView.dataSource = self
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient()
        
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
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
    

	
}

extension MainViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let placeMarker = marker as! PlaceMarker
    
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.name

            if let photo = placeMarker.place.photo {
                infoView.placePhoto.image = photo
            } else {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            
            return infoView
        } else {
            return nil
        }
    }
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
			fetchLocations(location.coordinate)
			// turns off location updates
			// TODO: probably want to set this on a timer
			locationManager.stopUpdatingLocation()
            //print("Got IT")
        }
        
	}
}

extension UIView {
    class func viewFromNibName(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}
