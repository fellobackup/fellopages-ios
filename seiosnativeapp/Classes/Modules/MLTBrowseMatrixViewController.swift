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
//  MLTBrowseMatrixViewController.swift
//  seiosnativeapp
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions

var addvideo_click : Int = 0
var mltToggleView : Bool = false

class MLTBrowseMatrixViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var editListingID:Int = 0                       // Edit listingID
    let mainView = UIView()
    var showSpinner = true                          // not show spinner at pull to refresh
    var listingsResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                     // For Pagination
    var listingsTableView:UITableView!              // TAbleView to show the Classified Contents
    var myListing:UIButton!
    var refresher:UIRefreshControl!                 // Pull to refresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                     // Paginatjion Flag
    var dynamicHeight:CGFloat = 160                 // Dynamic Height fort for Cell
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    //    var imageCache = [String:UIImage]()
    //    var imageCache1 = [String:UIImage]()
    var user_id : Int!
    var fromTab : Bool! = false
    var countListTitle : String!
    var scrollView = UIScrollView()
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var fromSearch: Bool!
    var browseOrMyListings = true               // True for Browse Listings & False for My Listings
    var listingTypeId:Int!
    var viewType : Int!
    var listingName : String!
    var listingContentName : String!
    var isUserInteractionEnabled : Bool!
    var profileCurrencySymbol : String!
    var listingSeeAllFilter: UIButton!
    var showListingType: String! = ""
    var responseCache = [String:AnyObject]()
    
    // AdMob Variable
    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var Totalrowcount = 0
    var isnativeAd:Bool = true
    
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
    var path = ""
    
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var navtitle : UILabel!
    var Adiconimageview : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var nativeAdArray = [AnyObject]()
    var adsImage : UIImageView!
    
    var adsCellheight:CGFloat = 250.0
    
    var packagesEnabled:Int! = 0
    var username : String = ""
    var timerFB = Timer()
    var btnFloaty = UIButton()
    var dashboardMenuId : Int = 0
    var filterTitle = ""
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var targetToggleValue : Int = 1
    var targetSeeAllValue : Int = 1
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if fromTab == false {
            if (self.tabBarController?.selectedIndex == 1 ) ||  (self.tabBarController?.selectedIndex == 2) || ( self.tabBarController?.selectedIndex == 3 ) {
                setDynamicTabValue()
            }
            self.navigationItem.hidesBackButton = true
        }
        
        
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        isUserInteractionEnabled = true
        listingUpdate = true
        globFilterValue = ""
        category_filterId = nil
        
        setNavigationImage(controller: self)
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        if showOnlyMyContent == false
        {
            self.navigationItem.hidesBackButton = true
            createScrollableListingMenu()
        }
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listings entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.sizeToFit()
        self.info.numberOfLines = 0
        self.info.center = self.view.center
        self.info.backgroundColor = bgColor
        self.mainView.addSubview(self.info)
        self.info.isHidden = true
        
        if showOnlyMyContent == true {
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTBrowseMatrixViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        self.navigationItem.hidesBackButton = true
        
        
        // Initialize Classified Table
        if tabBarHeight > 0{
            listingsTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            listingsTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        listingsTableView.register(ClassifiedTableViewCell.self, forCellReuseIdentifier: "Cell")
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.backgroundColor = UIColor.clear
        listingsTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingsTableView.estimatedRowHeight = 0
            listingsTableView.estimatedSectionHeaderHeight = 0
            listingsTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(listingsTableView)
        
        listingSeeAllFilter = createButton(CGRect(x: 10 ,y: 15,width: 20, height: 30),title:"See All" , border: false, bgColor: false,textColor: textColorPrime)
        listingSeeAllFilter.isHidden = true
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MLTBrowseMatrixViewController.refresh), for: UIControlEvents.valueChanged)
        listingsTableView.addSubview(refresher)
        
        
        scrollView.isUserInteractionEnabled = false
        
        if logoutUser == true || showOnlyMyContent == true{
            if showOnlyMyContent == true{
                listingSeeAllFilter.isHidden = true
                listingsTableView.frame.origin.y = TOPPADING
                listingsTableView.frame.size.height = view.bounds.height - (TOPPADING) - tabBarHeight
            }
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(MLTBrowseMatrixViewController.cancelSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        listingsTableView.tableFooterView = footerView
        listingsTableView.tableFooterView?.isHidden = true
        
        self.btnFloaty = UIButton(frame:CGRect(x:self.view.bounds.width-70, y:self.view.bounds.height-(tabBarHeight + 70), width:50, height:50))
        self.btnFloaty.layer.masksToBounds = false
        self.btnFloaty.shadowColors = UIColor.gray
        self.btnFloaty.shadowOffsets = CGSize(width:0.1,height:0.1)
        self.btnFloaty.shadowOpacitys = 1.0
        self.btnFloaty.layer.borderWidth = 1
        self.btnFloaty.layer.borderColor = buttonColor.cgColor
        self.btnFloaty.layer.cornerRadius = self.btnFloaty.frame.height/2
        
        sitereviewMenuDictionary = dashboardMenu[dashboardMenuId] as! NSDictionary
        self.btnFloaty.setTitle("\u{f0db}", for: UIControlState.normal)
        if sitereviewMenuDictionary != nil{
            let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
            if anotherViewBrowseType != 0 {
                var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
                
                if browseType == 3
                {
                    browseType = anotherViewBrowseType
                }
                
                if browseType == 1
                {
                    self.btnFloaty.setTitle("\u{f0ca}", for: UIControlState.normal)
                }
                else if browseType == 2
                {
                    self.btnFloaty.setTitle("\u{f00a}", for: UIControlState.normal)
                }
                else if browseType == 3
                {
                    self.btnFloaty.setTitle("\u{f0db}", for: UIControlState.normal)
                }
                else
                {
                    self.btnFloaty.setTitle("\u{f279}", for: UIControlState.normal)
                }
            }
        }
        self.btnFloaty.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZELarge)
        self.btnFloaty.backgroundColor = buttonColor
        self.btnFloaty.clipsToBounds = true
        self.btnFloaty.addTarget(self, action: #selector(MLTBrowseMatrixViewController.toggleView), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.btnFloaty)
        
        if browseOrMyListings == false || showOnlyMyContent == true
        {
            self.btnFloaty.isHidden = true
        }
        
        self.Updatetitle()
        
        if adsType_mltmatrix != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(MLTBrowseMatrixViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
         if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            return 4
        }
         if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            return 2
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            return 1
        }
        return 0
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        coachMark = coachMarksController.helper.makeCoachMark()
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
         if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
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
            
        case 2:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width/2
            let radious : Int = 35
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 3:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 45.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            switch(index) {
                
            case 0:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width/2
                let radious : Int = 35
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
            case 1:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width - 45.0
                let radious : Int = 40
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
                
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            switch(index) {
                
            case 0:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width - 45.0
                let radious : Int = 40
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
                
                
           
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
            
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
        
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = " 1/4"
                coachViews.bodyView.nextLabel.text = "Next "
                
            case 1:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = " 2/4"
                coachViews.bodyView.nextLabel.text = "Next "
            case 2:
                coachViews.bodyView.hintLabel.text = "Use Filters to search specific results."
                coachViews.bodyView.countTourLabel.text = " 3/4"
                coachViews.bodyView.nextLabel.text = "Next "
            case 3:
                coachViews.bodyView.hintLabel.text = "Click here to Switch Listings Views."
                coachViews.bodyView.countTourLabel.text = " 4/4"
                coachViews.bodyView.nextLabel.text = "Finish "
                
                
            default: break
            }
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        }
         if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            switch(index) {
    
                
            case 0:
                coachViews.bodyView.hintLabel.text = "Click here to Switch Listings Views."
                coachViews.bodyView.countTourLabel.text = " 1/1"
                coachViews.bodyView.nextLabel.text = "Finish "
                
                
                
            default: break
            }
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = "Use Filters to search specific results."
                coachViews.bodyView.countTourLabel.text = " 1/2"
                coachViews.bodyView.nextLabel.text = "Next "
                
            case 1:
                coachViews.bodyView.hintLabel.text = "Click here to Switch Listings Views."
                coachViews.bodyView.countTourLabel.text = " 2/2"
                coachViews.bodyView.nextLabel.text = "Finish "
                
                
                
            default: break
            }
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
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
        
        if let name = defaults.object(forKey: "showTogglePluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showTogglePluginAppTour") != nil {
                
                self.targetToggleValue = name as! Int
                
                
            }
            
        }
        
        if let name = defaults.object(forKey: "showSeeAllPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSeeAllPluginAppTour") != nil {
                
                self.targetSeeAllValue = name as! Int
                
                
            }
            
        }
        
        
        
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
       
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            
            
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            
            
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        IsRedirctToProfile()
        if let button = self.scrollView.viewWithTag(100) as? UIButton
        {
            if browseOrMyListings == true {
                listingSeeAllFilter.isHidden = false
                button.setSelectedButton()
            }
        }
        if let button = self.scrollView.viewWithTag(101) as? UIButton
        {
            button.setUnSelectedButton()
        }
        
        if showOnlyMyContent == true{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
        }
        else{
            Customnavigation()
        }
    }
    
    // Check for Listings Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
        if self.tabBarController?.selectedIndex == 1 || self.tabBarController?.selectedIndex == 2 || self.tabBarController?.selectedIndex == 3 {
            
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                
            }
        }
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }
        
        
        
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if listingUpdate == true {
            listingUpdate = false
            pageNumber = 1
            showSpinner = true
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }else{
            listingsTableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        listingsTableView.tableFooterView?.isHidden = true
        removeNavigationViews(controller: self)
        globalCatg = ""
        globFilterValue = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
        self.title = ""
        
    }
    
    func IsRedirctToProfile(){
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            if sitevideoPluginEnabled_mlt != 1 && addvideo_click != 1
            {
                SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : createResponse["listingtype_id"] as! Int , listingIdValue : createResponse["listing_id"] as! Int , viewTypeValue : viewType)
            }
            else
            {
                addvideo_click = 0
            }
        }
        
    }
    
    func Customnavigation()
    {
        removeNavigationViews(controller: self)
        if let navigationBar = self.navigationController?.navigationBar
        {
            self.title = ""
            let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/2))/2, y:-5, width: navigationBar.frame.width/2, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            
            if showOnlyMyContent == false {
                navtitle.text = NSLocalizedString(listingName,  comment: "")
            }
            else{
                navtitle.text = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            }
            navtitle.tag = 400
            
            
            //Filter option
            listingSeeAllFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 18,width: navigationBar.frame.width/3, height: 30),title:"" , border: false, bgColor: false,textColor: textColorLight)
            listingSeeAllFilter.isEnabled = true
            listingSeeAllFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            listingSeeAllFilter.addTarget(self, action: #selector(MLTBrowseMatrixViewController.showListingFilterOptions(_:)), for: .touchUpInside)
            listingSeeAllFilter.tag = 400
            let fitertext = "See All" + " " + searchFilterIcon
            if  filterTitle == "" {
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            }
            else{
                listingSeeAllFilter.setTitle(filterTitle, for: .normal)
            }
            
            navigationBar.addSubview(listingSeeAllFilter)
            navigationBar.addSubview(navtitle)
            
        }
    }
    
    func Updatetitle()
    {
        if showOnlyMyContent == true {
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTBrowseMatrixViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            self.navigationItem.title = countListTitle
        }
    }
    
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "showMyListingContent") != nil {
            if let name = defaults.object(forKey: "showMyListingContent")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingId")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
            }
        }
        
        if defaults.object(forKey: "showMyListingContent1") != nil {
            if let name = defaults.object(forKey: "showMyListingContent1")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent1") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName1") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingId1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId1") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType1") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
            }
        }
        
        if defaults.object(forKey: "showMyListingContent2") != nil {
            if let name = defaults.object(forKey: "showMyListingContent2")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent2") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName2") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingId2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId2") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType2") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
            }
        }
        
    }
    
    @objc func checkforAds(){
        nativeAdArray.removeAll()
        if adsType_mltmatrix == 1
        {
            if kFrequencyAdsInCells_mltmatrix > 4 && placementID != ""
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
                        listingsTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_mltmatrix == 0
        {
            if kFrequencyAdsInCells_mltmatrix > 4 && adUnitID != ""
            {
                showNativeAd()
            }
        }
        else if adsType_mltmatrix == 2 {
            checkCommunityAds()
        }
        
    }
    
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if reachability.connection != .none {
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_mltmatrix)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_mltmatrix)"
            
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
                                            self.listingsTableView.reloadData()
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
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControlState())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
                
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(MLTBrowseMatrixViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                     adImageView1.kf.indicatorType = .activity
                    (adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    adImageView1.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(MLTBrowseMatrixViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
        dictionary["type"] =  "\(adsType_mltmatrix)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_mltmatrix)"
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
            if ob.tag == 1005
            {
                (ob as! UIButton).alpha = 1.0
                ob.isUserInteractionEnabled = true
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
        //        {
        //            self.nativeAd = admanager.nextNativeAd
        //            self.fetchAds(self.nativeAd)
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
            
            listingsTableView.reloadData()
            
        }
        
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
        
        //        if ((self.nativeAd) != nil) {
        //            self.nativeAd.unregisterView()
        //        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x: PADING, y: 2*PADING ,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 160))
            
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x: 2*PADING, y: 2*PADING,width: (UIScreen.main.bounds.width - 4*PADING) , height: 160))
            
        }
        self.fbView.backgroundColor = UIColor.white
        self.fbView.tag = 1001001
        
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            adImageView = FBMediaView(frame: CGRect(x: 0, y: 0, width: self.fbView.bounds.width, height: 155))
        }
        else
        {
            adImageView = FBMediaView(frame: CGRect(x: 0 , y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y, width: self.fbView.bounds.width, height: 150))
        }
        self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        let gradient1: CAGradientLayer = CAGradientLayer()
        gradient1.frame = adImageView.frame
        gradient1.colors = [UIColor.clear.cgColor,UIColor.gray.cgColor]
        gradient1.locations = [0.7, 1.0]
        adImageView.layer.insertSublayer(gradient1, at: 0)
        self.fbView.addSubview(adImageView)
        
        adTitleLabel = UILabel(frame: CGRect(x: 5 , y: adImageView.bounds.height + adImageView.frame.origin.y - 40, width: self.fbView.bounds.width-80, height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorLight
        adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        adBodyLabel = UILabel(frame: CGRect(x: 5 , y: adTitleLabel.bounds.height + 10 + adTitleLabel.frame.origin.y, width: self.fbView.bounds.width-80, height: 40))
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        adBodyLabel.isHidden = true
        self.fbView.addSubview(adBodyLabel)
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-70,y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControlState())
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        adCallToActionButton.isHidden = true
        self.fbView.addSubview(adCallToActionButton)
        
        Adiconview = createImageView(CGRect(x: self.fbView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
    }
    
    func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error.localizedDescription)
    }
    
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
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
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
            self.listingsTableView.reloadData()
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
            self.listingsTableView.reloadData()
        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Classified Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Classified Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Height for row at index path
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_mltmatrix > 4 && nativeAdArray.count > 0 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_mltmatrix) == (kFrequencyAdsInCells_mltmatrix)-1))
        {
            if adsType_mltmatrix == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return 430
                }
                return adsCellheight
            }
            else if adsType_mltmatrix == 0
            {
                return 265
            }
            return 160
        }
        return dynamicHeight
    }
    
    // Set Classified Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            rowcount = 2*(kFrequencyAdsInCells_mltmatrix-1)
            if listingsResponse.count > rowcount
            {
                let b = Int(ceil(Float(listingsResponse.count)/2))
                adsCount = b/(kFrequencyAdsInCells_mltmatrix-1)
                if adsCount > 1 || listingsResponse.count%2 != 0
                {
                    adsCount = adsCount/2
                }
                let Totalrowcount = adsCount+b
                if b%(kFrequencyAdsInCells_mltmatrix-1) == 0 && listingsResponse.count % 2 != 0
                {
                    if adsCount%2 != 0
                    {
                        
                        return Totalrowcount - 1
                    }
                }
                else if listingsResponse.count % 2 != 0 && adsCount % 2 == 0
                {
                    
                    return Totalrowcount - 1
                }
                
                return Totalrowcount
            }
            else
            {
                
                return Int(ceil(Float(listingsResponse.count)/2))
            }
            
        }
        return Int(ceil(Float(listingsResponse.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_mltmatrix > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_mltmatrix) == (kFrequencyAdsInCells_mltmatrix)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            listingsTableView.register(NativeClassifiedCell.self, forCellReuseIdentifier: "Cell1")
            let cell = listingsTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeClassifiedCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_mltmatrix-1)
            
            for _ in stride(from: 0, to: 10, by: 1){
                Adcount = Adcount%10
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
                let adcount = row/kFrequencyAdsInCells_mltmatrix
                var index:Int!
                index = (row * 2) - adcount
                if listingsResponse.count > (index){
                    cell.contentSelection1.isHidden = false
                    cell.classifiedImageView1.isHidden = false
                    cell.classifiedName1.isHidden = false
                    
                    
                    cell.classifiedImageView1.image = nil
                    if let photoInfo = listingsResponse[index] as? NSDictionary {
                        
                        if let url = URL(string: photoInfo["image"] as! NSString as String){
                            
                            cell.classifiedImageView1.kf.indicatorType = .activity
                            (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.classifiedImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                            
                        }
                        
                        if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                            cell.featuredLabel1.isHidden = false
                            cell.featuredLabel1.frame.size.width = 80
                        }else{
                            cell.featuredLabel1.isHidden = true
                        }
                        
                        if photoInfo["sponsored"] != nil && photoInfo["sponsored"] as! Int == 1 {
                            
                            cell.sponsoredLabel1.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
                            if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                                cell.sponsoredLabel1.frame = CGRect(x: 0, y: 25, width: 80, height: 20)
                            }
                            cell.sponsoredLabel1.isHidden = false
                        }else{
                            cell.sponsoredLabel1.isHidden = true
                        }
                        
                        let name1 = photoInfo["title"] as? String
                        
                        let tempString1 = name1! as NSString
                        
                        var value1 : String
                        if tempString1.length > 22{
                            
                            value1 = tempString1.substring(to: 19)
                            value1 += NSLocalizedString("...",  comment: "")
                        }else{
                            value1 = "\(tempString1)"
                        }
                        
                        cell.classifiedName1.text = value1
                        cell.classifiedName1.font = UIFont(name: fontName, size: FONTSIZENormal)
                        
                        let location = photoInfo["location"] as? String
                        if location != "" && location != nil
                        {
                            cell.classifiedName1.frame.origin.y = 100
                            cell.lblLoc1.frame.origin.y = 125
                            cell.lblLoc1.isHidden = false
                            
                            cell.lblLoc1.text = locationIcon + "  " + location!
                        }
                        else
                        {
                            cell.classifiedName1.frame.origin.y = 125
                            cell.lblLoc1.isHidden = true
                        }
                        
                        listingContentName = photoInfo["title"] as! String
                        
                        //                        cell.contentSelection1.tag = photoInfo["listing_id"] as! Int
                        cell.contentSelection1.tag = index
                        if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                            cell.contentSelection1.addTarget(self, action: #selector(MLTBrowseMatrixViewController.showListing(_:)), for: .touchUpInside)
                        }else{
                            cell.contentSelection1.addTarget(self, action: #selector(MLTBrowseMatrixViewController.noRedirection(_:)), for: .touchUpInside)
                        }
                        
                        if browseOrMyListings {
                            
                            cell.menu1.isHidden = true
                        }else{
                            // Set MenuAction
                            
                            cell.menu1.addTarget(self, action:#selector(MLTBrowseMatrixViewController.showListingMenu(_:)) , for: .touchUpInside)
                            cell.menu1.isHidden = false
                            cell.featuredLabel1.isHidden = true
                            cell.sponsoredLabel1.isHidden = true
                            
                        }
                        
                        if(photoInfo["closed"] as! Int == 1){
                            cell.closeIconView1.frame = CGRect(x: cell.classifiedImageView1.bounds.width/2 - cell.classifiedImageView1.bounds.width/4 , y: cell.classifiedImageView1.bounds.height/2 - cell.classifiedImageView1.bounds.height/4, width: cell.classifiedImageView1.bounds.width/2, height: cell.classifiedImageView1.bounds.height/2)
                            cell.closeIconView1.isHidden = false
                            cell.closeIconView1.text = "\(closedIcon)"
                            cell.closeIconView1.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView1.bounds.width/4)
                        }
                        else{
                            cell.closeIconView1.isHidden = true
                        }
                        
                    }
                    
                }
                    
                else{
                    cell.contentSelection1.isHidden = true
                    cell.classifiedImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                }
                
            }
            else{
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
            }
            return cell
            
        }
        else
        {
            
            if kFrequencyAdsInCells_mltmatrix > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_mltmatrix)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClassifiedTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            var index:Int!
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if (kFrequencyAdsInCells_mltmatrix > 4 && nativeAdArray.count > 0)
                {
                    let adcount = row/(kFrequencyAdsInCells_mltmatrix-1)
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
            
            if listingsResponse.count > index {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.classifiedName.isHidden = false
                cell.classifiedImageView.image = nil
                
                
                if let photoInfo = listingsResponse[index] as? NSDictionary {
                    // LHS
                    if let url = URL(string: photoInfo["image"] as! NSString as String){
                        cell.classifiedImageView.kf.indicatorType = .activity
                        (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    
                    if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                        cell.featuredLabel.isHidden = false
                        cell.featuredLabel.frame.size.width = 80
                    }else{
                        cell.featuredLabel.isHidden = true
                    }
                    
                    if photoInfo["sponsored"] != nil && photoInfo["sponsored"] as! Int == 1{
                        
                        cell.sponsoredLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
                        if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                            cell.sponsoredLabel.frame = CGRect(x: 0, y: 25, width: 80, height: 20)
                        }
                        cell.sponsoredLabel.isHidden = false
                    }else{
                        cell.sponsoredLabel.isHidden = true
                    }
                    
                    if photoInfo["price"] != nil && (photoInfo["price"] as! Double > 0 ){
                        
                        if photoInfo["currency"] != nil{
                            let currencySymbol = getCurrencySymbol(photoInfo["currency"] as! String)
                            profileCurrencySymbol = currencySymbol
                        }
                    }
                    
                    let name = photoInfo["title"] as? String
                    let tempString = name! as NSString
                    var value : String
                    
                    if tempString.length > 22{
                        
                        value = tempString.substring(to: 19)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(tempString)"
                    }
                    
                    cell.classifiedName.text = value
                    
                    let location = photoInfo["location"] as? String
                    if location != "" && location != nil
                    {
                        cell.classifiedName.frame.origin.y = 100
                        cell.lblLoc.frame.origin.y = 125
                        cell.lblLoc.isHidden = false
                        
                        cell.lblLoc.text = locationIcon + "  " + location!
                    }
                    else
                    {
                        cell.classifiedName.frame.origin.y = 125
                        cell.lblLoc.isHidden = true
                    }
                    
                    //                    cell.contentSelection.tag = photoInfo["listing_id"] as! Int
                    listingContentName = photoInfo["title"] as! String
                    cell.contentSelection.tag = index
                    if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                        cell.contentSelection.addTarget(self, action: #selector(MLTBrowseMatrixViewController.showListing(_:)), for: .touchUpInside)
                    }else{
                        cell.contentSelection.addTarget(self, action: #selector(MLTBrowseMatrixViewController.noRedirection(_:)), for: .touchUpInside)
                    }
                    if browseOrMyListings {
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                    }else{
                        // Set MenuAction
                        cell.menu.addTarget(self, action:#selector(MLTBrowseMatrixViewController.showListingMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu1.addTarget(self, action:#selector(MLTBrowseMatrixViewController.showListingMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                        cell.featuredLabel.isHidden = true
                        cell.sponsoredLabel.isHidden = true
                        
                    }
                    
                    if(photoInfo["closed"] as! Int == 1){
                        cell.closeIconView.frame = CGRect(x: cell.classifiedImageView.bounds.width/2 - cell.classifiedImageView.bounds.width/4 , y: cell.classifiedImageView.bounds.height/2 - cell.classifiedImageView.bounds.height/4, width: cell.classifiedImageView.bounds.width/2, height: cell.classifiedImageView.bounds.height/2)
                        cell.closeIconView.isHidden = false
                        cell.closeIconView.text = "\(closedIcon)"
                        cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView.bounds.width/4)
                    }
                    else{
                        cell.closeIconView.isHidden = true
                    }
                }
                
            }else{
                cell.contentSelection.isHidden = true
                cell.classifiedImageView.isHidden = true
                cell.classifiedName.isHidden = true
                
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
            }
            
            if listingsResponse.count > (index + 1){
                cell.contentSelection1.isHidden = false
                cell.classifiedImageView1.isHidden = false
                cell.classifiedName1.isHidden = false
                
                cell.classifiedImageView1.image = nil
                if let photoInfo = listingsResponse[index + 1] as? NSDictionary {
                    
                    if let url = URL(string: photoInfo["image"] as! NSString as String){
                        
                        cell.classifiedImageView1.kf.indicatorType = .activity
                        (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                        
                    }
                    
                    if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                        cell.featuredLabel1.isHidden = false
                        cell.featuredLabel1.frame.size.width = 80
                    }else{
                        cell.featuredLabel1.isHidden = true
                    }
                    
                    if photoInfo["sponsored"] != nil && photoInfo["sponsored"] as! Int == 1{
                        
                        cell.sponsoredLabel1.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
                        if photoInfo["featured"] != nil && photoInfo["featured"] as! Int == 1{
                            cell.sponsoredLabel1.frame = CGRect(x: 0, y: 25, width: 80, height: 20)
                        }
                        cell.sponsoredLabel1.isHidden = false
                    }else{
                        cell.sponsoredLabel1.isHidden = true
                    }
                    
                    let name1 = photoInfo["title"] as? String
                    let tempString1 = name1! as NSString
                    var value1 : String
                    
                    if tempString1.length > 22{
                        
                        value1 = tempString1.substring(to: 19)
                        value1 += NSLocalizedString("...",  comment: "")
                    }else{
                        value1 = "\(tempString1)"
                    }
                    
                    cell.classifiedName1.text = value1
                    let location = photoInfo["location"] as? String
                    if location != "" && location != nil
                    {
                        cell.classifiedName1.frame.origin.y = 100
                        cell.lblLoc1.frame.origin.y = 125
                        cell.lblLoc1.isHidden = false
                        
                        cell.lblLoc1.text = locationIcon + "  " + location!
                    }
                    else
                    {
                        cell.classifiedName1.frame.origin.y = 125
                        cell.lblLoc1.isHidden = true
                    }
                    listingContentName = photoInfo["title"] as! String
                    //                    cell.contentSelection1.tag = photoInfo["listing_id"] as! Int
                    cell.contentSelection1.tag = index + 1
                    if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                        cell.contentSelection1.addTarget(self, action: #selector(MLTBrowseMatrixViewController.showListing(_:)), for: .touchUpInside)
                    }else{
                        cell.contentSelection1.addTarget(self, action: #selector(MLTBrowseMatrixViewController.noRedirection(_:)), for: .touchUpInside)
                    }
                    
                    if browseOrMyListings {
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                    }else{
                        // Set MenuAction
                        cell.menu.addTarget(self, action:#selector(MLTBrowseMatrixViewController.showListingMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu.tag = index
                        cell.menu1.addTarget(self, action:#selector(MLTBrowseMatrixViewController.showListingMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                        cell.menu1.tag = index + 1
                        cell.featuredLabel1.isHidden = true
                        cell.sponsoredLabel1.isHidden = true
                        
                    }
                    
                    if(photoInfo["closed"] as! Int == 1){
                        cell.closeIconView1.frame = CGRect(x: cell.classifiedImageView1.bounds.width/2 - cell.classifiedImageView1.bounds.width/4 , y: cell.classifiedImageView1.bounds.height/2 - cell.classifiedImageView1.bounds.height/4, width: cell.classifiedImageView1.bounds.width/2, height: cell.classifiedImageView1.bounds.height/2)
                        cell.closeIconView1.isHidden = false
                        cell.closeIconView1.text = "\(closedIcon)"
                        cell.closeIconView1.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView1.bounds.width/4)
                    }
                    else{
                        cell.closeIconView1.isHidden = true
                    }
                }
            }
                
            else{
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
            }
            return cell
        }
    }
    
    // MARK:  UISwipeGestureRecognizer
    
    //Handle swipes
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            //print("Swipe Left")
            
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Cancle Search Result for Logout User
    @objc func cancelSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.showSpinner = true
        browseEntries()
    }
    
    // Open Filter Search Form
    func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            listingUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "listings/search-form"
            presentedVC.serachFor = "classified"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    // Create Listing Form
    @objc func addNewListing(){
        //TODO: - Work For Listing Creation
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        else
        {
            if packagesEnabled == 1
            {
                isCreateOrEdit = true
                let presentedVC = PackageViewController()
                presentedVC.contentType = "listings"
                presentedVC.url = "listings/packages"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }else{
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Post A New Listing", comment: "")
                presentedVC.contentType = "listings"
                presentedVC.param = [ : ]
                presentedVC.url = "listings/create"
                presentedVC.listingTypeId = listingTypeId!
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
            }
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if listingsResponse.count != 0{
        if reachability.connection != .none {
            
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            scrollView.isUserInteractionEnabled = true
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        //   }
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK: - Server Connection For Classified Updation
    
    // Index Changed
    func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyListings = true
            self.browseEntries()
        case 1:
            
            browseOrMyListings = false
            self.browseEntries()
        default:
            break;
        }
    }
    
    // Update Listing
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            //            if showOnlyMyContent == true{
            //                browseOrMyListings = false
            //            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            var path = ""
            var parameters = [String:String]()
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
                viewType = globalViewType
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                viewType = globalViewType1
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                viewType = globalViewType2
            }
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyListings = true
            }
            
            // Set Parameters for Browse/myListing
            if browseOrMyListings
            {
                path = "listings"
                if listingOption != nil && listingOption.tag  == 100 {
                    listingSeeAllFilter.isHidden = false
                    listingOption.setSelectedButton()
                }
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "restapilocation": loc, "listing_filter": showListingType]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "restapilocation": loc, "listing_filter": showListingType]
                            
                        }
                    }
                    else
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "restapilocation": defaultlocation, "listing_filter": showListingType]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "restapilocation": defaultlocation, "listing_filter": showListingType]
                            
                        }
                        // listingsTableView.isHidden = true
                    }
                    
                }else{
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "listing_filter": showListingType]
                        
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "listing_filter": showListingType]
                    }
                }
            }else{
                path = "listings/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "getGutterMenu": "1"]
                
            }
            
            if (self.pageNumber == 1){
                self.listingsResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true {
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                        //  showSpinner = false
                        self.listingsResponse = responseCacheArray as! [AnyObject]
                        //  showSpinner = false
                    }
                    self.listingsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            
            if (showSpinner){
                
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
                //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                if isUserInteractionEnabled == false{
                    self.view.isUserInteractionEnabled = false
                }
                
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Classified Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    self.listingsTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.listingsResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if self.browseOrMyListings{
                                if response["response"] != nil {
                                    if let listing = response["response"] as? NSArray {
                                        
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                        
                                        if self.showOnlyMyContent == false {
                                            self.navtitle.text = NSLocalizedString(self.listingName,  comment: "")
                                        }
                                        else{
                                            //                                            let count = response["totalItemCount"] as? Int
                                            //                                            let title = "Products " + "(" + "\(count!)" + ")" + " : " + self.username
                                            //                                            self.countListTitle = title
                                            //                                            self.Updatetitle()
                                        }
                                        
                                        if (self.pageNumber == 1){
                                            self.responseCache["\(path)"] = listing
                                        }
                                    }
                                }
                            }else{
                                if response["listings"] != nil {
                                    if let listing = response["listings"] as? NSArray {
                                        
                                        //                                        if let value = listing[0] as? NSDictionary
                                        //                                        {
                                        //
                                        //                                            sitevideoPluginEnabled_mlt = value["sitevideoPluginEnabled"] as! Int
                                        //                                        }
                                        
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                        if (self.pageNumber == 1){
                                            self.responseCache["\(path)"] = listing
                                        }
                                    }
                                }
                            }
                            
                            if response["packagesEnabled"] != nil
                            {
                                self.packagesEnabled = response["packagesEnabled"] as! Int
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.showOnlyMyContent == false {
                                
                                if (response["canCreate"] as! Bool == true){
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MLTBrowseMatrixViewController.searchItem))
                                    searchItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MLTBrowseMatrixViewController.addNewListing))
                                    addBlog.imageInsets = UIEdgeInsetsMake(0,0, 0, 0)
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    self.showAppTour()
                                }
                                else
                                {
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MLTBrowseMatrixViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                }
                                
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Classified Tabel
                        self.listingsTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.listingsResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listing entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.tag = 1000
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(MLTBrowseMatrixViewController.browseEntries), for: UIControlEvents.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                            self.info.isHidden = false
                            
                            
                        }else{
                            self.refreshButton.isHidden = true
                            self.contentIcon.isHidden = true
                            self.info.isHidden = true
                            
                        }
                        
                        if self.isUserInteractionEnabled == false{
                            self.isUserInteractionEnabled = true
                            self.view.isUserInteractionEnabled = true
                        }
                        
                    }else{
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            scrollView.isUserInteractionEnabled = true
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    
    // MARK:  UIScrollViewDelegate

    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 2
        {
            if scrollView.contentOffset.x>45
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of: UIButton.self)
                    {
                        if ob.tag == 102
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
                    if ob .isKind(of: UIButton.self)
                    {
                        if ob.tag == 102
                        {
                            (ob as! UIButton).alpha = 1.0
                        }
                    }
                }
            }
        }
    }
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Classified
                //                if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        listingsTableView.tableFooterView?.isHidden = false
                        // if searchDic.count == 0{
                        if adsType_mltmatrix == 2 || adsType_mltmatrix == 4{
                            delay(0.1) {
                                self.checkforAds()
                            }
                        }
                        browseEntries()
                        //}
                    }
                }
                else
                {
                    listingsTableView.tableFooterView?.isHidden = true
                }
                
                // }
                
            }
            
        }
        
    }
    
    // Show Listing profile
    @objc func showListing(_ sender: UIButton){
        if let photoInfo = listingsResponse[sender.tag] as? NSDictionary {
            if(photoInfo["closed"] as! Int == 1){
                self.showMessage()
            }
            else
            {
                SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : photoInfo["listing_id"] as! Int , viewTypeValue : viewType)
            }
        }
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Toggle View
    
    @objc func toggleView()
    {
        listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
        sitereviewMenuDictionary = dashboardMenu[dashboardMenuId] as! NSDictionary
        
        let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
        if anotherViewBrowseType != 0 {
            var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
            let viewType = sitereviewMenuDictionary["viewProfileType"] as? Int ?? 0
            
            if browseType == 0 || viewType == 0 {
                return
            }
            
            if browseType == 3
            {
                mltToggleView = true
                browseType = anotherViewBrowseType
            }
            else
            {
                mltToggleView = false
            }
            
            if MLTbrowseOrMyListings == nil{
                MLTbrowseOrMyListings = true
            }
            SiteMltObject().redirectToMltBrowsePage(self, showOnlyMyContent: false, listingTypeIdValue : sitereviewMenuDictionary["listingtype_id"] as! Int , listingNameValue : sitereviewMenuDictionary["headerLabel"] as! String , MLTbrowseorMyListingsValue : MLTbrowseOrMyListings! , browseTypeValue : browseType , viewTypeValue : viewType,dashboardMenuId:dashboardMenuId)
        }
        else
        {
            return
        }
    }
    
    // Searching Items
    @objc func searchItem(){
        let presentedVC = MLTSearchMatrixViewController()
        
        presentedVC.listingTypeId = listingTypeId
        presentedVC.viewSearchType = viewType
        presentedVC.listingSearchName = listingName
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        listingGlobalTypeId = listingTypeId
        Formbackup.removeAllObjects()
        let url : String = "listings/search-form"
        loadFilter(url)
    }
    
    // Stop redirection
    @objc func noRedirection(_ sender: UIButton){
        self.view.makeToast("User not allowed to view this page", duration: 5, position: "bottom")
    }
    
    func showMessage(){
        self.view.makeToast("You do not have permission to view this Classified", duration: 5, position: "bottom")
    }
    // MARK: Create Scrollable Menu
    func createScrollableListingMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        
        if self.tabBarController?.selectedIndex == 1 {
            listingTypeId = globalListingTypeId
            listingName = globalListingName
            viewType = globalViewType
        }
        
        if self.tabBarController?.selectedIndex == 2 {
            listingTypeId = globalListingTypeId1
            listingName = globalListingName1
            viewType = globalViewType1
        }
        
        if self.tabBarController?.selectedIndex == 3 {
            listingTypeId = globalListingTypeId2
            listingName = globalListingName2
            viewType = globalViewType2
        }
        
        if logoutUser == false
        {
            var listingMenu = ["%@", "Categories", "My %@"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            for i in 100 ..< 103
            {
                listingOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: true, selected: false)
                if i == 100 && browseOrMyListings
                {
                    listingOption.setSelectedButton()
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    
                }
                else if i == 102 && !browseOrMyListings{
                    
                    listingOption.setSelectedButton()
                    scrollView.contentOffset = CGPoint(x: menuWidth, y: 0)
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(MLTBrowseMatrixViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor = UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
            }
        }
        else
        {
            var listingMenu = ["Browse %@", "Categories"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)
            for i in 100 ..< 102
            {
                if i == 100
                {   listingOption =  createNavigationButton(CGRect(x: origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: true)
                }else{
                    listingOption =  createNavigationButton(CGRect(x: origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: false)
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(MLTBrowseMatrixViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
            }
        }
        scrollView.contentSize = CGSize(width:menuWidth * 3,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        mainView.addSubview(scrollView)
    }
    
    // MARK: - Listing Selection Action
    @objc func listingSelectOptions(_ sender: UIButton)
    {
        listingBrowseType = sender.tag - 100
        _ = CGFloat((view.bounds.width)/3)
        if listingBrowseType == 1 {
            self.btnFloaty.isHidden = true
            browseOrMyListings = false
            listingSeeAllFilter.isHidden = true
            scrollView.contentOffset.x = 0
        }else if listingBrowseType == 0 {
            self.btnFloaty.isHidden = false
            browseOrMyListings = true
            listingSeeAllFilter.isHidden = false
            scrollView.contentOffset.x = 0
            if showGoogleMapView == true
            {
                showGoogleMapView = false
                let presentedVC = GoogleMapViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuId = dashboardMenuId
                navigationController?.pushViewController(presentedVC, animated: false)
            }
        }else if listingBrowseType == 2 {
            self.btnFloaty.isHidden = true
            browseOrMyListings = false
            listingSeeAllFilter.isHidden = false
            scrollView.contentOffset.x = 0
        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        for ob in scrollView.subviews
        {
            if ob .isKind(of: UIButton.self)
            {
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
        pageNumber = 1
        if listingBrowseType == 1 {
            browseOrMyListings = true
            showOnlyMyContent = false
            let presentedVC = CategoryBrowseViewController()
            presentedVC.listingName = listingName
            presentedVC.listingTypeId = self.listingTypeId
            presentedVC.browseType = 3
            presentedVC.dashboardMenuId = dashboardMenuId
            presentedVC.viewType = viewType
            navigationController?.pushViewController(presentedVC, animated: false)
        }else{
            listingsTableView.tableFooterView?.isHidden = true
            scrollView.isUserInteractionEnabled = false
            self.showSpinner = true
            browseEntries()
        }
    }
    
    // SHOW GUTTER MENUS ON MY LISTINGS PAGE
    @objc func showListingMenu(_ sender:UIButton){
        
        var listingInfo:NSDictionary
        listingInfo = listingsResponse[sender.tag] as! NSDictionary
        editListingID = listingInfo["listing_id"] as! Int
        
        let menuOption = listingInfo["gutterMenus"] as! NSArray
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for menu in menuOption{
            if let menuItem = menu as? NSDictionary{
                let titleString = menuItem["name"] as! String
                if titleString.range(of: "delete") != nil{
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.destructive , handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                        case "delete":
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this listing entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                self.performListingMenuAction(menuItem["url"] as! String)
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
                        
                        switch(condition){
                            
                        case "videoCreate" :
                            addvideo_click = 1
                            manage_advvideoshow = true
                            isCreateOrEdit = true
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                            presentedVC.contentType = "Advanced Video"
                            
                            if sitevideoPluginEnabled_mlt == 1
                            {
                                let subject_type = menuItem["subject_type"] as! String
                                let subject_id =   menuItem["subject_id"] as! Int
                                presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                            }
                            let url = menuItem["url"] as! String
                            presentedVC.url = url
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:true, completion: nil)
                            
                        case "edit":
                            isCreateOrEdit = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.contentType = "listings"
                            var editFormTitle = "Edit Listing"
                            if menuItem["label"] != nil{
                                editFormTitle = menuItem["label"] as! String
                            }
                            presentedVC.formTitle = NSLocalizedString(editFormTitle, comment: "")
                            presentedVC.listingTypeId = self.listingTypeId
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                            
                        case "addPhotos":
                            let presentedVC = UploadPhotosViewController()
                            presentedVC.contentType = "sitereview_photo"
                            presentedVC.directUpload = false
                            presentedVC.url = "listings/photo/\(self.editListingID)"
                            presentedVC.param = ["listing_id":"\(self.editListingID)", "listingtype_id": String(self.listingTypeId)]
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                    
                        case "close":
                            Reload = "Not Refresh"
                            self.performListingMenuAction(menuItem["url"] as! String)
                            
                        case "open":
                            Reload = "Not Refresh"
                            self.performListingMenuAction(menuItem["url"] as! String)
                            
                        case "makePayment":
                            let presentedVC = ExternalWebViewController()
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let navigationController = UINavigationController(rootViewController: presentedVC)
                            self.present(navigationController, animated: true, completion: nil)
                            
                        case "upgrade_package":
                            let presentedVC = PackageViewController()
                            presentedVC.contentType = "listings"
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                            presentedVC.listingTypeId = self.listingTypeId
                            presentedVC.isUpgradePackageScreen = true
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                            
                        default:
                            print("error")
                        }
                    }))
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    // Perform an action when an option is selected from listing gutter menu
    func performListingMenuAction(_ url : String){
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            self.view.isUserInteractionEnabled = false
            let dic = Dictionary<String, String>()
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Classified Contents with Classified_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Classified Detail
                        // Update Classified Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        updateAfterAlert = false
                        self.browseEntries()
                        self.isUserInteractionEnabled = false
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    
    // MARK: - Show Feed Filter Options Action
    // Show Feed Filter Options Action
    @objc func showListingFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:"See All", "Featured", "Sponsored")
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
            
        case 0:
            print("cancel")
            
        case 1:
            showListingType = ""
            let fitertext = "See All" + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
        case 2:
            showListingType = "featured"
            let fitertext = "Featured" + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
        case 3:
            showListingType = "sponsored"
            let fitertext = "Sponsored" + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
        default:
            print("Default")
        }
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
