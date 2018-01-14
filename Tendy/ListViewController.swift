//
//  ListViewController.swift
//  Tendy
//
//  Created by ATN on 02/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth




class ListViewController: SuperRevealViewController,UITableViewDelegate,UITableViewDataSource {
   
    //var  imgNoList:UIImage=#imageLiteral(resourceName: "no_chats")
    var imgNoList:UIImage=UIImage(named: "no chat image".localized)!
    var imgAnimation:UIImage!
    @IBOutlet weak var imgBackGround: UIImageView!
    @IBOutlet weak var tblList: UITableView!
    var arrProfile=[SObject]()
    var selectedMember:Profile?
    
    override func notificationReceived(data: [String: AnyObject]) {
        if (data["sender"] as? String) != nil{
            LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
        }
        print(data)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadList()
    }
 
   func loadList()
    {
        imgBackGround.image = nil

        if(arrProfile.count==0)
        {
            setNoPartners()
        }
        tblList.reloadData()
    }

    
    func setNoPartners()
    {
     imgBackGround.image = imgNoList
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMember=(arrProfile[indexPath.row] is ChatPartners) ? (arrProfile[indexPath.row] as! ChatPartners).profile :
            (arrProfile[indexPath.row] as! Profile)
        performSegue(withIdentifier: C.Segue.ChatSegue, sender:selectedMember)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ListCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.ListCell) as! ListCell
        cell.setCell( arrProfile[indexPath.row])
        return cell
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //  MARK: - Navigation
    
    //   In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if(segue.identifier==C.Segue.ChatSegue)
        {
            let chatViewController:ChatViewController = segue.destination as! ChatViewController
            chatViewController.member=sender as! Profile
        }
    }
}
