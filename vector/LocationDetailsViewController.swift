//
//  LocationDetailsViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import GoogleMaps

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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panoV.moveNearCoordinate(placeHolder.coordinate)
        panoV.delegate = self
        
        locationName.text = placeHolder.name
        locationAddress.text = placeHolder.address
        locationPhoneNum.text = placeHolder.phoneNum
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
