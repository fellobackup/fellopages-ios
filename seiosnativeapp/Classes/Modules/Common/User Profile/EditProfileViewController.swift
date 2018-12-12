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
//  EditProfileViewController.swift
//  seiosnativeapp
//

import UIKit


@objcMembers class EditProfileViewController: FXFormViewController, UIPopoverPresentationControllerDelegate {
    
    var popAfterDelay:Bool!
    var id:Int!
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        popAfterDelay = false
        self.title = NSLocalizedString("Edit Profile Info", comment: "")
        conditionalForm = "signupAccountForm"
        
    }
    
    // Generate Form On View Appear
    override func viewDidAppear(_ animated: Bool) {
        generateBlogForm()
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        // Check Internet Connection
        if reachability.connection != .none {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(spinner)
            
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
             var dic = Dictionary<String, String>()
             for (key, value) in form.valuesByKey{
                let string = "\(key)"
                if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment"){
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                }
                else if string.range(of: "alias_city") != nil || string.range(of: "alias_gender") != nil || string.range(of: "alias_country") != nil
                {
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                }
                    
                else if string.hasSuffix("_alias_"){
                    
                    if  form.valuesByKey["\(key)"] is String {
                        if findKeyForValue(form.valuesByKey["\(key)"] as! String) != "" {
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }
                        else
                        {
                            if let receiver = value as? NSString {
                                dic["\(key)"] = receiver as String
                            }
                            if let receiver = value as? Int {
                                dic["\(key)"] = String(receiver)
                            }
                            
                        }
                    }
                    
                    if  form.valuesByKey["\(key)"] is NSNumber{
                        if let receiver = value as? NSString {
                            dic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int {
                            dic["\(key)"] = String(receiver)
                        }
                        
                    }
                }
                else
                {
                    if let receiver = value as? Date {
                        //let tempString = String(describing: receiver)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dic["\(key)"] = dateFormatter.string(from: receiver)
                        //dic["\(key)"] = String(describing: receiver)
                    }
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                    if let receiver = value as? Int {
                        dic["\(key)"] = String(receiver)
                    }
                }
            }
            
            signupDictionary.update(dic)
            dic["account_validation"] = "0"
            dic["fields_validation"] = "1"
            
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = dic
            path = "members/edit/profile"
            
            // Send Server Request to Create/Edit Blog Entries
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    feedUpdate = true
                    self.view.makeToast("Profile Edited Successfully.", duration: 5, position: "bottom")
                    self.popAfterDelay = true
                    updateUserData()
                    self.createTimer(self)
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
        
        
    }
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateBlogForm(){
        // Check Internet Connection
        if reachability.connection != .none {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            UserDefaults.standard.removeObject(forKey: "SellSomething")
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            if signupDictionary.index(forKey: "profile_type") != nil {
                let profileTypeValue = signupDictionary["profile_type"]
                parameter = ["profile_type":"\(String(describing: profileTypeValue))"]
            }else{
                parameter = ["":""]
            }
            
            path = "members/edit/profile"
            // Send Server Request for Create/Edit Blog Form
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
                            
                            if( dic["form"] is NSDictionary ){
                                
                                let tempDictionary = dic["form"] as! NSDictionary
                                var tempArray = [AnyObject]()
                                
                                var allKeys = tempDictionary.allValues
                                
                                for temp in stride(from: allKeys.count-1, through: 0, by: -1){
                                    tempArray = tempArray + ((allKeys[temp] as! NSArray) as [AnyObject])
                                }
                                
                                Form = tempArray
                                
                                if let formValues = dic["formValues"] as? NSDictionary{
                                    var tempDic = [String:String]()
                                    isCreateOrEdit = false
                                    for(key,value) in formValues{
                                        if let tempValues = value as? NSDictionary{
                                            for(k,v) in tempValues{
                                                if (k as! NSString == "value"){
                                                    
                                                    tempDic["\(key)"] = "\(v)"
                                                }
                                            }
                                        }
                                    }
                                    
                                    formValue = tempDic as NSDictionary
                                }
                            }else{
                                let accountArray = dic["fields"] as? NSArray
                                Form = accountArray! as [AnyObject]
                                if let formValues = dic["formValues"] as? NSDictionary{
                                    var tempDic = [String:String]()
                                    for(key,value) in formValues{
                                        if let tempValues = value as? NSDictionary{
                                            for(k,v) in tempValues{
                                                if (k as! NSString == "value"){
                                                    
                                                    tempDic.update(signupDictionary)
                                                    
                                                    tempDic["\(key)"] = "\(v)"
                                                }
                                            }
                                        }
                                    }
                                    
                                    formValue = tempDic as NSDictionary
                                }
                            }
                        }
                        
                        
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                        
                    }else{
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveAndCheckValidations(){
        
        let presentedVC = SignupProfilePhotoController()
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
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
