//
//  HomeViewController.swift
//
//  Created by Lanqing on 11/8/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase


class HomeViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var logOut: UIBarButtonItem!
    var phoneNumInE64: String = ""
    
    let locationManager = CLLocationManager()
    var selectedMarker = GMSMarker()
    
    var docRef: DocumentReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumInE64 = Storagelocal.phoneNumberInE164 ?? "Error"
        selectUser()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        load_markers()
    }
    
    func selectUser(){
        docRef = Firestore.firestore().document("User/\(phoneNumInE64)")
    }
    
    func load_markers(){
        let eventRef = docRef.collection("Event")
        eventRef.getDocuments{ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                //use forced unwarp here because it's written in offical doc of firestore
                for document in querySnapshot!.documents {
                    print("Data: \(document.data())")
                    var la = 0.0;
                    var lo = 0.0;
                    for dic in document.data(){
                        if(dic.key == "latitude"){
                            let la_string = "\(dic.value)"
                            la = Double(la_string) ?? 0
                        }
                        if(dic.key == "longitude"){
                            let lo_string = "\(dic.value)"
                            lo = Double(lo_string) ?? 0
                        }
                    }
//                    let mydata = document.data()
//                    let latitude = mydata["latitude"] as? String ?? ""
//                    let longitude = mydata["longitude"] as? String ?? ""
//                    print("latitude: \(latitude), longitude: \(longitude)")
                    let position = CLLocationCoordinate2D(latitude: la, longitude: lo)
                    print("la: \(la), lo: \(lo)")
                    let marker = GMSMarker(position: position)
                    marker.map = self.mapView
                }
            }
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
        // animate the changes in the label’s intrinsic content size.
        UIView.animate(withDuration: 0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }

  
    
    @IBAction func ShowAddrPressed(_ sender: Any) {
        guard let position = self.locationManager.location?.coordinate else { return  }
        reverseGeocodeCoordinate(position)
        
    }
    //long press at a place to show a popup view to add a marker
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Add Marker", message: "enter the name of the event", preferredStyle: .alert)
            alert.addTextField{ textField in
                textField.keyboardType = .asciiCapable
            }
            alert.addAction(UIAlertAction(title:"Done", style: .default, handler: { _ in
                let textField = alert.textFields?.first
                let marker = GMSMarker(position: coordinate)
                marker.title = textField?.text ?? " "
                marker.map = self.mapView
                self.selectedMarker = marker
            }))
            self.present(alert, animated: true, completion: nil)
        // MARK: performSegue not working
//            self.performSegue(withIdentifier: "showMarker", sender: self)
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
            dest.delegate = self
            mapView.clear()
        }
        
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

  
            
                
  
    

