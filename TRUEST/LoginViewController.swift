//
//  ViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/9/26.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import FirebaseCrash
import FirebaseAnalytics
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData

class LoginViewController: UIViewController {

    
    @IBOutlet weak var loginDescription: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var loginTime: Int = 0
        
        button1.hidden = true
        button3.hidden = true
//        button4.hidden = true
        let guestImage = UIImage(named: "arrow button")
        button4.setImage(guestImage, forState: .Normal)
        
        
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        self.loadingSpinnerActive(false)
        self.hideLoginButtons(false)
        
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { (auth, user) in
            
            if user != nil {
                
                LoginManager.shared.delegate = self
                
                if loginTime == 1 {
                    self.manager(LoginManager(), userDidLogin: true)
                }
                
                loginTime += 1
                
            } else {
                
                self.setup()
            }
            
        }
        
    }
    
}



extension LoginViewController {
    
    @IBAction func facebookPressed(sender: AnyObject) {
        
        FIRAnalytics.logEventWithName("loginWithFB", parameters: nil)
        
        loginWithFacebook()
        
        self.loadingSpinnerActive(true)
        self.hideLoginButtons(true)
        
    }
    
}



extension LoginViewController {
    
    private func hideLoginButtons(decision: Bool) {
        
          loginDescription.hidden = decision
//          button1.hidden = decision
          facebookButton.hidden = decision
    
//          button3.hidden = decision
          button4.hidden = decision
     }
    
    
    
    private func loadingSpinnerActive(active: Bool) {
        
        if active == true {

            loadingSpinner.hidden = false
            loadingSpinner.startAnimating()

        } else {
        
            loadingSpinner.hidden = true
            loadingSpinner.stopAnimating()
        }
    }
    
    
    
    private func setup() {
        
        facebookButton.setTitle("", forState: .Normal) // use setTitle to set button's title, don't use titleLabel
       facebookButton.layer.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0).CGColor
    }
    
}


extension LoginViewController: LoginManagerDelegate {
    
    func manager(manager: LoginManager, userDidLogin: Bool) {
        if userDidLogin == true {
            
            UserDefaultManager().downloadCurrentUserInfo()
            
            self.hideLoginButtons(false)
            self.loadingSpinnerActive(false)
            
            switchViewController(from: self, to: "TabBarController")
            
        }
    }
}



extension LoginViewController {
    
    private func loginWithFacebook() {

        self.loadingSpinner.startAnimating()
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if let error = error {
                FIRCrashMessage("FB login error: \(error)")
                self.hideLoginButtons(false)
                self.loadingSpinner.stopAnimating()
                return
            }
            
            if result.isCancelled {
                print("Cancle button pressed")
                self.hideLoginButtons(false)
                self.loadingSpinner.stopAnimating()
            } else {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    
                    LoginManager.shared.userLogin()
                    
                }
            }
        })
        
    }
}




