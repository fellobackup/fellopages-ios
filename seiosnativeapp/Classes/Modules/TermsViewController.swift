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

//  TermsViewController.swift

import UIKit

class TermsViewController: UIViewController, UIWebViewDelegate  {
   
    var detailWebView = UIWebView()
    var popAfterDelay:Bool!
    var fromLoginPage = false
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        popAfterDelay = false
       
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TermsViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        self.title = NSLocalizedString("Terms", comment: "")
        navigationController?.navigationBar.isHidden = false
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }
        

        setNavigationImage(controller: self)
        if (baseController != nil)
        {
            if baseController.selectedIndex == 1 || baseController.selectedIndex == 2 || baseController.selectedIndex == 3{
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
            
        }

        // WebView for Terms
        detailWebView.frame = CGRect(x: PADING, y: TOPPADING, width: view.bounds.width, height: view.bounds.height)
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.delegate = self
        detailWebView.scrollView.bounces = false
        view.addSubview(detailWebView)
        // Get Terms From Server
     
    }
    override func viewDidAppear(_ animated: Bool) {
        getTerms()
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
        setNavigationImage(controller: self)
    }

     // MARK: - Get Terms and Conditions Data From Server
    
    func getTerms(){
        if reachability.connection != .none {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["":""], url: "help/terms", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                         self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
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
       
    @objc func goBack(){
        if fromLoginPage == true
        {

            if showAppSlideShow == 1
            {
                let presentedVC  = SlideShowLoginScreenViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else
            {
            let presentedVC = LoginScreenViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
            }
        }
        else
        {
            let presentedVC = AdvanceActivityFeedViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    
    
}
