//
//  LocationAutoSuggestInForm.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 17/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import Foundation

class LocationAutoSuggestInForm: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource
{
    var sendMsg:UIBarButtonItem!
    var locLabel: UITextField!
    var loc : String!
    var locationArray : NSArray!
    var locationTable: UITableView!
    var locDic : NSDictionary!
    var iscomingFrom:String = ""
    var popAfterDelay:Bool!
    var button : UIButton!
    var navView = UIView()
    var titleLabel = UILabel()
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        popAfterDelay = false
        if iscomingFrom == "feed"
        {
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(LocationAutoSuggestInForm.cancel))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        else
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(LocationAutoSuggestInForm.cancel))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        button.addTarget(self, action: #selector(LocationAutoSuggestInForm.send), for: UIControl.Event.touchUpInside)
        //        button.isHidden = true
        let sendButton = UIBarButtonItem()
        
        sendButton.customView = button
        self.navigationItem.setRightBarButtonItems([sendButton], animated: true)
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseLocationViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        
        locLabel = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Type location",  comment: ""), corner: true)
        locLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Type location",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        locLabel.addTarget(self, action: #selector(LocationAutoSuggestInForm.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        locLabel.font =  UIFont(name: fontName, size: FONTSIZELarge)
        locLabel.backgroundColor = bgColor
        locLabel.delegate = self
        locLabel.layer.masksToBounds = true
        view.addSubview(locLabel)
        
        
        let defaults = UserDefaults.standard
//        if let name = defaults.string(forKey: "Location")
//        {
//            locLabel.text = name
//        }
//        else if defaultlocation != nil && defaultlocation != ""
//        {
//            locLabel.text = defaultlocation
//        }
        
        let lineView1 = UIView(frame: CGRect(x: PADING,y: self.locLabel.frame.size.height+self.locLabel.frame.origin.y ,width: self.locLabel.frame.size.width,height: 0.5))
        lineView1.layer.borderWidth = 0.5
        lineView1.layer.borderColor = textColorMedium.cgColor
        self.view.addSubview(lineView1)
        
        
        locationTable = UITableView(frame: (CGRect(x: locLabel.bounds.origin.x,y: locLabel.frame.origin.y+locLabel.frame.size.height+1, width: locLabel.bounds.size.width, height: view.bounds.height-(locLabel.bounds.origin.x + locLabel.frame.size.height+5 + tabBarHeight) )), style: UITableView.Style.grouped)
        locationTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        locationTable.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        locationTable.rowHeight = 35
        locationTable.isHidden = true
        locationTable.isOpaque = false
        locationTable.backgroundColor = UIColor.white//tableViewBgColor
        view.addSubview(locationTable)
        
        
        if locLabel.text == "" {
            self.button.isHidden = false
        }else{
            //            self.button.isHidden = true
        }
        
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        navView.frame = CGRect(x: 60, y: 0, width: self.view.frame.size.width-120, height: 44)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width-120, height: self.navigationController!.navigationBar.frame.size.height)
        titleLabel.text = NSLocalizedString("Choose a Location",  comment: "")
        titleLabel.textColor = textColorPrime
        titleLabel.font = UIFont(name: fontName, size: 18)
        //titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textAlignment = .center
        
        navView.addSubview(titleLabel)
        //[self.navigationController.navigationBar addSubview:view]
        self.navigationController?.navigationBar.addSubview(navView)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        titleLabel.text = ""
    }
    
    func openSlideMenu()
    {
        self.view.endEditing(true)
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        openSideMenu = true
    }
    
    func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        removeAlert()
        //        spinner.center = view.center
        //        spinner.hidesWhenStopped = true
        //        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        //        self.view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        loc = locLabel.text
        var url = ""
        let parameters = ["suggest": loc]
        url = "location-suggest"
        // Send Server Request to Explore Group Contents with Group_ID
        post( parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                
                if msg
                {
                    if succeeded["message"] != nil
                        
                    {
                        self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                        
                    }
                    if succeeded["body"] != nil
                    {
                        
                        if let contentInfo = succeeded["body"] as? NSArray
                        {
                            if contentInfo.count>0
                            {
                                
                                self.locationArray = contentInfo
                                UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                                    self.locationTable.isHidden = false
                                    self.locationTable.dataSource = self
                                    self.locationTable.delegate = self
                                    self.locationTable.reloadData()
                                    
                                }, completion: { finished in
                                    
                                })
                                
                            }
                        }
                    }
                    
                }
                
            })
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            //            locLabel.text = ""
        }
        
        if locLabel.text == "" {
            self.button.isHidden = false
        }else{
            //            self.button.isHidden = true
            
        }
        
        return true
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 35.0
        
        
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if locationArray.count>0
        {
            return locationArray.count
        }
        else
        {
            return 0
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        let dic = locationArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        cell.textLabel?.text = dic["label"] as? String
        
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        locDic = locationArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let eventLocation = locDic["label"] as? String
        Formbackup["location"] = eventLocation
        needReload = 1
        self.locationTable.isHidden = true
        self.view.endEditing(true)
        self.popAfterDelay = true
        createTimer(self)
        
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    @objc func send()
    {
        defaultlocation = locLabel.text!
        self.view.endEditing(true)
        self.locationTable.isHidden = true
        let defaults = UserDefaults.standard
        
        defaults.set(defaultlocation, forKey: "Location")
        self.view.makeToast("Your location has been updated successfully.", duration: 5, position: "bottom")
        self.popAfterDelay = true
        createTimer(self)
        
        
    }
    
}
