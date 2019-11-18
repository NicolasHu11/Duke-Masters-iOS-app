//
//  UsercCell.swift
//  Duke Masters Program
//
//  Created by student on 11/13/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import Firebase
  class UserCell: UITableViewCell {
    var message : User?{
        didSet{
            
            self.textLabel?.text = User.name
            self.detailTextLabel?.text = user.message
             
                    
                    
        }
    }
       override func layoutSubviews() {
           super.layoutSubviews()
           
           textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
           
           detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
       }
       /*
       let profileImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.layer.cornerRadius = 24
           imageView.layer.masksToBounds = true
           imageView.contentMode = .scaleAspectFill
           return imageView
       }()
       */
       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
           /*
           addSubview(profileImageView)
           
           //ios 9 constraint anchors
           //need x,y,width,height anchors
           profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
           profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
           profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
           profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
 */
       }
       
       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

