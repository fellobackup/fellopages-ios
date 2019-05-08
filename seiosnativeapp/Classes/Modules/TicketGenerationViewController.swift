//
//  TicketGenerationViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 01/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import Foundation



var formValue2 = [String: Any]()
class TicketGenerationViewController : FXFormViewController
{
    var popAfterDelay:Bool!
    var contentType : String! = ""
    var formTitle:String!
    var shippingMethodForm = [AnyObject]()
    var shippingMethodFormValue = NSMutableDictionary()
    var countyrKey = NSString()
    var stateDIC = NSMutableDictionary()
    var index = Int()
    var backupForm = [AnyObject]()
    var logoutCartarr = NSMutableArray()
    var leftBarButtonItem: UIBarButtonItem!
    var storeId : String!
    var eventId : String!
    var url : String!
    var param : NSDictionary = [:]
    var dateDictionary : NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TicketGenerationViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        popAfterDelay = false
        
        if self.contentType == "editTicket"
        {
            self.title = NSLocalizedString("Edit Ticket", comment: "")
            isCreateOrEdit = false
            conditionalForm  = "editTicket"
            conditionForm = "editTicket"
        }
        else
        {
            conditionalForm  = "ticketGeneration"
            conditionForm = "ticketGeneration"
            isCreateOrEdit = true
            self.title = NSLocalizedString("Create Ticket", comment: "")
        }
        
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        generateShippingMethodForm()
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
            
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formDictionary = dic["form"] as? NSDictionary
                            {
                                let dic1 = formDictionary["Ticket Details"] as? NSArray
                                for elements in dic1! as [AnyObject]
                                {
                                    Form.append(elements as AnyObject)
                                }
                                let dic2 = formDictionary["Tickets available and buying limits"] as? NSArray
                                for elements in dic2! as [AnyObject]
                                {
                                    Form.append(elements as AnyObject)
                                }
                                let dic3 = formDictionary["Tickets availability duration"] as? NSArray
                                for elements in dic3! as [AnyObject]
                                {
                                    let dateDic = elements as! NSDictionary
                                    let name = dateDic["name"] as! String
                                    if name == "sell_endtime"
                                    {
                                        self.dateDictionary = dateDic
                                    }
                                    Form.append(elements as AnyObject)
                                }
                                var j : Int = 0
                                while j < Form.count
                                {
                                    let dic = Form[j] as! NSDictionary
                                    let name = dic["name"] as! String
                                    if ( name == "sell_endtime" )
                                    {
                                        Form.remove(at: j)
                                        j = j-1
                                    }
                                    else
                                    {
                                        j = j+1
                                    }
                                    
                                }
                            }
                            if let formValues = dic["formValues"] as? NSDictionary
                            {
                                for (key,value) in formValues
                                {
                                    let valueDic = value as! NSDictionary
                                    let realValue = valueDic["value"] as Any
                                    formValue2.updateValue(realValue, forKey: key as! String)
                                    //formValue["\(key)"] = realValue as Any
                                    //formValue.setValue(realValue, forKey: key as! String)
                                }
                                formValue = formValue2 as NSDictionary
                            }
                        }
                        let element = Form.remove(at: 1)
                        Form.insert(element, at: Form.count-1)
                        tempFormArray = Form
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
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        // Check for errors
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if(form.valuesByKey["\(name)"] == nil)
            {
                form.valuesByKey["\(name)"] = Formbackup["\(name)"]
            }
        }
        
        var error = ""
        var errorTitle = "Error"
        
        if ( form.valuesByKey["title"] == nil || form.valuesByKey["title"] as! String == "")
        {
            errorTitle = NSLocalizedString("Title of Ticket!", comment: "")
            error = NSLocalizedString("Please enter the title of the Ticket", comment: "")
        }
        else if ( form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == "" )
        {
            errorTitle = NSLocalizedString("Ticket Price!!", comment: "")
            error = NSLocalizedString("Please enter Ticket Price", comment: "")
        }
        else if ( form.valuesByKey["quantity"] == nil || form.valuesByKey["quantity"] as! String == "" )
        {
            errorTitle = NSLocalizedString("Ticket Quantity!!", comment: "")
            error = NSLocalizedString("Please enter Total Tickets Available", comment: "")
        }
        else if ( form.valuesByKey["buy_limit_min"] != nil && form.valuesByKey["buy_limit_min"] as! String == "")
        {
            errorTitle = NSLocalizedString("Minimum Buying Limit!", comment: "")
            error = NSLocalizedString("Please enter Minimum Buying Limit!", comment: "")
        }
        else if ( form.valuesByKey["buy_limit_max"] != nil && form.valuesByKey["buy_limit_max"] as! String == "")
        {
            errorTitle = NSLocalizedString("Maximum Buying Limit!", comment: "")
            error = NSLocalizedString("Please enter Maximum Buying Limit!", comment: "")
        }
        if error != ""
        {
            let alertController = UIAlertController(title: "\(errorTitle)", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
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
                    
                    let conditionArray:[String] = ["is_claimed_display","is_same_end_date","status"]
                    if conditionArray.contains(key as! String)
                    {
                        if let _ = value as? NSString
                        {
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }
                        if let receiver = value as? Int
                        {
                            dic["\(key)"] = String(receiver)
                        }
                    }
                    else
                    {
                        if let receiver = value as? NSString
                        {
                            dic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int
                        {
                            dic["\(key)"] = String(receiver)
                        }
                        if let receiver = value as? Date
                        {
                            let dateFormatter = DateFormatter()
                            //dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                            dateFormatter.dateFormat = "d MMM YYYY h:mm a"
                            dateFormatter.amSymbol = "AM"
                            dateFormatter.pmSymbol = "PM"
                            dic["\(key)"] = dateFormatter.string(from: receiver)
                        }
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
                
                
                self.popAfterDelay = true
                //Set Parameters (Token & Form Values) & path for Adding Shipping method
                var path = ""
                path = self.url
                var parameter = [String:String]()
                parameter = dic
                print(parameter)
                
                
                // Send Server Request for Form
                post(parameter,url: path , method: "post") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                        
                        if msg
                        {
                            UIApplication.shared.keyWindow?.makeToast(String(format: NSLocalizedString("Ticket Created successfully!", comment: ""), self.contentType ), duration: 5, position: "bottom")
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
    
    @objc func ticketEndDate(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "is_same_end_date"
            {
                index = i
            }
        }
        for (key,_) in form.valuesByKey
        {
            Formbackup["\(key)"] = form.valuesByKey["\(key)"]
        }
        
        var j : Int = 0
        while j < Form.count
        {
            let dic = Form[j] as! NSDictionary
            let name = dic["name"] as! String
            if ( name == "sell_endtime" )
            {
                Form.remove(at: j)
                //Formbackup["\(name)"] = ""
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }
        
        
        if form.valuesByKey["is_same_end_date"] != nil
        {
            
            if form.valuesByKey["is_same_end_date"] as! String == "Set your custom time"
            {
                index += 1
                let dic = self.dateDictionary
                print(dic)
                Form.insert(dic as AnyObject, at: index)
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
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
}

