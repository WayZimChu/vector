//
//  FriendsListViewController.swift
//  vector
//
//  Created by David Wayman on 3/14/16.
//  Copyright © 2016 WayZimChu. All rights reserved.
//

import UIKit
import Parse

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var users: [PFObject]?
    var friends: [PFObject]?
    var filteredUsers: [PFObject]?
    var myOwnObject: PFObject? // all updates revolve around this object
    var searchActive: Bool = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        self.tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        loadFriends()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            print("SEARCH IS ACTIVE")
            if let filteredUsers = filteredUsers {
                return filteredUsers.count
            } else {
                return 0
            }
        } else {
            print("SEARCH IS NOT ACTIVE")
            if let friends = friends {
                return friends.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MainViewCell", forIndexPath: indexPath) as! MainViewCell
        var data: [PFObject]?
        
        searchActive ? (data = filteredUsers) : (data = friends)
        
        let user = data![indexPath.row]
        
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
    
    @IBAction func addFriend(sender: AnyObject) {
        let cell = sender.superview!!.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let personToFriend = users![(indexPath?.row)!]
        print(personToFriend)
        
        //This is used to update friends into own object
        print(personToFriend["username"]!)
        myOwnObject!.addUniqueObjectsFromArray(["\(personToFriend["username"]!)"], forKey:"friends")
        myOwnObject!.saveInBackground()
        //personToFriend.addUniqueObjectsFromArray(["\(PFUser.currentUser()!.username!)"], forKey:"friends")
    }
    
    /* MARK: - Search Bar Functions
     *
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        searchUsers(searchText)
        
        print("FILTERED USERS: \(filteredUsers)")
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        searchActive = false
        self.searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.searchBar.endEditing(true)
    }
    
    func searchUsers(searchText: String) {
        var user: [PFObject]?
        let query = PFQuery(className: "Profile")
        query.whereKey("username", containsString: searchText)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            user = objects
            if error == nil {
                // The find succeeded.
                self.filteredUsers = objects
                self.tableView.reloadData()
                if let objects = objects {
                    for object in objects {
                        print("OBJECT: \(object)")
                        self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    func loadProfiles() -> [PFObject]? {
        
        var user: [PFObject]?
        let query = PFQuery(className:"Profile")
        //query.whereKey("name", equalTo: "\(name)")
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
                       // print(object.objectId)
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
    
    /* MARK: - Load Friends
     * loads all PFObjects that are your friends
     */
    func loadFriends() {
        let query = PFQuery(className:"Profile")
        
        //This query will check to see who has your name under friends and return those profile objects
        query.whereKey("friends",   containedIn: ["\((PFUser.currentUser()?.username!)!)"])
        query.orderByDescending("createdAt")
        query.limit = 50
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.friends = objects
            self.tableView.reloadData()
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) Points In Time.")
                self.friends = objects
                self.tableView.reloadData()
                
                if let objects = objects {
                    for object in objects {
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


