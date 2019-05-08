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

//  SignupViewController.swift

import UIKit
var signupDictionary = Dictionary<String, String>()
var signupValidation = [AnyObject]()
var signupValidationKeyValue = [AnyObject]()
var validation = NSDictionary()
var validationMessage : String = ""
var profileType : String!
var InitialForm = [AnyObject]()
var signUpPhotoFlag = false
var signUpUserSubscriptionEnabled = false
var isEmailValidationEnabled = false
var OTP = Bool()
var OTPvalue : String = ""
var sign_up : Int = 0

@objcMembers class SignupViewController: FXFormViewController, UIPopoverPresentationControllerDelegate, TTTAttributedLabelDelegate {
    var popAfterDelay:Bool!
    var id:Int!
    var tempDic : NSDictionary!
    var leftBarButtonItem : UIBarButtonItem!
    var phoneno : String = ""
    var isOtpSend : Bool = false
    var ticketViewController:TicketDetailViewController?
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = bgColor
        
        self.navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        popAfterDelay = false
        self.title = NSLocalizedString("Sign Up", comment: "")
        conditionalForm = "signupAccountForm"
        generateSignUpForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        //print("Hello")
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Server Connection For Sign Up Form Creation & Submission
    
    // FXFormForm Submission for Sign Up Form
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        Form = InitialForm
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        var error = ""
        if (form.valuesByKey["email"] != nil){
            OTPvalue = form.valuesByKey["email"] as! String
            //print("\(OTPvalue)===========>>>>>>")
            OTP = OTPvalue.contains("@")
            if ((form.valuesByKey["email"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter  email.", comment: "")
            }
        }
        if (form.valuesByKey["emailaddress"] != nil){
            OTPvalue = form.valuesByKey["emailaddress"] as! String
            
            OTP = OTPvalue.contains("@")
            if ((form.valuesByKey["emailaddress"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter  email.", comment: "")
            }
        }
        
        if (form.valuesByKey["country_code"] != nil){
            country_code = form.valuesByKey["country_code"] as! String
        }
        
        if (form.valuesByKey["phoneno"] != nil){
            phoneno = form.valuesByKey["phoneno"] as! String
            OTPvalue = form.valuesByKey["phoneno"] as! String
        }
        
        if(facebook_uid != nil)
        {
            if(form.valuesByKey["password"] != nil){
                if ((form.valuesByKey["password"] as! String) == "") &&  error == ""{
                    error = NSLocalizedString("Please enter the password.", comment: "")
                }
            }
            if(form.valuesByKey["passconf"] != nil){
                if ((form.valuesByKey["passconf"] as! String) == "") &&  error == ""{
                    error = NSLocalizedString("Please enter the confirm password.", comment: "")
                }
            }
        }
        if(form.valuesByKey["username"] != nil){
            if ((form.valuesByKey["username"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter username.", comment: "")
            }
        }
        for (key, _) in form.valuesByKey{
            if (key as! NSString == "profile_type"){
                profileType = findKeyForValue(form.valuesByKey["\(key)"] as! String)
            }
        }
        
        if error != ""{
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            if isEnableOtp != false {
                // Check Internet Connection
                if reachability.connection != .none {
                    view.isUserInteractionEnabled = false
                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                    var dic = Dictionary<String, String>()
                    for (key, value) in form.valuesByKey{
                        
                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }else{
                            if let receiver = value as? NSString {
                                dic["\(key)"] = receiver as String
                            }
                            if let receiver = value as? Int {
                                dic["\(key)"] = String(receiver)
                            }
                            dic["fields_validation"] = "0"
                        }
                        
                    }
                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                  //  var path = ""
                    if(facebook_uid != nil)
                    {
                       // path = "signup/validations"
                        dic["account_validation"] = "1"
                        dic["facebook_uid"] = String(facebook_uid)
                        dic["code"] = "%2520"
                        dic["access_token"] = String(access_token)
                    }
                    else
                    {
                        dic["account_validation"] = "1"
                     //   path = "signup/validations"
                    }
                    var parameter = [String:String]()
                    parameter = ["emailaddress":OTPvalue,"country_code":country_code]
                    // Send Server Request to Sign Up Form
                    post(parameter,url: "otpverifier/verify-mobileno" , method: "POST") { (succeeded, msg) -> () in
                        
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            UIApplication.shared.keyWindow?.willRemoveSubview(activityIndicatorView)
                            self.view.alpha = 1.0
                            self.view.isUserInteractionEnabled = true
                            if msg{
                                var otpDuration :Int = 0
                                if let body = succeeded["body"] as? NSDictionary
                                {
                                    //print(body)
                                    if let subsResponse = succeeded["body"] as? NSDictionary{
                                        if let Response = subsResponse["response"] as? NSDictionary{
                                            if let duration = Response["duration"] as? Int
                                            {
                                                otpDuration  = duration
                                            }
                                        }
                                    }
                                    if let response = body["response"] as? NSDictionary
                                    {   otp = ""
                                        self.isOtpSend = response["isOtpSend"] as! Bool
                                        if self.isOtpSend == true {
                                            if let code = response["code"]
                                            {
                                                otp = "\(code)"
                                            }
                                            
                                            if let senttime = response["sent_time"] as? String
                                            {
                                                sent_time = senttime
                                            }
                                            
                                            if let expairyTime = response["expairyTime"] as? Int64
                                            {
                                                expairy_time = expairyTime
                                            }
                                        }
                                    }
                                }
                                if reachability.connection != .none {
                                    
                                    self.view.isUserInteractionEnabled = false
                                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                                    activityIndicatorView.center = self.view.center
                                    activityIndicatorView.startAnimating()
                                    var dic = Dictionary<String, String>()
                                    for (key, value) in form.valuesByKey{
                                        
                                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                                        }else{
                                            if let receiver = value as? NSString {
                                                dic["\(key)"] = receiver as String
                                            }
                                            if let receiver = value as? Int {
                                                dic["\(key)"] = String(receiver)
                                            }
                                            dic["fields_validation"] = "0"
                                        }
                                        
                                    }
                                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                                    var path = ""
                                    if(facebook_uid != nil)
                                    {
                                        path = "signup/validations"
                                        dic["account_validation"] = "1"
                                        dic["facebook_uid"] = String(facebook_uid)
                                        dic["code"] = "%2520"
                                        dic["access_token"] = String(access_token)
                                    }
                                    else
                                    {
                                        dic["account_validation"] = "1"
                                        path = "signup/validations"
                                    }
                                    var parameter = [String:String]()
                                    parameter = dic
                                    
                                    signupDictionary = dic
                                    
                                    fbEmail = ""
                                    // Send Server Request to Sign Up Form
                                    post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                                        
                                        DispatchQueue.main.async(execute: {
                                            activityIndicatorView.stopAnimating()
                                            self.view.alpha = 1.0
                                            self.view.isUserInteractionEnabled = true
                                            if msg{
                                                if (OTP == false || self.phoneno != "") && self.isOtpSend == true
                                                {
                                                    sign_up = 1
                                                    let presentedVC = OtpVerificationViewController()
                                                    presentedVC.duration  = otpDuration
                                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                                }
                                                else
                                                {
                                                    let presentedVC = SignupProfileFieldController()
                                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                                }
                                            }
                                            else{
                                                self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                                if  (UIDevice.current.userInterfaceIdiom == .phone){
                                                    let a = validation
                                                    signupValidation.removeAll(keepingCapacity: false)
                                                    signupValidationKeyValue.removeAll(keepingCapacity: false)
                                                    for (key,value) in a  {
                                                        signupValidation.append(value as AnyObject)
                                                        signupValidationKeyValue.append(key as AnyObject)
                                                        
                                                    }
                                                    let count = signupValidation.count
                                                    for index in 0 ..< count {
                                                        if signupValidationKeyValue[index] as! NSString == "passconf"
                                                        {
                                                            self.view.makeToast("Password - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                                        }
                                                        else if signupValidationKeyValue[index] as! NSString == "password"
                                                        {
                                                            self.view.makeToast("Password - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                                        }
                                                        else if signupValidationKeyValue[index] as! NSString == "username"
                                                        {
                                                            self.view.makeToast("Username - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                                        }
                                                        else  if signupValidationKeyValue[index] as! NSString == "terms"
                                                        {
                                                            self.view.makeToast("Terms - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                                        }
                                                        else{
                                                            self.view.makeToast("\(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                                        }
                                                    }
                                                }else{
                                                    let a = validation
                                                    signupValidation.removeAll(keepingCapacity: false)
                                                    for (_,value) in a  {
                                                        signupValidation.append(value as AnyObject)
                                                    }
                                                    let secondViewController = SignUpValidationController()
                                                    secondViewController.validationArray = signupValidation as NSArray?
                                                    secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                                    secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                                    let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                                    popoverpresentationviewcontroller?.delegate = self
                                                    popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                                    popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                                    popoverpresentationviewcontroller?.sourceView = self.view
                                                    self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                            else
                            {
                                if succeeded["message"] != nil{
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                    
                                }
                            }
                        })
                    }
                }
            }
            else
            {
                if reachability.connection != .none {
                    
                    self.view.isUserInteractionEnabled = false
                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                    var dic = Dictionary<String, String>()
                    for (key, value) in form.valuesByKey{
                        
                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }else{
                            if let receiver = value as? NSString {
                                dic["\(key)"] = receiver as String
                            }
                            if let receiver = value as? Int {
                                dic["\(key)"] = String(receiver)
                            }
                            dic["fields_validation"] = "0"
                        }
                        
                    }
                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                    var path = ""
                    if(facebook_uid != nil)
                    {
                        path = "signup/validations"
                        dic["account_validation"] = "1"
                        dic["facebook_uid"] = String(facebook_uid)
                        dic["code"] = "%2520"
                        dic["access_token"] = String(access_token)
                    }
                    else
                    {
                        dic["account_validation"] = "1"
                        path = "signup/validations"
                    }
                    var parameter = [String:String]()
                    parameter = dic
                    
                    signupDictionary = dic
                    
                    fbEmail = ""
                    // Send Server Request to Sign Up Form
                    post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                        
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            self.view.alpha = 1.0
                            self.view.isUserInteractionEnabled = true
                            if msg{
                                let presentedVC = SignupProfileFieldController()
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            else{
                                self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                if  (UIDevice.current.userInterfaceIdiom == .phone){
                                    let a = validation
                                    signupValidation.removeAll(keepingCapacity: false)
                                    signupValidationKeyValue.removeAll(keepingCapacity: false)
                                    for (key,value) in a  {
                                        signupValidation.append(value as AnyObject)
                                        signupValidationKeyValue.append(key as AnyObject)
                                        
                                    }
                                    let count = signupValidation.count
                                    for index in 0 ..< count {
                                        if signupValidationKeyValue[index] as! NSString == "passconf"
                                        {
                                            self.view.makeToast("Password - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                        }
                                        else if signupValidationKeyValue[index] as! NSString == "password"
                                        {
                                            self.view.makeToast("Password - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                        }
                                        else if signupValidationKeyValue[index] as! NSString == "username"
                                        {
                                            self.view.makeToast("Username - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                        }
                                        else  if signupValidationKeyValue[index] as! NSString == "terms"
                                        {
                                            self.view.makeToast("Terms - \(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                        }
                                        else{
                                            self.view.makeToast("\(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
                                        }
                                    }
                                }else{
                                    let a = validation
                                    signupValidation.removeAll(keepingCapacity: false)
                                    for (_,value) in a  {
                                        signupValidation.append(value as AnyObject)
                                    }
                                    let secondViewController = SignUpValidationController()
                                    secondViewController.validationArray = signupValidation as NSArray?
                                    secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                    secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                    let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                    popoverpresentationviewcontroller?.delegate = self
                                    popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                    popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                    popoverpresentationviewcontroller?.sourceView = self.view
                                    self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // Create Request for Generation of Sign Up Form
    func generateSignUpForm(){
        signupDictionary = ["":""]
        // Check Internet Connection
        if reachability.connection != .none {
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            UserDefaults.standard.removeObject(forKey: "preferenceName")
            UserDefaults.standard.removeObject(forKey: "SellSomething")
            textstoreValue = ""
            isCreateOrEdit = true
            if(tempDic != nil)
            {
                activityIndicatorView.stopAnimating()
                DispatchQueue.main.async(execute: {
                    if let accountArray = self.tempDic["account"] as? NSArray{
                        
                        if let _ = self.tempDic["photo"] as? NSArray{
                            signUpPhotoFlag = true
                        }else{
                            signUpPhotoFlag = false
                        }
                        
                        if let _ = self.tempDic["subscription"] as? NSArray{
                            signUpUserSubscriptionEnabled = true
                        }else{
                            signUpUserSubscriptionEnabled = false
                        }
                        
                        if let EnablisEmailVerification = self.tempDic["isEmailVerificationEnable"] as? Int{
                            if EnablisEmailVerification == 1
                            {
                                isEmailValidationEnabled = true
                            }
                            else
                            {
                                isEmailValidationEnabled = false
                            }
                        }
                        
                        Form = accountArray as [AnyObject]
                        InitialForm = accountArray as [AnyObject]
                    }
                    self.formController.form = CreateNewForm()
                    self.formController.tableView.reloadData()
                })
            }
            else
            {
                //Set Parameters & path for Sign Up Form
                var parameter = [String:String]()
                var path = ""
                parameter = ["":""]
                parameter["subscriptionForm"] = "1"
                path = "signup"
                
                // Send Server Request for Sign Up Form
                post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            // On Success Add Value to Form Array & Values to formValue Array
                            Form.removeAll(keepingCapacity: false)
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                
                            }
                            if let dic = succeeded["body"] as? NSDictionary{
                                
                                if let EnablisEmailVerification = dic["isEmailVerificationEnable"] as? Int{
                                    if EnablisEmailVerification == 1
                                    {
                                        isEmailValidationEnabled = true
                                    }
                                    else
                                    {
                                        isEmailValidationEnabled = false
                                    }
                                }
                                
                                if let _ = dic["photo"] as? NSArray{
                                    signUpPhotoFlag = true
                                }else{
                                    signUpPhotoFlag = false
                                }
                                
                                if let _ = dic["subscription"] as? NSArray{
                                    signUpUserSubscriptionEnabled = true
                                }else{
                                    signUpUserSubscriptionEnabled = false
                                }
                                
                                if let accountArray = dic["account"] as? NSArray
                                {
                                    Form = accountArray as [AnyObject]
                                    InitialForm = accountArray as [AnyObject]
                                }
                                if let photoArray = dic["photo"] as? NSArray
                                {
                                    PhotoForm = photoArray as [AnyObject]
                                }
                                if let isEnable_otp = dic["isEnableotp"] as? String
                                {
                                    if isEnable_otp == "1"
                                    {
                                        isEnableOtp = true
                                    }
                                    else
                                    {
                                        isEnableOtp = false
                                    }
                                }
                                else if let isEnable_otp = dic["isEnableotp"] as? Int
                                {
                                    if isEnable_otp == 1
                                    {
                                        isEnableOtp = true
                                    }
                                    else
                                    {
                                        isEnableOtp = false
                                    }
                                }
                                
                            }
                            // Create FXForm Form
                            self.formController.form = CreateNewForm()
                            self.formController.tableView.reloadData()
                        }
                        else
                        {
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            }
                        }
                    })
                }
            }
        }
    }
    
    func readTerms(_ cell: FXFormFieldCellProtocol)
    {
        
        if termPrivacyUrl != nil && termPrivacyUrl != ""{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = termPrivacyUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack()
    {
        let alertController = UIAlertController(title: "Go Back?", message:"Are you sure that you want to go back?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default,handler: { action -> Void in
            FBSDKAccessToken.setCurrent(nil)
            if let tabBarObject = self.tabBarController?.tabBar
            {
                tabBarObject.isHidden = false
            }
            _ = self.navigationController?.popViewController(animated: false)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
