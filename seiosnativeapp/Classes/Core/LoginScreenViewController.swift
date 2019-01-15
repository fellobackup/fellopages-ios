/*
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/ios-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 */
//
//  LoginScreenViewController.swift
//  seiosnativeapp
//


import UIKit
import CoreData

var sign_in : Int = 0
var loginParams = ["":""]
var name = [String]()
var namelabel = [String]()
var isEnableOtp = Bool() //Check otp plugin is enabled ot not
var login_id : String = "email"
var forgotpass : Int = 0

class LoginScreenViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var email : UITextField!               // TextField for email
    var pass : UITextField!                // TextField for Password
    var signIn : UIButton!                 // SignIn Action
    var loginCustomView : UIView!
    var fromDashboard : Bool!
    var forgotPassword : UIButton!
    var registerButton : UIButton!
    var browseAsGuest : UIButton!
    var termsServices : UIButton!
    var privacyButton : UIButton!
    var seperator : UILabel!
    var emailField: UITextField!
    var bottomView : UIView!
    var Subscriptionurl: String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var fromPage:String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.view.backgroundColor = bgColor
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        removeNavigationImage(controller: self)
        
        //self.title = NSLocalizedString("Sign In",comment: "")
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.01
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let imageViewTemp = LoginImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageViewTemp.alpha = 0.99
        imageViewTemp.backgroundColor = textColorDark
        
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            // spalshName = "Splash-640x960"
            imageViewTemp.image = UIImage(named: "fellopage_login.png")!
            
        case 667.0:
            // spalshName = "Splash-750x1334"
            imageViewTemp.image = UIImage(named: "fellopage_login.png")!
        case 736.0:
            //spalshName = "Splash-1242x2208"
            imageViewTemp.image = UIImage(named: "fellopage_login.png")!
        default:
            
            imageViewTemp.image = UIImage(named: "fellopage_login.png")!
            
        }
        self.view.addSubview(imageViewTemp)
        
        //        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        //        leftNavView.backgroundColor = UIColor.clear
        //        let tapView = UITapGestureRecognizer(target: self, action: #selector(LoginScreenViewController.goBack))
        //        leftNavView.addGestureRecognizer(tapView)
        //        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        //        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        //        leftNavView.addSubview(backIconImageView)
        //
        //        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        //        self.navigationItem.leftBarButtonItem = barButtonItem
        if(self.fromPage == nil){
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        
        loginCustomView = createView( CGRect(x: 0, y: view.bounds.height/2+250, width: view.bounds.width, height: 320), borderColor: UIColor.clear , shadow: true)
        
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
        //view.addSubview(bottomView)
        bottomView.isHidden = true
        
        let defaults = UserDefaults.standard
        var namelabel : String = "Email Address"
        if let namelabel1 =  defaults.object(forKey: "namelabel") as? String
        {
            namelabel = namelabel1
        }
        email = createSkyTextField(CGRect(x: (view.bounds.width/2 - 140) , y: 2 ,width: 280 , height: 50), borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ %@", comment: ""), messageIcon , namelabel)  , corner: true)
        
        
        email = createSkyTextField(CGRect(x: 45 , y: 2 ,width: view.bounds.width-90 , height: 50), borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ Email", comment: ""), messageIcon)  , corner: true)
        
        email.attributedPlaceholder = NSAttributedString (string: String(format:  NSLocalizedString("Email Address",  comment: ""), messageIcon), attributes: [NSAttributedStringKey.foregroundColor: textColorPrime])
        email.autocapitalizationType = .none
        
        email.textColor = textColorPrime
        email.tintColor = textColorPrime
        email.font =  UIFont(name: "FontAwesome", size: FONTSIZELarge)
        email.delegate = self
        email.tag = 11
        email.backgroundColor = UIColor.clear
        email.autocorrectionType = UITextAutocorrectionType.no
        loginCustomView.addSubview(email)
        self.email.keyboardType = UIKeyboardType.emailAddress
        email.becomeFirstResponder()
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = email.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: email.frame.size.height - width, width: email.frame.size.width, height: 1)
        
        border.borderWidth = width
        email.layer.addSublayer(border)
        email.layer.masksToBounds = true
        email.textColor = textColorPrime
        
        
        let pwdIcon = "\u{F023}"
        pass = createSkyTextField(CGRect(x: 45 , y: 63 ,width: view.bounds.width-90 , height: 50),borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ Password", comment: ""), pwdIcon) , corner: true)  //"\u{F023} Password"
        pass.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        pass.attributedPlaceholder = NSAttributedString(string: String(format:  NSLocalizedString("Password",  comment: ""), pwdIcon), attributes: [NSAttributedStringKey.foregroundColor: textColorPrime])
        pass.backgroundColor = UIColor.clear
        pass.tag = 22
        pass.tintColor = textColorPrime
        pass.textColor = textColorPrime
        pass.isHidden = false
        pass.returnKeyType = UIReturnKeyType.done
        pass.autocapitalizationType = .none
        pass.isSecureTextEntry = true
        pass.delegate = self
        
        let border2 = CALayer()
        let width2 = CGFloat(1.0)
        border2.borderColor = UIColor.white.cgColor
        border2.frame = CGRect(x: 0, y: pass.frame.size.height - width2, width: pass.frame.size.width, height: 1)
        
        border2.borderWidth = width
        pass.layer.addSublayer(border2)
        pass.layer.masksToBounds = true
        loginCustomView.addSubview(pass)
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = pass.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        signIn = createButton(CGRect(x: 45 , y: 140 ,width: view.bounds.width-90 , height: 46) ,title: NSLocalizedString("Login",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        //signIn.backgroundColor = navColor
        signIn.backgroundColor = UIColor.clear
        signIn.layer.borderWidth = 2
        signIn.layer.borderColor = UIColor.white.cgColor
        signIn.layer.cornerRadius = 23
        //        signIn.layer.shadowColor = navColor.CGColor
        //signIn.layer.borderColor = UIColor.clear.cgColor
        //signIn.layer.cornerRadius = cornerRadiusSmall
        signIn.addTarget(self, action: #selector(LoginScreenViewController.signInAction), for: .touchUpInside)
        if deviceIdiom == .pad
        {
            signIn.titleLabel?.font = signIn.titleLabel?.font.withSize(25)
        }
        else
        {
            signIn.titleLabel?.font = signIn.titleLabel?.font.withSize(15)
        }
        loginCustomView.addSubview(signIn)
        
        // Register Button
        
        let customWidth2 = view.bounds.width
        let buttonsWidth2 = customWidth2/2-5
        
        if customWidth2 < 375
        {
            registerButton = createButton(CGRect(x: 15, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 375
        {
            registerButton = createButton(CGRect(x: 45, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 414
        {
            registerButton = createButton(CGRect(x: 60, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 768
        {
            registerButton = createButton(CGRect(x: 210, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 1024
        {
            registerButton = createButton(CGRect(x: 347, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else
        {
            registerButton = createButton(CGRect(x: 250, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        //registerButton = createButton(CGRect(x: 15, y: 200, width: 90, height: 30), title: NSLocalizedString("Register", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        registerButton.layer.cornerRadius = cornerRadiusSmall
        registerButton.backgroundColor = UIColor.clear
        registerButton.addTarget(self, action: #selector(LoginScreenViewController.registerUser), for: .touchUpInside)
        registerButton.isHidden = false
        registerButton.layer.borderColor = UIColor.white.cgColor
        //registerButton.layer.borderWidth = 0.5
        //registerButton.sizeToFit()
        registerButton.contentHorizontalAlignment = .right
        if deviceIdiom == .pad
        {
            registerButton.titleLabel?.font = registerButton.titleLabel?.font.withSize(20)
        }
        else
        {
            registerButton.titleLabel?.font = registerButton.titleLabel?.font.withSize(14)
        }
        
        loginCustomView.addSubview(registerButton)
        
        seperator = createLabel(CGRect(x: registerButton.frame.origin.x+registerButton.bounds.width+5, y:200, width:5, height: 30), text: "|", alignment: NSTextAlignment.center, textColor: textColorPrime)
        loginCustomView.addSubview(seperator)
        
        // Forgot Password Button
        forgotPassword = createButton(CGRect(x: registerButton.frame.origin.x+registerButton.bounds.width+15, y: 200, width: buttonsWidth2, height: 30) ,title: NSLocalizedString("Forgot your password?",comment: "") , border: false, bgColor: true, textColor: textColorPrime)
        forgotPassword.layer.cornerRadius = cornerRadiusSmall
        forgotPassword.backgroundColor = UIColor.clear
        forgotPassword.addTarget(self, action: #selector(LoginScreenViewController.forgotPasswords), for: .touchUpInside)
        forgotPassword.isHidden = false
        forgotPassword.layer.borderColor = UIColor.white.cgColor
        //forgotPassword.layer.borderWidth = 0.5
        forgotPassword.contentHorizontalAlignment = .left
        if deviceIdiom == .pad
        {
            forgotPassword.titleLabel?.font = forgotPassword.titleLabel?.font.withSize(22)
        }
        else
        {
            forgotPassword.titleLabel?.font = forgotPassword.titleLabel?.font.withSize(14)
        }
        
        loginCustomView.addSubview(forgotPassword)
        
        let customWidth = view.bounds.width-90
        let buttonsWidth = customWidth/2
        if view.bounds.width < 375
        {
            termsServices = createButton(CGRect(x: 70, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 375
        {
            termsServices = createButton(CGRect(x: 98, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 414
        {
            termsServices = createButton(CGRect(x: 120, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 768
        {
            termsServices = createButton(CGRect(x: 255, y: 250, width: 90, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else if customWidth2 == 1024
        {
            termsServices = createButton(CGRect(x: 407, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        else
        {
            termsServices = createButton(CGRect(x: 310, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        }
        //termsServices = createButton(CGRect(x: 70, y: 250, width: 65, height: 30), title: NSLocalizedString("Terms", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        termsServices.backgroundColor = UIColor.clear
        termsServices.isHidden = false
        //termsServices.titleLabel?.textAlignment = .right
        //termsServices.contentHorizontalAlignment = .right
        termsServices.layer.borderColor = UIColor.white.cgColor
        //termsServices.layer.borderWidth = 0.5
        if deviceIdiom == .pad
        {
            termsServices.titleLabel?.font = termsServices.titleLabel?.font.withSize(22)
        }
        else
        {
            termsServices.titleLabel?.font = termsServices.titleLabel?.font.withSize(14)
        }
        termsServices.addTarget(self, action: #selector(LoginScreenViewController.termsConditions), for: .touchUpInside)
        loginCustomView.addSubview(termsServices)
        
        privacyButton = createButton(CGRect(x: termsServices.frame.origin.x+termsServices.bounds.width+10, y: 250, width : buttonsWidth-10, height: 30), title: NSLocalizedString("Privacy Policy", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        privacyButton.backgroundColor = UIColor.clear
        if deviceIdiom == .pad
        {
            privacyButton.titleLabel?.font = privacyButton.titleLabel?.font.withSize(22)
        }
        else
        {
            privacyButton.titleLabel?.font = privacyButton.titleLabel?.font.withSize(14)
        }
        
        privacyButton.isHidden = false
        //privacyButton.layer.borderWidth = 0.5
        privacyButton.layer.borderColor = UIColor.white.cgColor
        //privacyButton.titleLabel?.textAlignment = .left
        privacyButton.contentHorizontalAlignment = .left
        privacyButton.addTarget(self, action: #selector(LoginScreenViewController.privacy), for: .touchUpInside)
        loginCustomView.addSubview(privacyButton)
        
        browseAsGuest = createButton(CGRect(x:0, y: 290, width: view.bounds.width, height: 30), title: NSLocalizedString("Browse as Guest", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        browseAsGuest.backgroundColor = UIColor.clear
        browseAsGuest.isHidden = false
        browseAsGuest.addTarget(self, action: #selector(LoginScreenViewController.logoutSite), for: .touchUpInside)
        if deviceIdiom == .pad
        {
            browseAsGuest.titleLabel?.font = browseAsGuest.titleLabel?.font.withSize(22)
        }
        else
        {
            browseAsGuest.titleLabel?.font = browseAsGuest.titleLabel?.font.withSize(14)
        }
        //browseAsGuest.titleLabel?.font = browseAsGuest.titleLabel?.font.withSize(14)
        loginCustomView.addSubview(browseAsGuest)
        
        //        let registerWidth = registerButton.bounds.width
        //        let forgetWidth = forgotPassword.bounds.width
        //        let totalWidth1 = registerWidth+forgetWidth+15
        //        registerButton.frame.origin.x = self.view.bounds.width/2-totalWidth1
        
        self.view.endEditing(true)
        // Do any additional setup after loading the view.
    }
    
    @objc func registerUser()
    {
        fbFirstName = ""
        fbLastName = ""
        fbEmail = ""
        let presentedVC = SignupViewController()
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func logoutSite(){
        oauth_token = ""
        logoutUser = true
        refreshMenu = true
        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
        userDefaults!.set(oauth_token, forKey: "oauth_token")
        userDefaults!.set(oauth_secret, forKey: "oauth_secret")
        showHomePage2()
    }
    
    
    // MARK: - Member Homepage redirection
    func showHomePage2 () {
        menuRefreshConter = 0
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
      
        
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
        self.email.resignFirstResponder()
        self.pass.resignFirstResponder()
        //self.view.endEditing(true)
//        removeNavigationImage(controller: self)

        //self.view.endEditing(true)
        if self.view.bounds.height == 568
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
        }
        else if self.view.bounds.height == 667
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
        }
        else if self.view.bounds.height == 736
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
        }
        else if self.view.bounds.height == 812
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+20)
        }
        else if self.view.bounds.height == 1366
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+20)
        }
        else
        {
            self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
        }
        //self.loginCustomView.frame.origin.y = self.view.bounds.height/2-50
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var toggle : Bool = true
    
    override func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    // MARK:  UITextViewDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Animation On TextView Begin Editing
        //        if toggle == true {
        //            toggle = false
        UIView.animate(withDuration: 0.5, animations: {
            if self.view.bounds.height < 667
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height/2-120
            }
            else
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height/2-100
            }
            
            //self.bottomView.frame.origin.y -= keyBoardHeight
            
        })
        
        //}
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        // Animation On TextView End Editing
        //        if toggle == false {
        //            toggle = true
        UIView.animate(withDuration: 0.5, animations: {
            if self.view.bounds.height == 568
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
            }
            else if self.view.bounds.height == 667
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
            }
            else if self.view.bounds.height == 736
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
            }
            else if self.view.bounds.height == 812
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+20)
            }
            else if self.view.bounds.height == 1366
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+20)
            }
            else
            {
                self.loginCustomView.frame.origin.y = self.view.bounds.height - (self.loginCustomView.bounds.height+10)
            }
            
            //self.bottomView.frame.origin.y += keyBoardHeight
        })
        
        //}
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
    
    
    func goBack()
    {
        //if user click on logout and than back
        if let _ = self.tabBarController?.tabBar
        {
            oauth_token = ""
            logoutUser = true
            refreshMenu = true
            let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
            userDefaults!.set(oauth_token, forKey: "oauth_token")
            userDefaults!.set(oauth_secret, forKey: "oauth_secret")
            menuRefreshConter = 0
            if let tabBarObject = self.tabBarController?.tabBar
            {
                tabBarObject.removeFromSuperview()
            }
            self.navigationController?.pushViewController(LoginViewController(), animated: false)
            
        }
        else   // already logout user or guest user
        {
            if let tabBarObject = self.tabBarController?.tabBar {
                tabBarObject.isHidden = true
            }
            self.navigationController?.pushViewController(LoginViewController(), animated: false)
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex
        {
        case 0:
            
            alertView.removeFromSuperview()
            alertView.isHidden = true
            if let url = URL(string: self.Subscriptionurl)
            {
                
                UIApplication.shared.openURL(url)
            }
            break
            
        default: break
            
        }
    }
    
    @objc func signInAction(){
        
     
        
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
                if !checkValidEmail(email.text!){
                    error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                    email.becomeFirstResponder()
                }
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
        else
        {
            
            // Check Internet Connection
            if reachability.isReachable {
                
                view.isUserInteractionEnabled = false
                loginCustomView.alpha = 0.7
                signIn.setTitle(NSLocalizedString("Signing...",comment: ""), for: UIControlState())
                // Send Server Request for Sign In
                
                var loginParams = ["email":"\(email.text!)","password":"\(pass.text!)","ip":"127.0.0.1" , "subscriptionForm": "1"]
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
                            
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
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
                                        if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                            if self.fromPage == nil {
                                                mergeAddToCart()
                                                self.showHomePage()
                                            }
                                            else {
                                                if self.fromPage == NSLocalizedString("Tickets", comment: ""){
                                                    self.navigationController?.popViewController(animated: false)
                                                }
                                                else{
                                                    return
                                                }
                                            }
                                        }
                                        else
                                        {
                                            self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                                        }
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
                                    let alertTest = UIAlertView()
                                    alertTest.message = "\(validationMessage)"
                                    alertTest.addButton(withTitle: "Ok")
                                    alertTest.delegate = self
                                    alertTest.title = "Message"
                                    alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                    alertTest.show()
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
                                        let alertTest = UIAlertView()
                                        alertTest.message = "\(SubscriptionMessage)"
                                        alertTest.addButton(withTitle: "Ok")
                                        alertTest.delegate = self
                                        alertTest.title = "Message"
                                        alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                                        alertTest.show()
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
    
    func forgotPasswordHandler(_ alertView: UIAlertAction!)
    {
        var error = ""
        if error == "" {
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
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            activityIndicatorView.startAnimating()
            self.emailField.resignFirstResponder()
            self.email.resignFirstResponder()
            self.pass.resignFirstResponder()
            post(["email":"\(self.emailField.text!)"], url: "forgot-password", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if(msg){
                        self.view.makeToast(NSLocalizedString("An email has been sent to your email address",comment: ""), duration: 5, position: "center")
                    }else{
                        // Handle Server Side Error Massages
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "center")
                            
                        }
                        
                    }
                })
                
            }
        }
        
    }
    
    @objc func termsConditions(){
        
        let presentedVC = ExternalWebViewController()
        presentedVC.url = "http://fellopages.com/help/terms?disableHeaderAndFooter=1"
        presentedVC.siteTitle = "Terms"
        presentedVC.fromDashboard = false
        navigationController?.pushViewController(presentedVC, animated: true)
        
        //        let pv = TermsViewController()
        //        pv.fromLoginPage = true
        //        navigationController?.pushViewController(pv, animated: true)
    }
    
    @objc func privacy(){
        let presentedVC = ExternalWebViewController()
        presentedVC.url = "http://fellopages.com/help/privacy?disableHeaderAndFooter=1"
        presentedVC.siteTitle = "Privacy Terms"
        presentedVC.fromDashboard = false
        navigationController?.pushViewController(presentedVC, animated: true)
        //        let pv = PrivacyViewController()
        //        pv.fromLoginPage = true
        //        navigationController?.pushViewController(pv, animated: true)
    }
    
    
    func showHomePage ()
    {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
        createTabs()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
        
    }
}


