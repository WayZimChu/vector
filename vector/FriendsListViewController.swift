//
//  FriendsListViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

let userDidLogoutNotification = "userDidLogoutNotification"

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onAddFriend(sender: AnyObject) {
        // MODALLY PRESENT ADD FRIEND VIEW CONTROLLER
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @IBAction func onLogout(sender: AnyObject) {
        print("Logging out user: \(PFUser.currentUser()!.username!)")
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
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
