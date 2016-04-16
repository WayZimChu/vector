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
    var allUsers: [PFObject]?
    var friends: [PFObject]?
    var arrayUsernames: [String] = []
    var filteredUsers: [PFObject]?
    var myOwnObject: PFObject? // all updates revolve around this object
    var searchActive: Bool = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addFriendButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        checkFriendStatus()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadFriends()
        self.allUsers = loadProfiles()
        checkFriendStatus()
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
        
        cell.addFriendView.hidden = false
        
        if arrayUsernames.contains(user["lowercaseUsername"] as! String) {
            cell.addFriendView.hidden = true
        }
        
        if let profile = user.valueForKey("profilePic")! as? PFFile {
            profile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    cell.profileImage.image = image
                    
                    // Make profile picture circular
                    cell.profileImage.layer.masksToBounds = false
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
                    cell.profileImage.clipsToBounds = true
                    
                    print("Profile Picture Loaded")
                    
                }
            })
        }
        
        // Check if person is not a friend. If so then:
//        cell.addFriendButton.hidden = false
//        cell.removeFriendButton.hidden = true
        /* ELSE:
        cell.addFriendButton.hidden = true
        cell.removeFriendButton.hidden = false
        */
        
        return cell
    }
    
    
    /* MARK: - Search Bar Functions
     *
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        searchUsers(searchText.lowercaseString)
        
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
        query.whereKey("lowercaseUsername", containsString: searchText)
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
                        //print("OBJECT: \(object)")
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
                //print("Successfully retrieved \(objects!.count) Points In Time.")
                self.allUsers = objects
                self.tableView.reloadData()
                
                if let objects = objects {
                    for object in objects {
                       // print(object.objectId)
                        //print(object)
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
        let friendUserNames = myOwnObject!.valueForKey("friends") as? [String]
        print("FRIEND USER NAMES:::::: \(friendUserNames!)")
        
        let query = PFQuery(className: "Profile")
        
        query.whereKey("lowercaseUsername", containedIn: friendUserNames!)
        query.orderByAscending("lowercaseUsername")
        query.limit = 50
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.friends = objects
            self.tableView.reloadData()
            if error == nil {
                // The find succeeded!
                print("FRIENDS::: Successfully retrieved \(objects!.count) Points in time.")
                self.friends = objects
                self.tableView.reloadData()
                
                if objects != nil {
                    for object in objects! {
                        self.arrayUsernames.append(object.valueForKey("lowercaseUsername") as! String)
                        print("LOWERCASE USERNAMES: \(object.valueForKey("lowercaseUsername")!)")
                        print("lowercaseUsername: \(self.arrayUsernames)")
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        self.tableView.reloadData()
    }
    
    /* MARK: - Friend Request function
     *
     */
    @IBAction func onAddFriend(sender: AnyObject) {
        let cell = sender.superview!!.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        var data: [PFObject]?
        
        searchActive ? (data = filteredUsers) : (data = friends)
        
        let personToFriend = data![(indexPath?.row)!]
        //print(personToFriend)
        
        //This is used to update friends into PFObjects
        //print(personToFriend["lowercaseUsername"]!)
        myOwnObject!.addUniqueObjectsFromArray(["\(personToFriend["lowercaseUsername"]!)"], forKey:"friendAdd")
        myOwnObject!.saveInBackground()
        personToFriend.addUniqueObjectsFromArray(["\(myOwnObject!["lowercaseUsername"])"], forKey: "friendRequest")
        personToFriend.saveInBackground()
        
        checkFriendStatus()
        //personToFriend.addUniqueObjectsFromArray(["\(PFUser.currentUser()!.username!)"], forKey:"friends")
    }
    
    /* MARK: - Helper Function to check friendAdd and friendRequest
     *         Moves username over if both are the same so a user can have a friend
     */
    func checkFriendStatus() {
        let friendAdds = myOwnObject!.valueForKey("friendAdd") as? [String]
        let friendRequests = myOwnObject!.valueForKey("friendRequest") as? [String]
        var friendRequestsCount: Int
        var friendAddsCount: Int
        
        // Optional chain, to safely unwrap number of friend requests / friend counts
        if let freqCount = friendRequests?.count {
            friendRequestsCount = freqCount
        } else {
            friendRequestsCount = 0
        }
        
        if let fradCount = friendAdds?.count {
            friendAddsCount = fradCount
        } else {
            friendAddsCount = 0
        }
        
        // Search for same username in each friendAdds and friendRequests
        for (var i = 0; i < friendRequestsCount; i++) {
            for (var j = 0; j < friendAddsCount; j++) {
                if friendRequests![i] == friendAdds![j] {
                    // YAY, found a friend
                    myOwnObject!.removeObjectsInArray(["\(friendRequests![i])"], forKey: "friendRequest")
                    myOwnObject!.removeObjectsInArray(["\(friendAdds![j])"], forKey: "friendAdd")
                    myOwnObject!.addUniqueObjectsFromArray(["\(friendRequests![i])"], forKey: "friends")
                    myOwnObject!.saveInBackground()
                }
            }
        }
        
        print("FRIENDS::::: \(friends)")
    }
    
    /* MARK: - Add Friend
     *
     */
//    func addFriendClicked(friendsCell: FriendsViewCell) {
//        let person = friendsCell.person! as User
//        
//        let cell = sender.superview!!.superview as! UITableViewCell
//        let indexPath = tableView.indexPathForCell(cell)
//        let personToFriend = allUsers![(indexPath?.row)!]
//        print(personToFriend)
//        
//        //This is used to update friends into own object
//        print(personToFriend["username"]!)
//        myOwnObject!.addUniqueObjectsFromArray(["\(personToFriend["username"]!)"], forKey:"friends")
//        myOwnObject!.saveInBackground()
//        //personToFriend.addUniqueObjectsFromArray(["\(PFUser.currentUser()!.username!)"], forKey:"friends")
//    }
    
    /* MARK: - Remove Friend
    *
    */
//    func removeFriendClicked(friendsCell: FriendsViewCell) {
//        // TO DO:
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


