//
//  ManageEventTicketViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 02/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class ManageEventTicketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var contentType : String!
    var url : String!
    var TicketListTableview : UITableView!
    var responseArr : NSArray!
    var dynamicHeight : CGFloat = 111
    var contentGutterMenu : NSArray = []
    var leftBarButtonItem : UIBarButtonItem!
    var contentId : Int!
    var storeID : String!
    var productID : String!
    var urlParams : NSDictionary!
    var popAfterDelay : Bool!
    var uploadUrl : String!
    var deleteFileEntry:Bool!
//    var fromEventGutter = false
    var fromCreateEvent = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        popAfterDelay = false
        TicketListTableview = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        TicketListTableview.register(ManageEventTicketTableCell.self, forCellReuseIdentifier: "Cell")
        TicketListTableview.estimatedRowHeight = 60.0
        TicketListTableview.separatorStyle = UITableViewCellSeparatorStyle.none
        TicketListTableview.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
        TicketListTableview.backgroundColor = tableViewBgColor
        self.TicketListTableview.isOpaque = false
        self.view.addSubview(TicketListTableview)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = buttonColor
        self.title = NSLocalizedString("Manage Tickets", comment: "")
        if self.contentType == "mainFile"
        {
            self.title = NSLocalizedString("Manage Tickets", comment: "")
        }
        else if self.contentType == "sampleFile"
        {
            self.title = NSLocalizedString("Manage Tickets", comment: "")
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ManageEventTicketViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(ManageEventTicketViewController.addFile))
        self.navigationItem.rightBarButtonItem = addButton
        exploreContent()
    }
    
    @objc func addFile()
    {
        
        let presentedVC = TicketGenerationViewController()
        presentedVC.url = "advancedeventtickets/tickets/add"
        presentedVC.contentType = "ticketGeneration"
        presentedVC.param = self.urlParams
        presentedVC.formTitle = "Create Ticket"
        
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
        
    }
    
    @objc func cancel()
    {
        if self.fromCreateEvent == true {
            conditionalProfileForm = "eventPaymentCancel"
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return responseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ManageEventTicketTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor.clear
        let dic = responseArr.object(at: (indexPath as NSIndexPath).row)
        let fileResponseDic = dic as! NSDictionary
        
        if let title = fileResponseDic["title"] as? String
        {
            cell.ticketTitle.text = "Title : "+title
        }
        if let price = fileResponseDic["price"] as? String
        {
            cell.ticketPrice.text = "Price : "+price
        }
        if let price = fileResponseDic["price"] as? Int
        {
            cell.ticketPrice.text = "Price : "+String(price)
        }
        if let quantity = fileResponseDic["quantity"] as? Int
        {
            cell.ticketQuantity.text = "Quantity : "+String(quantity)
        }
        cell.btnMenu.tag = (indexPath as NSIndexPath).row
        cell.btnMenu.addTarget(self, action: #selector(ManageEventTicketViewController.showGutterMenuOptions(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func showGutterMenuOptions(_ sender: UIButton)
    {
        print("gutter menu options to be displayed!")
        var fileInfo : NSDictionary!
        fileInfo = responseArr[sender.tag] as! NSDictionary
        
        if let guttermenu2 = fileInfo["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu2 as NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            for menu in contentGutterMenu
            {
                if let menuItem = menu as? NSDictionary
                {
                    let actionUrl = menuItem["url"] as! String
                    let params = menuItem["urlParams"] as! NSDictionary
                    let titleString = menuItem["name"] as! String
                    if titleString.range(of: "delete") != nil
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.destructive, handler:{ (UIAlertAction) -> Void in
                            
                            let condition = menuItem["name"] as! String
                            switch(condition)
                            {
                                
                            case "ticket_delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete File", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Ticket?",comment: "") , otherButton: NSLocalizedString("Delete Ticket", comment: "")) { () -> () in
                                    self.deleteFileEntry = true
                                    self.performFileAction(params : params as NSDictionary, url: actionUrl )
                                    
                                }
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                            }
                        }))
                    }
                    else
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition)
                            {
                            case "ticket_edit":
                                let presentedVC = TicketGenerationViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.contentType = "editTicket"
                                presentedVC.formTitle = "Edit Ticket"
                                isCreateOrEdit = false
                                presentedVC.url = actionUrl
                                //presentedVC.storeId = self.storeID
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                            case "ticket_details":
                                let presentedVC = TicketDetailViewController()
                                presentedVC.url = actionUrl
                                presentedVC.urlParams = params
                                presentedVC.contentType = "ticketDetail"
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                            }
                            
                            
                        }))
                    }
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone)
            {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }
            else
            {
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func performFileAction(params: NSDictionary, url: String)
    {
        if reachability.isReachable {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in params{
                
                if let id = value as? Int {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of:"delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute:  {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 4, position: "bottom")
                            
                        }
                        
                        if self.deleteFileEntry == true {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productDetailUpdate = true
                            productUpdate = true
                            
                            //_ = self.dismiss(animated: false, completion: nil)
                            //_ = self.navigationController?.popViewController(animated: false)
                            //return
                            self.TicketListTableview.reloadData()
                            self.exploreContent()
                        }
                        else
                        {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productUpdate = true
                            productDetailUpdate = true
                            self.TicketListTableview.reloadData()
                            self.exploreContent()
                            
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 3, position: "bottom")
                            
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
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
    
    func exploreContent()
    {
        if reachability.isReachable
        {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = Dictionary<String, String>()
            if urlParams != nil
            {
                for (key, value) in urlParams{
                    if let id = value as? Int
                    {
                        parameters["\(key)"] = String(id as Int)
                    }
                    if let receiver = value as? NSString
                    {
                        parameters["\(key)"] = receiver as String
                    }
                }
            }
            
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async( execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                        }
                        if succeeded["body"] != nil
                        {
                            if let body = succeeded["body"] as? NSDictionary
                            {
                                if let response = body["response"] as? NSArray
                                {
                                    self.responseArr = response
                                    self.TicketListTableview.dataSource = self
                                    self.TicketListTableview.delegate = self
                                    self.TicketListTableview.isOpaque = false
                                    self.TicketListTableview.isHidden = false
                                    self.TicketListTableview.reloadData()
                                }
                                
                                let response2 = body["response"] as? NSArray
                                if response2?.count == 0 || response2 == nil
                                {
                                    self.responseArr = []
                                    self.view.makeToast("No Ticket is available. Please add a Ticket!", duration: 5, position: "bottom")
                                    self.TicketListTableview.reloadData()
                                }
                                
                                if let upUrl = body["uploadurl"] as? String
                                {
                                    self.uploadUrl = upUrl
                                }
                            }
                        }
                    }
                })
                
            }
        }
    }
    
}
