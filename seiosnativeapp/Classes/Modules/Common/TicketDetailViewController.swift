//
//  TicketDetailViewController2.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 03/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class TicketDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var contentType : String!
    var url : String!
    var responseDic : NSDictionary!
    var keysArray = [String]()
    var valueArray = [Any]()
    
    var TicketDetailTableview : UITableView!
    var responseArr : NSArray!
    var dynamicHeight : CGFloat = 80
    var contentGutterMenu : NSArray = []
    var leftBarButtonItem : UIBarButtonItem!
    var contentId : Int!
    var storeID : String!
    var productID : String!
    var urlParams : NSDictionary!
    var popAfterDelay : Bool!
    var uploadUrl : String!
    var deleteFileEntry:Bool!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        popAfterDelay = false
        TicketDetailTableview = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        TicketDetailTableview.register(TicketDetailTableCell.self, forCellReuseIdentifier: "Cell")
        TicketDetailTableview.estimatedRowHeight = 60.0
        TicketDetailTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        TicketDetailTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        TicketDetailTableview.backgroundColor = tableViewBgColor
        self.TicketDetailTableview.isOpaque = false
        self.view.addSubview(TicketDetailTableview)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = NSLocalizedString("Ticket Detail", comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TicketDetailViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        exploreContent()
    }
    
    @objc func cancel()
    {
        self.dismiss(animated: true, completion: nil)
        
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
        return responseDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TicketDetailTableCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        let title = self.keysArray[indexPath.row]
        let titleInfo = self.valueArray[indexPath.row]
        
        cell.title.text = title
        if titleInfo is String
        {
            cell.titleInfo.text = titleInfo as? String
        }
        else if titleInfo is Int
        {
            cell.titleInfo.text = String(describing: titleInfo)
        }
        
        return cell
    }
    
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer
        {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
            
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
                                if let response = body["Basic Information"] as? NSDictionary
                                {
                                    for (key,value) in response
                                    {
                                        self.keysArray.append(key as! String)
                                        self.valueArray.append(value as Any)
                                    }
                                    self.responseDic = response
                                    self.TicketDetailTableview.dataSource = self
                                    self.TicketDetailTableview.delegate = self
                                    self.TicketDetailTableview.isOpaque = false
                                    self.TicketDetailTableview.isHidden = false
                                    self.TicketDetailTableview.reloadData()
                                }
                            }
                        }
                    }
                })
                
            }
        }
    }
    
}
