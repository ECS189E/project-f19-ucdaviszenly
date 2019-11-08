//
//  WalletViewController.swift
//  wallet-1
//
//  Created by Lanqing on 10/25/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{

    

    @IBOutlet weak var logOut: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // logout button bring user to login view
    @IBAction func logOutPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "logout",sender: self)
    }
}
  
            
                
  
    

