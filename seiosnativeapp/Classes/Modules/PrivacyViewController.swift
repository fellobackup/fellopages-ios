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

//  PrivacyViewController.swift

import UIKit

class PrivacyViewController: UIViewController, UIWebViewDelegate  {
    var detailWebView = UIWebView()
    var popAfterDelay:Bool!
    var fromLoginPage = false
    var leftBarButtonItem : UIBarButtonItem!
   
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        popAfterDelay = false
        navigationController?.navigationBar.isHidden = false
        
        setNavigationImage(controller: self)
        
        view.backgroundColor = bgColor
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PrivacyViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        self.title = NSLocalizedString("Privacy", comment: "")
        //baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        
        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: PADING, y: 0, width: view.bounds.width, height: view.bounds.height)
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.delegate = self
        detailWebView.scrollView.bounces = false
        view.addSubview(detailWebView)
   
    }
    
    // MARK: - Get Privacy Data From Server
    
    func getPrivacy(){
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
            post(["":""], url: "help/privacy", method: "GET") { (succeeded, msg) -> () in
                
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
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getPrivacy()
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }

    }

    override func viewWillAppear(_ animated: Bool) {
      removeNavigationViews(controller: self)
        setNavigationImage(controller: self)
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
