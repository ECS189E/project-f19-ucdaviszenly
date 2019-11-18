//
//  VerifyViewController.swift
//  wallet-1
//
//  Created by Lanqing on 10/15/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//


import UIKit
import Foundation


class VerifyViewController: UIViewController, PinTexFieldDelegate{
    func didPressBackspace(textField: PinTextField) {
        textField.isUserInteractionEnabled = false
        //enable last textfield, disable this textfield, and assign last textfield to be the first responder.
        if textField == input6{
            textField.text = ""
            input5.text = ""
            input5.isUserInteractionEnabled = true
            input5.becomeFirstResponder()
            input6.isUserInteractionEnabled = false
            
        }else if textField == input5{
            textField.text = ""
            input4.text = ""
            input4.isUserInteractionEnabled = true
            input4.becomeFirstResponder()
            input5.isUserInteractionEnabled = false
        }else if textField == input4{
            textField.text = ""
            input3.text = ""
            input3.isUserInteractionEnabled = true
            input3.becomeFirstResponder()
            input4.isUserInteractionEnabled = false
        }else if textField == input3{
            textField.text = ""
            input2.text = ""
            input2.isUserInteractionEnabled = true
            input2.becomeFirstResponder()
            input3.isUserInteractionEnabled = false
        }else if textField == input2{
            textField.text = ""
            input1.text = ""
            input1.isUserInteractionEnabled = true
            input1.becomeFirstResponder()
            input2.isUserInteractionEnabled = false
        
        }else if textField == input1{
            textField.text = ""
            input1.isUserInteractionEnabled = true
            input1.resignFirstResponder()
            
        }
        
    }
    
    

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var input1: PinTextField!
    @IBOutlet weak var input2: PinTextField!
    @IBOutlet weak var input3: PinTextField!
    @IBOutlet weak var input4: PinTextField!
    @IBOutlet weak var input5: PinTextField!
    @IBOutlet weak var input6: PinTextField!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    
    var phoneNumFormatted :String = ""
    var phoneNumber :String = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
        numberLabel.text = phoneNumFormatted
        errorLabel.isHidden = true
        loading.isHidden = true
        // disable all textfield except for the first one
        input1.becomeFirstResponder()
        input2.isUserInteractionEnabled = false
        input3.isUserInteractionEnabled = false
        input4.isUserInteractionEnabled = false
        input5.isUserInteractionEnabled = false
        input6.isUserInteractionEnabled = false

        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input4.delegate = self
        input5.delegate = self
        input6.delegate = self
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // if textField contain one number, go to the next one
        if ((textField.text?.count)! < 1) && (string.count > 0 ){
            if textField == input1 {
                input2.isUserInteractionEnabled = true
                input2.becomeFirstResponder()
                input1.isUserInteractionEnabled = false
                textField.text = string
            }
            if textField == input2 {
                input3.isUserInteractionEnabled = true
                input3.becomeFirstResponder()
                input2.isUserInteractionEnabled = false
                textField.text = string
            }
            if textField == input3 {
                input4.isUserInteractionEnabled = true
                input4.becomeFirstResponder()
                input3.isUserInteractionEnabled = false
                textField.text = string
            }
            if textField == input4 {
                input5.isUserInteractionEnabled = true
                input5.becomeFirstResponder()
                input4.isUserInteractionEnabled = false
                textField.text = string
            }
            if textField == input5 {
                input6.isUserInteractionEnabled = true
                input6.becomeFirstResponder()
                input5.isUserInteractionEnabled = false
                textField.text = string
            }
            if textField == input6 {
                input6.resignFirstResponder()
                textField.text = string
                checkVerifycode()
                
            }
            
            return false
         
        // if user hit backward, call didPressBackspace to handle deletion
        }else if ((textField.text?.count)! >= 1) && (string.count == 0 ){
            didPressBackspace(textField: textField as! PinTextField)
            return false
        }else if ((textField.text?.count)! >= 1) {
            textField.text = string
            return false
        }
        
        return true
    }


 
    func checkVerifycode(){

        let code = "\(input1.text!)\(input2.text!)\(input3.text!)\(input4.text!)\(input5.text!)\(input6.text!)"
        print("code = \(code)")
        loading.isHidden = false
        loading.startAnimating()
        Api.verifyCode(phoneNumber: phoneNumFormatted, code: code) { response, error in
            
            guard response != nil, error == nil else {
                self.errorLabel.text = error?.message
                self.errorLabel.textColor = UIColor.red
                self.errorLabel.isHidden = false
                self.clearInputs()
                self.loading.stopAnimating()
                self.loading.isHidden = true
                return
            }
            self.loading.stopAnimating()
            self.loading.isHidden = true
            //segue to home view
            let authToken = response?["auth_token"] as? String
            Storagelocal.phoneNumberInE164 = self.phoneNumFormatted
            Storagelocal.authToken = authToken
            
            self.performSegue(withIdentifier: "verified",sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeViewController" {
            let dest: HomeViewController = segue.destination as! HomeViewController
            dest.phoneNumInE64 = phoneNumFormatted
        }
    }
    
    // A function that used to clear the textfield, and move cursor to the first textfield
    func clearInputs(){
        input1.text = ""
        input2.text = ""
        input3.text = ""
        input4.text = ""
        input5.text = ""
        input6.text = ""
        input1.isUserInteractionEnabled = true
    
        input1.becomeFirstResponder()
    }

    
    @IBAction func ResendOnTap(_ sender: Any) {
        //Clear textfield once resend button is pressed
        clearInputs()
        
        //disable resend button during API process
        self.resendButton.isUserInteractionEnabled = false
        loading.isHidden = false
        loading.startAnimating()
        // Call API to resend verification code
        Api.sendVerificationCode(phoneNumber: phoneNumber) { response, error in
                
            guard response != nil && error == nil else {
                self.errorLabel.text = error?.message
                self.errorLabel.textColor = UIColor.red
                self.errorLabel.isHidden = false
                self.loading.stopAnimating()
                self.loading.isHidden = true
                return
            }
            //enable resend button after API process
            self.resendButton.isUserInteractionEnabled = true
            self.loading.stopAnimating()
            self.loading.isHidden = true
        }
    }
    
}
