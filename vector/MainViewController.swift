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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let locationManager = CLLocationManager()

	@IBOutlet weak var mapView: GMSMapView!
	
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var mapView: MKMapView! // NOT SURE IF THIS IS CORRECT FOR GOOGLE API
    
    @IBAction func onFriends(sender: AnyObject) {
        // GO TO FRIENDS LIST VIEW CONTROLLER
    }
    @IBAction func onCalcPoint(sender: AnyObject) {
        // GO TO LOCATION DETAILS VIEW
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
			
			locationManager.delegate = self
			locationManager.requestWhenInUseAuthorization()

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
	// 2
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		// 3
		if status == .AuthorizedWhenInUse {
			
			// 4
			locationManager.startUpdatingLocation()
			
			//5
			mapView.myLocationEnabled = true
			mapView.settings.myLocationButton = true
		}
	}
	
	// 6
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			
			// 7
			mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
			
			// 8
			locationManager.stopUpdatingLocation()
		}
		
	}
}

