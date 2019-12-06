//
//  DirectoryTableVC.swift
//  MEM_directory
//
//  Created by student on 10/26/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class DirectoryTableVC: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    var student_dict =  [String:String]()
    var studentarray = [[String]]()
    var Result = [[String]]()
    var signal_write = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SearchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let path = Bundle.main.path(forResource: "Fall 2019 MEM Students_MStxt", ofType: "txt")
        let filemagr = FileManager.default
        if filemagr.fileExists(atPath: path!){
            do{
                let fulltext = try String( contentsOfFile: path!, encoding: String.Encoding.utf8)
                let readings = fulltext.components(separatedBy: "\n") as [String]
                for i in 1..<(readings.count-1){
                    var temp = [String]()
                    let studentdata = readings[i].components(separatedBy: "\t")
//                    print("每一列：", studentdata)
                    temp.append(studentdata[0]) // First Name
                    temp.append(studentdata[1])// Last Name
                    temp.append(studentdata[2]) // Admit Term
                    temp.append(studentdata[3]) // Email
                    temp.append(studentdata[4]) // Project
                    temp.append(studentdata[5]) // MS/MENG
                    studentarray.append(temp)

                }

            }
            catch let error as NSError{
                print("Error:\(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if signal_write {
//            print("search result 0:", Result[0])
        // #warning Incomplete implementation, return the number of rows
            return Result.count
        }
        else{
            return studentarray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var student_Info = [String]()
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
            as! DirectoryTableViewCell
        if signal_write {
            if Result.count > 0 {
         student_Info  = Result[indexPath.row]
            }
            else {
                print(cell)
                return cell
            }
        }
        else{
            student_Info = studentarray[indexPath.row]
        }
        let first = student_Info[0]
        let last = student_Info[1]
        cell.Cell_Label?.text = first + " " + last
//        let Email = student_Info[2]
        let Term =  student_Info[3]
        let proj =  student_Info[4]
        let MS_MEN =  student_Info[5]
        // Configure the cell...
        cell.Cell_Description?.text = "\(Term), \(MS_MEN) student from \(proj)"
        // pic info
//        cell.Cell_Image.image = UIImage(contentsOfFile: "bluedevils")
        // copy current student info
        return cell
    }
    
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
    // MARK: unwind segue and reload data
    @IBAction func unwindPersonListTableView(segue: UIStoryboardSegue){
        // When returned from fromer segue
        self.tableView.reloadData()
    }
    
     //MARK: - Navigation

//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier == "toinformation") {
                guard let vc = segue.destination as? InfoVC else {
                    return
                }

                //Get the Index of selected Cell
                guard let indexPath = self.tableView.indexPathForSelectedRow else {
                    return
                }
               
                //assign string to next view controller instance from selected cell.
                if signal_write {
                vc.Name_fromtable = "\(Result[indexPath.row][0])" + " \(Result[indexPath.row][1])"
                vc.Email_fromtable = Result[indexPath.row][2]
                }
                else{
                    vc.Name_fromtable = "\(studentarray[indexPath.row][0])" + " \(studentarray[indexPath.row][1])"
                    vc.Email_fromtable = studentarray[indexPath.row][2]
                }
            }
        }
        
    
// Search Bar
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print("text input:", searchText)

    if searchText == "" {
        Result = studentarray
        signal_write = false
    }
    else { //
        signal_write = true
        self.Result = []
        for student in studentarray {
            let studentname = student[0] + " " + student[1]
            if studentname.lowercased().hasPrefix(searchText.lowercased()) {
                Result.append(student)
            }
        }
    }
    if Result.count>0{
        print("search result 0: input", Result[0])
    }
    self.tableView.reloadData()
}

    

}
