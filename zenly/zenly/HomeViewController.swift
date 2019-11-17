//
//  HomeViewController.swift
//
//  Created by Lanqing on 11/8/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import GoogleMaps
class HomeViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var logOut: UIBarButtonItem!
    let locationManager = CLLocationManager()

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
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
    //long press at a place to add a marker
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        let alert = UIAlertController(title: "Add Marker", message: "", preferredStyle: .alert)
        alert.addTextField{ textField in
            textField.keyboardType = .asciiCapable
        }
        alert.addAction(UIAlertAction(title:"Done", style: .default, handler: { _ in
            let textField = alert.textFields?.first
            let marker = GMSMarker(position: coordinate)
            marker.title = textField?.text
            marker.map = self.mapView
            
        }))
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



  
            
                
  
    

