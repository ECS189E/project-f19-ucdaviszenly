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
import CoreML
import Vision
import ImageIO
//declare delegate
protocol markerdelegate{
    func reload_data()
}

class MarkerViewController: UIViewController {

  
    @IBOutlet weak var deleteMarkerBtn: UIButton!
    @IBOutlet weak var DoneBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var deletePhotoBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imageURL = ""
    @IBOutlet weak var title_field: UITextField!
    @IBOutlet weak var textView: UITextView!
    var phoneNumInE64: String = ""
    var icon: String = ""
    var marker = GMSMarker()
    var docRef: DocumentReference!
    var date = NSDate()
    var dateStr = ""
    var delegate: markerdelegate?
    var imageTook = UIImage()
    var targetPath = ""
    var latitude = ""
    var longitude = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        activityIndicator.isHidden = true
        latitude = "\(marker.position.latitude)"
        longitude = "\(marker.position.longitude)"
    }
    
    func setup(){
        date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateStr = dateFormatter.string(from: date as Date)
        
        if (targetPath != ""){
            docRef = Firestore.firestore().document(targetPath)
            fetchData()
        }else{
            title_field.text = marker.title
            if imageTook.size != CGSize(width: 0.0, height: 0.0) {
                imageView.image = imageTook
                objectDetection(image: imageTook)
                deletePhotoBtn.isHidden = false
            }else{
                deletePhotoBtn.isHidden = true
            }
            
            let combinePosition = "la\(marker.position.latitude)lo\(marker.position.longitude)"
            docRef = Firestore.firestore().document("User/\(phoneNumInE64)/Event/\(combinePosition)")
            print("combiePosition: \(combinePosition)")
            fetchData()
        }
        
    }

    @IBAction func SaveButtonPressed(_ sender: Any) {

        DoneBtn.isUserInteractionEnabled = false
        deleteMarkerBtn.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let content = textView.text ?? ""
        let title = title_field.text ?? ""
        print("save: la= \(latitude) lo = \(longitude)")
        let dataToSave: [String: Any] = ["content": content, "title": title, "latitude": latitude, "longitude": longitude, "date": dateStr, "icon":icon ]
        docRef.setData(dataToSave)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        if imageView.image?.cgImage != nil || imageView.image?.ciImage != nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            uploadPhoto(imagename: "\(latitude)+\(longitude)")
        }else{
            DoneBtn.isUserInteractionEnabled = true
            deleteMarkerBtn.isUserInteractionEnabled = true
        }
        print("content: \(content) title: \(title)")

    }

    @IBAction func DonePressed(_ sender: Any) {
        self.delegate?.reload_data()

        let text = title_field.text ?? ""
        let url = imageURL
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"),object: nil,userInfo:["title": text, "url":url] )
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePhotoPressed(_ sender: Any) {
        imageView.image = nil
        deletePhotoBtn.isHidden = true
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        docRef.getDocument(completion: {(docNapShot, error) in
            guard let docNapShot = docNapShot, docNapShot.exists else {
                print("error in docnapshot, nothing to be deleted")
                self.delegate?.reload_data()
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
            self.docRef.delete()
            self.delegate?.reload_data()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "delete"),object: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
    }

    
    @IBAction func addImageButtonPressed(_ sender: Any) {
         let alert = UIAlertController(title: "Select image from:", message: "", preferredStyle: .alert)
         
        alert.addAction(UIAlertAction(title: "camera", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }else{
                print("no camera")
            }
        }))
        alert.addAction(UIAlertAction(title: "library", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }else{
                print("no Library")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //dismiss keyboard on tapping outside of text field
    override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func uploadPhoto(imagename: String){
        let imageRef = Storage.storage().reference(withPath: "image/\(imagename).jpg")
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 0.5) else{
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
                self.docRef.updateData(dataToSave)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.DoneBtn.isUserInteractionEnabled = true
                self.deleteMarkerBtn.isUserInteractionEnabled = true
            })
        }
        return
    }
    
    func fetchData(){
        docRef.getDocument(completion: { (docNapShot, error) in
            guard let docNapShot = docNapShot, docNapShot.exists else {
                print("error in docnapshot")
                return
            }
            let myData = docNapShot.data()
            let content = myData?["content"] as? String ?? ""
            let title = myData?["title"] as? String ?? ""
            let urlkey = myData?["URL"] as? String ?? ""
            self.latitude = myData?["latitude"] as? String ?? ""
            self.longitude = myData?["longitude"] as? String ?? ""
            self.title_field.text = title
            self.textView.text = content
            print("Fetch data success")
            if let url = URL(string: urlkey){
                do{
                    let data = try Data(contentsOf: url)
                    self.imageView.image = UIImage(data: data)
                    self.deletePhotoBtn.isHidden = false
                    print("Fetch image data success")
                }catch let err{
                  print("Error in fetch data:\(err)")
                }
            }
        })
    }
    

    
    func processClassifications(for request: VNRequest, error: Error?) {
        
        DispatchQueue.main.async {
            guard let results = request.results else { return }
            
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                print("Nothing recognized.")
            } else {
                
                let numOfTags = 5
                let topClassifications = classifications.prefix(numOfTags)
                let descriptions = topClassifications.map { classification -> String in
                    let delimiter = ","
                    
                    let tags = classification.identifier.components(separatedBy: delimiter)
                    let tag = tags[0].replacingOccurrences(of: " ", with: "_")
                    return String(format: "#%@ ",tag)
                   
                }
                print("Classification:\n")
                var tags:String = ""
                for i in descriptions{
                    tags = tags + i
                }
                self.textView.text = self.textView.text + tags
            }
        }
    }
    
    func objectDetection(image: UIImage){
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            /* https://developer.apple.com/machine-learning/models/ */
            let model = try VNCoreMLModel(for: Resnet50().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            try handler.perform([request])
        } catch {
            print("Failed to perform detection.\n\(error.localizedDescription)")
        }

        }
        
    }

}

extension MarkerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
        }
        deletePhotoBtn.isHidden = false
        dismiss(animated: true, completion: nil)
        
    }
}
