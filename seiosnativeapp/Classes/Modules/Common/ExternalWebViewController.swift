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


//  ExternalWebViewController.swift
//  seiosnativeapp

import UIKit
class ExternalWebViewController: UIViewController , UIWebViewDelegate , UITabBarControllerDelegate{
    
    var externalWebView = UIWebView()
    var url:String! = ""
    var siteTitle = ""
    var fromDashboard = false
    var flagInteger = 0
    var rightBarButton : UIBarButtonItem!
    var hidingNavBarManager: HidingNavigationBarManager?
    var currentUrl : String!
    var marqueeHeader : MarqueeLabel!
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    var fromEventGutter = false
    var fromCreateEvent = false
    var fromDiscussion = false
    var contentGutterMenu: NSArray = []
    var ticketUrlParams : NSDictionary!
    var ticketUrl : String!
    var ticketCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        setNavigationImage(controller: self)
        self.tabBarController?.delegate = self
        popAfterDelay = false
        if baseController != nil{
            switch baseController.selectedIndex {
            case 1:
                if url1 != ""{
                    url = url1
                }
                break
            case 2:
                if url2 != ""{
                    url = url2
                }
                break
            case 3:
                
                if url3 != ""{
                    url = url3
                    
                }
                break
            default:
                break
                
            }
            
        }
        //        if fromDashboard == false
        //        {
        //            self.navigationController?.navigationBar.backgroundColor = buttonColor
        //            self.navigationController?.navigationBar.barTintColor = buttonColor
        //        }
        self.navigationController?.navigationBar.tintColor = textColorPrime
        if fromDashboard == false {
            if fromDiscussion == true {
                let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                leftNavView.backgroundColor = UIColor.clear
                let tapView = UITapGestureRecognizer(target: self, action: #selector(ExternalWebViewController.goBack))
                leftNavView.addGestureRecognizer(tapView)
                let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
                backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
                leftNavView.addSubview(backIconImageView)
                
                let barButtonItem = UIBarButtonItem(customView: leftNavView)
                self.navigationItem.leftBarButtonItem = barButtonItem
            }
            else if url1 == "" && url2 == "" && url3 == ""{
                let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(ExternalWebViewController.cancel))
                self.navigationItem.leftBarButtonItem = cancel
                navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControlState())
                cancel.tintColor = textColorPrime
            }
        }else{
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(ExternalWebViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        rightBarButton = UIBarButtonItem(image: UIImage(named: "upload")!.maskWithColor(color: textColorPrime) , style: UIBarButtonItemStyle.plain , target: self, action: #selector(ExternalWebViewController.openBrowserSetting))
        rightBarButton.isEnabled = true
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        // hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: externalWebView.scrollView)
        
        
        // WebView for Blog Detail
        externalWebView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height )
        externalWebView.backgroundColor = bgColor
        externalWebView.delegate = self
        externalWebView.scalesPageToFit = true
        externalWebView.contentMode = .scaleAspectFit
        
        view.addSubview(externalWebView)
        
       
    }
    
    func menuAction(_ sender:UIButton){
        switch(sender.tag){
        case 0:
            externalWebView.goBack()
        case 1:
            externalWebView.goForward()
        case 2:
            externalWebView.reload()
        case 3:
            externalWebView.stopLoading()
        default:
            externalWebView.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        removeNavigationViews(controller: self)
        var tempUrl :  String = ""
        if url.contains("?"){
            tempUrl = url
        }
        else{
            tempUrl = url+"?disableHeaderAndFooter=1&token=" + oauth_token
        }
        self.currentUrl = tempUrl
        
        let prefs = UserDefaults.standard
        if let city = prefs.string(forKey: "Location"){
            
            tempUrl = tempUrl+"&restapilocation=\(city)"
        }
        let urlNew:String = tempUrl.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        print(urlNew)
        externalWebView.loadRequest(URLRequest(url: URL(string: urlNew)! ))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //print("viewdidappear")
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 70, y: 0, width: navigationBar.frame.width - 120, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
            marqueeHeader.textColor = textColorPrime
            marqueeHeader.text = ""
        }
        
        if baseController != nil
        {
            if baseController.selectedIndex == 1 {
                //print("url1 value")
                if url1 != ""{
                    url = url1
                    marqueeHeader.text = siteTitle
                    
                }
                if baseController.selectedIndex == 2{
                    //print("url2 value")
                    if url2 != ""{
                        url = url2
                    }
                }
                if baseController.selectedIndex == 3{
                    //print("url3 value")
                    if url3 != ""{
                        url = url3
                        marqueeHeader.text = siteTitle//fourthControllerName
                    }
                }
            }
        }
        
    }
    
    @objc func cancel()
    {
        if conditionForm == "eventpayment" || conditionForm == "advancedevents"
        {
            let alert = UIAlertController(title: "Cancel Payment", message: "Do you want to cancel payment for this event", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            let action2 = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
                
                if conditionForm == "advancedevents"
                {
                    conditionalProfileForm = "eventPaymentCancel"
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                else
                {
                    conditionForm = ""
                    _ = self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            _ = navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - UIWebView Delegates
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //        spinner.center = view.center
        //        spinner.hidesWhenStopped = true
        //        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        //        view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        flagInteger += 1
        let siteTitle = externalWebView.stringByEvaluatingJavaScript(from: "document.title")!
        if self.marqueeHeader != nil {
            self.siteTitle = siteTitle
            self.marqueeHeader.text = siteTitle
        }
        //        let query = "document.getElementById('global_header').remove();"
        //        externalWebView.stringByEvaluatingJavaScript(from: query)
        //        let query2 = "document.getElementById('global_footer').remove();"
        //        externalWebView.stringByEvaluatingJavaScript(from: query2)
        
        // let currentUrlString = "\(String(describing: externalWebView.request!.mainDocumentURL))"
        guard let currentUrlString:String = externalWebView.request?.mainDocumentURL?.absoluteString else
        {
            return
        }
        print(currentUrlString)
        self.currentUrl = currentUrlString
        
        if (currentUrlString.range(of: "success/payment/finish/state/active") != nil) || (currentUrlString.range(of:  "/success") != nil) //stores/products/success
        {
            let alert = UIAlertController(title: "Payment Successful. Your order has been Placed!", message: "To accept payment for your events, setup your payment method", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                
                eventUpdate = true
                contentFeedUpdate = true
                
                if self.fromCreateEvent == true {
                     self.popAfterDelay = false
                }
                else {
                     self.popAfterDelay = true
                }
               
                self.createTimer(self)
            })
           
            alert.addAction(action1)
            self.present(alert, animated: true, completion: nil)
            
            self.view.makeToast(NSLocalizedString("Payment Successful", comment: ""), duration: 5, position: "bottom")
            
           /* eventUpdate = true
            contentFeedUpdate = true
            
            self.popAfterDelay = true
           self.createTimer(self)*/
        }
        else if ((currentUrlString.range(of:"success/payment/finish/state/failure") != nil) || (currentUrlString.range(of:"/failure") != nil)) //stores/products/failure
        {
            self.view.makeToast(NSLocalizedString("Payment Fail", comment: ""), duration: 5, position: "bottom")
            self.popAfterDelay = true
           self.createTimer(self)
            
            placeandorder = 0
        }
       
        //print(currentUrlString)
    }
    func checkAvailableTicket()
    {
        for menu in self.contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                if menuItem["name"] as! String == "create_ticket"
                {
                    self.ticketUrlParams = menuItem["urlParams"] as! NSDictionary
                }
            }
        }
        if reachability.isReachable
        {
            var parameters = Dictionary<String, String>()
            let url = "advancedeventtickets/tickets/manage"
            if ticketUrlParams != nil
            {
                for (key, value) in ticketUrlParams{
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
                    if msg
                    {
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                        }
                        if succeeded["body"] != nil
                        {
                            if let body = succeeded["body"] as? NSDictionary
                            {
                                if let totalItemCount = body["totalItemCount"] as? Int
                                {
                                   self.ticketCount = totalItemCount
                                }
                            }
                        }
                    }
                })
                
            }
        }
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
        externalWebView.delegate = nil
        externalWebView.stopLoading()
        if self.popAfterDelay == true
        {
            if conditionForm == "advancedevents" || conditionForm == "ticketCheckout"
            {
                conditionalProfileForm = "eventPaymentCancel"
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.dismiss(animated: false, completion: nil)
            }
        }
        else {
            if self.contentGutterMenu != nil {
                for menu in self.contentGutterMenu
                {
                    if let menuItem = menu as? NSDictionary
                    {
                        if menuItem["name"] as! String == "payment_method"
                        {
                            let presentedVC = AddPaymentMethodViewController()
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.param = menuItem["urlParams"] as! NSDictionary
                            presentedVC.fromCreateEvent = true
                            presentedVC.contentGutterMenu = self.contentGutterMenu
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                            let navigationController = UINavigationController(rootViewController: presentedVC)
                            self.present(navigationController, animated: true, completion: nil)
                        }
                    }
                }
            }
            else {
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        if (error._code != NSURLErrorCancelled)
        {
            activityIndicatorView.stopAnimating()
            if error._code != 102
            {
                self.view.makeToast("Invalid Url : server with the specified hostname could not be found", duration: 10, position: "bottom")
            }
        }

    }
    
    @objc func openBrowserSetting(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment: ""), style: .default, handler: { (UIAlertAction) -> Void in
            self.openInSafari()
        }))
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    func openInSafari(){
        
        //        guard let url = URL(string: self.currentUrl) else {
        //            return
        //        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: self.currentUrl)!, options: [:],completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: self.currentUrl)!)
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchItem(){
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            searchDic.removeAll(keepingCapacity: false)
            pv.fromInapp = true
            self.navigationController?.pushViewController(pv, animated: false)
            
        }
        
    }
    
    @objc func goBack()
    {
        activityIndicatorView.stopAnimating()
        if externalWebView.canGoBack == false {
            if((self.fromDashboard == true))
            {
          
                if logoutUser == true
                {
                    feedArray.removeAll()
                }
              let presentedVC = AdvanceActivityFeedViewController()
              self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else
            {
                if fromDiscussion == true {
                     _ = self.navigationController?.popViewController(animated: true)
                }
                else if conditionForm == "advancedevents"
                {
                    conditionalProfileForm = "eventPaymentCancel"
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                else
                {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        else
        {
            externalWebView.goBack()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if externalWebView.isLoading
        {
            externalWebView.stopLoading()
        }
        
        self.marqueeHeader.text = ""
        removeNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
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

