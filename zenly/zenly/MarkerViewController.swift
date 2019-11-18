//
//  MarkerViewController.swift
//  zenly
//
//  Created by Lanqing on 11/16/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import Dispatch

class MarkerViewController: UIViewController {

  
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imageURL = ""
    @IBOutlet weak var title_field: UITextField!
    @IBOutlet weak var textView: UITextView!
    var phoneNumInE64: String = ""
    var marker = GMSMarker()
    var docRef: DocumentReference!
    var date = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setup()
    }
    
    func setup(){
        title_field.text = marker.title
        date = NSDate()
        let combinePosition = "la\(marker.position.latitude)lo\(marker.position.longitude)"
        docRef = Firestore.firestore().document("User/\(phoneNumInE64)/Event/\(combinePosition)")
        fetchData()
    }

    @IBAction func SaveButtonPressed(_ sender: Any) {
        let content = textView.text ?? ""
        let title = title_field.text ?? ""
        let position = marker.position
        let latitude = position.latitude
        let longitude = position.longitude
        let dataToSave: [String: Any] = ["content": content, "title": title, "latitude": latitude, "longitude": longitude, "date": date ]
        docRef.setData(dataToSave, completion: nil)
        uploadPhoto()
       // self.dismiss(animated: true)
    }
    //for test
    @IBAction func testimagesave(_ sender: Any) {
        uploadPhoto()
    }
    
    var imagePicker = UIImagePickerController()
    @IBAction func addImageButtonPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    //dismiss keyboard on tapping outside of text field
    override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?){
        self.view.endEditing(true)
    }
    func uploadPhoto(){
        let image_name = UUID().uuidString
        let imageRef = Storage.storage().reference(withPath: "image/\(image_name).jpg")
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 1.0) else{
            print("error in upload photo")
            return
        }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        imageRef.putData(data, metadata: uploadMetadata){ (downloadMetadata, error) in
            if error != nil{
                print("imageRef error")
                return
            }
            print("MetaData: \(String(describing: downloadMetadata))")
            imageRef.downloadURL(completion:{ (url, error) in
                if(error != nil){
                    print("error get \(String(describing: error))")
                    return
                }
                print("upload url:\(String(describing: url?.absoluteString))")
                self.imageURL = url?.absoluteString ?? ""
                let dataToSave: [String: Any] = ["URL": self.imageURL]
                self.docRef.updateData(dataToSave, completion: nil)
            })
        }
    }
    func fetchData(){
        docRef.getDocument(completion: { (docNapShot, error) in
            guard let docNapShot = docNapShot, docNapShot.exists else {return}
            let myData = docNapShot.data()
            let content = myData?["content"] as? String ?? ""
            let title = myData?["title"] as? String ?? ""
            let urlkey = myData?["URL"] as? String ?? ""
            self.title_field.text = title
            self.textView.text = content
            if let url = URL(string: urlkey){
                do{
                    let data = try Data(contentsOf: url)
                    self.imageView.image = UIImage(data: data)
                }catch let err{
                  print("Error in fetch data:\(err)")
                }
                
                
            }
        })
    }
}

extension MarkerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
