//
//  MarkerPopUpViewController.swift
//  zenly
//
//  Created by Lanqing on 11/20/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var diaryTable: UITableView!
    
    var phoneNum = ""
    var eventCount = 0
    var docRef: DocumentReference!

    var titleVec = [String]()
    var iconVec = [String]()
    var timeVec = [String]()
    var pathVec = [String]()
    var selectPathIndex = IndexPath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("title vector is \(titleVec)")
        docRef = Firestore.firestore().document("User/\(phoneNum)")
        diaryTable.delegate = self
        diaryTable.dataSource = self
        //reload table
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    @objc func loadList(notification: NSNotification){
        self.diaryTable.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventCount
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DiaryTableViewCell
        cell.cell_docRef = Firestore.firestore().document(pathVec[indexPath.row])
        cell.cell_title.text = titleVec[indexPath.row]
        let urlkey = iconVec[indexPath.row]
        if let url = URL(string: urlkey){
           do{
               let data = try Data(contentsOf: url)
               cell.cell_image.image = UIImage(data: data)
               
               print("Fetch image data success")
           }catch let err{
             print("Error in fetch data:\(err)")
           }
       }
       
        cell.cell_time.text = timeVec[indexPath.row]
        
        return cell
    }
    
    /* Method that tells the delegate that the specified row is now selected. */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(indexPath.section)
        self.selectPathIndex = indexPath
        let markerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MarkerViewController") as! MarkerViewController

       markerVC.targetPath = pathVec[indexPath.row]
        //markerVC.dismissFlag = true
       print("pathVec is \(pathVec[indexPath.row])")
       self.navigationController?.present(markerVC, animated: true)
    }
   
    
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//      if editingStyle == .delete {
//        print("Deleted")
//
////        self.cellList.remove(at: indexPath.row)
//        self.diaryTable.deleteRows(at: [indexPath], with: .automatic)
//      }
//    }
    
    
}
