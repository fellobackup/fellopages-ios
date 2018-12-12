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
//  BlogDetailViewController.swift
//  seiosnativeapp
//


import UIKit

class DescriptionViewController: UIViewController, UIWebViewDelegate , TTTAttributedLabelDelegate{
    // Variable for Blog Detail Form
    var subjectId : Int!
    var mytitle : String!
    var detailWebView = UIWebView()
    var headertitle : String!
    var url : String!
    var smallDescription : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("\(headertitle!): \(mytitle!)", comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(DescriptionViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: 0, y: 10, width: view.bounds.width, height: view.bounds.height)
        self.detailWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
        //self.detailWebView.scrollView.delegate = self
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.delegate = self
        detailWebView.scrollView.bounces = false
        detailWebView.isUserInteractionEnabled = true
        //detailWebView.scalesPageToFit = true
        detailWebView.scrollView.isScrollEnabled = true
        view.addSubview(detailWebView)
        
        if url == ""
        {
           detailWebView.loadHTMLString(smallDescription, baseURL: nil)
        }
        else
        {
            exploreInfo()
        }

        
        
    }
    
    
    
    
    // MARK: - Server Connection For Blog Updation
    
    // Explore  Detail
    func exploreInfo(){
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Contents
            post(["subject_id": String(subjectId), "feed_filter": "1", "maxid": "0", "post_menus": "1"], url:url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        if self.headertitle == "Info"
                        {
                            if let blog = succeeded["body"] as? NSDictionary
                            {
                                let description = blog["infoString"] as! String
                                self.detailWebView.loadHTMLString(description, baseURL: nil)
                            }
                        }
                        else
                        {
                            if let _ = succeeded["body"] as? String
                            {
                                //self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
                                let topicDescription = (succeeded["body"] as! String)
                                let truncatedDescription = topicDescription.html2String
                                let temp = "<body style=\"background-color: transparent;\"><div style= \"font-size:20px;\">"
                                let topicDescription1 = "\(temp) \(truncatedDescription) </body>"
                                self.detailWebView.loadHTMLString(topicDescription1, baseURL: nil)
                                

                            }
                        }
                        
                    }else{
                        // Handle Server Error
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
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    
}
