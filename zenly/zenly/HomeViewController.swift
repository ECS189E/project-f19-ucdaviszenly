//
//  HomeViewController.swift
//
//  Created by Lanqing on 11/8/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class HomeViewController: UIViewController, GMSMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {
    

    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var logOut: UIBarButtonItem!
    var phoneNumInE64: String = ""
    let locationManager = CLLocationManager()
    var selectedMarker = GMSMarker()
    var choices = ["pin","book","game","store","airplane","rice"]
    var selectedIconName = "pin"
    var docRef: DocumentReference!
    var imageTook = UIImage()
    var curMarkerExist = false
    var eventNum = 0
    var title_Vec = [String]()
    var icon_Vec = [String]()
    var time_Vec = [String]()
    var path_Vec = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumInE64 = Storagelocal.phoneNumberInE164 ?? "Error"
        selectUser()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        load_markers()
        self.imageTook = UIImage()
        
        
    }

    
    func selectUser(){
        docRef = Firestore.firestore().document("User/\(phoneNumInE64)")
    }
    
    func load_markers(){
        curMarkerExist = false
        let eventRef = docRef.collection("Event")
        eventRef.getDocuments{ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                
            } else {
                //use forced unwarp here because it's written in offical doc of firestore
                for document in querySnapshot!.documents {
                    var la = 0.0
                    var lo = 0.0
                    var icon = "";
                    for dic in document.data(){
                        if(dic.key == "latitude"){
                            let la_string = "\(dic.value)"
                            la = Double(la_string) ?? 0
                        }
                        if(dic.key == "longitude"){
                            let lo_string = "\(dic.value)"
                            lo = Double(lo_string) ?? 0
                        }
                        if(dic.key == "icon"){
                            icon = "\(dic.value)"
                
                        }
                        if(dic.key == "title"){
                            self.title_Vec.append("\(dic.value)")
                        }
                        if(dic.key == "date"){
                            self.time_Vec.append("\(dic.value)")
                           
                        }
                        
                        
                    }
                    
                    let n = document.data()["URL"] as? String ?? "https://firebasestorage.googleapis.com/v0/b/ecs189e-project.appspot.com/o/image%2Fdefault.jpg?alt=media&token=de615864-aa76-4e4e-b078-e963254fdf4b"
                    self.icon_Vec.append(n)
                    
                    
                    let path = "la\(la)lo\(lo)"
                    self.path_Vec.append("User/\(self.phoneNumInE64)/Event/\(path)")
                    print("path in home is \(String(describing: self.path_Vec.last))")
                    
                    let position = CLLocationCoordinate2D(latitude: la, longitude: lo)
                   
                    self.checkCurrentLocation(la,lo)
                    let marker = GMSMarker(position: position)
                    marker.iconView = UIImageView(image: UIImage(named: icon))
                    marker.map = self.mapView
                }
                self.eventNum = querySnapshot?.count ?? 0
                
            }
        }
    }
    func checkCurrentLocation(_ la: Double, _ lo: Double ){
        guard let currentposition = self.locationManager.location?.coordinate else {
            return
        }
        if (currentposition.latitude == la && currentposition.longitude == lo){
            self.curMarkerExist = true
        }
    }
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
      //turn a coordinate into a street address.
      let geocoder = GMSGeocoder()
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
        guard let address = response?.firstResult(), let lines = address.lines else {
          return
        }
          
        // Sets the text of the addressLabel to the address returned by the geocoder
        self.addressLabel.text = lines.joined(separator: "\n")
        self.addressLabel.backgroundColor = .white
          // add padding
        let labelHeight = self.addressLabel.intrinsicContentSize.height
        self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                              bottom: labelHeight, right: 0)

        UIView.animate(withDuration: 0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }

    @IBAction func CameraPressed(_ sender: Any) {
        guard let position = self.locationManager.location?.coordinate else { return  }
        reverseGeocodeCoordinate(position)
        if(curMarkerExist){
            let alert = UIAlertController(title: "Error", message: "Current location already has a marker", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let marker = GMSMarker(position: position)
        marker.title = self.getTime()
        marker.map = self.mapView
        marker.icon = #imageLiteral(resourceName: "pin")
        self.selectedMarker = marker
        if UIImagePickerController.isSourceTypeAvailable( .camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            print("no camera")
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
      
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        print("image size = \(image.size)")
        imageTook = image
        
        self.performSegue(withIdentifier: "showMarker", sender: self)
    }
    func getTime()-> String{
        let date = Date()
        let calendar = Calendar.current
        let min = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(year)-\(month)-\(day) \(hour):\(min)"
    }
    //long press at a place to show a popup view to add a marker
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        reverseGeocodeCoordinate(coordinate)
        let alert = UIAlertController(title: "Add Event", message: "Choose pin icon and name the event: \n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 30, width: 260, height: 162))
        alert.view.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        
        alert.addTextField{ textField in
            textField.keyboardType = .asciiCapable
            textField.placeholder = "name the event"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title:"Done", style: .default, handler: { _ in
            let textField = alert.textFields?.first
            let marker = GMSMarker(position: coordinate)
            
            marker.title = textField?.text!
            if( marker.title == ""){
                marker.title = self.getTime()
            }
            marker.map = self.mapView
            
            marker.iconView = UIImageView(image: UIImage(named: self.selectedIconName))
            self.selectedMarker = marker
            //self.performSegue(withIdentifier: "showMarker", sender: self)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x: 0, y: 0, width:pickerView.bounds.width , height: 30))
        let myImageView = UIImageView(frame: CGRect(x: 100, y: 0, width: 30, height: 30))
        
        switch row {
        //image: 32x32 px
        case 0:
            myImageView.image =  #imageLiteral(resourceName: "pin")
        case 1:
            myImageView.image =  #imageLiteral(resourceName: "book")
        case 2:
            myImageView.image =  #imageLiteral(resourceName: "game")
        case 3:
            myImageView.image =  #imageLiteral(resourceName: "store")
        case 4:
            myImageView.image =  #imageLiteral(resourceName: "airplane")
        case 5:
            myImageView.image =  #imageLiteral(resourceName: "rice")
        default:
            myImageView.image = #imageLiteral(resourceName: "pin")
        }
        myView.addSubview(myImageView)
        return myView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIconName = choices[row]
    }
    //go to MarkerView if tap on a marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        selectedMarker = marker
        self.performSegue(withIdentifier: "showMarker", sender: self)
        return true
    }
    //send marker.userData to MarkerViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMarker" {
            let dest : MarkerViewController = segue.destination as! MarkerViewController
            dest.marker = self.selectedMarker
            dest.phoneNumInE64 = self.phoneNumInE64
            dest.date = NSDate()
            dest.icon = self.selectedIconName
            dest.delegate = self
            mapView.clear()
            if imageTook.size != CGSize(width: 0.0, height: 0.0) {
                dest.imageTook = self.imageTook
            }
        }
        
        if segue.identifier == "list" {
           let dest : EventsViewController = segue.destination as! EventsViewController
            dest.phoneNum = self.phoneNumInE64
            dest.eventCount = self.eventNum
            dest.titleVec = self.title_Vec
            dest.timeVec = self.time_Vec
            dest.iconVec = self.icon_Vec
            dest.pathVec = self.path_Vec
            
                  
        }
        
    }
    @IBAction func EventListPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "list",sender: self)
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "logout",sender: self)
    }
    
}


extension HomeViewController: CLLocationManagerDelegate {
//when the user revokes location permission
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //verify permission
    guard status == .authorizedWhenInUse else {
      return
    }
    //update user's location
    locationManager.startUpdatingLocation()

    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  //executes when the location manager receives new location data.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
      
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

    locationManager.stopUpdatingLocation()
  }
}

extension HomeViewController: markerdelegate{
    func reload_data() {
        self.dismiss(animated: true, completion: {
            print("clear")
            self.mapView.clear()
            self.load_markers()
        })
    }
    
    
}

  
            
                
  
    

