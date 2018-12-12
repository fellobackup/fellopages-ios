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
//  OverViewViewController.swift
//  seiosnativeapp
//


import UIKit

class OverViewViewController: UIViewController, UIWebViewDelegate, TTTAttributedLabelDelegate, UITextViewDelegate{
    // Variable for Blog Detail Form
    var subjectId : Int!
    var mytitle : String!
    var detailWebView = UIWebView()
    var label1 : String! = ""
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        //self.title = NSLocalizedString("Overview", comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(OverViewViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: 0, y: 5, width: view.bounds.width, height: view.bounds.height - 5)
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.delegate = self
        detailWebView.scalesPageToFit = true
        
        let temp = "<span style=\"font-family:Helvetica; font-size: 35\">"
        let topicDescription1 = "\(temp) \(label1!) </span>"
        self.detailWebView.loadHTMLString(topicDescription1, baseURL: nil)
        
        view.addSubview(detailWebView)
        
    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        let urlString = request.url!.absoluteString
//        // Restrict WebView to Open URLs
//        
//        if urlString == "about:blank"{
//            return true
//        }else{
//            let presentedVC = ExternalWebViewController()
//            presentedVC.url = urlString
//            // presentedVC.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
//            let navigationController = UINavigationController(rootViewController: presentedVC)
//            self.present(navigationController, animated: true, completion: nil)
//            return false
//        }
//        
//    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.title = NSLocalizedString("Overview", comment: "")
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
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
