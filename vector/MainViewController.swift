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
import Parse

class MainViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	var placeArray: GooglePlace?
	var dataMachine = GoogleDataProvider()
	var placesClient: GMSPlacesClient?
	var time: NSDate?
	var users: [PFObject]?
	var myOwnObject: PFObject? //All update functions revolve around this object.
	
	let meetingPlaceTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
	
	let searchRadius: Double = 1000
	
	@IBOutlet weak var mapView: GMSMapView!
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var markerInfoView: MarkerInfoView!
	
	@IBAction func onFriends(sender: AnyObject) {
		// GO TO FRIENDS LIST VIEW CONTROLLER
	}
	@IBAction func onCalcPoint(sender: AnyObject) {
		// GO TO LOCATION DETAILS VIEW
       //print((locationManager.location?.coordinate)!)
        self.tableView.reloadData();
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
        self.addSlideMenuButton()
		tableView.delegate = self
		tableView.dataSource = self
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		placesClient = GMSPlacesClient()
		self.tableView.reloadData()
		//print(users)
		// fetchLocations()
		print("%%%%% \((PFUser.currentUser()?.username!)!)")
		loadOwnObject((PFUser.currentUser()?.username!)!)
		
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			// do some task
//			self.recursiveUpdate()
			dispatch_async(dispatch_get_main_queue()) {
				// update some UI
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		self.users = loadProfiles()
		print("#### \(users)")
		self.tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
//	func recursiveUpdate()
//	{
//		sleep(10)
//		print(self.myOwnObject?.objectId)
//		Post.updateLocation((myOwnObject?.objectId!)!, long: (locationManager.location?.coordinate.longitude)!, lat: (locationManager.location?.coordinate.latitude)!)
//		sleep(30)
//		recursiveUpdate()
//	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let users = users {
			return users.count
		}
		else {
			return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MainViewCell", forIndexPath: indexPath) as! MainViewCell
		let user = users![indexPath.row]
		cell.nameLabel.text = user["username"] as? String
		
		if let profile = user.valueForKey("profilePic")! as? PFFile {
			profile.getDataInBackgroundWithBlock({
				(imageData: NSData?, error: NSError?) -> Void in
				if (error == nil) {
					let image = UIImage(data:imageData!)
					cell.profileImage.image = image
					
					print("Profile Picture Loaded")
				}
			})
		}
		
		return cell
	}
	
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Fetch locations called")
        let otherUser = users![indexPath.row]
        let myLocation = locationManager.location?.coordinate
        let otherLocation = CLLocationCoordinate2DMake(otherUser["latitude"] as! Double, otherUser["longitude"] as! Double)
        let midpoint = calculateMidpoint([myLocation!, otherLocation])
        fetchLocations(midpoint)
        mapView.animateToLocation(midpoint)
    }
	
	
	
	func fetchLocations(coord: CLLocationCoordinate2D) {
		dataMachine.fetchPlacesNearCoordinate(coord, radius: searchRadius, types: meetingPlaceTypes){places in
			for place: GooglePlace in places {
				let marker = PlaceMarker(place: place)
				let markerView = MarkerInfoView()
				
				// marker icon control
    marker.title = "💩 " + place.name + " 💩"
				if let placeImage = UIImage(named: place.placeType)?.imageWithRenderingMode(.AlwaysTemplate) {
					marker.icon = placeImage
				} else {
					marker.icon = UIImage(named: "Generic")
				}
				
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
	/** loads profile owner's profile object so it can be updated
     *
     */
    func loadOwnObject(myName: String){
        var user:  PFObject?
        let query = PFQuery(className: "Profile")
        query.whereKey("username", containsString: myName)
        query.limit = 1
        query.findObjectsInBackgroundWithBlock {
            (object: [PFObject]?, error: NSError?) -> Void in
            user = object![0]
            if error == nil {
                //The find succeeded.
                print("Successfully retrieved my own object \(user)")
                self.myOwnObject = user
            }
        }
    }
    
    func loadProfiles() -> [PFObject]? {
        
        var user: [PFObject]?
        let query = PFQuery(className:"Profile")
        //query.whereKey("name", equalTo: "\(name)")
        
        //This query will check to see who has your name under friends and return those profile objects
        query.whereKey("friends",   containedIn: ["\((PFUser.currentUser()?.username!)!)"])
        query.orderByDescending("createdAt")
        //query.includeKey("username")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            user = objects
            self.tableView.reloadData()
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) Points In Time.")
                self.users = objects
                self.tableView.reloadData()
                
                if let objects = objects {
                    for object in objects {
                        //print(object.objectId)
                        print(object)
                    }
                }
                
                
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        return user
        
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toFriendView" {
            let destinationNavigationController = segue.destinationViewController as! FriendsListViewController
            destinationNavigationController.myOwnObject = self.myOwnObject!
        }
    }

	
}

extension MainViewController: GMSMapViewDelegate {
	func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
		let placeMarker = marker as! PlaceMarker
        
		print("in mapView extension")
		/*
		
		// attempts at marker view
		markerView.nameLabel.text = place.name
		if let placePhoto = UIImage(named: place.photoReference!)?.imageWithRenderingMode(.AlwaysTemplate) {
			print("found photo" + place.photoReference!)
			markerView.image = placePhoto
		} else {
			print("looked for a photo")
			markerView.image = nil
		}
		markerView.icon = UIImage(named: "unknown_travel")
*/
		if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
			infoView.nameLabel.text = placeMarker.place.name
			
			if let photo = placeMarker.place.photo {
				print("found a photo " + placeMarker.place.photoReference!)
				infoView.image = photo
			} else {
				print("this is not a photo " + (placeMarker.place.photoReference)!)
				infoView.image = UIImage(named: "nothing")
			}
			
			view.addSubview(infoView);
			
			return infoView
		} else {
			return nil
		}
	}
	
	func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
            mapView.selectedMarker = nil
            return false
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
			//fetchLocations(location.coordinate)
			
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
