//
//  MarkerViewController.swift
//  zenly
//
//  Created by Lanqing on 11/16/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import GoogleMaps
class MarkerViewController: UIViewController {

  
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title_field: UITextField!
    @IBOutlet weak var textView: UITextView!
    var marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup(){
       var data =  marker.userData as! eventData
        title_field.text = data.title
        textView.text = data.content
        imageView.image = data.image
    }
    //need:
    // a function to upload image
    // functions to save changed title and content
    // a function to add image
    // store data
    

}
