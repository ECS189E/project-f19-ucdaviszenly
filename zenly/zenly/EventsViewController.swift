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
    var docRef_1: DocumentReference!
    var selectedIndex = IndexPath()
    var titleVec = [String]()
    var urlVec = [String]()
    var timeVec = [String]()
    var pathVec = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("title vector is \(titleVec)")
//        docRef = Firestore.firestore().document("User/\(phoneNum)")
        diaryTable.delegate = self
        diaryTable.dataSource = self
        print("view did load: \(eventCount)")

    //Notification for removing deleted cell
        NotificationCenter.default.addObserver(self, selector: #selector(deleteList), name: NSNotification.Name(rawValue: "delete"), object: nil)
       }
    @objc func deleteList(notification: NSNotification){
        self.removeCell(indexPath: selectedIndex)
        
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventCount
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DiaryTableViewCell
        
        cell.cell_title.text = titleVec[indexPath.row]
        let urlkey = urlVec[indexPath.row]
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
        let markerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MarkerViewController") as! MarkerViewController
        markerVC.targetPath = pathVec[indexPath.row]
        self.selectedIndex = indexPath
        self.navigationController?.present(markerVC, animated: true)
    }
    func removeCell(indexPath: IndexPath){
        self.titleVec.remove(at: indexPath.row)
        self.urlVec.remove(at: indexPath.row)
        self.timeVec.remove(at: indexPath.row)
        self.pathVec.remove(at: indexPath.row)
        self.eventCount  = self.eventCount - 1
        self.diaryTable.deleteRows(at: [indexPath], with: .automatic)
    }
    //delete cell function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        //delete data in server
        let docRef_1 = Firestore.firestore().document(pathVec[indexPath.row])
        docRef_1.getDocument(completion: {(docNapShot, error) in
            guard let docNapShot = docNapShot, docNapShot.exists else {
                print("error in docnapshot, nothing to be deleted")
                
                return
            }
            let myData = docNapShot.data()
            let urlkey = myData?["URL"] as? String ?? ""
            if urlkey != "" {
                let storagePath = urlkey
                let imageRef = Storage.storage().reference(forURL: storagePath)
                imageRef.delete(completion: { error in
                    if error != nil{
                        print("no image to delete in server")
                    }
                    print("image deleted in server")
                })
                
            }
            docRef_1.delete()
            print("data deleted from server")
            self.removeCell(indexPath: indexPath)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),object: nil)
        })
        
        


      }
    }
    

    
    
}
