//
//  MarkerInfoView.swift
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

class MarkerInfoView: UIView {
  
	@IBOutlet var markerInfoView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var placePhoto: UIImageView!
	@IBOutlet weak var travelIcon: UIImageView!

	
	//	@IBOutlet weak var travelIcon: UIImageView!
	
	var label: String? {
		get { return nameLabel?.text }
		set { nameLabel.text = newValue }
	}
	
	var image: UIImage? {
		get { print("getting image")
			return placePhoto.image }
		set { placePhoto.image = newValue }
	}

	var icon: UIImage? {
		get { return travelIcon.image }
		set { travelIcon.image = newValue }
	}

	required init(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)!
		print ("initializing subviews")
		initSubviews()
	}
	
	override init (frame: CGRect) {
		super.init(frame: frame)
		initSubviews()
	}
	
	func initSubviews() {
		let nib = UINib(nibName: "MarkerInfoView", bundle: nil)
		//print("in subviews")
		nib.instantiateWithOwner(self, options: nil)
		markerInfoView.frame = frame
		addSubview(markerInfoView)
	}
}
