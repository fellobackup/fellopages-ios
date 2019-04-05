//
//  AddPaymentMethodViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 09/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

var FieldsArray = [AnyObject]()

class AddPaymentMethodViewController : FXFormViewController
{
    var popAfterDelay:Bool!
    //var contentType : String! = ""
    //var formTitle:String!
    var fieldsArray = [AnyObject]()
    var optionsArray = [AnyObject]()
    var formvalues = [String : Any]()
    var index = Int()
    var backupForm = [AnyObject]()
    var leftBarButtonItem: UIBarButtonItem!
    var storeId : String!
    var password : String!
    var url : String!
    var param : NSDictionary!
    var eventId : Int!
    var fromEventGutter = false
    var fromCreateEvent = false
    var contentGutterMenu: NSArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        if fromCreateEvent == true {
            let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(AddPaymentMethodViewController.cancel))
            self.navigationItem.leftBarButtonItem = cancel
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControlState())
            cancel.tintColor = textColorPrime
            
            let skip = UIBarButtonItem(title: NSLocalizedString("Skip",  comment: ""), style:.plain , target:self , action: #selector(AddPaymentMethodViewController.skip))
            self.navigationItem.rightBarButtonItem = skip
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControlState())
            skip.tintColor = textColorPrime
        }
        else {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AddPaymentMethodViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
      
        
        popAfterDelay = false
        self.title = NSLocalizedString("Payment Methods", comment: "")
        conditionalForm  = "paymentMethod"
        conditionForm = "paymentMethod"
        isCreateOrEdit = true
        
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        
        generateShippingMethodForm()
    }
    
    @objc func cancel()
    {
        conditionalProfileForm = "eventPaymentCancel"
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func skip()
    {
         self.navigateToTicket()
    }
    func navigateToTicket()
    {
        for menu in self.contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                if menuItem["name"] as! String == "create_ticket"
                {
                    let presentedVC = ManageEventTicketViewController()
                    presentedVC.url = "advancedeventtickets/tickets/manage"
                    presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                    presentedVC.fromCreateEvent = true
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool)
    {
        Form = backupForm
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        backupForm = Form
    }
    
    @objc func goBack()
    {
        conditionForm = ""
        conditionalForm = ""
        _ = self.dismiss(animated: false, completion: nil)
        //_ = self.navigationController?.popViewController(animated: false)
    }
    
    func generateShippingMethodForm()
    {
        
        // Check Internet Connection
        if reachability.isReachable
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Adding new Shipping Method
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            for (key,value) in param
            {
                if let id = value as? NSNumber {
                    parameter["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    parameter["\(key)"] = receiver as String
                }
            }
            path = self.url
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if self.fromEventGutter == true {
                                if let paypalEnable = dic["paypalEnable"] as? Int {
                                    print("proceed to ticket")
                                    self.navigateToTicket()
                                }
                            }
                            
                            if let formvalue = dic["formValues"] as? NSDictionary
                            {
                                formValue = formvalue
                            }
                            if let formarr = dic["form"] as? NSArray
                            {
                                for i in 0 ..< (formarr.count) where i < formarr.count
                                {
                                    var arrindex = 0
                                    let dic = formarr[i] as? NSDictionary
                                    let name = dic?["name"] as? String
                                    if name == "isPaypalChecked" || name == "isByChequeChecked" || name == "isCodChecked"
                                    {
                                        self.optionsArray.insert(dic as AnyObject, at: arrindex)
                                        arrindex += 1
                                    }
                                    
                                    if (name == "email" || name == "username" || name == "password" || name == "signature") && formValue["isPaypalChecked"] as? Int == 1
                                    {
                                        self.optionsArray.insert(dic as AnyObject, at: arrindex)
                                        arrindex += 1
                                    }
                                
                                    if name == "bychequeGatewayDetail" && formValue["isByChequeChecked"] as? Int == 1
                                    {
                                        self.optionsArray.insert(dic as AnyObject, at: arrindex)
                                        arrindex += 1
                                    }
                                }
                                for j in 0 ..< (formarr.count) where j < formarr.count
                                {
                                    var fieldIndex = 0
                                    let dic = formarr[j] as? NSDictionary
                                    let name = dic?["name"] as? String
                                    if name == "email" || name == "username" || name == "password" || name == "signature" || name == "bychequeGatewayDetail"
                                    {
                                        self.fieldsArray.insert(dic as AnyObject, at: fieldIndex)
                                        fieldIndex += 1
                                    }
                                }
                                self.optionsArray = self.optionsArray.reversed()
                                self.fieldsArray = self.fieldsArray.reversed()
                                
                                Form = self.optionsArray as [AnyObject]
                                tempFormArray = self.optionsArray as [AnyObject]
                                FieldsArray = self.fieldsArray as [AnyObject]
                                
                            }
                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic
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
    
    
    @objc func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        // Check the navigation origin
        if self.fromCreateEvent == true {
            popAfterDelay = false
        }
        else {
            popAfterDelay = true
        }
        //self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        // Check for errors
       
        var error = ""
        var errorTitle = "Error"
        var isPaypalChecked = 0
        var isByChequeChecked = 0
        var isCodChecked = 0
        
        if( (form.valuesByKey["isPaypalChecked"] != nil) && (form.valuesByKey["isPaypalChecked"] as! Int) == 1)
        {
            
            if( (form.valuesByKey["email"] == nil) || (form.valuesByKey["email"] as! String) == "") {
                error = NSLocalizedString("Please enter paypal Email", comment: "")
            }
            
            if( (form.valuesByKey["username"] == nil) || (form.valuesByKey["username"] as! String) == "") {
                error = NSLocalizedString("Please enter paypal username", comment: "")
            }
            
            if( (form.valuesByKey["password"] == nil) || (form.valuesByKey["password"] as! String) == "") {
                error = NSLocalizedString("Please enter paypal password", comment: "")
            }
            
            if( (form.valuesByKey["signature"] == nil) || (form.valuesByKey["signature"] as! String) == "") {
                error = NSLocalizedString("Please enter paypal API Signature", comment: "")
            }
            
        }
        
        if( (form.valuesByKey["isByChequeChecked"] != nil) && (form.valuesByKey["isByChequeChecked"] as! Int) == 1)
        {
            if( (form.valuesByKey["bychequeGatewayDetail"] == nil) || (form.valuesByKey["bychequeGatewayDetail"] as! String) == "") {
                error = NSLocalizedString("Please enter Cheque Details", comment: "")
            }
        }
        
        if( form.valuesByKey["isPaypalChecked"] != nil) {
            isPaypalChecked = form.valuesByKey["isPaypalChecked"] as! Int
        }
        if( form.valuesByKey["isByChequeChecked"] != nil) {
            isByChequeChecked = form.valuesByKey["isByChequeChecked"] as! Int
        }
        if( form.valuesByKey["isCodChecked"] != nil) {
            isCodChecked = form.valuesByKey["isCodChecked"] as! Int
        }
        
        if isPaypalChecked == 0 && isByChequeChecked == 0 && isCodChecked == 0 {
            error = "Please select at least 1 payment method"
        }
        if error != ""
        {
            let alertController = UIAlertController(title: "\(errorTitle)", message:
                error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
            
        else
        {
            if reachability.isReachable
            {
                view.isUserInteractionEnabled = false
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var dic = Dictionary<String, String>()
                
                for (key, value) in form.valuesByKey
                {
                    if let receiver = value as? NSString
                    {
                        dic["\(key)"] = receiver as String
                    }
                    if let receiver = value as? Int
                    {
                        dic["\(key)"] = String(receiver)
                    }
                }
                
                for (key,value) in param
                {
                    if let id = value as? NSNumber {
                        dic["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                }
                
                
                
//                self.popAfterDelay = true
                //Set Parameters (Token & Form Values) & path for Adding Shipping method
                var path = ""
                path = "advancedeventtickets/order/set-event-gateway-info"
                var parameter = [String:String]()
                parameter = dic
                print(parameter)
                // Send Server Request for Form
                post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                        
                        if msg
                        {
                            UIApplication.shared.keyWindow?.makeToast(String(format: NSLocalizedString("Payment Method has been added successfully.", comment: ""), "" ), duration: 5, position: "bottom")
                            self.createTimer(self)
                        }
                        else
                        {
                            self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                            if validationMessage != ""
                            {
                                self.view.makeToast("\(validationMessage)", duration: 5, position: "bottom")
                            }
                            else
                            {
                                self.view.makeToast("\(succeeded["message"]!)", duration: 5, position: "bottom")
                            }
                        }
                    })
                }
            }
        }
        
        // Check Internet Connection
        
    }
    
    // Submit form ends here
    
    
    // Sub Fields Insertion in the form on the value changed
    @objc func showPaypalFields(_ cell : FXFormFieldCellProtocol)
    {
        
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "isPaypalChecked"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["isPaypalChecked"] != nil)
        {
            if form.valuesByKey["isPaypalChecked"] as! Int == 1
            {
                var ndic = FieldsArray[0] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                index += 1
                ndic = FieldsArray[1] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                index += 1
                ndic = FieldsArray[2] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                index += 1
                ndic = FieldsArray[3] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                tempFormArray = Form
            }
            if form.valuesByKey["isPaypalChecked"] as! Int == 0
            {
                
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if ( name == "email" || name == "username" || name == "password" || name == "signature" )
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    
    @objc func showChequeField(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "isByChequeChecked"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["isByChequeChecked"] != nil)
        {
            if form.valuesByKey["isByChequeChecked"] as! Int == 1
            {
                let ndic = FieldsArray[FieldsArray.count-1] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                tempFormArray = Form
            }
            
            if formValue["isByChequeChecked"] as? Int == 1
            {
                print("hello")
            }
            
            if form.valuesByKey["isByChequeChecked"] as! Int == 0
            {
                for i in 0 ..< (Form.count) where i < Form.count
                {
                    let dic = Form[i] as! NSDictionary
                    let name = dic["name"] as! String
                    if name == "bychequeGatewayDetail"
                    {
                        Form.remove(at: i)
                    }
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {
            conditionalForm = ""
            conditionForm = ""
            self.dismiss(animated: true, completion: nil)
        }
        else {
             self.navigateToTicket()
        }
    }
    
}


