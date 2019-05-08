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
//  BlogViewController.swift
//  SocailEngineDemoForSwift

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import Foundation
import NVActivityIndicatorView
import Instructions
// Global Variable Initialization Used in Blog Module

var blogUpdate: Bool!                           // Flag to refresh Blog

class BlogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    
    var editBlogID:Int = 0                          // Edit BlogID
    let mainView = UIView()
    var browseOrMyBlog = true                   // true for Browse Blog & false for My Blog
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var blogTableView:UITableView!              // TAbleView to show the blog Contents
    var browseBlog:UIButton!                    // Blog Types
    var myBlog:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var fromSearch: Bool!
    var customSegmentControl: UISegmentedControl!
    var scrollView: UIScrollView!
    var user_id : Int!
    var fromTab : Bool! = false
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var countListTitle : String!
   // var imageCache = [String:UIImage]()
    var responseCache = [String:AnyObject]()
    var nativeAdArray = [AnyObject]()
    // AdMob Variable
    var adLoader: GADAdLoader!
//    var nativeAdArray = [AnyObject]()
    var loadrequestcount = 0
    var isnativeAd:Bool = true
    
    // Native FacebookAd Variable
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var nativeAd:FBNativeAd!
    var admanager:FBNativeAdsManager!
    var Adiconview:UIImageView!
    var leftBarButtonItem : UIBarButtonItem!
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var Adiconimageview : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    var adsCellheight:CGFloat = 250.0
//  var nativeAdArray = [AnyObject]()
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
  
        removeMarqueFroMNavigaTion(controller: self)
        
        if fromTab == false{
            setDynamicTabValue()
         }

        blogUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        globFilterValue = ""
        category_filterId = nil
        openMenu = false
        updateAfterAlert = true
        

        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        if showOnlyMyContent == false {
            self.title = NSLocalizedString("Blogs",  comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
            }

            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(BlogViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        // Initialize Blog Types
        browseBlog = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Browse Entries",  comment: ""), border: true, selected: true)
        
        browseBlog.tag = 11
        browseBlog.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        browseBlog.addTarget(self, action: #selector(BlogViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browseBlog)
        browseBlog.isHidden = false
        
        
        myBlog = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("My Entries",  comment: ""), border: true, selected: false)
        myBlog.tag = 22
        myBlog.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        myBlog.addTarget(self, action: #selector(BlogViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myBlog)
        myBlog.isHidden = false
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon , border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: #selector(BlogViewController.filterSerach), for: .touchUpInside)

        mainView.addSubview(filter)
        filter.isHidden = true

        
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRect(x: 0, y: filter.bounds.height + filter.frame.origin.y - 12  , width: view.bounds.width, height: view.bounds.height-(filter.bounds.height + filter.frame.origin.y) - tabBarHeight + 18 ), style: .grouped)
        blogTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            blogTableView.estimatedRowHeight = 0
            blogTableView.estimatedSectionHeaderHeight = 0
            blogTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(blogTableView)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(BlogViewController.refresh), for: UIControl.Event.valueChanged)
        blogTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            browseBlog.isHidden = true
            myBlog.isHidden = true
            filter.frame.origin.y = TOPPADING
            blogTableView.frame.origin.y = TOPPADING
            blogTableView.frame.size.height = view.bounds.height - (filter.bounds.height + 2 * contentPADING + filter.frame.origin.y) - tabBarHeight
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: Selector(("cancleSearch")))

            self.navigationItem.rightBarButtonItem = addCancel
            
        }

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        blogTableView.tableFooterView = footerView
        blogTableView.tableFooterView?.isHidden = true
        
        if adsType_blogs != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(BlogViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
    }
   
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        switch(index) {
            
        case 0:
            
            var  coachMark1 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 75.0
            let radious : Int = 40
            
            coachMark1 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                return circlePath
                
            }
            
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            return coachMark1
            
            
        case 1:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        
        coachMarksController.stop(immediately: true)
        return false
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 1:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 1/2"
            coachViews.bodyView.nextLabel.text = "Next "
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 2/2"
            coachViews.bodyView.nextLabel.text = "Finish "
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    
    func showAppTour(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    func setDynamicTabValue(){
       let defaults = UserDefaults.standard
         if let name = defaults.object(forKey: "showBlogContent")
         {
         if  UserDefaults.standard.object(forKey: "showBlogContent") != nil {
        
         showOnlyMyContent = name as! Bool
        
         }
         UserDefaults.standard.removeObject(forKey: "showBlogContent")
         }
        
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
        IsRedirctToProfile()
    }
    
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = BlogDetailViewController()
            if (createResponse["blog_id"] is String){
                let tempValue = createResponse["blog_id"] as! String
                presentedVC.blogId = Int(tempValue)
            }else{
                presentedVC.blogId = createResponse["blog_id"] as! Int
            }
            presentedVC.blogName = createResponse["title"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
        }

    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_blogs == 1
        {
            if kFrequencyAdsInCells_blogs > 4 && placementID != ""
            {
                if arrGlobalFacebookAds.count == 0
                {
                    self.showFacebookAd()
                }
                else
                {
                    for nativeAd in arrGlobalFacebookAds {
                        self.fetchAds(nativeAd)
                    }
                    if nativeAdArray.count == 10
                    {
                        blogTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_blogs == 0
        {
            if kFrequencyAdsInCells_blogs > 4 && adUnitID != ""
            {
                showNativeAd()
            }
        }
        else if adsType_blogs == 2 {
            checkCommunityAds()
        }

        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if reachability.connection != .none {
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_blogs)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_blogs)"
            post(dic, url: "communityads/index/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray
                                    self.uiOfCommunityAds(count: advertismentsArray.count){
                                        (status : Bool) in
                                        if status == true{
                                            self.blogTableView.reloadData()
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                })
            }
            
        }
        else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    func uiOfCommunityAds(count : Int,completion: @escaping (_ status: Bool) -> Void){
    var status  = false

        for i in 0  ..< communityAdsValues.count{
            
            if  let dic = communityAdsValues[i]  as? NSDictionary {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 430))
                }
                else
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 250))
                }
                self.fbView.backgroundColor = UIColor.clear
                self.fbView.tag = 1001001
                
                adsImage = createImageView(CGRect(x: 0, y: 0, width: 18, height: 15), border: true)
                adsImage.image = UIImage(named: "ad_badge.png")
                self.fbView.addSubview(adsImage)
                
                adTitleLabel = UILabel(frame: CGRect(x:  23,y: 10,width: self.fbView.bounds.width-(40),height: 30))
                adTitleLabel.numberOfLines = 0
                adTitleLabel.textColor = textColorDark
                adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                let title = String(describing: dic["cads_title"]!)
                adTitleLabel.text = title
                 adTitleLabel.sizeToFit()
                self.fbView.addSubview(adTitleLabel)
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(30), y: 5,width: 20,height: 20))
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControl.State())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
                //                adCallToActionButton.clipsToBounds = true
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(BlogViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 150),title: "", border: false, bgColor: false, textColor: textColorLight)
                }
                else
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 300),title: "", border: false, bgColor: false, textColor: textColorLight)
                }
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 150), border: false)
                }
                else
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 300), border: false)
                }
                adImageView1.contentMode = UIView.ContentMode.scaleAspectFit
                adImageView1.clipsToBounds = true
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                     adImageView1.kf.indicatorType = .activity
                    (adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    adImageView1.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(BlogViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
                self.fbView.addSubview(imageButton)
                imageButton.addSubview(adImageView1)
                
                
                adBodyLabel = UILabel(frame: CGRect(x: 10,y: imageButton.bounds.height + 10 + imageButton.frame.origin.y,width: self.fbView.bounds.width-20,height: 40))
                adBodyLabel.numberOfLines = 0
                adBodyLabel.textColor = textColorDark
                adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                self.fbView.addSubview(adBodyLabel)
                var description = String(describing: dic["cads_body"]!)
                description = description.html2String
                adBodyLabel.text = description
                adBodyLabel.sizeToFit()
                self.fbView.frame.size.height = getBottomEdgeY(inputView: adBodyLabel) + 5
                nativeAdArray.append(self.fbView)
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
            }
        }
        
    }
    @objc func tappedOnAds(_ sender: UIButton){
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
  
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_blogs)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_blogs)"
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic!["userad_id"] != nil{
            dictionary["adsId"] =  String(dic!["userad_id"] as! Int)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            if reachability.connection != .none {
                // Send Server Request for Comments
                post(dictionary, url: "communityads/index/remove-ad", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg
                        {
                            if succeeded["body"] != nil{
                                if let body = succeeded["body"] as? NSDictionary{
                                    if let form = body["form"] as? NSArray
                                    {
                                        let  key = form as! [NSDictionary]
                                        
                                        for dic in key
                                        {
                                            for(k,v) in dic{
                                                if k as! String == "multiOptions"{
                                                    self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
                                                    self.blackScreenForAdd.backgroundColor = UIColor.black
                                                    self.blackScreenForAdd.alpha = 0.0
                                                    self.parent?.view.addSubview(self.blackScreenForAdd)
                                                    self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
                                                    self.adsReportView.showMenu(dic: v as! NSDictionary,parameters : dictionary,view : self)
                                                    reportDic = v as! NSDictionary
                                                    self.parent?.view.addSubview(self.adsReportView)
                                                    
                                                    
                                                    UIView.animate(withDuration: 0.2) { () -> Void in
                                                        self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                                                        self.blackScreenForAdd.alpha = 0.5
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
                
            }
            else{
                // No Internet Connection Message
                self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            }
        }
        else {
            self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
            self.blackScreenForAdd.backgroundColor = UIColor.black
            self.blackScreenForAdd.alpha = 0.0
            self.parent?.view.addSubview(self.blackScreenForAdd)
            self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
            self.adsReportView.showMenu(dic: reportDic as NSDictionary,parameters : dictionary,view : self)
            self.parent?.view.addSubview(self.adsReportView)
            
            
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                self.blackScreenForAdd.alpha = 0.5
                
            }
            
        }
        
    }
   @objc func doneAfterReportSelect(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                ob.resignFirstResponder()
            }
            
        }
        UIView.animate(withDuration:0.5) { () -> Void in
            self.blackScreenForAdd.isHidden = true
            self.adsReportView.isHidden = true
            self.blackScreenForAdd.alpha = 0.0
        }
        
    }
   @objc func pressedAd(_ sender: UIButton){
        
      //  parametersNeedToAdd = [:]
    for ob in adsReportView.subviews{
        if ob .isKind(of: UIButton.self){
            if ob.tag == 0 || ob.tag == 1 || ob.tag == 2 || ob.tag == 3 || ob.tag == 4{
                (ob as! UIButton).setTitle("\u{f10c}", for: UIControl.State.normal)
            }
            if ob.tag == 1005
            {
                (ob as! UIButton).alpha = 1.0
                ob.isUserInteractionEnabled = true
            }
        }
    }
        
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"]!
        sender.setTitle("\u{f111}", for: UIControl.State.normal)
        if parametersNeedToAdd["adCancelReason"] != "Other"{
            
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = true
                }
                if ob.tag == 1000{
                    ob.isHidden = true
                }
                if ob.tag == 1005{
                    ob.isHidden = false
                }
            }
            // removeAd()
        }
        else{
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = false
                }
                if ob.tag == 1000{
                    ob.isHidden = false
                }
                if ob.tag == 1005{
                    ob.isHidden = true
                }
            }
        }
    }
    @objc func submitReasonPressed()
    {
        removeAd()
    }
    func removeAd(){
        self.doneAfterReportSelect()
        self.view.makeToast(NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), duration: 5, position: "bottom")
        activityIndicatorView.startAnimating()
        if reachability.connection != .none {
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        if succeeded["body"] != nil{
                            if (succeeded["body"] as? NSDictionary) != nil{
                                self.nativeAdArray.removeAll(keepingCapacity: false)
                                self.checkCommunityAds()
                            }
                        }
                    }
                })
            }
            
        }
                else{
                    // No Internet Connection Message
                    self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
                }
        
        
        
    }
    @objc func removeOtherReason(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                let view = ob as? UITextField
                parametersNeedToAdd["adDescription"] = view?.text
            }
        }
        removeAd()
        
    }

    // MARK: - FacebookAd Delegate
    // MARK: - FacebookAd
    func showFacebookAd()
    {
        //FBAdSettings.addTestDevices(fbTestDevice)
        //FBAdSettings.addTestDevice(fbTestDevice)
        //        nativeAd = FBNativeAd(placementID: placementID)
        //        nativeAd.mediaCachePolicy = FBNativeAdsCachePolicy.None
        //        nativeAd.delegate = self
        //        nativeAd.loadAd()
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager.delegate = self
        admanager.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager.loadAds()
        
        
        
    }
    
    func nativeAdsLoaded()
    {
//        for _ in 0 ..< 10
//
//        {
//
//            self.nativeAd = admanager.nextNativeAd
//             self.fetchAds(self.nativeAd)
//        }
        arrGlobalFacebookAds.removeAll()
        for _ in 0 ..< 10
        {
            if let fb = admanager.nextNativeAd
            {
                 fb.unregisterView()
                arrGlobalFacebookAds.append(fb)
            }
        }
        for nativeAd in arrGlobalFacebookAds {
            self.fetchAds(nativeAd)
        }
        
        if nativeAdArray.count == 10
        {
            blogTableView.reloadData()
        }
        
    }

    func fetchAds(_ nativeAd: FBNativeAd)
    {
        
//        if ((self.nativeAd) != nil) {
//            self.nativeAd.unregisterView()
//        }
//

        self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75))
        self.fbView.backgroundColor = tableViewBgColor
        self.fbView.tag = 1001001
        
        Adiconview = createImageView(CGRect(x: self.fbView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        
        adImageView = FBMediaView(frame: CGRect(x: 5, y: 7, width: 60, height: 60))
        self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        //self.adImageView.layer.masksToBounds = true
        self.adImageView.backgroundColor = UIColor.clear
        self.fbView.addSubview(adImageView)
        
        adTitleLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10,y: 5,width: (self.fbView.bounds.width - (adImageView.bounds.width + 80)) , height: 20))
        adTitleLabel.textColor = textColorDark
        adTitleLabel.numberOfLines = 1
        adTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        adTitleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        
        adBodyLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10, y: adTitleLabel.bounds.height + adTitleLabel.frame.origin.y,width: (self.fbView.bounds.width - (adImageView.bounds.width + 100)) , height: 40))
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        adBodyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        adBodyLabel.numberOfLines = 2
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.sizeToFit()
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.fbView.addSubview(adBodyLabel)
        
        
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-75,y: adImageView.bounds.height/2 + adImageView.frame.origin.y/2-10, width: 70, height: 30))
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControl.State())
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
        //print(nativeAdArray.count)
       
        
    }
    
    public func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error.localizedDescription)
    }
    
//    func nativeAdDidLoad(_ nativeAd: FBNativeAd)
//    {
////        if ((self.nativeAd) != nil) {
////            self.nativeAd.unregisterView()
////        }
//        if loadrequestcount <= 10
//        {
//            loadrequestcount = loadrequestcount+1
//            if arrGlobalFacebookAds.count == 0
//            {
//                self.showFacebookAd()
//            }
//            else
//            {
//                for nativeAd in arrGlobalFacebookAds {
//                    self.fetchAds(nativeAd)
//                }
//                if nativeAdArray.count == 10
//                {
//                    blogTableView.reloadData()
//                }
//            }
//            // nativeAd1.delegate = self
//        }
//
//        self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75))
//        self.fbView.backgroundColor = tableViewBgColor
//        self.fbView.tag = 1001001
//
//        adImageView = FBMediaView(frame: CGRect(x: 5, y: 7, width: 60, height: 60))
//        self.adImageView.nativeAd = nativeAd
//        self.adImageView.clipsToBounds = true
//        //self.adImageView.layer.masksToBounds = true
//        self.adImageView.backgroundColor = UIColor.clear
//        self.fbView.addSubview(adImageView)
//
//        adTitleLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10,y: 5,width: (self.fbView.bounds.width - (adImageView.bounds.width + 80)) , height: 20))
//        adTitleLabel.textColor = textColorDark
//        adTitleLabel.numberOfLines = 1
//        adTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        adTitleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
//        adTitleLabel.text = nativeAd.title
//        self.fbView.addSubview(adTitleLabel)
//
//
//        adBodyLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10, y: adTitleLabel.bounds.height + adTitleLabel.frame.origin.y,width: (self.fbView.bounds.width - (adImageView.bounds.width + 100)) , height: 40))
//
//        if let _ = nativeAd.body {
//
//            adBodyLabel.text = nativeAd.body
//        }
//        adBodyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        adBodyLabel.numberOfLines = 2
//        adBodyLabel.textColor = textColorMedium
//        adBodyLabel.sizeToFit()
//        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
//        self.fbView.addSubview(adBodyLabel)
//
//
//
//
//        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-75,y: adImageView.bounds.height/2 + adImageView.frame.origin.y/2-10, width: 70, height: 30))
//        adCallToActionButton.setTitle(
//            nativeAd.callToAction, for: UIControl.State())
//
//        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
//        adCallToActionButton.titleLabel?.textColor = navColor
//        adCallToActionButton.backgroundColor = navColor
//        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
//        adCallToActionButton.clipsToBounds = true
//        self.fbView.addSubview(adCallToActionButton)
//
//        nativeAd.registerView(forInteraction: self.fbView, with: self)
//        nativeAdArray.append(self.fbView)
//        //print(nativeAdArray.count)
//        if nativeAdArray.count == 10
//        {
//            blogTableView.reloadData()
//        }
//    }
    
    //    func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError){
    //        showFacebookAd()
    //    }
    
    // MARK: - GADAdLoaderDelegate
    func showNativeAd()
    {
        var adTypes = [GADAdLoaderAdType]()
        if iscontentAd == true
        {
            if isnativeAd
            {
                adTypes.append(GADAdLoaderAdType.nativeAppInstall)
                isnativeAd = false
            }
            else
            {
                adTypes.append(GADAdLoaderAdType.nativeContent)
                isnativeAd = true
            }
        }
        else
        {
            adTypes.append(GADAdLoaderAdType.nativeAppInstall)
        }
        delay(0, closure: {
            self.adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                                        adTypes: adTypes, options: nil)
            self.adLoader.delegate = self
            let request = GADRequest()
//            request.testDevices = [kGADSimulatorID,"bc29f25fa57e135618e267a757a5fa35"]
            self.adLoader.load(request)
        })
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    // Mark: - GADNativeAppInstallAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAppInstallAd: GADNativeAppInstallAd)
    {
        
        let appInstallAdView = Bundle.main.loadNibNamed("NativeadsBlogtype", owner: nil,
                                                        options: nil)?.first as! GADNativeAppInstallAdView
        appInstallAdView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds).width, height: appInstallAdView.frame.size.height)
        
        
        
        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
        appInstallAdView.tag = 1001001
        (appInstallAdView.imageView as! UIImageView).image =
            (nativeAppInstallAd.images?.first as! GADNativeAdImage).image
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        }
        else
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        }
        (appInstallAdView.imageView as! UIImageView).layer.masksToBounds = true
        
        
        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: ((appInstallAdView.imageView as! UIImageView).bounds).width + 10,y: 5,width: ((appInstallAdView.bounds).width - (((appInstallAdView.imageView as! UIImageView).bounds).width + 70)) , height: 20)
        
        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
        (appInstallAdView.headlineView as! UILabel).numberOfLines = 1
        (appInstallAdView.headlineView as! UILabel).lineBreakMode = NSLineBreakMode.byTruncatingTail
        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontName, size: FONTSIZELarge)
        //(appInstallAdView.headlineView as! UILabel).sizeToFit()
        
        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: ((appInstallAdView.imageView as! UIImageView).bounds).width + 10, y: ((appInstallAdView.headlineView as! UILabel).bounds).height + (appInstallAdView.headlineView as! UILabel).frame.origin.y,width: ((appInstallAdView.bounds).width - (((appInstallAdView.imageView as! UIImageView).bounds).width + 100)) , height: 40)
        
        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
        (appInstallAdView.bodyView as! UILabel).lineBreakMode = NSLineBreakMode.byWordWrapping
        (appInstallAdView.bodyView as! UILabel).numberOfLines = 2
        (appInstallAdView.bodyView as! UILabel).textColor = textColorMedium
        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        
        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: (appInstallAdView.bounds).width-75,y: ((appInstallAdView.imageView as! UIImageView).bounds).height/2 + (appInstallAdView.imageView as! UIImageView).frame.origin.y/2-10, width: 65, height: 30)
        (appInstallAdView.callToActionView as! UIButton).setTitle(
            nativeAppInstallAd.callToAction, for: UIControl.State.normal)
        (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (appInstallAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
        (appInstallAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
        (appInstallAdView.callToActionView as! UIButton).backgroundColor = bgColor
        (appInstallAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
        (appInstallAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
        (appInstallAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
        (appInstallAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        nativeAdArray.append(appInstallAdView)
        if loadrequestcount <= 10
        {
            self.loadrequestcount = self.loadrequestcount+1
            self.adLoader.delegate = nil
            self.showNativeAd()
            self.blogTableView.reloadData()
        }
    }

    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeContentAd: GADNativeContentAd) {   
        let contentAdView = Bundle.main.loadNibNamed("ContentAdListType", owner: nil,
                                                     options: nil)?.first as! GADNativeContentAdView
        // Associate the app install ad view with the app install ad object. This is required to make
        // the ad clickable.
        contentAdView.nativeContentAd = nativeContentAd
        contentAdView.tag = 1001001
        
        contentAdView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds).width, height: contentAdView.frame.size.height)
        
        
        
        (contentAdView.imageView as! UIImageView).image =
            (nativeContentAd.images?.first as! GADNativeAdImage).image
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        }
        else
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        }
        (contentAdView.imageView as! UIImageView).layer.masksToBounds = true
        
        
        (contentAdView.headlineView as! UILabel).frame = CGRect(x: ((contentAdView.imageView as! UIImageView).bounds).width + 10,y: 5,width: ((contentAdView.bounds).width - (((contentAdView.imageView as! UIImageView).bounds).width + 70)) , height: 20)
        
        (contentAdView.headlineView as! UILabel).textColor = textColorDark
        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
        (contentAdView.headlineView as! UILabel).numberOfLines = 1
        (contentAdView.headlineView as! UILabel).lineBreakMode = NSLineBreakMode.byTruncatingTail
        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontName, size: FONTSIZELarge)
        //(appInstallAdView.headlineView as! UILabel).sizeToFit()
        
        (contentAdView.bodyView as! UILabel).frame = CGRect(x: ((contentAdView.imageView as! UIImageView).bounds).width + 10, y: ((contentAdView.headlineView as! UILabel).bounds).height + (contentAdView.headlineView as! UILabel).frame.origin.y,width: ((contentAdView.bounds).width - (((contentAdView.imageView as! UIImageView).bounds).width + 100)) , height: 40)
        
        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
        (contentAdView.bodyView as! UILabel).lineBreakMode = NSLineBreakMode.byWordWrapping
        (contentAdView.bodyView as! UILabel).numberOfLines = 2
        (contentAdView.bodyView as! UILabel).textColor = textColorMedium
        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        
        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: (contentAdView.bounds).width-75,y: ((contentAdView.imageView as! UIImageView).bounds).height/2 + (contentAdView.imageView as! UIImageView).frame.origin.y/2-10, width: 65, height: 30)
        (contentAdView.callToActionView as! UIButton).setTitle(
            nativeContentAd.callToAction, for: UIControl.State.normal)
        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (contentAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
        (contentAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
        (contentAdView.callToActionView as! UIButton).backgroundColor = bgColor
        (contentAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
        (contentAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
        (contentAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
        (contentAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        nativeAdArray.append(contentAdView)
        if loadrequestcount <= 10
        {
            self.loadrequestcount = self.loadrequestcount+1
            self.adLoader.delegate = nil
            self.showNativeAd()
            self.blogTableView.reloadData()
        }
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if (blogUpdate == true){
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
    }
    
    
    func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyBlog = true
            self.browseEntries()
        case 1:
            
            browseOrMyBlog = false
            self.browseEntries()
        default:
            break;
        }
    }
   
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{

            searchDic.removeAll(keepingCapacity: false)
            blogUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "blogs/browse-search-form"
            presentedVC.serachFor = "blog"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // Create Blog Form
    @objc func addNewBlog(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
            presentedVC.contentType = "blog"
            presentedVC.param = [ : ]
            presentedVC.url = "blogs/create"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)

        }
    }
    
    // Handle Browse Blog or My Blog PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Browse Blog & false for My Blog
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            browseOrMyBlog = false
        }else if sender.tag == 11 {
            browseOrMyBlog = true
        }
        blogTableView.tableFooterView?.isHidden = true
        self.blogResponse.removeAll(keepingCapacity: false)
        self.blogTableView.reloadData()
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Blog
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if reachability.connection != .none {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK: - Server Connection For Blog Updation
    
    // For delete  a Blog
    func updateBlogMenuAction(_ url : String){
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
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        updateAfterAlert = false
                        self.browseEntries()
                    }
                    else{
                        // Handle Server Side Error
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
    
    
    
    // Update Blog
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
//            if showOnlyMyContent == true{
//                browseOrMyBlog = false
//            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            var path = ""
            var parameters = [String:String]()
            
            if browseOrMyBlog {
                path = "blogs/browse"
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id)]
                }else{
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                }
                myBlog.setUnSelectedButton()
                browseBlog.setSelectedButton()
                
            }else{
                path = "blogs/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                browseBlog.setUnSelectedButton()
                myBlog.setSelectedButton()
            }
            
            
            if (showSpinner){
             //   spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters for Browse/MyBlog
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyBlog = true
            }
            
            
            if (self.pageNumber == 1){
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.blogResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                        self.blogResponse = responseCacheArray as! [AnyObject]
                      //  showSpinner = false
                    }
                    self.blogTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            self.refreshButton.isHidden = true
            self.contentIcon.isHidden = true

            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    //})
                    self.blogTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.blogResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let blog = response["response"] as? NSArray {
                                    self.blogResponse = self.blogResponse + (blog as [AnyObject])
                                    
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = blog
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.showOnlyMyContent == false {
                                
                                if (response["canCreate"] as! Bool == true){
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(BlogViewController.searchItem))
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(BlogViewController.addNewBlog))

                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    self.showAppTour()
                                    
                                    
                                }else{
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(BlogViewController.searchItem))

                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                    
                                }
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Blog Tabel
                        self.blogTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.blogResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(blogIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any blog entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(BlogViewController.browseEntries), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                            
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
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_blogs > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_blogs) == (kFrequencyAdsInCells_blogs)-1))
        {
            if adsType_blogs == 2
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 430
                }
                else
                {
                    return adsCellheight
                }
                
            }
            else if adsType_blogs == 0
            {
                return 75
            }
            return dynamicHeight
            
        }
        return dynamicHeight
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return dynamicHeight
    }
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if nativeAdArray.count > 0
        {
            var rowcount = Int()
            rowcount = (kFrequencyAdsInCells_blogs-1)
            if blogResponse.count > rowcount
            {
                let a = blogResponse.count/(kFrequencyAdsInCells_blogs-1)
                let b = blogResponse.count
                let Totalrowcount = a+b
                if Totalrowcount % kFrequencyAdsInCells_blogs == 0
                {
                    return Totalrowcount-1
                }
                else
                {
                    return Totalrowcount
                }
                
                
            }
            else
            {
                //print("total rows with  \(blogResponse.count)")
                return blogResponse.count
            }
            
        }
        return blogResponse.count
        
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        var row = (indexPath as NSIndexPath).row as Int
        
        if (kFrequencyAdsInCells_blogs > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_blogs) == (kFrequencyAdsInCells_blogs)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            blogTableView.register(NativeAdBlogcell.self, forCellReuseIdentifier: "Cell1")
            let cell = blogTableView.dequeueReusableCell(withIdentifier: "Cell1",for: indexPath) as! NativeAdBlogcell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_blogs-1)

            while Adcount > 10{

                Adcount = Adcount%10
            }
            
            if Adcount > 0
            {
                Adcount = Adcount-1
            }
            
            if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
            {
                for obj in cell.contentView.subviews
                {
                    if obj.tag == 1001001 //Condition if that view belongs to any specific class
                    {
                        
                        
                        obj.removeFromSuperview()
                        
                    }
                }
                let view = nativeAdArray[Adcount]
                cell.contentView.addSubview(view as! UIView)
                if(UIDevice.current.userInterfaceIdiom != .pad)
                {
                    cell.contentView.frame.size.height = view.frame.size.height
                    adsCellheight = cell.contentView.frame.size.height + 5
                }
            }
            return cell
            
        }
        else
        {
            var blogInfo:NSDictionary
            if kFrequencyAdsInCells_blogs > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_blogs)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.backgroundColor = tableViewBgColor
            
            blogInfo = blogResponse[row] as! NSDictionary
            cell.imgUser.contentMode = .scaleAspectFill
            cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
            // Set Blog Title
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
            cell.labTitle.text = blogInfo["title"] as? String
            cell.labTitle.numberOfLines = 2
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.labTitle.sizeToFit()
            
            if let ownerName = blogInfo["owner_title"] as? String {
                if let postedDate = blogInfo["creation_date"] as? String{
                    let date = dateDifferenceWithEventTime(postedDate)
                    var DateC = date.components(separatedBy: ", ")
                    var tempInfo = ""
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 100)
                    var labMsg = ""
                    if browseOrMyBlog {
                        labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, tempInfo)
                    }else{
                        labMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
                    }

                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                        // TODO: Clean this up..
                        return mutableAttributedString
                    })
                }
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            cell.labMessage.font = UIFont(name: fontName, size: FONTSIZESmall)
            
            // Set Blog Owner Image
            
            if let url = URL(string: blogInfo["owner_image"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            if browseOrMyBlog
            {
                cell.accessoryView = nil
            }
            else
            {
                //if (blogInfo["edit"] as! Bool) || (blogInfo["delete"] as! Bool) {
                let optionMenu = createButton(CGRect(x: view.bounds.width - 45, y: 0, width: 45, height: cell.bounds.height), title: "\u{f141}", border: false, bgColor: false, textColor: textColorDark)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
                optionMenu.addTarget(self, action: #selector(BlogViewController.showMenu(_:)), for: .touchUpInside)

                optionMenu.tag = row
                cell.accessoryView = optionMenu
            }
            return cell
            
        }
        
    }
    
    @objc func showMenu(_ sender:UIButton)
    {
        var blogInfo:NSDictionary
        blogInfo = blogResponse[sender.tag] as! NSDictionary
        editBlogID = blogInfo["blog_id"] as! Int
        if(blogInfo["menu"] != nil){
            let menuOption = blogInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    if titleString.range(of: "delete") != nil {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "delete":
                                let paramUrl =  menuItem["url"] as! String
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this blog entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.updateBlogMenuAction(paramUrl)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                            }
                        }))
                    }else{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                            case "edit":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Blog Entry", comment: "")
                                presentedVC.contentType = "blog"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                            }
                        }))
                    }
                }
            }
            if  (!isIpad()){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var index = Int()
        
        if kFrequencyAdsInCells_blogs > 4 && nativeAdArray.count > 0
        {
            let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_blogs
            index = (indexPath as NSIndexPath).row-row
        }
        else
        {
            index = (indexPath as NSIndexPath).row
        }
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[index] as! NSDictionary
        if(blogInfo["allow_to_view"] as! Int == 1){
            let presentedVC = BlogDetailViewController()
            if (blogInfo["blog_id"] is String){
                let tempValue = blogInfo["blog_id"] as! String
                presentedVC.blogId = Int(tempValue)
            }else{
                presentedVC.blogId = blogInfo["blog_id"] as! Int
            }
            presentedVC.blogName = blogInfo["title"] as! String
            
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        }else{
            self.view.makeToast( NSLocalizedString("You do not have permission to view this private page.",  comment: ""), duration: 5, position: "bottom")
        }
        
    }
    
    // MARK:  UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
//                if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if reachability.connection != .none {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            blogTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                if adsType_blogs == 2 || adsType_blogs == 4{
                                    delay(0.1) {
                                        self.checkforAds()
                                    }
                                }
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        blogTableView.tableFooterView?.isHidden = true
                }
                    
            //    }
                
            }
            
        }
        
    }
    
    @objc func searchItem(){
        let presentedVC = BlogSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "blogs/search-form"
        loadFilter(url)
    }
    
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        blogTableView.tableFooterView?.isHidden = true
        globFilterValue = ""
        globalCatg = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
