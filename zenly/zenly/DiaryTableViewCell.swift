//
//  DiaryTableViewCell.swift
//  zenly
//
//  Created by Zirong Yu on 11/24/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import Firebase


class DiaryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var cell_title: UILabel!
    @IBOutlet weak var cell_time: UILabel!
    var cell_docRef: DocumentReference!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
            cell_docRef.getDocument(completion: {(docNapShot, error) in
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
                            print("Error in deletion from server")
                        }
                        print("Success in deletion from server")
                    })
                    
                }
                //delete data in firebase
                self.cell_docRef.delete()
                 let markerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MarkerViewController") as! MarkerViewController
                markerVC.delegate?.reload_data()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),object: nil)
                
                //delete data in table
                
                
            })
    }
}
