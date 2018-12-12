//
//  SlideShowLoginScreenViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 16/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import AVFoundation
import UIKit
import Foundation
import CoreData
import QuartzCore

class SlideShowLoginScreenViewController: UIViewController , UITextFieldDelegate, UIGestureRecognizerDelegate,FBSDKLoginButtonDelegate{
    
    var email : UITextField!               // TextField for email
    var pass : UITextField!                // TextField for Password
    var signIn : UIButton!                 // SignIn Action
    var signInotp : UIButton!              // Singin with otp action
    var loginCustomView : UIView!
    var fromDashboard : Bool!
    var forgotPassword : UIButton!
    var emailField: UITextField!
    var bottomView : UIView!
    var Subscriptionurl: String = ""
    var leftBarButtonItem = UIBarButtonItem()
    var rightBarButtonItem = UIBarButtonItem()
    var signUpButton = UIButton()
    var signUpLabel = UILabel()
    var policyView = UIView()
    var termsButton = UIButton()
    var privacyButton = UIButton()
    
    var showAppIcon = UIImageView()
    var loginView  = FBSDKLoginButton()
    var facebookSignUpButton : UIButton!
    var button = UIButton()
    
    var fbIcon = "\u{f39e}"

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
       
        view.backgroundColor = UIColor.white
 
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        removeNavigationImage(controller: self)
        
        self.hideKeyboardWhenTappedAround()
        FBSDKAccessToken.setCurrent(nil)
        
        showAppIcon = createImageView(CGRect(x: view.bounds.width/2 - 60, y: TOPPADING , width: 120,height: 120), border: false)

        showAppIcon.image = UIImage(named: "login_icon")//?.maskWithColor(color: buttonColor)
        
        view.addSubview(showAppIcon)
        
        loginCustomView = createView( CGRect(x: 0, y: view.bounds.height/2 - 120, width: view.bounds.width, height: 300), borderColor: UIColor.clear , shadow: true)
        
        loginCustomView.backgroundColor = UIColor.clear
        view.addSubview(loginCustomView)
        
        bottomView = createView( CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50), borderColor: UIColor.clear , shadow: true)
        bottomView.backgroundColor = UIColor.clear
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = UIColor.white.cgColor
        border1.frame = CGRect(x: 0, y: 0, width: bottomView.frame.size.width, height: 1)
        
        border1.borderWidth = width1
        bottomView.layer.addSublayer(border1)
        bottomView.layer.masksToBounds = true
        view.addSubview(bottomView)
        bottomView.isHidden = true
        
        let defaults = UserDefaults.standard
        var namelabel : String = NSLocalizedString("Email Address",comment: "")
        if let namelabel1 =  defaults.object(forKey: "namelabel") as? String
        {
            namelabel = namelabel1
        }
        email = createSkyTextField(CGRect(x: (view.bounds.width/2 - 140) , y: 0 ,width: 280 , height: 50), borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ %@", comment: ""), messageIcon , namelabel)  , corner: true)
        
        email.attributedPlaceholder = NSAttributedString (string: String(format:  NSLocalizedString("%@ %@",  comment: ""), messageIcon, namelabel), attributes: [NSAttributedStringKey.foregroundColor: textColorMedium])
        email.autocapitalizationType = .none
        email.layer.masksToBounds = false
        email.layer.shadowOffset = CGSize(width: 0, height: 0);
        email.layer.shadowOpacity = 0.0
        email.textColor = textColorDark
        email.tintColor = textColorDark
       // email.font =  UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        email.delegate = self
        email.tag = 11
        email.backgroundColor = UIColor.clear
        
        email.autocorrectionType = UITextAutocorrectionType.no
        loginCustomView.addSubview(email)
        self.email.keyboardType = UIKeyboardType.emailAddress
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = email.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = textColorMedium.withAlphaComponent(0.5).cgColor
        border.frame = CGRect(x: 0, y: email.frame.size.height - width, width: email.frame.size.width, height: 0.5)
        
        border.borderWidth = width
        email.layer.addSublayer(border)
        
        email.textColor = textColorDark
        
        
        let pwdIcon = "\u{F023}"
        pass = createSkyTextField(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: email) + 13,width: 280 , height: 50),borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ Password", comment: ""), pwdIcon) , corner: true)  //"\u{F023} Password"
      
        pass.attributedPlaceholder = NSAttributedString(string: String(format:  NSLocalizedString("%@ Password",  comment: ""), pwdIcon), attributes: [NSAttributedStringKey.foregroundColor: textColorMedium])
      
        pass.backgroundColor = UIColor.clear
        pass.layer.masksToBounds = false
        pass.layer.shadowOffset = CGSize(width: 0, height: 0);
        pass.layer.shadowOpacity = 0.0
        pass.tag = 22
        pass.tintColor = textColorDark
        pass.textColor = textColorDark
        pass.isHidden = true//false
        pass.returnKeyType = UIReturnKeyType.done
        
        pass.autocapitalizationType = .none
        pass.isSecureTextEntry = true
        pass.delegate = self
         let eyeicon = "\u{f06e}"
        button = UIButton(type: .custom)
        button.setTitle(eyeicon, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 5, 0)
        button.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        button.setTitleColor(textColorMedium, for: .normal)
        button.frame = CGRect(x: CGFloat(email.frame.size.width - 20), y: CGFloat(10), width: CGFloat(20), height: CGFloat(20))
        button.addTarget(self, action: #selector(SlideShowLoginScreenViewController.showPassword), for: .touchUpInside)
        pass.rightView = button
        pass.rightViewMode = .always
        
        loginCustomView.addSubview(pass)
        let border2 = CALayer()
        let width2 = CGFloat(0.5)
        border2.borderColor = textColorMedium.withAlphaComponent(0.5).cgColor
        border2.frame = CGRect(x: 0, y: pass.frame.size.height - width2, width: email.frame.size.width, height: 0.5)
        
        border2.borderWidth = width
        pass.layer.addSublayer(border2)
        
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = pass.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        signIn = createButton(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: pass) + 62,width: 280 , height: 40) ,title: NSLocalizedString("Log In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        signIn.backgroundColor = navColor.withAlphaComponent(0.5)
        //        signIn.layer.shadowColor = navColor.CGColor
        signIn.layer.borderColor = UIColor.clear.cgColor
        signIn.layer.cornerRadius = cornerRadiusSmall
        signIn.titleLabel?.font = signIn.titleLabel?.font.withSize(15)
        signIn.isHidden = false
        signIn.isEnabled = false
        loginCustomView.addSubview(signIn)
        
        signInotp = createButton(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: email) + 17 ,width: 280 , height: 40) ,title: NSLocalizedString("OTP Sign In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        signInotp.backgroundColor = navColor
        //        signIn.layer.shadowColor = navColor.CGColor
        signInotp.layer.borderColor = UIColor.clear.cgColor
        signInotp.layer.cornerRadius = cornerRadiusSmall
        signInotp.isHidden = true
        signInotp.titleLabel?.font = signInotp.titleLabel?.font.withSize(15)
        loginCustomView.addSubview(signInotp)
        
        // Forgot Password Button
        forgotPassword = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: pass) + 8, width: email.frame.size.width + (view.bounds.width/2 - 140) , height: 35) ,title: NSLocalizedString("Forgot Password?",comment: "") , border: false, bgColor: false, textColor: textColorDark)
        forgotPassword.contentHorizontalAlignment = .right
        
       // forgotPassword.sizeToFit()
        
        let formmode =  defaults.string(forKey: "formmode")
        
        if formmode ==  "default" || isEnableOtp == false
        {
            signInotp.isHidden = true
            signIn.isEnabled = true
            signIn.isHidden = false
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            signIn.addTarget(self, action: #selector(SlideShowLoginScreenViewController.login), for: .touchUpInside)
        }
        else if formmode == "both"
        {
            self.signIn.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 17
            signIn.addTarget(self, action: #selector(SlideShowLoginScreenViewController.login), for: .touchUpInside)
            signInotp.addTarget(self, action: #selector(SlideShowLoginScreenViewController.signInAction), for: .touchUpInside)
        }
        else
        {
            signInotp.isHidden = true
            signIn.isEnabled = true
            signIn.isHidden = false
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            signIn.addTarget(self, action: #selector(SlideShowLoginScreenViewController.signInAction), for: .touchUpInside)
        }
        
      //  forgotPassword.layer.cornerRadius = cornerRadiusSmall
        forgotPassword.backgroundColor = UIColor.clear
        forgotPassword.addTarget(self, action: #selector(SlideShowLoginScreenViewController.forgotPasswords), for: .touchUpInside)
        forgotPassword.isHidden = true//false
        forgotPassword.titleLabel?.font = forgotPassword.titleLabel?.font.withSize(15)
        
        loginCustomView.addSubview(forgotPassword)
        
        if sign_in == 1
        {
            sign_in = 0
            self.login()
        }
        
        if browseAsGuest == true
        {
            let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
            rightNavView.backgroundColor = UIColor.clear
            
            let shareButton = createButton(CGRect(x: 20,y: 12,width: 44,height: 22), title: "Skip", border: false, bgColor: false, textColor: textColorMedium)
            // shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControlState())
            shareButton.addTarget(self, action: #selector(SlideShowLoginScreenViewController.logoutSite), for: .touchUpInside)
            rightNavView.addSubview(shareButton)
            
            
            let barButtonItem1 = UIBarButtonItem(customView: rightNavView)
            
            self.navigationItem.rightBarButtonItem = barButtonItem1
        }
        
        
        signUpLabel = createLabel(CGRect(x: (view.bounds.width/2 - 150),y:view.bounds.height - 120 - iphonXBottomsafeArea,width: 180,height: 30), text: NSLocalizedString("Don't have an account?",comment: ""), alignment: .center, textColor: textColorMedium)
        //signUpLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view.addSubview(signUpLabel)
        
        signUpButton = createButton(CGRect(x: (view.bounds.width/2 - 150) + signUpLabel.bounds.size.width + 5,y:view.bounds.height - 120 -  iphonXBottomsafeArea,width: 150,height: 30), title: NSLocalizedString("Register Now!",comment: ""), border: false, bgColor: false, textColor: textColorDark)
        signUpButton.addTarget(self, action: #selector(SlideShowLoginScreenViewController.signUpAction), for: .touchUpInside)
        signUpButton.contentHorizontalAlignment = .left
        view.addSubview(signUpButton)
        
        policyView = createView( CGRect(x: view.bounds.width/2, y: view.bounds.height - 25 - iphonXBottomsafeArea, width: 1, height: 20), borderColor: UIColor.clear , shadow: false)
        policyView.backgroundColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1.0)
        
        view.addSubview(policyView)
        
        termsButton = createButton(CGRect(x: 0,y:view.bounds.height - 40 - iphonXBottomsafeArea,width: view.bounds.width/2,height: 40), title: NSLocalizedString("Terms",comment: ""), border: false, bgColor: false, textColor: textColorMedium)
        termsButton.addTarget(self, action: #selector(SlideShowLoginScreenViewController.termsConditions), for: .touchUpInside)
        termsButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        termsButton.contentHorizontalAlignment = .center
      //  termsButton.isHidden = true
        view.addSubview(termsButton)
        
        privacyButton = createButton(CGRect(x: view.bounds.width/2,y:view.bounds.height - 40 - iphonXBottomsafeArea,width: view.bounds.width/2,height: 40), title: NSLocalizedString("Privacy Policy",comment: ""), border: false, bgColor: false, textColor: textColorMedium)
        privacyButton.addTarget(self, action: #selector(SlideShowLoginScreenViewController.privacy), for: .touchUpInside)
        privacyButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        privacyButton.contentHorizontalAlignment = .center
      //  privacyButton.isHidden = true
        view.addSubview(privacyButton)
        
        
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in, do work such as! go to next view controller.
            self.view.alpha = 0.6
        }
        else
        {
            if let facebookSdk = Bundle.main.infoDictionary?["FacebookAppID"] as? String {
                if facebookSdk != "" && (logoutUser == true) {
                    // Create FbsignUpfakebutton Button
                    var fbOriginY = view.bounds.height - 200 - iphonXBottomsafeArea
                    let bounds = UIScreen.main.bounds
                    let height = bounds.size.height
                    switch height
                    {
                    case 568.0:
                        
                        fbOriginY = view.bounds.height - 170 - iphonXBottomsafeArea
                        
                    default:
                        
                         fbOriginY = view.bounds.height - 200 - iphonXBottomsafeArea
                        
                    }
                    
                    facebookSignUpButton = createButton(CGRect(x: (view.bounds.width/2 - 140) ,  y: fbOriginY, width: 280, height: 40) ,title: NSLocalizedString("  Login with Facebook",comment: "") , border: false, bgColor: true, textColor: textColorLight)
                    
                    facebookSignUpButton.layer.borderColor = UIColor.clear.cgColor
                    facebookSignUpButton.layer.cornerRadius = cornerRadiusSmall
                    
                    let fbColor = UIColor(red: 59/255 , green: 89/255 , blue: 152/255, alpha: 1.0)
                    let iconFont = CTFontCreateWithName(("FontAwesome5BrandsRegular" as CFString?)!, 18.0, nil)
                    let textFont = CTFontCreateWithName((fontName as CFString?)!, 18.0, nil)
                    let attrString = NSMutableAttributedString(string: " \(fbIcon)", attributes: [NSAttributedStringKey.font:iconFont ,  NSAttributedStringKey.foregroundColor : textColorLight])
                    
                    let textPart = NSMutableAttributedString(string: "       Login with Facebook", attributes: [NSAttributedStringKey.font:textFont , NSAttributedStringKey.foregroundColor : textColorLight])
                    attrString.append(textPart)
                    facebookSignUpButton.contentVerticalAlignment = UIControlContentVerticalAlignment.center
//                    facebookSignUpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
//                    facebookSignUpButton.titleLabel?.textAlignment = .left
                    facebookSignUpButton.setAttributedTitle(attrString, for: UIControlState.normal)
                    
                    
                    facebookSignUpButton.backgroundColor = fbColor//textColorLight
                    // facebookSignUpButton.layer.shadowColor = fbNavColor.cgColor
                    facebookSignUpButton.layer.borderColor = textColorMedium.cgColor
                    facebookSignUpButton.addTarget(self, action: #selector(SlideShowLoginScreenViewController.fakeFbLoginButtonClick(_:)), for: .touchUpInside)
                    // facebookSignUpButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                    view.addSubview(facebookSignUpButton)
                    
                    loginView = FBSDKLoginButton()
                    loginView.frame = CGRect(x: (view.bounds.width/2 - 140) ,  y: fbOriginY, width: 280, height: 40)
                    //                    view.addSubview(loginView)
                    loginView.readPermissions = ["public_profile", "email", "user_friends"]
                    loginView.delegate = self
                }
            }
            
        }
        
        


        // Do any additional setup after loading the view.
    }
    @objc func fakeFbLoginButtonClick(_ sender: UIButton){
        loginView.sendActions(for: UIControlEvents.touchUpInside)
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil)
        {
            // loginView.isUserInteractionEnabled = false
            self.returnUserData()
            
        }
        else
        {
            //  loginView.isUserInteractionEnabled = true
            //print(error.localizedDescription)
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    // Get User Information From Successful Facebook Login
    func returnUserData()
    {
        var fbAccessTokenn : String!
        if((FBSDKAccessToken.current()) != nil){
            
           
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, gender,email,picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    
                    
                    let tempResult = result as! NSDictionary
                    
                    let id = tempResult["id"]! as! String
                    
                    if tempResult["email"] != nil
                    {
                        fbEmail = tempResult["email"]! as! String
                    }else
                    {
                        fbEmail = ""
                    }
                    if tempResult["gender"] != nil
                    {
                        
                        fbGender = tempResult["gender"]! as! String
                    }
                    else
                    {
                        fbGender = ""
                    }
                    if tempResult["first_name"] != nil {
                        
                        fbFirstName = tempResult["first_name"]! as! String
                        fbFirstName = fbFirstName.lowercased()
                    }else{
                        fbFirstName = ""
                    }
                    
                    if tempResult["last_name"] != nil {
                        
                        fbLastName = tempResult["last_name"]! as! String
                        fbLastName = fbLastName.lowercased()
                    }else{
                        fbLastName = ""
                    }
                    
                    if let picture = tempResult["picture"] as? NSDictionary{
                        if let data = picture["data"] as? NSDictionary{
                            fbImageUrl = data["url"] as! String
                        }
                    }
                    
                    fbAccessTokenn = FBSDKAccessToken.current().tokenString
                    // Check Internet Connection
                    if reachability.connection != .none {
                        self.view.addSubview(activityIndicatorView)
                        activityIndicatorView.center = self.view.center
                        
                        activityIndicatorView.startAnimating()
                        
                        
                        userInteractionOff = true
                        
                        var loginParams = ["facebook_uid":id, "code":"%2520", "access_token":fbAccessTokenn, "ip":"127.0.0.1", "subscriptionForm": "1"]
                        if device_uuid != nil{
                            loginParams.updateValue(device_uuid, forKey: "device_uuid")
                        }
                        if device_token_id != nil{
                            loginParams.updateValue(device_token_id, forKey: "device_token")
                        }
                        
                        // Send Server Request for Sign In
                        post(loginParams as! Dictionary<String, String>, url: "login", method: "POST") { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute: {
                                self.signIn.setTitle("Sign In", for: UIControlState())
                                activityIndicatorView.stopAnimating()
                                //    self.loginView.isUserInteractionEnabled = true
                                // On Success save authentication_token in Core Data
                                if(msg)
                                {
                                    // Get Data From Core Data
                                    if succeeded["message"] != nil{
                                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                    }
                                    if succeeded["body"] != nil{
                                        if let body = succeeded["body"] as? NSDictionary{
                                            if var _ = body["oauth_token"] as? String
                                            {
                                                if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                    userInteractionOff = false
                                                    mergeAddToCart()
                                                    self.showHomePage()
                                                }else{
                                                    userInteractionOff = false
                                                    self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                                                }
                                            }
                                            else
                                            {
                                                
                                                
                                                let pv = SignupViewController()
                                                pv.tempDic = body
                                                facebook_uid = id
                                                code = "%2520"
                                                access_token = fbAccessTokenn
                                                self.navigationController?.pushViewController(pv, animated: false)
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                else{
                                    let a = validation as NSDictionary
                                    signupValidation.removeAll(keepingCapacity: false)
                                    if  (UIDevice.current.userInterfaceIdiom == .phone){
                                        
                                        signupValidationKeyValue.removeAll(keepingCapacity: false)
                                        for (key,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                            signupValidationKeyValue.append(key as AnyObject)
                                            
                                        }
                                        
                                        let count = signupValidation.count
                                        
                                        for index in (0..<count) {
                                            self.view.makeToast("\(signupValidationKeyValue[index]) - \(signupValidation[index] as! String).\n", duration: 5, position: "bottom")
                                        }
                                        
                                    }else{
                                        
                                        for (_,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                        }
                                        if signupValidation.count != 0{
                                            let secondViewController = SignUpValidationController()
                                            
                                            secondViewController.validationArray = signupValidation as NSArray?
                                            
                                            
                                            secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                            
                                            secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                            
                                            let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                            //popoverpresentationviewcontroller?.delegate = self
                                            popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                            popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                            popoverpresentationviewcontroller?.sourceView = self.view
                                            self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                        }
                                        
                                    }
                                    self.showRequiredAlert()
                                }
                            })
                        }
                    }else{
                        // No Internet Connection Message
                        self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
                        // self.loginView.isUserInteractionEnabled = true
                    }
                }
            })
        }
    }
    
    func showRequiredAlert(){
        if validationMessage != ""{
            validationMessage = validationMessage.html2String as String
            let alertTest = UIAlertView()
            alertTest.message = "\(validationMessage)"
            alertTest.addButton(withTitle: "Ok")
            alertTest.delegate = self
            alertTest.title = "Message"
            alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
            alertTest.show()
        }
        else if SubscriptionMessage != ""{
            if signUpUserSubscriptionEnabled == true {
                let presentedVC = SignupUserSubscriptionViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                let myString: String = "<a href="
                
                var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                let tempAnotherString = myStringArr[1]
                let temp1: String = ">"
                
                var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                self.Subscriptionurl = myStringArr1[0]
                
                self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                SubscriptionMessage = SubscriptionMessage.html2String as String
                let alertTest = UIAlertView()
                alertTest.message = "\(SubscriptionMessage)"
                alertTest.addButton(withTitle: "Ok")
                alertTest.delegate = self
                alertTest.title = "Message"
                alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                alertTest.show()
            }
        }
    }
    
    
    @objc func termsConditions(){
        let pv = TermsViewController()
        pv.fromLoginPage = true
        navigationController?.pushViewController(pv, animated: true)
    }
    
    @objc func privacy(){
        let pv = PrivacyViewController()
        pv.fromLoginPage = true
        navigationController?.pushViewController(pv, animated: true)
    }
    
    @objc func signUpAction() {
        
        fbFirstName = ""
        fbLastName = ""
        fbEmail = ""
        let presentedVC = SignupViewController()
        navigationController?.pushViewController(presentedVC, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationImage(controller: self)
       self.navigationItem.setHidesBackButton(true, animated: false)
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        if !((formmode !=  "default" && formmode != "otp") && isEnableOtp != false)
        {
            self.forgotPassword.isHidden = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationImage(controller: self)
        
    }
    @objc func logoutSite(){
        oauth_token = ""
        oauth_secret = ""
        logoutUser = true
        refreshMenu = true
        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
        userDefaults!.set(oauth_token, forKey: "oauth_token")
        userDefaults!.set(oauth_secret, forKey: "oauth_secret")
        showHomePage()
    }
    
  
    
    @objc func login()
    {
        var error = ""
        if email.text == "" && pass.text == "" {
            error = NSLocalizedString("Please enter the Email Address and Password.",comment: "")
            email.becomeFirstResponder()
        }
        
        if error == "" {
            if email.text == "" && pass.text != "" {
                error = NSLocalizedString("Please enter the Email Address.",comment: "")
                email.becomeFirstResponder()
            }else if email.text != "" {
            }
        }
        if error == "" && pass.text == ""{
            error = NSLocalizedString("Please enter the Password.",comment: "")
            pass.becomeFirstResponder()
        }
        
        if error != ""{
            let alertController = UIAlertController(title: NSLocalizedString("Error",comment: ""), message:
                error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",comment: ""), style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // Check Internet Connection
            if reachability.connection != .none {
                
                view.isUserInteractionEnabled = false
                loginCustomView.alpha = 0.7
                signIn.setTitle(NSLocalizedString("Loging...",comment: ""), for: UIControlState())
                // Send Server Request for Sign In
                loginParams = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1" , "subscriptionForm": "1"]
                
                if device_uuid != nil{
                    loginParams.updateValue(device_uuid, forKey: "device_uuid")
                }
                if device_token_id != nil{
                    loginParams.updateValue(device_token_id, forKey: "device_token")
                }
                
                post(loginParams, url: "login", method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        self.signIn.setTitle("Sign In", for: UIControlState())
                        self.view.isUserInteractionEnabled = true
                        self.loginCustomView.alpha = 1.0
                        // On Success save authentication_token in Core Data
                        if(msg)
                        {
                            sign_in = 0
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
                                    self.gohomepage(subsResponse : subsResponse)
                                }
                            }
                        }
                        else
                        {
                            // Handle Server Side Error Massages
                            if succeeded["message"] != nil
                            {
                                
                                if validationMessage != ""
                                {
                                    validationMessage = validationMessage.html2String as String
                                    //                                    let alertTest = UIAlertView()
                                    //                                    alertTest.message = "\(validationMessage)"
                                    //                                    alertTest.addButton(withTitle: "Ok")
                                    //                                    alertTest.delegate = self
                                    //                                    alertTest.title = "Message"
                                    //                                    alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                    //                                    alertTest.show()
                                    
                                    let alertController = UIAlertController(title: "Message", message:
                                        "\(validationMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                                        if let url = URL(string: self.Subscriptionurl)
                                        {
                                            
                                            UIApplication.shared.openURL(url)
                                        }
                                    }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                else if SubscriptionMessage != ""
                                {
                                    if signUpUserSubscriptionEnabled == true
                                    {
                                        let presentedVC = SignupUserSubscriptionViewController()
                                        self.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    else
                                    {
                                        let myString: String = "<a href="
                                        
                                        var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                                        let tempAnotherString = myStringArr[1]
                                        let temp1: String = ">"
                                        
                                        var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                                        self.Subscriptionurl = myStringArr1[0]
                                        
                                        self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                                        
                                        SubscriptionMessage = SubscriptionMessage.html2String as String
                                        //                                        let alertTest = UIAlertView()
                                        //                                        alertTest.message = "\(SubscriptionMessage)"
                                        //                                        alertTest.addButton(withTitle: "Ok")
                                        //                                        alertTest.delegate = self
                                        //                                        alertTest.title = "Message"
                                        //                                        alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                        //                                        alertTest.show()
                                        
                                        let alertController = UIAlertController(title: "Message", message:
                                            "\(SubscriptionMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                                            if let url = URL(string: self.Subscriptionurl)
                                            {
                                                
                                                UIApplication.shared.openURL(url)
                                            }
                                        }))
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }else
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                }
                            }
                            
                        }
                    })
                }
            }
            else
            {
                // No Internet Connection Message
                self.view.endEditing(true)
                self.view.makeToast(network_status_msg, duration: 5, position: "top")
                
            }
            
        }
        
    }
    
    @objc func forgotPasswords(){
        if isOTPEnableplugin != 1 {
            let alert = UIAlertController(title: NSLocalizedString("Forgot Password",comment: ""), message: NSLocalizedString("Enter your email address",comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done",comment: ""), style: UIAlertActionStyle.default, handler: forgotPasswordHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = NSLocalizedString("Enter Email",comment: "")
                textField.isSecureTextEntry = false
                self.emailField = textField
            })
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: NSLocalizedString("Forgot Password",comment: ""), message: NSLocalizedString("Please enter your email address or mobile number whose password you want to reset.",comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue",comment: ""), style: UIAlertActionStyle.default, handler: forgotPasswordHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = NSLocalizedString("Enter Email or Mobile No",comment: "")
                textField.isSecureTextEntry = false
                self.emailField = textField
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func forgotPasswordHandler(_ alertView: UIAlertAction!)
    {
        var error = ""
        if error == "" {
            if isOTPEnableplugin != 1 {
                if self.emailField.text! == "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    //                email.becomeFirstResponder()
                }else if self.emailField.text! != "" {
                    if !checkValidEmail(self.emailField.text!){
                        error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                        email.becomeFirstResponder()
                    }
                }
            }
            else
            {
                let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
                
                if self.emailField.text! == "" {
                    error = NSLocalizedString("Please enter the Email Address or Mobile no.",comment: "")
                    //                email.becomeFirstResponder()
                }else if self.emailField.text! != "" {
                    if Set(self.emailField.text!).isSubset(of: nums){
                        if self.emailField.text!.contains("@")
                        {
                            if !checkValidEmail(self.emailField.text!){
                                error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                                email.becomeFirstResponder()
                            }
                        }
                        else if self.emailField.text!.length < 6
                        {
                            error = NSLocalizedString("Please enter the valid Mobile Number.",comment: "")
                            email.becomeFirstResponder()
                        }
                    }
                    else if !checkValidEmail(self.emailField.text!){
                        error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                        email.becomeFirstResponder()
                    }
                }
            }
        }
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.proceed()
        }
    }
    
    @objc func signInAction(){
        var error = ""
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        
        if formmode != "both" {
            if email.text == "" && pass.text == "" {
                error = NSLocalizedString("Please enter the Email Address and Password.",comment: "")
                email.becomeFirstResponder()
            }
            
            if error == "" {
                if email.text == "" && pass.text != "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    email.becomeFirstResponder()
                }else if email.text != "" {
                }
            }
            
            if error == "" && pass.text == ""{
                error = NSLocalizedString("Please enter the Password.",comment: "")
                pass.becomeFirstResponder()
            }
        }
        else
        {
            if error == "" {
                if email.text == "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    email.becomeFirstResponder()
                }
            }
        }
        
        if error != ""{
            let alertController = UIAlertController(title: NSLocalizedString("Error",comment: ""), message:
                error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",comment: ""), style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            
            // Check Internet Connection
            if reachability.connection != .none {
                
                
                self.view.isUserInteractionEnabled = false
                self.loginCustomView.alpha = 0.7
                if formmode != "both" {
                    self.signIn.setTitle("Signing...", for: UIControlState())
                }
                else
                {
                    self.signInotp.setTitle("OTP Signing...", for: UIControlState())
                }
                // Send Server Request for Sign In
                
                var param = ["":""]
                loginParams = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1" , "subscriptionForm": "1"]
                param = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1"]
                OTPvalue = self.email.text!
                
                if device_uuid != nil{
                    loginParams.updateValue(device_uuid, forKey: "device_uuid")
                }
                if device_token_id != nil{
                    loginParams.updateValue(device_token_id, forKey: "device_token")
                }
                
                post(param, url: "otpverifier/send", method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        self.signIn.setTitle("Sign In", for: UIControlState())
                        self.signInotp.setTitle("OTP Sign In", for: UIControlState())
                        self.view.isUserInteractionEnabled = true
                        self.loginCustomView.alpha = 1.0
                        // On Success save authentication_token in Core Data
                        if(msg)
                        {
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
                                    if subsResponse["status"] as? Bool == true
                                    {
                                        //print(subsResponse)
                                        sign_in = 1
                                        
                                        let presentedVC = OtpVerificationViewController()
                                        
                                        if let mobno = subsResponse["phoneno"] as? Int64
                                        {
                                            presentedVC.mobileno = mobno
                                        }
                                        
                                        if let country_code = subsResponse["country_code"] as? Int
                                        {
                                            presentedVC.countrycode = country_code
                                        }
                                        
                                        if let duration = subsResponse["duration"] as? Int
                                        {
                                            presentedVC.duration  = duration
                                        }
                                        presentedVC.useremail = self.email.text!
                                        presentedVC.userpassword = self.pass.text!
                                        self.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    else{
                                        self.gohomepage(subsResponse : subsResponse)//  self.login()
                                    }
                                    
                                }
                            }
                        }
                        else
                        {
                            // Handle Server Side Error Massages
                            if succeeded["message"] != nil
                            {
                                
                                if validationMessage != ""
                                {
                                    validationMessage = validationMessage.html2String as String
                                    //                                    let alertTest = UIAlertView()
                                    //                                    alertTest.message = "\(validationMessage)"
                                    //                                    alertTest.addButton(withTitle: "Ok")
                                    //                                    alertTest.delegate = self
                                    //                                    alertTest.title = "Message"
                                    //                                    alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                    //                                    alertTest.show()
                                    
                                    let alertController = UIAlertController(title: "Message", message:
                                        "\(validationMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                                        if let url = URL(string: self.Subscriptionurl)
                                        {
                                            
                                            UIApplication.shared.openURL(url)
                                        }
                                    }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                else if SubscriptionMessage != ""
                                {
                                    if signUpUserSubscriptionEnabled == true
                                    {
                                        let presentedVC = SignupUserSubscriptionViewController()
                                        self.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    else
                                    {
                                        let myString: String = "<a href="
                                        
                                        var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                                        let tempAnotherString = myStringArr[1]
                                        let temp1: String = ">"
                                        
                                        var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                                        self.Subscriptionurl = myStringArr1[0]
                                        
                                        self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                                        
                                        SubscriptionMessage = SubscriptionMessage.html2String as String
                                        //                                        let alertTest = UIAlertView()
                                        //                                        alertTest.message = "\(SubscriptionMessage)"
                                        //                                        alertTest.addButton(withTitle: "Ok")
                                        //                                        alertTest.delegate = self
                                        //                                        alertTest.title = "Message"
                                        //                                        alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                        //                                        alertTest.show()
                                        
                                        let alertController = UIAlertController(title: "Message", message:
                                            "\(SubscriptionMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                                            if let url = URL(string: self.Subscriptionurl)
                                            {
                                                
                                                UIApplication.shared.openURL(url)
                                            }
                                        }))
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }else
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                }
                            }
                            
                        }
                    })
                }
            }
            else
            {
                // No Internet Connection Message
                self.view.endEditing(true)
                self.view.makeToast(network_status_msg, duration: 5, position: "top")
            }
        }
    }

    
    //Send forgot password request
    func proceed()
    {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        self.emailField.resignFirstResponder()
        self.email.resignFirstResponder()
        self.pass.resignFirstResponder()
        var param  = [String:String]()
        param = ["email":"\(self.emailField.text!)"]
        var forgotPasswordUrl = ""
        if isEnableOtp
        {
            forgotPasswordUrl = "otpverifier/forgot-password"
        }
        else
        {
            forgotPasswordUrl = "forgot-password"
        }
        
        post( param,url: forgotPasswordUrl, method: "POST") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if(msg){
                    if let body = succeeded["body"] as? NSDictionary{
                        //print(body)
                        if let response = body["response"] as? NSDictionary{
                            if let isEmail = response["isEmail"] as? Int
                            {
                                if isEmail != 1 {
                                    let presentedVC = OtpVerificationViewController()
                                    forgotpass = 1
                                    if let mobno = response["phoneno"] as? Int64
                                    {
                                        phone_no = mobno
                                        OTPvalue = "\(mobno)"
                                    }
                                    if let countrycode = response["country_code"] as? Int
                                    {
                                        country_code = String(countrycode)
                                    }
                                    if let duration = response["duration"] as? Int
                                    {
                                        presentedVC.duration  = duration
                                    }
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                }
                                else
                                {
                                    self.view.makeToast(NSLocalizedString("An email has been sent to your email address",comment: ""), duration: 5, position: CSToastPositionCenter)
                                }
                            }
                        }
                    }
                }else{
                    // Handle Server Side Error Massages
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                    }
                }
            })
        }
    }
    
    func gohomepage(subsResponse : NSDictionary)
    {
        
        if subsResponse["subscription"] != nil && subsResponse["subscription"] as! Int == 1{
            let presentedVC = SignupUserSubscriptionViewController()
            if let userId = subsResponse["user_id"] as? Int{
                presentedVC.user_id = userId
            }
            presentedVC.loginOrSignup = true
            presentedVC.email = self.email.text!
            presentedVC.pass = self.pass.text!
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else
        {
            let defaults = UserDefaults.standard
            defaults.set("\(self.pass.text!)", forKey: "userPassword")
            if performLoginActionSuccessfully(subsResponse){
                mergeAddToCart()
                self.showHomePage()
            }
            else
            {
                self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
            }
        }
        
        
    }
    
    
    
    func showHomePage()
    {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        else
        {
            baseController.tabBar.items![1].isEnabled = true
            baseController.tabBar.items![2].isEnabled = true
            baseController.tabBar.items![3].isEnabled = true
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
    }
    @objc func showPassword()
    {
        self.pass.isSecureTextEntry = !self.pass.isSecureTextEntry
        let eyeicon2 = "\u{f070}"
        let eyeicon1 = "\u{f06e}"
        self.pass.becomeFirstResponder()
        if self.pass.isSecureTextEntry {
            button.setTitle(eyeicon1, for: .normal)
        }
        else{
            button.setTitle(eyeicon2, for: .normal)
        }
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.loginCustomView.frame.origin.y -= 20
            self.bottomView.frame.origin.y -= keyBoardHeight
            
        })
    }
    
   
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        pass.isHidden = true
        signIn.isHidden = true
        forgotPassword.isHidden = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nums: Set<Character> = ["0" , "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        if (formmode !=  "default" && formmode != "otp") && isEnableOtp != false && textField.tag == 11{
            if !string.contains(" ") {
                if range.location <= 0 && string == ""
                {
                    pass.isHidden = true
                    signInotp.isHidden = true
                    forgotPassword.isHidden = true
                    signIn.isHidden = false
                    signIn.isEnabled = false
                    signIn.backgroundColor = navColor.withAlphaComponent(0.5)
                }
                else if Set(string).isSubset(of: nums) && string != ""{
                    
                    pass.isHidden = true
                    signIn.isHidden = true
                    forgotPassword.isHidden = true
                    
                    if range.location > 5{
                        UIView.animate(withDuration: 2, animations: {
                            if Set(self.email.text!).isSubset(of: nums)
                            {
                                self.signInotp.isHidden = false
                                self.signInotp.isEnabled = true
                                self.signInotp.backgroundColor = navColor.withAlphaComponent(1.0)
                                self.signInotp.frame.origin.y = getBottomEdgeY(inputView: self.email) + 17
                            }
                            else
                            {
                                self.pass.isHidden = false
                                self.signIn.isHidden = false
                                self.forgotPassword.isHidden = false
                            }
                        })
                    }
                    else
                    {
                        if  range.location == 1{
                            signInotp.isHidden = false
                            signInotp.isEnabled = false
                            signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else if Set(email.text!).isSubset(of: nums)
                        {
                            signInotp.isHidden = false
                            signInotp.isEnabled = false
                            signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else
                        {
                            pass.isHidden = false
                            signIn.isHidden = false
                            forgotPassword.isHidden = false
                        }
                        
                    }
                    
                }
                else if string != ""
                {
                    signInotp.isHidden = true
                    signInotp.isEnabled = false
                    
                    self.pass.isHidden = false
                    self.signIn.isHidden = false
                    self.forgotPassword.isHidden = false
                    signIn.isEnabled = false
                    signIn.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                    
                    self.pass.frame.origin.y = getBottomEdgeY(inputView: self.email) + 11
                    self.signIn.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 62//getBottomEdgeY(inputView: self.pass) + 17
                    self.forgotPassword.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 8//getBottomEdgeY(inputView: self.signIn) + 5
                }
                
                
                
                if self.email.text!.contains("@")
                {
                    UIView.animate(withDuration: 2, animations: {
                        if !checkValidEmail(self.email.text!) || string == ""{
                            self.signIn.isEnabled = false
                            self.signIn.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else{
                            self.pass.isHidden = false
                            self.signIn.isHidden = false
                            self.forgotPassword.isHidden = false
                            
                            self.signIn.isEnabled = true
                            self.signIn.backgroundColor = navColor.withAlphaComponent(1.0)
                            self.pass.frame.origin.y = getBottomEdgeY(inputView: self.email) + 11
                            self.signIn.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 62//getBottomEdgeY(inputView: self.pass) + 17
                            self.forgotPassword.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 8//getBottomEdgeY(inputView: self.signIn) + 5
                        }
                    })
                }
                else if Set(self.email.text!).isSubset(of: nums) && range.location > 0
                {
                    pass.isHidden = true
                    signIn.isHidden = true
                    forgotPassword.isHidden = true
                    
                    if range.location > 5{
                        UIView.animate(withDuration: 2, animations: {
                            self.signInotp.isHidden = false
                            self.signInotp.isEnabled = true
                            self.signInotp.backgroundColor = navColor.withAlphaComponent(1.0)
                            self.signInotp.frame.origin.y = getBottomEdgeY(inputView: self.email) + 17
                        })
                    }
                    else
                    {
                        signInotp.isHidden = false
                        signInotp.isEnabled = false
                        signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                    }
                }
            }
            else
            {
                pass.isHidden = true
                forgotPassword.isHidden = true
                signInotp.isHidden = true
                
                signIn.isHidden = false
                signIn.isEnabled = false
                signIn.backgroundColor = navColor.withAlphaComponent(0.5)
                
            }
        }
        else
        {
            signIn.isEnabled = true
            signIn.isHidden = false
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            forgotPassword.isHidden = false
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        // Animation On TextView End Editing
        UIView.animate(withDuration: 0.5, animations: {
            self.loginCustomView.frame.origin.y += 20
            self.bottomView.frame.origin.y += keyBoardHeight
        })
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if textField.tag == 22
        {
            signInAction()
            return true;
        }
        else
        {
            self.pass.becomeFirstResponder()
            return true
        }
    }
//    @objc func goBack(){
//    _ = self.navigationController?.popViewController(animated: false)
//    }
    
//    @objc func goBack()
//    {
//        //if user click on logout and than back
//        if let _ = self.tabBarController?.tabBar
//        {
//            oauth_token = ""
//            logoutUser = true
//            refreshMenu = true
//            let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
//            userDefaults!.set(oauth_token, forKey: "oauth_token")
//            userDefaults!.set(oauth_secret, forKey: "oauth_secret")
//            menuRefreshConter = 0
//            if let tabBarObject = self.tabBarController?.tabBar
//            {
//                tabBarObject.removeFromSuperview()
//            }
//            self.navigationController?.pushViewController(LoginSlideShowViewController(), animated: false)
//
//        }
//        else   // already logout user or guest user
//        {
//            if goback == true
//            {
//                goback = false
//                _ = self.navigationController?.popViewController(animated: false)
//            }
//            else
//            {
//                if let tabBarObject = self.tabBarController?.tabBar {
//                    tabBarObject.isHidden = true
//                }
//                self.navigationController?.pushViewController(LoginSlideShowViewController(), animated: false)
//            }
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
