//
//  ViewController.swift
//  wallet-1
//
//  Created by Lanqing on 10/7/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import PhoneNumberKit



class LoginViewController: UIViewController, UITextFieldDelegate{
 
    @IBOutlet weak var loadingImg: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var inputField: PhoneNumberTextField!
    var phoneNumFormatted = String()
    var phoneNumber = String()
    let phoneNumberKit = PhoneNumberKit()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        inputField.becomeFirstResponder()
        loadingImg.isHidden = true
        // hide errorLabel at first
        errorLabel.isHidden = true
        // get phonenumber in storage, and display in textfield
        phoneNumber = Storagelocal.phoneNumberInE164 ?? ""
            if phoneNumber != "" {
                phoneNumber = phoneNumber.replacingOccurrences(of: "+1", with: "")
                
                do {
                    let phoneNumParsed = try phoneNumberKit.parse(phoneNumber, withRegion: "US",  ignoreType: true)
                phoneNumFormatted = phoneNumberKit.format(phoneNumParsed, toType:.e164)
                    self.performSegue(withIdentifier: "Auth", sender: self)
                inputField.text = phoneNumber
            }catch {
            print("error")
            }
    }
        
}

    @IBAction func nextButtonPressed() {
        self.view.endEditing(true)
        
        // parse input string
        phoneNumber = inputField.text?.filter { $0 >= "0" && $0 <= "9" } ?? ""
        
        do {
            //parse and format phone number
            let phoneNumParsed = try phoneNumberKit.parse(phoneNumber, withRegion: "US",  ignoreType: true)
             phoneNumFormatted = phoneNumberKit.format(phoneNumParsed, toType:.e164)
            errorLabel.text = phoneNumFormatted
            errorLabel.textColor = UIColor.blue
        }
        catch {
            //catch errors if phone number is not valid
            print("Generic parser error")
            if phoneNumber.count != 10{
                errorLabel.text = "Please enter 10 digits"
            }else{
                errorLabel.text = "Not a valid phone number"
            }
            errorLabel.textColor = UIColor.red
            
        }
        // first check if user has authToken, if yes, go to wallet view
        if Storagelocal.authToken != nil, Storagelocal.phoneNumberInE164 == phoneNumFormatted {
            self.performSegue(withIdentifier: "Auth", sender: self)
        //if new user, go to verify view
        }else if(errorLabel.textColor == UIColor.blue){
            //disable button if code has sent out
            nextButton.isUserInteractionEnabled = false
            loadingImg.isHidden = false
            loadingImg.startAnimating()
            // Api call to send verification code
            Api.sendVerificationCode(phoneNumber: phoneNumber) { response, error in
                   
                guard response != nil && error == nil else {
                       
                    self.errorLabel.text = error?.message
                    self.errorLabel.textColor = UIColor.red
                    self.errorLabel.isHidden = false
                    self.nextButton.isUserInteractionEnabled = true
                    self.loadingImg.stopAnimating()
                    self.loadingImg.isHidden = true
                    return
                }
                //enable button when api get response back
                self.nextButton.isUserInteractionEnabled = true
                self.loadingImg.stopAnimating()
                self.loadingImg.isHidden = true
                self.performSegue(withIdentifier: "verify",sender: self)
            }
        }
        //display info/error message
        errorLabel.isHidden = false
       
    }
    

    
    //dismiss keyboard on tapping outside of text field
    override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?){
        self.view.endEditing(true)
    }
    //pass phoneNum to VerifyViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verify" {
            let dest : VerifyViewController = segue.destination as! VerifyViewController
            dest.phoneNumFormatted = self.phoneNumFormatted
            dest.phoneNumber = self.phoneNumber
       
        }
    }
    
}
