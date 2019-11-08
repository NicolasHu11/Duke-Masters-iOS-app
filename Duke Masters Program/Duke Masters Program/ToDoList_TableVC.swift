//
//  ToDoList_TableVC.swift
//  ToDoList_PJ
//
//  Created by student on 11/6/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class ToDoList_TableVC: UITableViewController {
    var fresh_grad =  String()
//    var checklist = [[String]]()
    var checklist = [Checklistitem]()
    func initaildata(){
        
    //========Method 1 Use TXT to keep data============
//        print("Fall 2019 " + fresh_grad + " Checklist")
//        let path = Bundle.main.path(forResource: "Fall 2019 " + fresh_grad + " Checklist", ofType: "txt")
//                let filemagr = FileManager.default
//                if filemagr.fileExists(atPath: path!){
//                    do{
//                        let fulltext = try String( contentsOfFile: path!, encoding: String.Encoding.ascii)
//                        let readings = fulltext.components(separatedBy: "\n") as [String]
//                        for i in 1..<(readings.count-1){
//                            var temp = [String]()
//                            let item = readings[i].components(separatedBy: "\t")
//                            print("每一列：", item)
//                            temp.append(item[0]) //  Item Name
//                            temp.append(item[1])// Due Date
//
//                            checklist.append(temp)
//                            print("\(checklist)")
//                        }
//
//                    }
//                    catch let error as NSError{
//                        print("Error:\(error)")
//                    }
//        }
        //=========medthod 2 JSON============
       if let tempList = Checklistitem.loadChecklist()  {
        checklist = tempList
        print("loaded successed")
        if checklist.count != 7{
            print(checklist.count)
            print("loaded failed, saved file doesn't have the entire list")
            for i in checklist.count..<7{
                checklist.append(firstyear_list[i])
            }
        let _ = Checklistitem.encodeChecklist(checklist)

        }
        
       }
       else{
        checklist.append(test1)
        checklist.append(test2)
        checklist.append(test3)
        checklist.append(test4)
        checklist.append(test5)
        checklist.append(test6)
        checklist.append(test7)
        print("loaded failed, inital ")
        
        let _ = Checklistitem.encodeChecklist(checklist)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("init: grad or fresh \(fresh_grad)")
        initaildata()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return checklist.count
        
    }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let Item_Info = checklist[indexPath.row]
        cell.completed_cell = Item_Info.completed
        // if item is completed, word turns gray
        if cell.completed_cell{
            cell.ItemName?.textColor = .gray
            cell.ItemDate?.textColor = .gray
        }
        else{
            cell.ItemName?.textColor = .black
            cell.ItemDate?.textColor = .black

            }
        cell.ItemName?.text = Item_Info.itemname
            cell.ItemDate?.text = Item_Info.date
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView,
      trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
      ->   UISwipeActionsConfiguration? {
        print("Swipe Action")
      // Get current state from data source
        print("\(String(describing: checklist[indexPath.row].completed))")
        guard let complete_or_not = checklist[indexPath.row].completed else {
        return nil
      }
        // if this item is completed, show uncompleted button
      let title = complete_or_not ?
        NSLocalizedString("Uncompleted", comment: "Uncompleted"):
        NSLocalizedString("Completed", comment: "Completed")

      let action = UIContextualAction(style: .normal, title: title,
        handler: { (action, view, completionHandler) in
        // Update data source when user taps action
            self.checklist[indexPath.row].completed = !self.checklist[indexPath.row].completed
            let _ = Checklistitem.encodeChecklist(self.checklist)
        self.tableView.reloadData()
        completionHandler(true)
            
      })

//      action.image = UIImage(named: "heart")
      action.backgroundColor = complete_or_not ? .red : .green
     let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
      return configuration
    }
    //MARK:==========保存completed状态==================
    
    
    
    // MARK: - Navigation
    @IBAction func unwindListTableView(segue: UIStoryboardSegue){
        // When returned from fromer segue
        self.tableView.reloadData()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "Detail_segue") {
            guard let vc = segue.destination as? Detail_VC else {
                return
            }

            //Get the Index of selected Cell
            guard let indexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
           
            //assign string to next view controller instance from selected cell.
            
            vc.Name_fromtable = checklist[indexPath.row].itemname
            vc.Descri_fromtable = checklist[indexPath.row].Description
            
        }
    }
    

}
