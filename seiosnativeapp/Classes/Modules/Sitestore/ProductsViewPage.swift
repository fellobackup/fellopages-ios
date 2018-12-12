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

//  ProductsViewPage.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.


import UIKit
import GoogleMobileAds
import NVActivityIndicatorView
import Instructions
var productUpdate = true

class ProductsViewPage: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate , UIGestureRecognizerDelegate, GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    let mainView = UIView()
    var browsePage:UIButton!
    var myPage:UIButton!
    var productTableView:UITableView!    // Table view to show Products
    var categoryTableView:UITableView!   // Table View to show category
    var productBrowseType : Int!
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var productResponse = [AnyObject]()
    var myproductResponse = [AnyObject]()
    var popularproductResponse = [AnyObject]()
    var categoryResponse = [AnyObject]()
    var showSpinner = true                      // not show spinner at pull to refresh
    var pageOption:UIButton!
    let scrollView = UIScrollView()
    var feedFilter : UIButton!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var fromActivityFeed = false
    var showOnlyMyContent:Bool!
    var user_id : Int!
    var fromTab : Bool! = false
    var countListTitle : String!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var customSegmentControl : UISegmentedControl!
    var categResponse = [AnyObject]()
    var searchType = "view_count"
    var popularSearch = ""
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
    var currency : String = ""
    // AdMob Variable
    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    
    var dynamicHeight:CGFloat = 230              // Dynamic Height fort for Cell
    var sort : UIButton!
    var filter : UIButton!
    var lastContentOffset: CGFloat = 0
    var sortingDictionary : NSDictionary! = [:]
    var sortingString : String = ""
    
    
    // Native FacebookAd Variable
    var nativeAd:FBNativeAd!
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var admanager:FBNativeAdsManager!
    var Adiconview:UIImageView!
    var leftBarButtonItem : UIBarButtonItem!
    let cartButton = UIBarButtonItem()
    
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var adsImage : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var nativeAdArray = [AnyObject]()
    var adsCellheight:CGFloat = 250.0
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        // Do any additional setup after loading the view.
  
        view.backgroundColor = bgColor
        if fromTab == false{
            setDynamicTabValue()
        }

        category_filterId = nil
        globFilterValue = ""
        updateAfterAlert = true
        searchDic.removeAll(keepingCapacity: false)
        openMenu = false
        productUpdate = false
        productBrowseType = 0
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(ProductsViewPage.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        if showOnlyMyContent == false
        {
            self.title = NSLocalizedString("Products", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
            }

            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
  
            let menuImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            menuImageView.image = UIImage(named: "dashboard_icon")!.maskWithColor(color:textColorPrime)
            leftNavView.addSubview(menuImageView)
            
            
            if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
                let countLabel = createLabel(CGRect(x:17, y: 3, width: 17, height: 17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
                countLabel.backgroundColor = UIColor.red
                countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
                countLabel.layer.masksToBounds = true
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
                leftNavView.addSubview(countLabel)
            }
            
            self.navigationItem.hidesBackButton = true
            createScrollPageMenu()
            
        }
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x:0, y: 0, width: 0, height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x:0, y: 0, width: 0, height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        // Products Table View to show products
        productTableView = UITableView(frame: CGRect(x:0, y: ButtonHeight+10+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+10+TOPPADING + ButtonHeight )-(tabBarHeight)), style:.grouped)
        productTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
        productTableView.rowHeight = 253.0
        productTableView.dataSource = self
        productTableView.delegate = self
        productTableView.isOpaque = false
        productTableView.backgroundColor = bgColor
        productTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            productTableView.estimatedRowHeight = 0
            productTableView.estimatedSectionHeaderHeight = 0
            productTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(productTableView)
        
        // For sorting and filter
        sort = createButton(CGRect(x:0, y: view.bounds.height-(tabBarHeight + ButtonHeight)-6, width: view.bounds.width/2, height: ButtonHeight), title: NSLocalizedString("\(sortIcon)  Sort",  comment: ""), border: false, bgColor: false, textColor: textColorLight)
        sort.tag = 11
        sort.setTitleColor(textColorDark, for: .highlighted)
        sort.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        sort.addTarget(self, action: #selector(ProductsViewPage.sorting), for: .touchUpInside)
        sort.backgroundColor =  navColor
        sort.isHidden = true
        mainView.addSubview(sort)
        
        
        let bottomBorder2 = UIView(frame: CGRect(x: view.bounds.width/2 - 1,y: 0, width: 1 , height: sort.frame.size.height ))
        bottomBorder2.backgroundColor = textColorLight //textColorMedium
        sort.addSubview(bottomBorder2)
        
        filter = createButton(CGRect(x:view.bounds.width/2, y: view.bounds.height-(tabBarHeight + ButtonHeight)-6,width: view.bounds.width/2,height: ButtonHeight), title: NSLocalizedString("\(filterIcon)  Filter",  comment: ""), border: false, bgColor: false, textColor: textColorLight)
        filter.tag = 12
        filter.setTitleColor(textColorDark, for: .highlighted)
        filter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        filter.addTarget(self, action: #selector(ProductsViewPage.filters), for: UIControlEvents.touchUpInside)
        filter.backgroundColor =  navColor //bgColor
        filter.isHidden = true
        mainView.addSubview(filter)
        
        if showOnlyMyContent == true  {
            productTableView.frame.origin.y = TOPPADING
            productTableView.frame.size.height = view.bounds.height-(ButtonHeight+10+TOPPADING )-(tabBarHeight)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductsViewPage.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
        }
        
        
        // Categories Table View to show categories
        categoryTableView = UITableView(frame: CGRect(x:0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + tabBarHeight)), style:.grouped)
        categoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "Cellone")
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.isOpaque = false
        categoryTableView.isHidden = true
        categoryTableView.estimatedRowHeight = 165.0
        categoryTableView.rowHeight = UITableViewAutomaticDimension
        categoryTableView.backgroundColor = bgColor
        categoryTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            categoryTableView.estimatedRowHeight = 0
            categoryTableView.estimatedSectionHeaderHeight = 0
            categoryTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview( categoryTableView)
        
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProductsViewPage.refresh), for: UIControlEvents.valueChanged)
        productTableView.addSubview(refresher)
        
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(ProductsViewPage.refresh), for: UIControlEvents.valueChanged)
        categoryTableView.addSubview(refresher2)
        
        
        self.contentIcon = createLabel(CGRect(x:self.view.bounds.width/2 - 30, y: self.view.bounds.height/2-50, width: 60 , height: 50), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        self.contentIcon.isHidden = true
        self.mainView.addSubview(self.contentIcon)
        
        self.info = createLabel(CGRect(x:0, y: self.contentIcon.bounds.height + self.contentIcon.frame.origin.y + (2 * contentPADING), width: self.view.bounds.width , height: 60), text: NSLocalizedString("You do not have any products.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.numberOfLines = 0
        self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.info.backgroundColor = bgColor
        self.info.tag = 1000
        self.info.isHidden = true
        self.mainView.addSubview(self.info)
        
        self.refreshButton = createButton(CGRect(x:self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        self.refreshButton.backgroundColor = bgColor
        self.refreshButton.layer.borderColor = navColor.cgColor
        self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        self.refreshButton.addTarget(self, action: #selector(ProductsViewPage.browseEntries), for: UIControlEvents.touchUpInside)
        self.refreshButton.layer.cornerRadius = 5.0
        self.refreshButton.layer.masksToBounds = true
        self.mainView.addSubview(self.refreshButton)
        self.refreshButton.isHidden = true
        scrollView.isUserInteractionEnabled = false
    
        
        browseEntries()
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        categoryTableView.tableFooterView = footerView
        categoryTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        productTableView.tableFooterView = footerView2
        productTableView.tableFooterView?.isHidden = true
        
        if adsType_product != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(ProductsViewPage.checkforAds),
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
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(cartTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 1/2"
            coachViews.bodyView.nextLabel.text = "Next "
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
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
    
    @objc func goBack(){
         _ = self.navigationController?.popViewController(animated: false)
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showProductContent")
        {
            if  UserDefaults.standard.object(forKey: "showProductContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showProductContent")
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        setNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
        removeNavigationViews(controller: self)
        self.cartButton.customView = cartButtonView(functionOf: self)
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if productUpdate {
            showSpinner = true
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
            productUpdate = false
        }
    }
  
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        globFilterValue = ""
        globalCatg = ""
        tableViewFrameType = ""
        categoryTableView.tableFooterView?.isHidden = true
productTableView.tableFooterView?.isHidden = true
        
    }
    
    // MARK: - GADAdLoaderDelegate
    @objc func checkforAds(){
        nativeAdArray.removeAll()
        if adsType_product == 1
        {
            if kFrequencyAdsInCells_product > 4 && placementID != ""
            {
                if arrGlobalFacebookAds.count == 0
                {
                    self.showFacebookAd()
                }
                else
                {
                    for nativeAd in arrGlobalFacebookAds {
                        self.fetchAds(nativeAd: nativeAd)
                    }
                    if nativeAdArray.count == 10
                    {
                        productTableView.reloadData()
                    }
                }
                
            }
            
        }
        else if adsType_product == 0
        {
            if kFrequencyAdsInCells_product > 4 && adUnitID != ""
            {
                showNativeAd()
            }
            
        }
        else if adsType_product == 2 {
            checkCommunityAds()
        }
        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if reachability.connection != .none {
            //            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_product)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_product)"
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
                                            self.productTableView.reloadData()
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
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControlState())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
                //                adCallToActionButton.clipsToBounds = true
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(ProductsViewPage.actionAfterClick(_:)), for: .touchUpInside)
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
                adImageView1.contentMode = UIViewContentMode.scaleAspectFit
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
                imageButton.addTarget(self, action: #selector(ProductsViewPage.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
                self.fbView.frame.size.height = getBottomEdgeY(inputView: adBodyLabel) + 10
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
        dictionary["type"] =  "\(adsType_product)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_product)"
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
        
       // parametersNeedToAdd = [:]
        for ob in adsReportView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag == 0 || ob.tag == 1 || ob.tag == 2 || ob.tag == 3 || ob.tag == 4{
                    (ob as! UIButton).setTitle("\u{f10c}", for: UIControlState.normal)
                }
            }
        }
        
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"]!
        sender.setTitle("\u{f111}", for: UIControlState.normal)
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


    
    func showFacebookAd()
    {
        //FBAdSettings.addTestDevices(fbTestDevice)
        //FBAdSettings.addTestDevice(fbTestDevice)
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager.delegate = self
        admanager.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager.loadAds()
        
    }

    func showNativeAd(){
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
    
    func nativeAdsLoaded()
    {
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
            self.fetchAds(nativeAd: nativeAd)
        }
        
        if nativeAdArray.count == 10
        {
            productTableView.reloadData()
        }
    }
    
    func fetchAds(nativeAd: FBNativeAd){
        
//        if ((self.nativeAd) != nil) {
//            self.nativeAd.unregisterView()
//        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x:0,y: 0 , width: (UIScreen.main.bounds.width/2) , height: 230))
            
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x:0, y:5 , width: (UIScreen.main.bounds.width) , height: 230))
            
        }
        self.fbView.backgroundColor = UIColor.white
        self.fbView.tag = 1001001
        
        adImageView = FBMediaView(frame: CGRect(x:0, y:0, width: self.fbView.bounds.width, height: 180))
        self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        self.fbView.addSubview(adImageView)
        
        adTitleLabel = UILabel(frame: CGRect(x:5 , y: adImageView.bounds.height + 10 + adImageView.frame.origin.y, width: self.fbView.bounds.width-100, height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontName, size: 12)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        adBodyLabel = UILabel(frame: CGRect(x:5 , y: adTitleLabel.bounds.height + 10 + adTitleLabel.frame.origin.y, width: self.fbView.bounds.width-80, height: 30))
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        adBodyLabel.isHidden = true
        
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        self.fbView.addSubview(adBodyLabel)
        
        adCallToActionButton = UIButton(frame:CGRect(x:self.fbView.bounds.width-80, y: adImageView.bounds.height + 10 + adImageView.frame.origin.y,width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControlState.normal)
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        Adiconview = createImageView(CGRect(x:self.fbView.frame.size.width-19,y: 0,width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
     
        
    }
    func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error)
    }
    
    // MARK: - GADAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError){
    }
    
    // Mark: - GADNativeAppInstallAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd)
    {
        let appInstallAdView = Bundle.main.loadNibNamed("NativeAdAdvancedevent", owner: nil,
                                                        options: nil)?.first as! GADNativeAppInstallAdView
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height+150)
        }
        else
        {
            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height)
        }
        
        // Associate the app install ad view with the app install ad object. This is required to make
        // the ad clickable.
        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
        appInstallAdView.tag = 1001001
        
        (appInstallAdView.iconView as! UIImageView).frame = CGRect(x:5,y: 5,width: 40,height: 40)
        (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
        
        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: (appInstallAdView.iconView as! UIImageView).bounds.width + 10 ,y: 5,width: appInstallAdView.bounds.width-((appInstallAdView.iconView as! UIImageView).bounds.width + 55),height: 30)
        (appInstallAdView.headlineView as! UILabel).numberOfLines = 0
        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x:0,y: (appInstallAdView.iconView as! UIImageView).bounds.height + 10 + (appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 150)
        }
        else
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (appInstallAdView.iconView as! UIImageView).bounds.height+10+(appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 300)
        }
        
        let imgheight = Double(appInstallAdView.frame.size.height)
        let imgWidth = Double((appInstallAdView.imageView as! UIImageView).frame.size.width)
        (appInstallAdView.imageView as! UIImageView).image = cropToBounds((nativeAppInstallAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
        //(appInstallAdView.imageView as! UIImageView).contentMode = .ScaleAspectFit
        
        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: 10,y: (appInstallAdView.imageView as! UIImageView).bounds.height + 10 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-100,height: 40)
        
        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
        (appInstallAdView.bodyView as! UILabel).numberOfLines = 0
        (appInstallAdView.bodyView as! UILabel).textColor = textColorDark
        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: appInstallAdView.bounds.width-75, y:(appInstallAdView.imageView as! UIImageView).bounds.height + 15 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
        
        (appInstallAdView.callToActionView as! UIButton).setTitle(
            nativeAppInstallAd.callToAction, for: UIControlState.normal)
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
            self.productTableView.reloadData()
        }
    }

    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        
        let contentAdView = Bundle.main.loadNibNamed("ContentAdsFeedview", owner: nil,
                                                     options: nil)?.first as! GADNativeContentAdView
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height+150)
        }
        else
        {
            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height)
        }
        
        // Associate the app install ad view with the app install ad object. This is required to make
        // the ad clickable.
        contentAdView.nativeContentAd = nativeContentAd
        contentAdView.tag = 1001001
        
        // Populate the app install ad view with the app install ad assets.
        // Some assets are guaranteed to be present in every app install ad.
        (contentAdView.headlineView as! UILabel).frame = CGRect(x: 10 ,y: 5,width: contentAdView.bounds.width-55, height: 30)
        (contentAdView.headlineView as! UILabel).numberOfLines = 0
        (contentAdView.headlineView as! UILabel).textColor = textColorDark
        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 160)
        }
        else
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 300)
        }
        
        let imgheight = Double(contentAdView.frame.size.height)
        let imgWidth = Double((contentAdView.imageView as! UIImageView).frame.size.width)
        (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
        
        (contentAdView.bodyView as! UILabel).frame = CGRect(x:10 ,y: (contentAdView.imageView as! UIImageView).bounds.height + 10 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: contentAdView.bounds.width-100,height: 40)
        
        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
        (contentAdView.bodyView as! UILabel).numberOfLines = 0
        (contentAdView.bodyView as! UILabel).textColor = textColorDark
        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        
        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: contentAdView.bounds.width-75, y: (contentAdView.imageView as! UIImageView).bounds.height + 15 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
        
        (contentAdView.callToActionView as! UIButton).setTitle(
            nativeContentAd.callToAction, for: UIControlState.normal)
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
            self.productTableView.reloadData()
        }
    }
        
    func createScrollPageMenu()
    {
        
        scrollView.frame = CGRect(x:0, y: TOPPADING, width:  view.bounds.width, height:  ButtonHeight+10)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0.0
        var eventMenu = ["Products","Categories"]
        for i in 100 ..< 102
        {
            
            menuWidth = CGFloat((view.bounds.width)/2)
            if i == 100
            {   pageOption =  createNavigationButton(CGRect(x:origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
            }else{
                pageOption =  createNavigationButton(CGRect(x:origin_x, y: ScrollframeY, width: menuWidth , height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
            }
            pageOption.tag = i
            pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            pageOption.addTarget(self, action:#selector(ProductsViewPage.pageSelectOptions(_:)), for: .touchUpInside)
            pageOption.backgroundColor =  UIColor.clear//textColorLight
            
            pageOption.alpha = 1.0
            
            if i==102
            {
                pageOption.alpha = 0.4
                
            }
            scrollView.addSubview(pageOption)
            origin_x += menuWidth
            
        }
        scrollView.contentSize = CGSize(width:origin_x + 10,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        mainView.addSubview(scrollView)
        
    }

    @objc func handleSwipes( _ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
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
    
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    
    @objc func pageSelectOptions( _ sender: UIButton)
    {
        productBrowseType = sender.tag - 100
        if productBrowseType == 0
        {
            if productResponse.count == 0
            {
                categoryTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseEntries()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of:NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                self.refreshButton.isHidden = true
                self.contentIcon.isHidden = true
                
                
                productTableView.isHidden = false
                categoryTableView.isHidden = true
                productTableView.reloadData()
                
            }
            
        }
        else if productBrowseType == 1
        {
            if categoryResponse.count == 0
            {
                productTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseEntries()
            }
            else
            {

                self.refreshButton.isHidden = true
                self.contentIcon.isHidden = true
                productTableView.isHidden = true
                categoryTableView.isHidden = false
                categoryTableView.reloadData()
            }
            
            
            
        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        for ob in scrollView.subviews{
            if ob .isKind(of:UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }
        searchDic.removeAll(keepingCapacity: false)
        
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    
    
    
    @objc func browseEntries()
    {
        // Check Internet Connectivity
        if reachability.connection != .none
        {
            
            self.info.isHidden = true
            self.refreshButton.isHidden = true
            self.contentIcon.isHidden = true
            
            if (self.pageNumber == 1)
            {
                
                if updateAfterAlert == true
                {
                    removeAlert()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            if (showSpinner)
            {
              //  spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            switch(productBrowseType)
            {
            case 0:
                
                path = "sitestore/product/browse"
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : "\(user_id)","restapilocation":"\(loc)","type" : "userPages","orderby":"\(sortingString)"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation":"\(loc)", "orderby":"\(sortingString)"]
                        }
                        if searchDic.count > 0 {
                            parameters.merge(searchDic)
                        }
                        
                        
                    }
                    else
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : "\(user_id)","restapilocation":"\(defaultlocation)","type" : "userPages","orderby":"\(sortingString)"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation":"\(defaultlocation)","orderby":"\(sortingString)"]
                        }
                        
                        if searchDic.count > 0 {
                            parameters.merge(searchDic)
                        }
                        
                        categoryTableView.isHidden = true
                    }
                    
                }
                else
                {
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : "\(user_id)","type" : "userPages"]
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                    }
                    categoryTableView.isHidden = true
                    
                }
            case 1:
                
                path = "sitestore/product/category"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showCount": "1"] //,"showCategory": "1"
                productTableView.isHidden = true
            default:
                print("Error")
            }
            
            
            // Send Server Request to Browse Page Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: 
                    {
                        self.refresher.endRefreshing()
                        self.refresher2.endRefreshing()
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        self.scrollView.isUserInteractionEnabled = true
                      
                        if msg
                        {
                            
                            if self.productBrowseType==1
                            {
                                
                                self.productTableView.isHidden = true
                                self.categoryTableView.isHidden = false
                                if self.pageNumber == 1
                                {
                                    self.categoryResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["categories"] != nil
                                    {
                                        if let page = response["categories"] as? NSArray
                                        {
                                            self.categoryResponse = self.categoryResponse + (page as [AnyObject])
                                        }
                                    }
                                    
                                    if response["totalItemCount"] != nil
                                    {
                                        self.totalItems = response["totalItemCount"] as! Int
                                    }
                                    
                                    
                                }
                                self.isPageRefresing = false
                                if self.categoryResponse.count == 0
                                {
                                    
                                    
                                    self.info.isHidden = false
                                    self.refreshButton.isHidden = false
                                    self.contentIcon.isHidden = false
                                    
                                }
                                else
                                {
                                    self.info.isHidden = true
                                    self.refreshButton.isHidden = true
                                    self.contentIcon.isHidden = true
                                    
                                }
                                self.categoryTableView.reloadData()
                                
                            }
                            else
                            {
                                self.info.isHidden = true
                                self.refreshButton.isHidden = true
                                self.contentIcon.isHidden = true
                                self.sort.isHidden = false
                                self.filter.isHidden = false
                                self.productTableView.isHidden = false
                                self.categoryTableView.isHidden = true
                                if self.pageNumber == 1
                                {
                                    self.productResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["response"] != nil
                                    {
                                        if let page = response["response"] as? NSArray
                                        {
                                            self.productResponse = self.productResponse + (page as [AnyObject])
                                        }
                                    }
                                    
                                    
                                    
                                    if response["orderby"] != nil
                                    {
                                        if let sorting = response["orderby"] as? NSDictionary
                                        {
                                            self.sortingDictionary = sorting
                                        }
                                    }
                                    if response["totalItemCount"] != nil
                                    {
                                        self.totalItems = response["totalItemCount"] as! Int
                                    }
                                    if response["currency"] != nil{
                                        self.currency = response["currency"] as! String
                                    }
                                    if self.showOnlyMyContent == false
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(ProductsViewPage.searchItem))
                                        
                                        self.cartButton.customView = cartButtonView(functionOf: self)
                                        self.navigationItem.setRightBarButtonItems([searchItem, self.cartButton], animated: true)
                                        self.showAppTour()
                                        
                                    }
                                }
                                
                                
                                self.isPageRefresing = false
                                if self.productResponse.count == 0
                                {
                                    self.info = createLabel(CGRect(x:0, y: self.contentIcon.bounds.height + self.contentIcon.frame.origin.y + (2 * contentPADING), width: self.view.bounds.width , height: 60), text: NSLocalizedString("There is no products entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                    self.info.numberOfLines = 0
                                    self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.info.backgroundColor = bgColor
                                    self.info.tag = 1000
                                    self.info.isHidden = false
                                    self.mainView.addSubview(self.info)
                                    self.info.isHidden = false
                                    self.refreshButton.isHidden = false
                                    self.contentIcon.isHidden = false
                                    
                                }
                                self.productTableView.reloadData()
                                
                            }
                            
                        }
                        else
                        {
                            self.refresher.endRefreshing()
                            if succeeded["message"] != nil
                            {
                                self.scrollView.isUserInteractionEnabled = true
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            }
                            
                        }
                        
                })
            }
        }
        else
        {
            // No Internet Connection Message
            self.scrollView.isUserInteractionEnabled = true
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if tableView.tag == 11{
            return 0.00001
        }
        else{
            
            if (limit*pageNumber < totalItems){
                return 0
            }else{
                return 0.00001
            }
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if productBrowseType == 2 {
            return ButtonHeight + 10
        }
        else{
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if productBrowseType==1
        {
            return 160.0
        }
        else
        {
            if (kFrequencyAdsInCells_product > 4 && nativeAdArray.count > 0 && ((indexPath.row % kFrequencyAdsInCells_product) == (kFrequencyAdsInCells_product)-1))
            {
                if adsType_product == 2{
                    guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                        return 430
                    }
                     return adsCellheight
                }
                else if adsType_product == 0
                {
                    return 265
                }
                return 235
            }
            return dynamicHeight
        }
        
        
    }
    
    
    // Set No. of Rows in Section
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if productBrowseType == 0
        {
            if nativeAdArray.count > 0
            {
                var rowcount = Int()
                rowcount = 2*(kFrequencyAdsInCells_product-1)
                if productResponse.count > rowcount
                {
                    let b = Int(ceil(Float(productResponse.count)/2))
                    adsCount = b/(kFrequencyAdsInCells_product-1)
                    let Totalrowcount = adsCount+b
                    if b%(kFrequencyAdsInCells_product-1) == 0 && productResponse.count % 2 != 0
                    {
                        if adsCount%2 != 0
                        {
                            
                            return Totalrowcount - 1
                        }
                    }
                    else if productResponse.count % 2 != 0 && adsCount % 2 == 0
                    {
                        
                        return Totalrowcount - 1
                    }
                    
                    return Totalrowcount
                    
                }
                else
                {
                    
                    return Int(ceil(Float(productResponse.count)/2))
                }
                
            }
            
            return Int(ceil(Float(productResponse.count)/2))
            
        }
        else
        {
            
            return Int(ceil(Float(categoryResponse.count)/2))
            
        }
        
        
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var row = indexPath.row as Int
        if productBrowseType == 0  {
            
            
            if (kFrequencyAdsInCells_product > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_product) == (kFrequencyAdsInCells_product)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                productTableView.register(NativeProductsCell.self, forCellReuseIdentifier: "Cell1")
                let cell = productTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath as IndexPath) as! NativeProductsCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = bgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_product-1)
                
                
                
                while Adcount > 10
                {
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
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let adcount = row/kFrequencyAdsInCells_product
                    var index:Int!
                    index = (row * 2) - adcount
                    
                    if productResponse.count > (index)
                    {
                        cell.contentSelection1.isHidden = false
                        cell.productImageView1.isHidden = false
                        cell.classifiedName1.isHidden = false
                        cell.ratings1.isHidden = false
                        cell.descriptionView1.isHidden = false
                        cell.actualPrice1.isHidden = false
                        cell.productImageView1.image = nil
                        if let productInfo = productResponse[index] as? NSDictionary {
                            
                            if let url = NSURL(string: productInfo["image"] as! String){
                                cell.productImageView1.kf.indicatorType = .activity
                                (cell.productImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.productImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                                cell.featuredLabel1.isHidden = false
                            }else{
                                cell.featuredLabel1.isHidden = true
                            }
                            
                            if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                                
                                cell.sponsoredLabel1.frame = CGRect(x:0, y:  0, width: 70, height: 20)
                                if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                                    cell.sponsoredLabel1.frame = CGRect(x:0, y: 25, width: 70, height: 20)
                                }
                                cell.sponsoredLabel1.isHidden = false
                            }else{
                                cell.sponsoredLabel1.isHidden = true
                            }
                            
                            var title = productInfo["title"] as! String
                            if title.length > 30{
                                title = (title as NSString).substring(to: 30-3)
                                title  = title + "..."
                            }
                            cell.classifiedName1.frame.size.width =  cell.descriptionView1.bounds.width-10
                            cell.classifiedName1.text = title
                            cell.classifiedName1.numberOfLines = 1
                            cell.classifiedName1.lineBreakMode = NSLineBreakMode.byWordWrapping
                            cell.classifiedName1.sizeToFit()
                            
                            cell.ratings1.frame.origin.y = cell.classifiedName1.frame.size.height + cell.classifiedName1.frame.origin.y + 5
                            if let rating = productInfo["rating_avg"] as? Int
                            {
                                cell.updateRating1(rating: rating, ratingCount: rating)
                            }
                            else
                            {
                                cell.updateRating1(rating: 0, ratingCount: 0)
                            }
                            
                            
                            cell.actualPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                            cell.discountedPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                            
                            cell.contentSelection1.tag = (index + 1) as Int
                            cell.contentSelection1.addTarget(self, action: #selector(ProductsViewPage.showProduct(_:)), for: .touchUpInside)
                            
                            
                            if logoutUser == false{
                                
                                
                                if let menu = productInfo["menu"] as? NSArray{
                                    for menuitem in menu{
                                        
                                        let menuitem = menuitem as! NSDictionary
                                        if menuitem["name"] as! String == "wishlist"{
                                            
                                            cell.menu1.isHidden = false
                                            cell.menu1.tag = (index + 1) as Int
                                            cell.menu1.addTarget(self, action:#selector(ProductsViewPage.addToWishlist(_:)), for: .touchUpInside)
                                            if let _ = productInfo["wishlist"] as? NSArray{
                                                cell.menu1.setTitleColor(UIColor.red, for: .normal)
                                            }
                                            else{
                                                cell.menu1.setTitleColor(textColorLight, for: .normal)
                                            }
                        
                                            
                                        }
                                    }

                                }
                                
                            }
                            var totalView = ""
                            
                            if let information = productInfo["information"] as? NSDictionary{
                                if let price = information["price"] as? NSDictionary{
                                    if let discount = price["discount"] as? CGFloat{
                                        if discount == 1{
                                            
                                            if let productType = productInfo["product_type"] as? String{
                                                if productType == "grouped"{
                                                    
                                                    cell.actualPrice1.text = NSLocalizedString("Start at:", comment: "")
                                                    cell.actualPrice1.sizeToFit()
                                                }
                                                else{
                                                    if let views = price["discounted_amount"] as? Double{
                                                        cell.discountedPrice1.isHidden = false
                                                        cell.discountedPrice1.frame.origin.x = 5
                                                        let formatter = NumberFormatter()
                                                        formatter.numberStyle = .currency
                                                        formatter.locale = NSLocale.current // This is the default
                                                        formatter.currencyCode = "\(currency)"
                                                        totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                                        if let signValue = price["sign"] as? Int{
                                                            if signValue == 1{
                                                                cell.discountedPrice1.text = "\(totalView)*"
                                                            }
                                                            else{
                                                                cell.discountedPrice1.text = "\(totalView)"
                                                            }
                                                        }
                                                        else{
                                                            cell.discountedPrice1.text = "\(totalView)"
                                                        }
                                                        cell.discountedPrice1.sizeToFit()
                                                    }
                                                }
                                            }
                                            if let ratingAvg = price["price"] as? Double{
                                                
                                                cell.actualPrice1.isHidden = false
                                                cell.actualPrice1.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice1) + 5
                                                var ratingView = ""
                                                let formatter = NumberFormatter()
                                                formatter.numberStyle = .currency
                                                formatter.locale = NSLocale.current // This is the default
                                                formatter.currencyCode = "\(currency)"
                                                ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                                cell.actualPrice1.text = "\(ratingView)"
                                                cell.actualPrice1.sizeToFit()
                                                cell.actualPrice1.frame.size.width = cell.actualPrice1.bounds.width
                                                let viewBorder1 = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice1.frame.size.width, height: 1))
                                                viewBorder1.backgroundColor = UIColor.black
                                                viewBorder1.tag = 1003
                                                cell.actualPrice1.addSubview(viewBorder1)
                                                
                                            }
                                            
                                        }
                                        else{
                                            cell.discountedPrice1.isHidden = true
                                            for ob in cell.actualPrice1.subviews{
                                                if ob.tag == 1003 {
                                                    ob.removeFromSuperview()
                                                }
                                                
                                                
                                            }
                                            if let views = price["price"] as? Double{
                                                cell.actualPrice1.frame.origin.x = 5
                                                let formatter = NumberFormatter()
                                                formatter.numberStyle = .currency
                                                formatter.locale = NSLocale.current // This is the default
                                                formatter.currencyCode = "\(currency)"
                                                totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                                if let productType = productInfo["product_type"] as? String{
                                                    if productType == "grouped"{
                                                        if let signValue = price["sign"] as? Int{
                                                            if signValue == 1{
                                                                cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                                
                                                            }
                                                            else{
                                                                cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                            }
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                            
                                                        }
                                                    }
                                                    else{
                                                        
                                                        if let signValue = price["sign"] as? Int{
                                                            if signValue == 1{
                                                                cell.actualPrice1.text = "\(totalView)*"
                                                            }
                                                            else{
                                                                cell.actualPrice1.text = "\(totalView)"
                                                            }
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = "\(totalView)"
                                                        }
                                                        
                                                    }
                                                }
                                                cell.actualPrice1.sizeToFit()
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    else{
                        cell.contentSelection1.isHidden = true
                        cell.productImageView1.isHidden = true
                        cell.classifiedName1.isHidden = true
                        cell.ratings1.isHidden = true
                        cell.descriptionView1.isHidden = true
                        cell.actualPrice1.isHidden = true
                    }
                }
                else{
                    cell.contentSelection1.isHidden = true
                    cell.productImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                    cell.ratings1.isHidden = true
                    cell.descriptionView1.isHidden = true
                    cell.actualPrice1.isHidden = true
                    
                }
                
                return cell
                
            }
            else
            {
                
                
                if kFrequencyAdsInCells_product > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_product)
                }
                
                let cell = productTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductTableViewCell
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = bgColor //UIColor.red
                
                var index:Int!
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if (kFrequencyAdsInCells_product > 4 && nativeAdArray.count > 0)
                    {
                        let adcount = row/(kFrequencyAdsInCells_product-1)
                        index = (row * 2) + adcount
                        
                    }
                    else
                    {
                        index = row * 2
                        
                    }
                    
                    
                }
                else
                {
                    index = row * 2
                }
                
                
                if productResponse.count > index {
                    cell.contentSelection.isHidden = false
                    cell.classifiedImageView.isHidden = false
                    cell.classifiedName.isHidden = false
                    cell.ratings.isHidden = false
                    cell.classifiedImageView.image = nil
                    
                    
                    
                    if let productInfo = productResponse[index] as? NSDictionary {
                        // LHS
                        if let url = NSURL(string: productInfo["image"] as! String){
                            cell.classifiedImageView.kf.indicatorType = .activity
                            (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        }
                        
                        
                        if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                            cell.featuredLabel.isHidden = false
                        }else{
                            cell.featuredLabel.isHidden = true
                        }
                        
                        if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                            
                            cell.sponsoredLabel.frame = CGRect(x:0, y: 0, width: 70, height: 20)
                            if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                                cell.sponsoredLabel.frame = CGRect(x:0, y: 25, width: 70, height: 20)
                            }
                            cell.sponsoredLabel.isHidden = false
                        }else{
                            cell.sponsoredLabel.isHidden = true
                        }
                        
                        var title = productInfo["title"] as! String
                        if title.length > 30{
                            title = (title as NSString).substring(to: 30-3)
                            title  = title + "..."
                        }
                
                        cell.classifiedName.text = title
                        cell.classifiedName.numberOfLines = 1
                        cell.classifiedName.lineBreakMode = .byTruncatingTail
                        cell.classifiedName.sizeToFit()
                        cell.classifiedName.frame.size.width =  cell.descriptionView.bounds.width-10
                        cell.ratings.frame.origin.y = cell.classifiedName.frame.size.height + cell.classifiedName.frame.origin.y + 5
                        
                        if let rating = productInfo["rating_avg"] as? Int
                        {
                            cell.updateRating(rating: rating, ratingCount: rating)
                        }
                        else
                        {
                            cell.updateRating(rating: 0, ratingCount: 0)
                        }
                        
                        cell.actualPrice.frame.origin.y = cell.ratings.frame.origin.y + cell.ratings.bounds.height
                        cell.discountedPrice.frame.origin.y = cell.ratings.frame.origin.y + cell.ratings.bounds.height
                        
                        cell.contentSelection.tag = index as Int
                        cell.contentSelection.addTarget(self, action:#selector(ProductsViewPage.showProduct(_:)), for: .touchUpInside)
                        
                        if logoutUser == false{
                            
                            
                            if let menu = productInfo["menu"] as? NSArray{
                                for menuitem in menu{
                                    
                                    let menuitem = menuitem as! NSDictionary
                                    if menuitem["name"] as! String == "wishlist"{
                                        
                                        cell.menu.isHidden = false
                                        cell.menu.tag = index as Int
                                        cell.menu.addTarget(self, action:#selector(ProductsViewPage.addToWishlist(_:)), for: .touchUpInside)
                                        if let _ = productInfo["wishlist"] as? NSArray{
                                            cell.menu.setTitleColor(UIColor.red, for: .normal)
                                        }
                                        else{
                                            cell.menu.setTitleColor(textColorLight, for: .normal)
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                        }
                        var totalView = ""
                        if let information = productInfo["information"] as? NSDictionary{
                            if let price = information["price"] as? NSDictionary{
                                if let discount = price["discount"] as? CGFloat{
                                    if discount == 1{
                                        
                                        if let productType = productInfo["product_type"] as? String{
                                            if productType == "grouped"{
                                                
                                                cell.actualPrice.text = NSLocalizedString("Start at:", comment: "")
                                                cell.actualPrice.sizeToFit()
                                            }
                                            else{
                                                if let views = price["discounted_amount"] as? Double{
                                                    cell.discountedPrice.isHidden = false
                                                     cell.discountedPrice.frame.origin.x = 5
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(currency)"
                                                    totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.discountedPrice.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.discountedPrice.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.discountedPrice.text = "\(totalView)"
                                                    }
                                                    cell.discountedPrice.sizeToFit()
                                                }
                                            }
                                        }
                                        if let ratingAvg = price["price"] as? Double{
                                            
                                            cell.actualPrice.isHidden = false
                                            cell.actualPrice.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice) + 5
                                            var ratingView = ""
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                            cell.actualPrice.text = "\(ratingView)"
                                            cell.actualPrice.sizeToFit()
                                            cell.actualPrice.frame.size.width = cell.actualPrice.bounds.width
                                            let viewBorder = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice.frame.size.width, height: 1))
                                            viewBorder.backgroundColor = UIColor.black
                                            viewBorder.tag = 1002
                                            cell.actualPrice.addSubview(viewBorder)
                                            
                                        }
                                        
                                    }
                                    else{
                                        cell.discountedPrice.isHidden = true
                                        for ob in cell.actualPrice.subviews{
                                            if ob.tag == 1002 {
                                                ob.removeFromSuperview()
                                            }
                                            
                                            
                                        }
                                        if let views = price["price"] as? Double{
                                            cell.actualPrice.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                            if let productType = productInfo["product_type"] as? String{
                                                if productType == "grouped"{
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                            
                                                        }
                                                        else{
                                                            cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                        }
                                                    }
                                                    else{
                                                         cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")

                                                    }
                                                }
                                                else{
                                                    
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.actualPrice.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice.text = "\(totalView)"
                                                    }
                                                    
                                                }
                                            }
                                            cell.actualPrice.sizeToFit()
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    
                    
                }
                else{
                    cell.contentSelection.isHidden = true
                    cell.classifiedImageView.isHidden = true
                    cell.classifiedName.isHidden = true
                    cell.ratings.isHidden = true
                    cell.discountedPrice.isHidden = true
                    cell.actualPrice.isHidden = true
                    cell.descriptionView.isHidden = true
                    
                    cell.contentSelection1.isHidden = true
                    cell.productImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                    cell.ratings1.isHidden = true
                    cell.descriptionView1.isHidden = true
                    cell.discountedPrice1.isHidden = true
                    cell.actualPrice1.isHidden = true
                }
                
                
                if productResponse.count > (index + 1){
                    cell.contentSelection1.isHidden = false
                    cell.productImageView1.isHidden = false
                    cell.classifiedName1.isHidden = false
                    cell.ratings1.isHidden = false
                    cell.descriptionView1.isHidden = false
                    cell.discountedPrice1.isHidden = false
                    cell.actualPrice1.isHidden = false
                    cell.productImageView1.image = nil
                    if let productInfo = productResponse[index + 1] as? NSDictionary {
                        
                        if let url = NSURL(string: productInfo["image"] as! String){
                            cell.productImageView1.kf.indicatorType = .activity
                            (cell.productImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.productImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        
                        if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                            cell.featuredLabel1.isHidden = false
                        }else{
                            cell.featuredLabel1.isHidden = true
                        }
                        
                        if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                            
                            cell.sponsoredLabel1.frame = CGRect(x:0, y: 0, width: 70, height: 20)
                            if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                                cell.sponsoredLabel1.frame = CGRect(x:0, y: 25, width: 70, height: 20)
                            }
                            cell.sponsoredLabel1.isHidden = false
                        }else{
                            cell.sponsoredLabel1.isHidden = true
                        }
                        var title = productInfo["title"] as! String
                        if title.length > 30{
                            title = (title as NSString).substring(to: 30-3)
                            title  = title + "..."
                        }
                        
                        cell.classifiedName1.text = title
                        cell.classifiedName1.numberOfLines = 1
                        cell.classifiedName1.lineBreakMode = .byTruncatingTail
                        cell.classifiedName1.sizeToFit()
                        cell.classifiedName1.frame.size.width =  cell.descriptionView1.bounds.width-10
                        cell.ratings1.frame.origin.y = cell.classifiedName1.frame.size.height + cell.classifiedName1.frame.origin.y + 5
                        if let rating = productInfo["rating_avg"] as? Int
                        {
                            cell.updateRating1(rating: rating, ratingCount: rating)
                        }
                        else
                        {
                            cell.updateRating1(rating: 0, ratingCount: 0)
                        }
                        
                        
                        cell.actualPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                        cell.discountedPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                        
                        cell.contentSelection1.tag = (index + 1) as Int
                        cell.contentSelection1.addTarget(self, action: #selector(ProductsViewPage.showProduct(_:)), for: .touchUpInside)
                        
                        
                        if logoutUser == false{
                            
                            
                            if let menu = productInfo["menu"] as? NSArray{
                                for menuitem in menu{
                                    
                                    let menuitem = menuitem as! NSDictionary
                                    if menuitem["name"] as! String == "wishlist"{
                                        
                                        cell.menu1.isHidden = false
                                        cell.menu1.tag = (index + 1) as Int
                                        cell.menu1.addTarget(self, action:#selector(ProductsViewPage.addToWishlist(_:)) , for: .touchUpInside)
                                        if let _ = productInfo["wishlist"] as? NSArray{
                                            cell.menu1.setTitleColor(UIColor.red, for: .normal)
                                        }
                                        else{
                                            cell.menu1.setTitleColor(textColorLight, for: .normal)
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                            
                        }
                        var totalView = ""
                        
                        if let information = productInfo["information"] as? NSDictionary{
                            if let price = information["price"] as? NSDictionary{
                                if let discount = price["discount"] as? CGFloat{
                                    if discount == 1{
                                        
                                        if let productType = productInfo["product_type"] as? String{
                                            if productType == "grouped"{
                                                
                                                cell.actualPrice1.text = NSLocalizedString("Start at:", comment: "")
                                                cell.actualPrice1.sizeToFit()
                                            }
                                            else{
                                                if let views = price["discounted_amount"] as? Double{
                                                    cell.discountedPrice1.isHidden = false
                                                    cell.discountedPrice1.frame.origin.x = 5
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(currency)"
                                                    totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.discountedPrice1.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.discountedPrice1.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.discountedPrice1.text = "\(totalView)"
                                                    }
                                                    cell.discountedPrice1.sizeToFit()
                                                }
                                            }
                                        }
                                        if let ratingAvg = price["price"] as? Double{
                                            
                                            cell.actualPrice1.isHidden = false
                                            cell.actualPrice1.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice1) + 5
                                            var ratingView = ""
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                            cell.actualPrice1.text = "\(ratingView)"
                                            cell.actualPrice1.sizeToFit()
                                            cell.actualPrice1.frame.size.width = cell.actualPrice1.bounds.width
                                            let viewBorder1 = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice1.frame.size.width, height: 1))
                                            viewBorder1.backgroundColor = UIColor.black
                                            viewBorder1.tag = 1003
                                            cell.actualPrice1.addSubview(viewBorder1)
                                            
                                        }
                                        
                                    }
                                    else{
                                        cell.discountedPrice1.isHidden = true
                                        for ob in cell.actualPrice1.subviews{
                                            if ob.tag == 1003 {
                                                ob.removeFromSuperview()
                                            }
                                            
                                            
                                        }
                                        if let views = price["price"] as? Double{
                                            cell.actualPrice1.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                            if let productType = productInfo["product_type"] as? String{
                                                if productType == "grouped"{
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                            
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                        
                                                    }
                                                }
                                                else{
                                                    
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice1.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice1.text = "\(totalView)"
                                                    }
                                                    
                                                }
                                            }
                                            cell.actualPrice1.sizeToFit()
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                        /*
                        
                        if let information = productInfo["information"] as? NSDictionary{
                            if let price = information["price"] as? NSDictionary{
                                if let discount = price["discount"] as? CGFloat{
                                    if discount == 1{
                                        if let productType = productInfo["product_type"] as? String{
                                            if productType == "grouped"{
                                                
                                                cell.actualPrice1.text = NSLocalizedString("Start at:", comment: "")
                                                cell.actualPrice1.sizeToFit()
                                            }
                                            else{
                                                if let views = price["discounted_amount"] as? Int{
                                                    cell.actualPrice1.isHidden = false
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(currency)"
                                                    totalView += formatter.string(from: NSNumber( value: views))! // $123"
                                                    
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice1.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice1.text = "\(totalView)"
                                                    }
                                                    
                                                    cell.actualPrice1.sizeToFit()
                                                }
                                            }
                                        }
                                        if let ratingAvg = price["price"] as? Float{
                                            cell.discountedPrice1.isHidden = false
                                            cell.discountedPrice1.frame.origin.x = getRightEdgeX(inputView: cell.actualPrice1) + 5
                                            var ratingView = ""
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            ratingView += formatter.string(from: NSNumber( value: ratingAvg))! // $123"
                                            cell.discountedPrice1.text = "\(ratingView)"
                                            
                                            let viewBorder1 = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice1.frame.size.width, height: 1))
                                            viewBorder1.backgroundColor = UIColor.black
                                            viewBorder1.tag = 1002
                                            cell.discountedPrice1.addSubview(viewBorder1)
                                            cell.discountedPrice1.sizeToFit()
                                        }
                                        
                                    }
                                    else{
                                        cell.discountedPrice1.isHidden = true
                                        for ob in cell.actualPrice1.subviews{
                                            if ob.tag == 1002 {
                                                ob.removeFromSuperview()
                                            }
                                            
                                            
                                        }
                                        if let views = price["price"] as? Float{
                                            cell.actualPrice1.isHidden = false
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                            if let productType = productInfo["product_type"] as? String{
                                                if productType == "grouped"{
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                    }

                                                    
                                                }
                                                else{
                                                    
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            cell.actualPrice1.text = "\(totalView)*"
                                                        }
                                                        else{
                                                            cell.actualPrice1.text = "\(totalView)"
                                                        }
                                                    }
                                                    else{
                                                        cell.actualPrice1.text = "\(totalView)"
                                                    }
                                                    
                                                }
                                                
                                            }
                                            cell.actualPrice1.sizeToFit()
                                        }
                                    }
                                }
                            }
                        }
                       // check
 */
                    }
                    
                }
                else{
                    cell.contentSelection1.isHidden = true
                    cell.productImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                    cell.ratings1.isHidden = true
                    cell.discountedPrice1.isHidden = true
                    cell.actualPrice1.isHidden = true
                    cell.descriptionView1.isHidden = true
                }
                
                return cell
            }
        }
            
        else {
            
            let cell = categoryTableView.dequeueReusableCell(withIdentifier: "Cellone") as! CategoryTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.blue
            cell.DiaryName.isHidden = false
            cell.DiaryName1.isHidden = false
            cell.classifiedImageView.frame.size.height = 155
            cell.backgroundColor = UIColor.clear
            var index:Int!
            index = indexPath.row * 2
            
            
            if categoryResponse.count > index
            {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.DiaryName.isHidden = false
                
                if let imageInfo = categoryResponse[index] as? NSDictionary
                {
                    if imageInfo["images"] != nil
                    {
                        
                        if let imagedic = imageInfo["images"] as? NSDictionary
                        {
                            if let url = NSURL(string: imagedic["image"] as! String)
                            {
                                cell.classifiedImageView.kf.indicatorType = .activity
                                (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    // LHS
                    cell.DiaryName.text = imageInfo["category_name"] as? String
                    cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(ProductsViewPage.showSubCategory(_:)), for: .touchUpInside)
                    
                    
                    
                }
                
                
            }
            else
            {
                cell.contentSelection.isHidden = true
                cell.classifiedImageView.isHidden = true
                cell.DiaryName.isHidden = true
                
                
                
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.DiaryName1.isHidden = true
                
                
            }
            if categoryResponse.count > (index + 1)
            {
                cell.contentSelection1.isHidden = false
                cell.classifiedImageView1.isHidden = false
                cell.DiaryName1.isHidden = false
                
                
                //cell.classifiedImageView1.image = nil
                if let imageInfo = categoryResponse[index + 1] as? NSDictionary
                {
                    if imageInfo["images"] != nil
                    {
                        
                        if let imagedic = imageInfo["images"] as? NSDictionary
                        {
                            
                            if let url = NSURL(string: imagedic["image"] as! String)
                            {
                                cell.classifiedImageView1.kf.indicatorType = .activity
                                (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.classifiedImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                        }
                    }
                    
                    
                    cell.DiaryName1.text = imageInfo["category_name"] as? String
                    cell.contentSelection1.tag = index+1
                    cell.contentSelection1.addTarget(self, action: #selector(ProductsViewPage.showSubCategory(_:)), for: .touchUpInside)
                }
                
            }
            else
            {
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.DiaryName1.isHidden = true
                
            }
            
            
            return cell
        }
    }
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 2
        {
            
            if scrollView.contentOffset.x>30
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of:UIButton.self)
                    {
                        if ob.tag == 103
                        {
                            
                            (ob as! UIButton).alpha = 1.0
                            
                        }
                        
                    }
                }
                
            }
            else
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of:UIButton.self)
                    {
                        if ob.tag == 103
                        {
                            
                            (ob as! UIButton).alpha = 0.4
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
        
        if updateScrollFlag{
            // Check for Page Number for Browse Page
            
            if productBrowseType == 0{
                let scrollOffset = scrollView.contentOffset.y
                
                let scrollViewHeight = scrollView.frame.size.height / 2

                
                if (scrollOffset > 60.0){
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        // move up
                        
                        self.sort.fadeIn()
                        self.filter.fadeIn()
                        if logoutUser == false{
                            productTableView.frame.size.height = view.bounds.height-(ButtonHeight+10+TOPPADING + ButtonHeight )-(tabBarHeight)
                        }
                        else{
                            productTableView.frame.size.height = view.bounds.height-(ButtonHeight+TOPPADING+10+ButtonHeight )-(tabBarHeight)
                        }
                        
                    }
                    else if ((self.lastContentOffset < scrollView.contentOffset.y) && (scrollView.contentOffset.y < scrollViewHeight - 5 )){
                        // move down
                        self.sort.fadeOut()
                        self.filter.fadeOut()
                        if logoutUser == false{
                            productTableView.frame.size.height = view.bounds.height-(ButtonHeight+10+TOPPADING )-(tabBarHeight)
                        }
                        else{
                            productTableView.frame.size.height = view.bounds.height-(TOPPADING)-(tabBarHeight)
                        }
                    }
                    
                    // update the new position acquired
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    
                }
                
                
                
            }
//            else if productBrowseType == 1
//            {
//                if categoryTableView.contentOffset.y >= categoryTableView.contentSize.height - categoryTableView.bounds.size.height{
//                    if (!isPageRefresing  && limit*pageNumber < totalItems)
//                    {
//                        if reachability.connection != .none
//                        {
//                            updateScrollFlag = false
//                            pageNumber += 1
//                            isPageRefresing = true
//                            if searchDic.count == 0{
//                                browseEntries()
//                            }
//                        }
//                    }
//
//                }
//
//            }
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Page
                
                if productBrowseType == 0{
               
//                    if productTableView.contentOffset.y >= productTableView.contentSize.height - productTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems){
                            if reachability.connection != .none {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                productTableView.tableFooterView?.isHidden = false
                              //  if searchDic.count == 0{
                                    if adsType_product == 2 || adsType_product == 4{
                                        delay(0.1) {
                                            self.checkforAds()
                                        }
                                    }
                                    browseEntries()
                              //  }
                            }
                        }
                        else
                        {
                            productTableView.tableFooterView?.isHidden = true
                    }
                        
                   // }
                }
                else if productBrowseType == 1
                {
//                    if categoryTableView.contentOffset.y >= categoryTableView.contentSize.height - categoryTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if reachability.connection != .none
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                categoryTableView.tableFooterView?.isHidden = false
                             //   if searchDic.count == 0{
                                    browseEntries()
                              //  }
                            }
                        }
                        else
                        {
                            categoryTableView.tableFooterView?.isHidden = true
                    }
                        
                 //   }
                    
                }
                
            }
            
        }
        
    }
    
    
    // After click on particular products redirect to Product Profile
    @objc func showProduct( _ sender: UIButton){
        if let productInfo = productResponse[sender.tag] as? NSDictionary {
            let product_id =   productInfo["product_id"] as? Int
            if(productInfo["allow_to_view"] as! Int == 1){
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id!)
            }else{
                self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            }
        }
    }
    
    // After Click on Search
    @objc func searchItem(){
        let presentedVC = ProductSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        Formbackup.removeAllObjects()
        let url : String = "sitestore/product/product-search-form"
        loadFilter(url)
    }
    
    
    // Category Details after Click On Particular Category
    @objc func showSubCategory( _ sender:UIButton)
    {
        var categoryInfo:NSDictionary!
        categoryInfo = categoryResponse[sender.tag] as! NSDictionary
        let presentedVC = ProductCategoriesDetailViewController()
        presentedVC.categoryType = "products"
        presentedVC.subjectId = categoryInfo["category_id"] as! Int
        presentedVC.tittle = categoryInfo["category_name"] as! String
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    
    // Sort the products according to options coming
    @objc func sorting()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for (k,v) in sortingDictionary{
            if v as! String != ""{
                alertController.addAction(UIAlertAction(title: (v as! String), style: UIAlertActionStyle.default, handler:{ (UIAlertAction) -> Void in
                    self.sortingString = k as! String
                    self.pageNumber = 1
                    self.showSpinner = true
                    self.browseEntries()
                }))
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x:view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    // Filter the products
    @objc func filters(){
        searchDic.removeAll(keepingCapacity: false)
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "products"
            presentedVC.url = "sitestore/product/product-search-form"
            presentedVC.contentType = "products"
            presentedVC.stringFilter = ""
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "sitestore/product/product-search-form"
            presentedVC.serachFor = "products"
            presentedVC.url = "sitestore/product/product-search-form"
            presentedVC.contentType = "products"
            presentedVC.stringFilter = ""
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    // Add products in  Wishlist
    @objc func addToWishlist( _ sender : UIButton){
        var productInfo:NSDictionary!
        productInfo = productResponse[sender.tag] as! NSDictionary
        let product_id =   productInfo["product_id"] as! Int
        if let menu = productInfo["menu"] as? NSArray{
            for menuitem in menu{
                let menuitem = menuitem as! NSDictionary
                if menuitem["name"] as! String == "wishlist"{
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                    presentedVC.contentType = "product wishlist"
                    presentedVC.url = menuitem["url"] as! String
                    var tempDic = NSDictionary()
                    tempDic = ["product_id" : "\(product_id)"]
                    presentedVC.param = tempDic
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
            }
        }
    }
    
    // Show all products that are in cart
    @objc func showCart()
    {
        let presentedVC = ManageCartViewController()
        navigationController?.pushViewController(presentedVC, animated: true)
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
    // Pass the isSelected object to the new view controller.
    }
    */
    
}
