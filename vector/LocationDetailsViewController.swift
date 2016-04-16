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

protocol LocationDetailsViewControllerDelegate : class {
    func vectored(controller: LocationDetailsViewController, encodedPolyline: String)
}

class LocationDetailsViewController: UIViewController, GMSPanoramaViewDelegate {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationCategory: UILabel!
    @IBOutlet weak var distFromMiddle: UILabel!
    @IBOutlet weak var openForLabel: UILabel!
    @IBOutlet weak var locationDiscription: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var locationPhoneNum: UILabel! // MAKE THIS A TEXT VIEW LATER TO GET PHONE USEABILITY
    @IBOutlet weak var locationHoursLabel: UILabel!
    
    @IBOutlet weak var thumbsUp: UIImageView!
    @IBOutlet weak var thumbsDown: UIImageView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var clockIcon: UIImageView!
    

    @IBOutlet weak var panoV: GMSPanoramaView!
    
    var placeHolder: GooglePlace!
    var myObject: PFObject?
    var dataMachine: GoogleDataProvider!
    weak var delegate : LocationDetailsViewControllerDelegate!
    var m = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panoV.moveNearCoordinate(placeHolder.coordinate)
        panoV.delegate = self
        
        locationName.text = placeHolder.name
        locationAddress.text = placeHolder.address
        locationPhoneNum.text = placeHolder.phoneNum
        dataMachine = GoogleDataProvider()
        let a = myObject!.valueForKey("latitude") as! Double
        let b = myObject!.valueForKey("longitude") as! Double
        let c = placeHolder.coordinate.latitude
        let d = placeHolder.coordinate.longitude

        self.dataMachine?.fetchDirection(a,myLong: b,theirLat: c,theirLong: d){
            g in
            print("inside locations view from closure \(g)")
            self.m = g
        }


    }
    
    @IBAction func vectorMe(sender: AnyObject) {
        print(myObject)
        print(placeHolder)

        
        print("this is g: \(m)")
        delegate.vectored(self, encodedPolyline: m)
        

        
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
