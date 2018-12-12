//
//  AdvanceVideoViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 05/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//
import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import AVKit
import AVFoundation
import NVActivityIndicatorView
import Instructions

var advVideosUpdate = false
class AdvanceVideoViewController: UIViewController,UIScrollViewDelegate,GADNativeAppInstallAdLoaderDelegate,GADNativeContentAdLoaderDelegate,FBNativeAdDelegate,FBNativeAdsManagerDelegate,UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,UIActionSheetDelegate,UIWebViewDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
    //Navigation variables
    var navtitle : UILabel!
    var navTitle = String()
    var feedFilter: UIButton!
    var feedFilter2: UIButton!
    var viewSubview = UIView()
    
    var showOnlyMyContent:Bool!
    let scrollView = UIScrollView()
    var fromTab : Bool! = false
    var headermenuBtn:UIButton!
    var videoTypeCheck = ""
    var pageNumber:Int = 1
    var user_id : Int!
    var showSpinner = true
    var url : String!
    var updateScrollFlag = true
    var advVideoTableView:UITableView!
    var myAdvVideoTableView:UITableView!
    var categoryTableView:UITableView!
    var categoryResponse = [AnyObject]()
    var videosResponse = [AnyObject]()
    var myvideosResponse = [AnyObject]()
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var isPageRefresing = false
    var responseCache = [String:AnyObject]()
    var totalItems:Int = 0
    
    var listingTypeId : Int!
    
    // AdMob Variable
    var adLoader: GADAdLoader!
    // var nativeAdArray = [AnyObject]()
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    // Native FacebookAd Variable
    var nativeAdArray = [AnyObject]()
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
    var videoBrowseType:Int = 0
    var gutterMenu1 = NSDictionary()
    var gutterMenu = NSDictionary()
    var filterDic = Dictionary<String, String>()
    var filterDic2 = Dictionary<String, String>()
    
    // Carausal variables
    var videoSlideshow: ContentSlideshowScrollView!
    var slideShowHeading: UILabel!
    var videoSlideShowView: UIView!
    var featuredVideosResponse = [AnyObject]()
    var dynamicHeaderHeight: CGFloat = 0.0001
    var countListTitle : String!
    var selectedTab:Int = 100
    var username : String = ""
    var check_videotitle : Int = 0
    var popoverTableView:UITableView!
    var videoCreateOption = [String(format: NSLocalizedString("Create a New Video", comment: "")), String(format: NSLocalizedString("Create a New Channel", comment: ""))]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var other_module : Bool = false
    var subject_type : String = ""
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var targetSeeAllValue : Int = 1
    //MARK: Override Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        openMenu = false
        updateAfterAlert = true
        advVideosUpdate = false
        self.filterDic.removeAll()
        self.filterDic2.removeAll()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        removeNavigationViews(controller: self)
        
        if fromTab == false{
            setDynamicTabValue()
        }
        
        // UI Stuff
        designViews()
        
        
        // Get listing
        self.browseVideo()
        
        if adsType_advancedvideo != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(AdvanceVideoViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        IsRedirctToProfile()
        setNavigationImage(controller: self)
        
        Customnavigation()
        if  showOnlyMyContent == true || other_module == true{
            scrollView.isHidden = true
            removeNavigationViews(controller: self)
            feedFilter.frame.origin.y = TOPPADING
            advVideoTableView.frame.origin.y = TOPPADING - 4
            advVideoTableView.frame.size.height = view.bounds.height - (TOPPADING - 4) - tabBarHeight
        }
        if self.videoBrowseType == 2//self.check_videotitle != 1
        {
            // self.title = "Videos (" + String(self.totalItems)+")"
            feedFilter.isHidden = true
            feedFilter2.isHidden = true
            self.videoSlideShowView.isHidden = true
        }
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
         if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
            return 3
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
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
         if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
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
            let radious : Int = 50
            
            
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
            
    }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            switch(index) {
                
            case 0:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width/2
                let radious : Int = 50
                
                
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
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.nextLabel.text = "Next "
            coachViews.bodyView.countTourLabel.text = " 1/3"
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 2/3"
            coachViews.bodyView.nextLabel.text = "Next "
       
        case 2:
            coachViews.bodyView.hintLabel.text = "Use Filters to search specific results."
            coachViews.bodyView.countTourLabel.text = " 3/3"
            coachViews.bodyView.nextLabel.text = "Finish "
            
        default: break
        }
    }
        
         if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = "Use Filters to search specific results."
                coachViews.bodyView.nextLabel.text = "Finish "
                coachViews.bodyView.countTourLabel.text = " 1/1"
            default: break
            }
        
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
        
        if let name = defaults.object(forKey: "showSeeAllPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSeeAllPluginAppTour") != nil {
                
                self.targetSeeAllValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
 
    // Check for Group Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if advVideosUpdate == true {
            setNavigationImage(controller: self)
            pageNumber = 1
            updateScrollFlag = false
            self.browseVideo()
            
        }
        
       
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        timerFB.invalidate()
        advVideoTableView.tableFooterView?.isHidden = true
        myAdvVideoTableView.tableFooterView?.isHidden = true
        self.title = ""
        removeNavigationViews(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
    }
    
    // MARK: UI Implimentation
    func designViews()
    {
        
        //MARK: Create AdvancedEvent Menu
        CreateScrollHeadermenu()
        
        
        advVideoTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight , width: view.bounds.width, height: view.bounds.height - (TOPPADING + ButtonHeight) - tabBarHeight), style: .grouped)
        advVideoTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "Cell")
        advVideoTableView.dataSource = self
        advVideoTableView.delegate = self
        advVideoTableView.isOpaque = false
        advVideoTableView.backgroundColor = UIColor.clear//tableViewBgColor
        advVideoTableView.separatorColor = TVSeparatorColorClear
        self.view.addSubview(advVideoTableView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(AdvanceVideoViewController.refresh), for: UIControlEvents.valueChanged)
        advVideoTableView.addSubview(refresher)
        
        // Featured carausal
        videoSlideShowView = UIView(frame: CGRect(x:0, y: 0, width: view.bounds.width, height: 180))
        videoSlideShowView.backgroundColor = textColorclear
        videoSlideShowView.isHidden = true
        
        slideShowHeading = createLabel(CGRect(x:0, y: 5, width: videoSlideShowView.bounds.width, height: 25), text: "Featured Videos", alignment: .center, textColor: textColorDark)
        slideShowHeading.font = UIFont(name: fontName, size: FONTSIZELarge)
        slideShowHeading.backgroundColor = textColorLight
        videoSlideShowView.addSubview(slideShowHeading)
        
        videoSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y: 30, width: view.bounds.width, height: 150))
        videoSlideshow.backgroundColor = UIColor.white
        videoSlideshow.delegate = self
        videoSlideShowView.addSubview(videoSlideshow)
        advVideoTableView.addSubview(videoSlideShowView)
        
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        advVideoTableView.tableFooterView = footerView
        advVideoTableView.tableFooterView?.isHidden = true
        
        //        if showOnlyMyContent == true{
        //            advVideoTableView.frame.origin.y = TOPPADING - 4
        //            advVideoTableView.frame.size.height = view.bounds.height - (TOPPADING - 4) - tabBarHeight
        //        }
        
        // My video view
        if showOnlyMyContent == true{
            myAdvVideoTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + 3, width: view.bounds.width, height: view.bounds.height-(TOPPADING + 3) - tabBarHeight), style: .grouped)
        }
        else
        {
            myAdvVideoTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight + 3, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + 3) - tabBarHeight), style: .grouped)
        }
        
        myAdvVideoTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "Cell")
        //  myAdvVideoTableView.rowHeight = 253.0
        myAdvVideoTableView.dataSource = self
        myAdvVideoTableView.delegate = self
        myAdvVideoTableView.isOpaque = false
        myAdvVideoTableView.isHidden = true
        myAdvVideoTableView.backgroundColor = bgColor
        myAdvVideoTableView.separatorColor = UIColor.clear
        self.view.addSubview(myAdvVideoTableView)
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(AdvanceVideoViewController.refresh), for: UIControlEvents.valueChanged)
        myAdvVideoTableView.addSubview(refresher1)
        
        // Category view
        categoryTableView = UITableView(frame: CGRect(x: 0, y:  TOPPADING + ButtonHeight + 3, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + tabBarHeight + 3)), style: .grouped)
        
        categoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        categoryTableView.rowHeight = 110.0
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.isOpaque = false
        categoryTableView.isHidden = true
        categoryTableView.backgroundColor = bgColor
        categoryTableView.separatorColor = UIColor.clear
        self.view.addSubview( categoryTableView)
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(AdvanceVideoViewController.refresh), for: UIControlEvents.valueChanged)
        categoryTableView.addSubview(refresher2)
        
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        myAdvVideoTableView.tableFooterView = footerView2
        myAdvVideoTableView.tableFooterView?.isHidden = true
    }
    // MARK: Create AdvancedEvent Menu
    func CreateScrollHeadermenu()
    {
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        // scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if logoutUser == false
        {
            var eventMenu = [String]()
            
            if isChannelEnable == true
            {
                eventMenu = ["Videos","My Videos","Categories","Channels","My Channels","Ch Categories"]
                if isPlaylistEnable == true{
                    eventMenu = ["Videos","My Videos","Categories","Channels","My Channels","Ch Categories","Playlists","My Playlists"]
                }
            }
            else if isPlaylistEnable == true{
                
                eventMenu =  ["Videos","My Videos","Categories","Playlists","My Playlists"]
                
            }
            else{
                eventMenu =  ["Videos","My Videos","Categories"]
            }
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            let menucount = eventMenu.count + 100
            for i in 100 ..< menucount
            {
                if i == selectedTab
                {
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                    headermenuBtn.setSelectedButton()
                }
                else
                {
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                headermenuBtn.tag = i
                headermenuBtn.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                headermenuBtn.addTarget(self, action: #selector(AdvanceVideoViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let scrollWidth = menuWidth * CGFloat(eventMenu.count)
            scrollView.contentSize = CGSize(width:scrollWidth,height:ScrollframeY)
        }
        else
        {
            var eventMenu = [String]()
            if isChannelEnable == true
            {
                
                eventMenu = ["Videos","Categories","Channels","Ch Categories"]
                if isPlaylistEnable == true{
                    eventMenu = ["Videos","Categories","Channels","Ch Categories","Playlists"]
                }
            }
            else if isPlaylistEnable == true{
                
                eventMenu =  ["Videos","Categories","Playlists"]
                
            }
            else{
                eventMenu =  ["Videos","Categories"]
            }
            
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)
            let menucount = eventMenu.count + 100
            for i in 100 ..< menucount
            {
                if i == selectedTab
                {   headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                headermenuBtn.tag = i
                headermenuBtn.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                headermenuBtn.addTarget(self, action: #selector(AdvanceVideoViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let scrollWidth = menuWidth * CGFloat(eventMenu.count)
            scrollView.contentSize = CGSize(width:scrollWidth,height:ScrollframeY)
        }
        
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
    }
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            if self.videoTypeCheck == "listings"{
                let presentedVC = AdvanceVideoProfileViewController()
                presentedVC.listingTypeId = listingTypeId
                presentedVC.videoProfileTypeCheck = "listings"
                presentedVC.videoId = createResponse["video_id"] as! Int
                presentedVC.videoType = createResponse["type"] as? Int
                presentedVC.videoUrl = createResponse["video_url"] as! String
                if sitevideoPluginEnabled_mlt == 1
                {
                    presentedVC.listingId = createResponse["parent_id"] as! Int
                }
                else
                {
                    presentedVC.listingId = createResponse["listing_id"] as! Int
                }
                navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else
            {
                
                let presentedVC = AdvanceVideoProfileViewController()
                if self.videoTypeCheck == "AdvEventVideo"{
                    presentedVC.videoProfileTypeCheck = "AdvEventProfile"
                }
                else
                {
                    presentedVC.videoProfileTypeCheck = ""
                }
                presentedVC.videoId = createResponse["video_id"] as! Int
                presentedVC.videoType = createResponse["type"] as? Int
                presentedVC.videoUrl = createResponse["video_url"] as! String
                if self.videoTypeCheck == "AdvEventVideo"{
                    if sitevideoPluginEnabled_event == 1
                    {
                        presentedVC.event_id = createResponse["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.event_id = createResponse["event_id"] as! Int
                    }
                }
                navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            
        }
        
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAdvVideoContent")
        {
            if  UserDefaults.standard.object(forKey: "showAdvVideoContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showAdvVideoContent")
        }
        
    }
    
    // MARK: Create Navigation
    func createNavigationbuttons()
    {
        
        if showOnlyMyContent == false
        {
            if other_module == true
            {
                self.navigationItem.setHidesBackButton(false, animated: false)
                let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                leftNavView.backgroundColor = UIColor.clear
                let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceVideoViewController.goBack))
                leftNavView.addGestureRecognizer(tapView)
                let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
                backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
                leftNavView.addSubview(backIconImageView)
                let barButtonItem = UIBarButtonItem(customView: leftNavView)
                self.navigationItem.leftBarButtonItem = barButtonItem
            }
            else
            {
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
        }
        else
        {
            if(countListTitle != nil)
            {
                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            }
            self.navigationItem.setHidesBackButton(false, animated: false)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceVideoViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
    }
    func Customnavigation()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2, y:0, width: navigationBar.frame.width/3, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            navtitle.text = NSLocalizedString("Videos", comment: "")
            //navtitle.sizeToFit()
            navtitle.tag = 400
            
            //Filter option
            feedFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 18,width: navigationBar.frame.width/3, height: 30),title:"" , border: false, bgColor: false,textColor: textColorLight)
            feedFilter.isEnabled = true
            feedFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            feedFilter.addTarget(self, action: #selector(AdvanceVideoViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
            feedFilter.tag = 400
            let fitertext = "See All" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: .normal)
            
            feedFilter2 = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 18,width: navigationBar.frame.width/3, height: 30),title:"See All" , border: false, bgColor: false,textColor: textColorLight)
            feedFilter2.isEnabled = true
            feedFilter2.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            feedFilter2.addTarget(self, action: #selector(AdvanceVideoViewController.showFeedFilterOptions2(_:)), for: .touchUpInside)
            feedFilter2.tag = 400
            feedFilter2.setTitle(fitertext, for: .normal)
            feedFilter2.isHidden = true
            
            navigationBar.addSubview(feedFilter)
            navigationBar.addSubview(feedFilter2)
            navigationBar.addSubview(navtitle)
            
        }
    }
    
    // MARK: Back Implimentation
    @objc func goBack(){
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        return true
    }

    // Pull to Request Action
    @objc func refresh()
    {
        // Check Internet Connectivity
        if reachability.connection != .none {
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            filterDic.removeAll(keepingCapacity: false)
            filterDic2.removeAll(keepingCapacity: false)
            browseVideo()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    // MARK: - Video Selection Action
    @objc func menuSelectOptions(_ sender: UIButton)
    {
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        videoBrowseType = sender.tag - 100
        if logoutUser == false
        {
            switch videoBrowseType
            {
            case 0:
                feedFilter.isHidden = false
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = false
                if videosResponse.count == 0
                {
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = true
                    pageNumber = 1
                    advVideoTableView.tableFooterView?.isHidden = true
                    showSpinner = true
                    scrollView.isUserInteractionEnabled = false
                    self.filterDic.removeAll()
                    browseVideo()
                }
                else
                {
                    advVideoTableView.isHidden = false
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = true
                    advVideoTableView.reloadData()
                    
                }
                break
            case 1:
                feedFilter.isHidden = true
                feedFilter2.isHidden = false
                self.videoSlideShowView.isHidden = true
                if showOnlyMyContent == false{
                    myAdvVideoTableView.frame = CGRect(x: 0, y: ButtonHeight + TOPPADING + 3, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+TOPPADING+3)-tabBarHeight)
                }
                else{
                    myAdvVideoTableView.frame = CGRect(x: 0, y: TOPPADING+3, width: view.bounds.width, height: view.bounds.height - (tabBarHeight + TOPPADING - 3))
                }
                if myvideosResponse.count == 0
                {
                    
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = true
                    scrollView.isUserInteractionEnabled = false
                    pageNumber = 1
                    showSpinner = true
                    myAdvVideoTableView.tableFooterView?.isHidden = true
                    self.filterDic2.removeAll()
                    browseVideo()
                }
                else
                {
                    
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = false
                    categoryTableView.isHidden = true
                    
                    
                }
                break
            case 2:
                
                feedFilter.isHidden = true
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = true
                advVideoTableView.isHidden = true
                myAdvVideoTableView.isHidden = true
                if categoryResponse.count == 0
                {
                    categoryTableView.isHidden = true
                    pageNumber = 1
                    showSpinner = true
                    self.filterDic.removeAll()
                    self.filterDic2.removeAll()
                    categoryTableView.tableFooterView?.isHidden = true
                    scrollView.isUserInteractionEnabled = false
                    browseVideo()
                }
                else
                {
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = false
                    
                }
                break
            case 3:
                if isChannelEnable == true
                {
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 103
                    presentedVC.videoBrowseType = 3
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else
                {
                    let playlistObj = PlaylistBrowseViewController()
                    playlistObj.showOnlyMyContent = false
                    playlistObj.browseOrmyListing = true
                    playlistObj.isPlaylist = true
                    playlistObj.isMyPlaylist = false
                    playlistObj.selectedTab = 103
                    playlistObj.videoBrowseType = 3
                    self.navigationController?.pushViewController(playlistObj, animated: false)
                }
                break
            case 4:
                if isChannelEnable == true
                {
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 104
                    presentedVC.videoBrowseType = 4
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else
                {
                    let playlistObj = PlaylistBrowseViewController()
                    playlistObj.showOnlyMyContent = false
                    playlistObj.browseOrmyListing = false
                    playlistObj.isPlaylist = false
                    playlistObj.isMyPlaylist = true
                    playlistObj.selectedTab = 104
                    playlistObj.videoBrowseType = 4
                    self.navigationController?.pushViewController(playlistObj, animated: false)
                }
                break
            case 5:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 105
                    presentedVC.videoBrowseType = 5
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                break
            case 6:
                
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = true
                playlistObj.isPlaylist = true
                playlistObj.isMyPlaylist = false
                playlistObj.selectedTab = 106
                playlistObj.videoBrowseType = 6
                self.navigationController?.pushViewController(playlistObj, animated: false)
                break
                
            case 7:
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = false
                playlistObj.isPlaylist = false
                playlistObj.isMyPlaylist = true
                playlistObj.selectedTab = 107
                playlistObj.videoBrowseType = 7
                self.navigationController?.pushViewController(playlistObj, animated: false)
                break
                
            default:
                break
            }
            
        }
        else
        {
            switch videoBrowseType {
            case 0:
                feedFilter.isHidden = false
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = false
                if videosResponse.count == 0
                {
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = true
                    pageNumber = 1
                    showSpinner = true
                    scrollView.isUserInteractionEnabled = false
                    self.filterDic.removeAll()
                    browseVideo()
                }
                else
                {
                    advVideoTableView.isHidden = false
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = true
                    advVideoTableView.reloadData()
                    
                }
                break
            case 1:
                feedFilter.isHidden = true
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = true
                advVideoTableView.isHidden = true
                myAdvVideoTableView.isHidden = true
                if categoryResponse.count == 0
                {
                    categoryTableView.isHidden = true
                    pageNumber = 1
                    showSpinner = true
                    self.filterDic.removeAll()
                    self.filterDic2.removeAll()
                    scrollView.isUserInteractionEnabled = false
                    browseVideo()
                }
                else
                {
                    advVideoTableView.isHidden = true
                    myAdvVideoTableView.isHidden = true
                    categoryTableView.isHidden = false
                    
                }
                break
                
            case 2:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 102
                    presentedVC.videoBrowseType = 2
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else{
                    let playlistObj = PlaylistBrowseViewController()
                    playlistObj.showOnlyMyContent = false
                    playlistObj.browseOrmyListing = true
                    playlistObj.isPlaylist = true
                    playlistObj.isMyPlaylist = false
                    playlistObj.selectedTab = 102
                    playlistObj.videoBrowseType = 2
                    self.navigationController?.pushViewController(playlistObj, animated: false)
                }
                break
            case 3:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 103
                    presentedVC.videoBrowseType = 3
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                break
            case 4:
                
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = true
                playlistObj.isPlaylist = true
                playlistObj.isMyPlaylist = false
                playlistObj.selectedTab = 104
                playlistObj.videoBrowseType = 4
                self.navigationController?.pushViewController(playlistObj, animated: false)
                break
                
                
            default:
                break
            }
            
        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(self.view)
            return
        }
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 107
                {
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }
        filterDic.removeAll(keepingCapacity: false)
        filterDic2.removeAll(keepingCapacity: false)
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 11{
            return 0.00001
        }else{
            if (limit*pageNumber < totalItems){
                return 0
            }else{
                return 0.00001
            }
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag == 11
        {
            return 0.0001
        }
        else
        {
            if  videoBrowseType == 0
            {
                return dynamicHeaderHeight
            }
            else
            {
                return 0.00001
            }
        }
        
    }
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Apply condition for tableViews
        if tableView.tag == 11{
            return 2
        }
        switch videoBrowseType {
        case 0:
            if nativeAdArray.count > 0
            {
                // For showing facebook ads count
                var rowcount = Int()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    rowcount = 2*(kFrequencyAdsInCells_advancedvideo-1)
                }
                else
                {
                    rowcount = (kFrequencyAdsInCells_advancedvideo-1)
                }
                if videosResponse.count > rowcount
                {
                    
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(videosResponse.count)/2))
                        adsCount = b/(kFrequencyAdsInCells_advancedvideo-1)
                        
                        if adsCount > 1 || videosResponse.count%2 != 0
                        {
                            adsCount = adsCount/2
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_advancedvideo-1) == 0 && videosResponse.count % 2 != 0
                        {
                            if adsCount%2 != 0
                            {
                                
                                return Totalrowcount - 1
                            }
                        }
                        else if videosResponse.count % 2 != 0 && adsCount % 2 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        
                        return Totalrowcount
                    }
                    else
                    {
                        let b = videosResponse.count
                        adsCount = b/(kFrequencyAdsInCells_advancedvideo-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_advancedvideo == 0
                        {
                            return Totalrowcount-1
                        }
                        else
                        {
                            return Totalrowcount
                        }
                    }
                    
                }
            }
            
            if(isIpad()){
                return Int(ceil(Float(videosResponse.count)/2))
            }else{
                return videosResponse.count
            }
        case 1:
            if nativeAdArray.count > 0
            {
                // For showing facebook ads count
                var rowcount = Int()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    rowcount = 2*(kFrequencyAdsInCells_advancedvideo-1)
                }
                else
                {
                    rowcount = (kFrequencyAdsInCells_advancedvideo-1)
                }
                if myvideosResponse.count > rowcount
                {
                    
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(myvideosResponse.count)/2))
                        adsCount = b/(kFrequencyAdsInCells_advancedvideo-1)
                        
                        if adsCount > 1 || myvideosResponse.count%2 != 0
                        {
                            adsCount = adsCount/2
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_advancedvideo-1) == 0 && myvideosResponse.count % 2 != 0
                        {
                            if adsCount%2 != 0
                            {
                                
                                return Totalrowcount - 1
                            }
                        }
                        else if myvideosResponse.count % 2 != 0 && adsCount % 2 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        
                        return Totalrowcount
                    }
                    else
                    {
                        let b = myvideosResponse.count
                        adsCount = b/(kFrequencyAdsInCells_advancedvideo-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_advancedvideo == 0
                        {
                            return Totalrowcount-1
                        }
                        else
                        {
                            return Totalrowcount
                        }
                    }
                    
                }
            }
            
            if(isIpad()){
                return Int(ceil(Float(myvideosResponse.count)/2))
            }else{
                return myvideosResponse.count
            }
        default:
            
            
            return Int(ceil(Float(categoryResponse.count)/2))
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 11{
            return 40
        }
        if videoBrowseType == 2
        {
            return 160.0
        }
        if (kFrequencyAdsInCells_advancedvideo > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_advancedvideo) == (kFrequencyAdsInCells_advancedvideo)-1))
        {
            if adsType_advancedvideo == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return 430
                }
                return adsCellheight+5
            }
            else if adsType_advancedvideo == 0
            {
                return 265
            }
            return 235
        }
        return 235
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView.tag != 11
        {
            return videoSlideShowView
        }
        return nil
    }
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 11 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = videoCreateOption[(indexPath as NSIndexPath).row]
            cell.textLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            return cell
            
        }
        else
        {
            let totalRows = videosResponse.count + adsCount
            let totalRows1 = myvideosResponse.count + adsCount
            if (videoBrowseType == 0 && totalRows > (indexPath.row - 1 - adsCount))
            {
                var row = (indexPath as NSIndexPath).row as Int
                if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedvideo) == (kFrequencyAdsInCells_advancedvideo)-1))
                {  // or 9 == if you don't want the first cell to be an ad!
                    advVideoTableView.register(NativeVideoCellTableViewCell.self, forCellReuseIdentifier: "Cell1")
                    let cell = advVideoTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeVideoCellTableViewCell
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = tableViewBgColor
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                    
                    while Adcount > 10 {
                        
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
                        if adsType_advancedvideo != 0 {
                            if(UIDevice.current.userInterfaceIdiom != .pad)
                            {
                                cell.contentView.frame.size.height = view.frame.size.height
                                adsCellheight = cell.contentView.frame.size.height + 5
                            }
                        }
                    }
                    if(isIpad())
                    {
                        var videosInfo2:NSDictionary!
                        let adcount = row/kFrequencyAdsInCells_advancedvideo
                        if(videosResponse.count > ((row)*2-adcount) ){
                            videosInfo2 = videosResponse[((row)*2-adcount)] as! NSDictionary
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = ((row)*2-adcount)
                            cell.menu2.tag = ((row)*2-adcount)
                        }else{
                            cell.cellView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            return cell
                        }
                        
                        // Select Video Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                        cell.imgVideo2.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                        cell.imgVideo2.tag = cell.contentSelection2.tag
                        // Set MenuAction
                        cell.menu2.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                        cell.contentImage2.frame.size.height = 180
                        
                        
                        // Set Video Image
                        if let photoId = videosInfo2["photo_id"] as? Int{
                            if photoId != 0{
                                cell.contentImage2.image = nil
                                let url = URL(string: videosInfo2["image"] as! NSString as String)
                                if  url != nil {
                                    
                                    cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        cell.contentImage2.backgroundColor = UIColor.clear
                                    })
                                }
                            }else{
                                
                                cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                            }
                        }
                        
                        // Set Video Duration
                        let duration = videosInfo2["duration"] as? Int
                        let durationString = timeFormatted(duration!) as String
                        cell.videoDuration2.isHidden = false
                        cell.videoDuration2.text = "\(durationString)"
                        cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                        cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                        cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.contentName2.sizeToFit()
                        cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                        // Set Video Info
                        cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                        var value2 = ""
                        
                        if let videoTitle2 = videosInfo2["title"] as? NSString {
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                        }else if videosInfo2["title"] is NSNumber{
                            
                            let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                            
                        }
                        
                        
                        var tempInfo = ""
                        
                        tempInfo = "\(value2)\n"
                        tempInfo = "\(tempInfo)"
                        let postedDate2 = videosInfo2["creation_date"] as? String
                        
                        let date = dateDifferenceWithEventTime(postedDate2!)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                        
                        cell.createdBy2.delegate = self
                        cell.createdBy2.textAlignment = .left
                        cell.createdBy2.textColor = textColorMedium
                        cell.createdBy2.numberOfLines = 0
                        
                        cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                            let range = (tempInfo as NSString).range(of: value2)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            
                            
                            return mutableAttributedString
                        })
                        
                        var totalView = ""
                        
                        if let ratingCount = videosInfo2["rating_count"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        if let likes = videosInfo2["like_count"] as? Int{
                            totalView += " \(likes) \(likeIcon)"
                        }
                        if let comment = videosInfo2["comment_count"] as? Int{
                            totalView += " \(comment) \(commentIcon)"
                        }
                        cell.totalMembers2.text = "\(totalView)"
                        cell.totalMembers2.textColor = textColorMedium
                        cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                        cell.totalMembers2.sizeToFit()
                        //   Set Menu
                        if videoBrowseType == 0 {
                            cell.menu2.isHidden = true
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                        }else{
                            cell.menu2.isHidden = false
                            
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                        }
                    }
                    
                    return cell
                    
                }
                else
                {
                    if kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0
                    {
                        row = row - (row / kFrequencyAdsInCells_advancedvideo)
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCellThree
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = tableViewBgColor
                    var videosInfo:NSDictionary!
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0)
                        {
                            let adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                            if(videosResponse.count > ((row)*2+adcount))
                            {
                                videosInfo = videosResponse[((row)*2+adcount)] as! NSDictionary
                                cell.contentSelection.tag = ((row)*2+adcount)
                                cell.menu.tag = ((row)*2+adcount)
                                
                            }
                        }
                        else
                        {
                            if(videosResponse.count > (row)*2)
                            {
                                videosInfo = videosResponse[(row)*2] as! NSDictionary
                                cell.contentSelection.tag = (row)*2
                                cell.menu.tag = (row)*2
                                
                            }
                        }
                        
                        
                    }
                    else
                    {
                        videosInfo = videosResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.menu.tag = row
                    }
                    
                    //Select Video Action
                    cell.contentSelection.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                    cell.imgVideo.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    cell.imgVideo.tag = cell.contentSelection.tag
                    // Set MenuAction
                    cell.menu.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage.frame.size.height = 180
                    
                    if (videosInfo["image"] as? String) != nil
                    {
                        let url  = URL(string: videosInfo["image"] as! NSString as String)
                        cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    else
                    {
                        cell.contentImage.image = UIImage(named: "nophoto_video_thumb_icon.png")!
                    }
                    
                    
                    // Set Video Name
                    let duration = videosInfo["duration"] as? Int
                    let durationString = timeFormatted(duration!) as String
                    cell.videoDuration.isHidden = false
                    cell.videoDuration.text = "\(durationString)"
                    
                    cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
                    cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName.sizeToFit()
                    cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
                    
                    // Set Video Info
                    
                    cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
                    var tempInfo = ""
                    var value = ""
                    
                    if let videoTitle = videosInfo["title"] as? NSString
                    {
                        if videoTitle.length > 32
                        {
                            value = videoTitle.substring(to: 32-3)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(videoTitle)"
                        }
                    }
                    else if videosInfo["title"] is NSNumber
                    {
                        let videoTitle = String(describing: videosInfo["title"]!) as NSString
                        if videoTitle.length > 32{
                            value = videoTitle.substring(to: 32-3)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(videoTitle)"
                        }
                        
                    }
                    
                    tempInfo = "\(value)\n"
                    tempInfo = "\(tempInfo)"
                    let postedDate = videosInfo["creation_date"] as? String
                    let date = dateDifferenceWithEventTime(postedDate!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    cell.createdBy.delegate = self
                    cell.createdBy.textAlignment = .left
                    cell.createdBy.textColor = textColorMedium
                    cell.createdBy.numberOfLines = 0

                    
                    cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        let range = (tempInfo as NSString).range(of: value)
                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        // TODO: Clean this up...
                        
                        return mutableAttributedString
                    })
                    // Set Like , Comment & ViewCount
                    
                    var totalView = ""
                    if let ratingCount = videosInfo["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if videoTypeCheck == "sitegroup"{
                        if let ratingCount = videosInfo["rating"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        
                    }
                    
                    if let likes = videosInfo["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo["comment_count"] as? Int{
                        totalView += " \(comment) \(viewIcon)"
                    }
                    cell.totalMembers.textColor = textColorMedium
                    cell.totalMembers.text = "\(totalView)"
                    cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    cell.totalMembers.textAlignment = .center
                    // Set Menu
                    if(isIpad()){
                        
                        if videoBrowseType == 0 {
                            cell.menu.isHidden = true
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                            //
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 100,y: cell.contentImage.bounds.height, width: 100
                                , height: 40)
                            
                        }else{
                            cell.menu.isHidden = false
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 100,y: cell.contentImage.bounds.height, width: 100
                                , height: 40)
                            
                        }
                        
                    }
                    else{
                        if videoBrowseType == 0 {
                            cell.menu.isHidden = true
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 90
                                , height: 40)
                            
                        }else{
                            cell.menu.isHidden = false
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 90
                                , height: 40)
                            
                        }
                        
                    }

                    // RHS
                    if(isIpad()){
                        var videosInfo2:NSDictionary!
                        var adcount = Int()
                        if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0)
                        {
                            adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                        }
                        else
                        {
                            adcount = 0
                        }
                        if(videosResponse.count > ((row)*2+1+adcount))
                        {
                            
                            videosInfo2 = videosResponse[((row)*2+1+adcount)] as! NSDictionary
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = ((row)*2+1+adcount)
                            cell.menu2.tag = ((row)*2+1+adcount)
                        }
                        else
                        {
                            cell.cellView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            return cell
                        }
                        
                        // Select Video Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                        cell.imgVideo2.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                        cell.imgVideo2.tag = cell.contentSelection2.tag
                        // Set MenuAction
                        cell.menu2.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                        cell.contentImage2.frame.size.height = 180
                        
                        
                        cell.contentImage2.image = nil
                        let url = URL(string: videosInfo2["image"] as! NSString as String)
                        if  url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                        
                        
                        // Set Video Duration
                        let duration = videosInfo2["duration"] as? Int
                        let durationString = timeFormatted(duration!) as String
                        cell.videoDuration2.isHidden = false
                        cell.videoDuration2.text = "\(durationString)"
                        cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                        cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                        cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.contentName2.sizeToFit()
                        cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                        // Set Video Info
                        cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                        
                        var value2 = ""
                        if let videoTitle2 = videosInfo2["title"] as? NSString {
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                        }else if videosInfo2["title"] is NSNumber{
                            let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                            
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                            
                        }
                        
                        tempInfo = "\(value2)\n"
                        tempInfo = "\(tempInfo)\n"
                        let postedDate2 = videosInfo2["creation_date"] as? String
                        
                        let date = dateDifferenceWithEventTime(postedDate2!)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                        
                        
                        cell.createdBy2.delegate = self
                        cell.createdBy2.textAlignment = .left
                        cell.createdBy2.textColor = textColorMedium
                        cell.createdBy2.numberOfLines = 0
                        
                        cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                            let range = (tempInfo as NSString).range(of: value2)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            
                            
                            return mutableAttributedString
                        })
                        
                        var totalView = ""
                        
                        if let ratingCount = videosInfo2["rating_count"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        if let likes = videosInfo2["like_count"] as? Int{
                            totalView += " \(likes) \(likeIcon)"
                        }
                        if let comment = videosInfo2["comment_count"] as? Int{
                            totalView += " \(comment) \(commentIcon)"
                        }
                        cell.totalMembers2.text = "\(totalView)"
                        cell.totalMembers2.textColor = textColorMedium
                        cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                        cell.totalMembers2.sizeToFit()
                        //   Set Menu
                        if videoBrowseType == 0 {
                            cell.menu2.isHidden = true
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 85,y: cell.contentImage2.bounds.height, width: 85, height: 40)
                        }else{
                            cell.menu2.isHidden = false
                            
                            
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 85,y: cell.contentImage2.bounds.height, width: 85, height: 40)
                        }
                    }
                    return cell
                }
                
            }
            else if (videoBrowseType == 1 && totalRows1 > (indexPath.row - 1 - adsCount))
            {
                var row = (indexPath as NSIndexPath).row as Int
                if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedvideo) == (kFrequencyAdsInCells_advancedvideo)-1))
                {  // or 9 == if you don't want the first cell to be an ad!
                    myAdvVideoTableView.register(NativeVideoCellTableViewCell.self, forCellReuseIdentifier: "Cell1")
                    let cell = myAdvVideoTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeVideoCellTableViewCell
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = tableViewBgColor
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                    
                    while Adcount > 10 {
                        
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
                            //                        adsCellheight = cell.contentView.frame.size.height + 5
                        }
                    }
                    if(isIpad())
                    {
                        var videosInfo2:NSDictionary!
                        let adcount = row/kFrequencyAdsInCells_advancedvideo
                        if(myvideosResponse.count > ((row)*2-adcount) ){
                            videosInfo2 = videosResponse[((row)*2-adcount)] as! NSDictionary
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = ((row)*2-adcount)
                            cell.menu2.tag = ((row)*2-adcount)
                        }else{
                            cell.cellView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            return cell
                        }
                        
                        // Select Video Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                        cell.imgVideo2.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                        cell.imgVideo2.tag = cell.contentSelection2.tag
                        // Set MenuAction
                        cell.menu2.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                        cell.contentImage2.frame.size.height = 180
                        
                        
                        // Set Video Image
                        if let photoId = videosInfo2["photo_id"] as? Int{
                            if photoId != 0{
                                cell.contentImage2.image = nil
                                let url = URL(string: videosInfo2["image"] as! NSString as String)
                                
                                if  url != nil {
                                    cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        cell.contentImage2.backgroundColor = UIColor.clear
                                    })
                                }
                            }else{
                                
                                cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                            }
                        }
                        
                        // Set Video Duration
                        let duration = videosInfo2["duration"] as? Int
                        let durationString = timeFormatted(duration!) as String
                        cell.videoDuration2.isHidden = false
                        cell.videoDuration2.text = "\(durationString)"
                        cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                        cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                        cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.contentName2.sizeToFit()
                        cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                        // Set Video Info
                        cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                        var value2 = ""
                        
                        if let videoTitle2 = videosInfo2["title"] as? NSString {
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                        }else if videosInfo2["title"] is NSNumber{
                            
                            let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                            
                        }
                        
                        
                        var tempInfo = ""
                        
                        tempInfo = "\(value2)\n"
                        tempInfo = "\(tempInfo)"
                        let postedDate2 = videosInfo2["creation_date"] as? String
                        
                        let date = dateDifferenceWithEventTime(postedDate2!)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                        
                        cell.createdBy2.delegate = self
                        cell.createdBy2.textAlignment = .left
                        cell.createdBy2.textColor = textColorMedium
                        cell.createdBy2.numberOfLines = 0
                        
                        cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                            let range = (tempInfo as NSString).range(of: value2)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            
                            
                            return mutableAttributedString
                        })
                        
                        var totalView = ""
                        
                        if let ratingCount = videosInfo2["rating_count"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        if let likes = videosInfo2["like_count"] as? Int{
                            totalView += " \(likes) \(likeIcon)"
                        }
                        if let comment = videosInfo2["comment_count"] as? Int{
                            totalView += " \(comment) \(commentIcon)"
                        }
                        cell.totalMembers2.text = "\(totalView)"
                        cell.totalMembers2.textColor = textColorMedium
                        cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                        cell.totalMembers2.sizeToFit()
                        //   Set Menu
                        if videoBrowseType == 0 {
                            cell.menu2.isHidden = true
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                        }else{
                            cell.menu2.isHidden = false
                            
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                        }
                    }
                    return cell
                    
                }
                else
                {
                    if kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0
                    {
                        row = row - (row / kFrequencyAdsInCells_advancedvideo)
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCellThree
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.backgroundColor = tableViewBgColor
                    var videosInfo:NSDictionary!
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0)
                        {
                            let adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                            if(myvideosResponse.count > ((row)*2+adcount))
                            {
                                videosInfo = myvideosResponse[((row)*2+adcount)] as! NSDictionary
                                cell.contentSelection.tag = ((row)*2+adcount)
                                cell.menu.tag = ((row)*2+adcount)
                                
                            }
                        }
                        else
                        {
                            if(myvideosResponse.count > (row)*2)
                            {
                                videosInfo = myvideosResponse[(row)*2] as! NSDictionary
                                cell.contentSelection.tag = (row)*2
                                cell.menu.tag = (row)*2
                                
                            }
                        }
                        
                    }
                    else
                    {
                        videosInfo = myvideosResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.menu.tag = row
                    }
                    
                    //Select Video Action
                    cell.contentSelection.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                    cell.imgVideo.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    cell.imgVideo.tag = cell.contentSelection.tag
                    // Set MenuAction
                    cell.menu.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage.frame.size.height = 180
                    
                    //      cell.contentImage.image = UIImage(named: "nophoto_video_thumb_icon.png")!
                    //cell.contentImage.backgroundColor = placeholderColor
                    let url = URL(string: videosInfo["image"] as! NSString as String)
                    if  url != nil {
                        cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            cell.contentImage.backgroundColor = UIColor.clear
                        })
                    }
                    
                    
                    
                    
                    // Set Video Name
                    let duration = videosInfo["duration"] as? Int
                    if duration != nil
                    {
                        let durationString = timeFormatted(duration!) as String
                        cell.videoDuration.isHidden = false
                        cell.videoDuration.text = "\(durationString)"
                    }
                    
                    cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
                    cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName.sizeToFit()
                    cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
                    
                    // Set Video Info
                    
                    cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
                    var tempInfo = ""
                    var value = ""
                    
                    if let videoTitle = videosInfo["title"] as? NSString {
                        if videoTitle.length > 32{
                            value = videoTitle.substring(to: 32-3)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(videoTitle)"
                        }
                    }else if videosInfo["title"] is NSNumber{
                        let videoTitle = String(describing: videosInfo["title"]!) as NSString
                        
                        if videoTitle.length > 32{
                            value = videoTitle.substring(to: 32-3)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(videoTitle)"
                        }
                        
                    }
                    
                    
                    tempInfo = "\(value)\n"
                    tempInfo = "\(tempInfo)"
                    let postedDate = videosInfo["creation_date"] as? String
                    
                    let date = dateDifferenceWithEventTime(postedDate!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    cell.createdBy.delegate = self
                    cell.createdBy.textAlignment = .left
                    cell.createdBy.textColor = textColorMedium
                    cell.createdBy.numberOfLines = 0

                    cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        let range = (tempInfo as NSString).range(of: value)
                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        // TODO: Clean this up...
                        
                        return mutableAttributedString
                    })
                    // Set Like , Comment & ViewCount
                    
                    var totalView = ""
                    if let ratingCount = videosInfo["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if videoTypeCheck == "sitegroup"{
                        if let ratingCount = videosInfo["rating"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        
                    }
                    
                    if let likes = videosInfo["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo["comment_count"] as? Int{
                        totalView += " \(comment) \(viewIcon)"
                    }
                    cell.totalMembers.textColor = textColorMedium
                    cell.totalMembers.text = "\(totalView)"
                    
                    //cell.totalMembers.sizeToFit()
                    cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    
                    // Set Menu
                    if(isIpad()){
                        
                        if videoBrowseType == 0 {
                            cell.menu.isHidden = true
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                            //
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 100,y: cell.contentImage.bounds.height, width: 95
                                , height: 40)
                            
                        }else{
                            cell.menu.isHidden = false
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 100,y: cell.contentImage.bounds.height, width: 95
                                , height: 40)
                            
                        }
                        
                    }
                    else{
                        if videoBrowseType == 0 {
                            cell.menu.isHidden = true
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 90
                                , height: 40)
                            
                        }else{
                            cell.menu.isHidden = false
                            cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                            cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 90
                                , height: 40)
                            
                        }
                        
                    }
                    
                    // RHS
                    if(isIpad()){
                        var videosInfo2:NSDictionary!
                        var adcount = Int()
                        if (kFrequencyAdsInCells_advancedvideo > 4 && nativeAdArray.count > 0)
                        {
                            adcount = row/(kFrequencyAdsInCells_advancedvideo-1)
                        }
                        else
                        {
                            adcount = 0
                        }
                        if(videosResponse.count > ((row)*2+1+adcount))
                        {
                            
                            videosInfo2 = videosResponse[((row)*2+1+adcount)] as! NSDictionary
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = ((row)*2+1+adcount)
                            cell.menu2.tag = ((row)*2+1+adcount)
                        }
                        else
                        {
                            cell.cellView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            return cell
                        }
                        
                        // Select Video Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvanceVideoViewController.showVideo(_:)), for: .touchUpInside)
                        cell.imgVideo2.addTarget(self, action: #selector(AdvanceVideoViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                        cell.imgVideo2.tag = cell.contentSelection2.tag
                        // Set MenuAction
                        cell.menu2.addTarget(self, action:#selector(AdvanceVideoViewController.showVideoMenu(_:)) , for: .touchUpInside)
                        cell.contentImage2.frame.size.height = 180
                        //            cell.contentSelection2.frame.size.height = 180
                        // Set Video Image
                        if let photoId = videosInfo2["photo_id"] as? Int{
                            if photoId != 0{
                                cell.contentImage2.image = nil
                                let url = URL(string: videosInfo2["image"] as! NSString as String)
                                
                                if  url != nil {
                                    
                                    cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        cell.contentImage2.backgroundColor = UIColor.clear
                                    })
                                }
                            }else{
                                
                                cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                            }
                        }
                        
                        // Set Video Duration
                        let duration = videosInfo2["duration"] as? Int
                        let durationString = timeFormatted(duration!) as String
                        cell.videoDuration2.isHidden = false
                        cell.videoDuration2.text = "\(durationString)"
                        cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                        cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                        //            cell.contentName2.text = timeFormatted(duration!)
                        cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.contentName2.sizeToFit()
                        cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                        // Set Video Info
                        cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                        
                        var value2 = ""
                        
                        if let videoTitle2 = videosInfo2["title"] as? NSString {
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                        }else if videosInfo2["title"] is NSNumber{
                            let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                            
                            if videoTitle2.length > 25{
                                value2 = videoTitle2.substring(to: 25 - 3)
                                value2 += NSLocalizedString("...",  comment: "")
                            }else{
                                value2 = "\(videoTitle2)"
                            }
                            
                            
                        }
                        
                        tempInfo = "\(value2)\n"
                        tempInfo = "\(tempInfo)\n"
                        let postedDate2 = videosInfo2["creation_date"] as? String
                        
                        let date = dateDifferenceWithEventTime(postedDate2!)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                        
                        cell.createdBy2.delegate = self
                        cell.createdBy2.textAlignment = .left
                        cell.createdBy2.textColor = textColorMedium
                        cell.createdBy2.numberOfLines = 0
                        
                        cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                            let range = (tempInfo as NSString).range(of: value2)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            
                            
                            return mutableAttributedString
                        })
                        
                        var totalView = ""
                        if let ratingCount = videosInfo2["rating_count"] as? Int{
                            totalView = "\(ratingCount) \(starIcon)"
                        }
                        if let likes = videosInfo2["like_count"] as? Int{
                            totalView += " \(likes) \(likeIcon)"
                        }
                        if let comment = videosInfo2["comment_count"] as? Int{
                            totalView += " \(comment) \(commentIcon)"
                        }
                        cell.totalMembers2.text = "\(totalView)"
                        cell.totalMembers2.textColor = textColorMedium
                        cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                        cell.totalMembers2.sizeToFit()
                        //Set Menu
                        if videoBrowseType == 0 {
                            cell.menu2.isHidden = true
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 85,y: cell.contentImage2.bounds.height, width: 85, height: 40)
                        }else{
                            cell.menu2.isHidden = false
                            
                            
                            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 85,y: cell.contentImage2.bounds.height, width: 85, height: 40)
                        }
                    }
                    return cell
                }
                
            }
            else if (videoBrowseType == 2 && categoryResponse.count > (indexPath.row - 1))
            {
                
                let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.blue
                cell.DiaryName.isHidden = false
                cell.DiaryName1.isHidden = false
                cell.classifiedImageView.frame.size.height = 155
                cell.backgroundColor = UIColor.clear
                var index:Int!
                index = (indexPath as NSIndexPath).row * 2
                if categoryResponse.count > index
                {
                    cell.contentSelection.isHidden = false
                    cell.classifiedImageView.isHidden = false
                    cell.DiaryName.isHidden = false
                    //cell.classifiedImageView.image = nil
                    
                    if let imageInfo = categoryResponse[index] as? NSDictionary
                    {
                        if imageInfo["images"] != nil
                        {
                            
                            if let imagedic = imageInfo["images"] as? NSDictionary
                            {
                                if let url = URL(string: imagedic["image"] as! String)
                                {
                                    cell.classifiedImageView.kf.indicatorType = .activity
                                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                    
                                }
                            }
                        }
                        
                        // LHS
                        cell.DiaryName.text = imageInfo["category_name"] as? String
                        cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                        cell.contentSelection.addTarget(self, action: #selector(AdvanceVideoViewController.showSubCategory(_:)), for: .touchUpInside)
                        
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
                                
                                if let url = URL(string: imagedic["image"] as! String)
                                {
                                    cell.classifiedImageView1.image = nil
                                    cell.classifiedImageView1.kf.indicatorType = .activity
                                    (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                                
                            }
                        }
                        cell.DiaryName1.text = imageInfo["category_name"] as? String
                        cell.contentSelection1.tag = index+1//imageInfo["category_id"] as! Int
                        cell.contentSelection1.addTarget(self, action: #selector(AdvancedEventViewController.showSubCategory(_:)), for: .touchUpInside)
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
        let cell = CustomTableViewCellThree()
        return cell
    }
    // Handle Video Table Cell Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        // Apply condition for tableViews
        if  tableView.tag == 11{
            self.popover.dismiss()
            if (indexPath as NSIndexPath).row == 0{
                // Create Album Form
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                presentedVC.contentType = "Advanced Video"
                presentedVC.param = [ : ]
                presentedVC.url = "advancedvideos/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:true, completion: nil)
                
                
            }
            else if (indexPath as NSIndexPath).row == 1{
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Create New Channel", comment: "")
                presentedVC.contentType = "Advanced Channel"
                presentedVC.param = [ : ]
                presentedVC.url = "advancedvideos/channel/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:true, completion: nil)
            }
            
        }
    }
    
    // MARK:  UIScrollViewDelegate
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView)
    //    {
    //
    //        if updateScrollFlag{
    //
    //            filterDic.removeAll(keepingCapacity: false)
    //            filterDic2.removeAll(keepingCapacity: false)
    //            // Check for Page Number for Browse Video
    //            if videoBrowseType == 0
    //            {
    //                if advVideoTableView.contentOffset.y >= advVideoTableView.contentSize.height - advVideoTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                        if reachability.connection != .none {
    //                            updateScrollFlag = false
    //                            pageNumber += 1
    //                            isPageRefresing = true
    //                            if filterDic.count == 0{
    //                                browseVideo()
    //                            }
    //                        }
    //                    }
    //
    //                }
    //            }
    //            else if videoBrowseType == 1
    //            {
    //                if myAdvVideoTableView.contentOffset.y >= myAdvVideoTableView.contentSize.height - myAdvVideoTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*pageNumber < totalItems)
    //                    {
    //                        if reachability.connection != .none
    //                        {
    //                            updateScrollFlag = false
    //                            pageNumber += 1
    //                            isPageRefresing = true
    //                            if filterDic2.count == 0{
    //                                browseVideo()
    //                            }
    //                        }
    //                    }
    //
    //                }
    //
    //            }
    //
    //        }
    //
    //    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag
            {
                
                filterDic.removeAll(keepingCapacity: false)
                filterDic2.removeAll(keepingCapacity: false)
                // Check for Page Number for Browse Video
                if videoBrowseType == 0
                {
                    //                    if advVideoTableView.contentOffset.y >= advVideoTableView.contentSize.height - advVideoTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if reachability.connection != .none {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            advVideoTableView.tableFooterView?.isHidden = false
                            //  if filterDic.count == 0
                            //  {
                            browseVideo()
                            //  }
                        }
                    }
                    else
                    {
                        advVideoTableView.tableFooterView?.isHidden = true
                    }
                    
                    // }
                }
                else if videoBrowseType == 1
                {
                    //                    if myAdvVideoTableView.contentOffset.y >= myAdvVideoTableView.contentSize.height - myAdvVideoTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems)
                    {
                        if reachability.connection != .none
                        {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            myAdvVideoTableView.tableFooterView?.isHidden = false
                            // if filterDic2.count == 0{
                            browseVideo()
                            //  }
                        }
                    }
                    else
                    {
                        myAdvVideoTableView.tableFooterView?.isHidden = true
                    }
                    
                    //   }
                    
                }
                
            }
            
        }
    }
    
    
    
    
    //Showing message when response count is 0
    func emptylistingMessage(msg :String)
    {
        let contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(videoIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        contentIcon.tag = 1000
        self.view.addSubview(contentIcon)
        
        let info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: String(format: NSLocalizedString("You do not have any %@", comment: ""),msg), alignment: .center, textColor: textColorMedium)
        info.sizeToFit()
        info.numberOfLines = 0
        info.center = self.view.center
        info.backgroundColor = bgColor
        info.tag = 1000
        self.view.addSubview(info)
        
        let refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: info.bounds.height + info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        refreshButton.backgroundColor = bgColor
        refreshButton.layer.borderColor = navColor.cgColor
        refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        refreshButton.addTarget(self, action: #selector(AdvanceVideoViewController.browseVideo), for: UIControlEvents.touchUpInside)
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.layer.masksToBounds = true
        self.view.addSubview(refreshButton)
        refreshButton.tag = 1000
        refreshButton.isHidden = false
        contentIcon.isHidden = false
    }
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_advancedvideo == 1
        {
            if kFrequencyAdsInCells_advancedvideo > 4 && placementID != ""
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
                        advVideoTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_advancedvideo == 0
        {
            if kFrequencyAdsInCells_advancedvideo > 4 && adUnitID != ""
            {
                showNativeAd()
                
            }
            
        }
        else if adsType_advancedvideo == 2 {
            checkCommunityAds()
        }
        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if reachability.connection != .none {
            var dic = Dictionary<String, String>()
            dic["type"] =  "\(adsType_advancedvideo)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_advancedvideo)"
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
                                            self.advVideoTableView.reloadData()
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
                //                adCallToActionButton.clipsToBounds = true
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(AdvanceVideoViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    adImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(AdvanceVideoViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
        dictionary["type"] =  "\(adsType_advancedvideo)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_advancedvideo)"
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
   @objc func removeAd(){
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
    func showFacebookAd()
    {
        //        FBAdSettings.addTestDevices(fbTestDevice)
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager.delegate = self
        admanager.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager.loadAds()
    }
    func nativeAdsLoaded()
    {
        
        //        for _ in 0 ..< 10
        //        {
        //
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
            advVideoTableView.reloadData()
        }
        
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
        
        //        if ((self.nativeAd) != nil) {
        //            self.nativeAd.unregisterView()
        //        }
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x: PADING, y: 0 ,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 230))
            
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x: PADING, y: 0,width: (UIScreen.main.bounds.width - 2*PADING) , height: 230))
            
        }
        self.fbView.layer.shadowColor = shadowColor.cgColor
        self.fbView.layer.shadowOpacity = shadowOpacity
        self.fbView.layer.shadowRadius = shadowRadius
        self.fbView.layer.shadowOffset = shadowOffset
        self.fbView.layer.borderColor = borderColorMedium.cgColor
        self.fbView.backgroundColor = UIColor.white
        self.fbView.tag = 1001001
        
        
        adImageView = FBMediaView(frame: CGRect(x: 0, y: 0, width: self.fbView.bounds.width, height: 180))
        self.adImageView.nativeAd = nativeAd
        
        
        self.adImageView.clipsToBounds = true
        self.adImageView.backgroundColor = UIColor.clear
        self.fbView.addSubview(adImageView)
        
        adTitleLabel = UILabel(frame: CGRect(x: 5 , y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: self.fbView.bounds.width-100, height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: adImageView.bounds.height + 10 + adImageView.frame.origin.y, width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControlState())
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        Adiconview = createImageView(CGRect(x: self.fbView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
        
        
        
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
    //                    advVideoTableView.reloadData()
    //                }
    //            }
    //
    //        }
    //
    //
    //
    //        if(UIDevice.current.userInterfaceIdiom == .pad)
    //        {
    //            self.fbView = UIView(frame: CGRect(x: PADING, y: 0 ,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 230))
    //
    //        }
    //        else
    //        {
    //            self.fbView = UIView(frame: CGRect(x: PADING, y: 0,width: (UIScreen.main.bounds.width - 2*PADING) , height: 230))
    //
    //        }
    //        self.fbView.layer.shadowColor = shadowColor.cgColor
    //        self.fbView.layer.shadowOpacity = shadowOpacity
    //        self.fbView.layer.shadowRadius = shadowRadius
    //        self.fbView.layer.shadowOffset = shadowOffset
    //        self.fbView.layer.borderColor = borderColorMedium.cgColor
    //        self.fbView.backgroundColor = UIColor.white
    //        self.fbView.tag = 1001001
    //
    //
    //        adImageView = FBMediaView(frame: CGRect(x: 0, y: 0, width: self.fbView.bounds.width, height: 180))
    //        self.adImageView.nativeAd = nativeAd
    //
    //
    //        self.adImageView.clipsToBounds = true
    //        self.adImageView.backgroundColor = UIColor.clear
    //        self.fbView.addSubview(adImageView)
    //
    //        adTitleLabel = UILabel(frame: CGRect(x: 5 , y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: self.fbView.bounds.width-80, height: 30))
    //        adTitleLabel.numberOfLines = 0
    //        adTitleLabel.textColor = textColorDark
    //        adTitleLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
    //        adTitleLabel.text = nativeAd.title
    //        self.fbView.addSubview(adTitleLabel)
    //
    //
    //
    //
    //        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: adImageView.bounds.height + 10 + adImageView.frame.origin.y, width: 70, height: 30))
    //
    //        adCallToActionButton.setTitle(
    //            nativeAd.callToAction, for: UIControlState())
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
    //        if nativeAdArray.count == 10
    //        {
    //            advVideoTableView.reloadData()
    //        }
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
            self.advVideoTableView.reloadData()
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
            self.advVideoTableView.reloadData()
        }
    }
    
    //MARK: Action method
    @objc func addNewVideo(){
        let startPoint = CGPoint(x: self.view.frame.width - 28, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: 80))
        popoverTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "Cell")
        popoverTableView.delegate = self
        popoverTableView.dataSource = self
        popoverTableView.isScrollEnabled = false
        popoverTableView.tag = 11
        popover.show(popoverTableView, point: startPoint)
        popoverTableView.reloadData()
    }
    @objc func searchItem(){
        let presentedVC = AdvancedVideoSearchViewController()
        if self.videoTypeCheck == "AdvEventVideo"{
            //videoType = ""
            presentedVC.searchPath = "advancedevents/videos/" + String(user_id)
        }
        else{
            if sitevideoPluginEnabled_event == 1
            {
                presentedVC.searchPath = "advancedvideos/index/\(user_id!)"
                //                parameters = ["subject_type":"siteevent_event","subject_id":"\(user_id!)"]
            }
            else
            {
                presentedVC.searchPath = "advancedvideos/browse"
            }
        }
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "advancedvideos/search-form"
        loadFilter(url)
    }
    @objc func showVideo(_ sender:UIButton){
        var videoInfo:NSDictionary!
        if self.videoBrowseType == 0
        {
            videoInfo = videosResponse[sender.tag] as! NSDictionary
        }
        else
        {
            videoInfo = myvideosResponse[sender.tag] as! NSDictionary
        }
        if self.videoTypeCheck == "listings"{
            let presentedVC = AdvanceVideoProfileViewController()
            presentedVC.listingTypeId = listingTypeId
            presentedVC.videoProfileTypeCheck = "listings"
            presentedVC.videoId = videoInfo["video_id"] as! Int
            presentedVC.videoType = videoInfo["type"] as? Int
            presentedVC.videoUrl = videoInfo["video_url"] as! String
            if sitevideoPluginEnabled_mlt == 1
            {
                presentedVC.listingId = videoInfo["parent_id"] as! Int
            }
            else
            {
                presentedVC.listingId = videoInfo["listing_id"] as! Int
            }
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else
        {
            
            if(videoInfo["allow_to_view"] as! Int == 1){
                let presentedVC = AdvanceVideoProfileViewController()//GroupDetailViewController()
                
                if self.videoTypeCheck == "AdvEventVideo"{
                    presentedVC.videoProfileTypeCheck = "AdvEventProfile"
                }
                else if self.videoTypeCheck == "sitegroupvideo"{
                    presentedVC.videoProfileTypeCheck = "sitegroupvideo"
                    if sitevideoPluginEnabled_group == 1
                    {
                        presentedVC.group_id = videoInfo["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.group_id = videoInfo["group_id"] as! Int
                    }
                }
                else if self.videoTypeCheck == "Pages"{
                    presentedVC.videoProfileTypeCheck = "Pages"
                    if sitevideoPluginEnabled_page == 1
                    {
                        presentedVC.page_id = videoInfo["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.page_id = videoInfo["page_id"] as! Int
                    }
                }
                else if self.videoTypeCheck == "stores"{
                    presentedVC.videoProfileTypeCheck = "stores"
                    if sitevideoPluginEnabled_store == 1
                    {
                        presentedVC.store_id = videoInfo["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.store_id = videoInfo["store_id"] as! Int
                    }
                }
                else{
                    presentedVC.videoProfileTypeCheck = ""
                }
                presentedVC.videoId = videoInfo["video_id"] as! Int
                presentedVC.videoType = videoInfo["type"] as? Int
                
                if let type = videoInfo["type"] as? Int {
                    if  type == 1 || type == 2 || type == 3 || type == 4 ||  type == 5 || type == 6
                    {
                        if let url = videoInfo["video_url"] as? String
                        {
                            presentedVC.videoUrl = url
                        }
                    }
                    else
                    {
                        presentedVC.videoUrl = videoInfo["content_url"] as! String
                    }
                }
                
                if self.videoTypeCheck == "AdvEventVideo"{
                    if sitevideoPluginEnabled_event == 1
                    {
                        presentedVC.event_id = videoInfo["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.event_id = videoInfo["event_id"] as! Int
                    }
                }
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            else{
                self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            }
        }
    }
    @objc func showVideoMenu(_ sender:UIButton){
        
        var videoInfo:NSDictionary
        videoInfo = myvideosResponse[sender.tag] as! NSDictionary
        if (videoInfo["menu"] != nil){
            let menuOption = videoInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.destructive, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Video", comment: ""),message: NSLocalizedString("Are you sure you want to delete this video?", comment: "") , otherButton: NSLocalizedString("Delete Video", comment: "")) { () -> () in
                                    self.updateMyVideoMenuAction(menuItem["url"] as! String)
                                    
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
                                presentedVC.formTitle = NSLocalizedString("Edit Video", comment: "")
                                presentedVC.contentType = "video"
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
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    //MARK: Category Selection
    @objc func showSubCategory(_ sender:UIButton)
    {
        
        var categInfo:NSDictionary!
        categInfo = categoryResponse[sender.tag] as! NSDictionary
        var category_title = categInfo["category_name"] as! String
        if let totalItem = categInfo["count"] as? Int{
            if totalItem > 0{
                category_title = category_title + ": " + "\(totalItem)"
            }
        }
        let presentedVC = AdvancvideoCategoryDetailViewController()
        presentedVC.subjectId = categInfo["category_id"] as! Int
        presentedVC.tittle = category_title
        presentedVC.contentType = "AdvVideo"
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    //MARK: Show Feed Filter Options Action
    @objc func showFeedFilterOptions(_ sender: UIButton){
        
        self.advVideoTableView.setContentOffset(CGPoint.zero, animated: true)
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        filterDic.removeAll(keepingCapacity: false)
        for (key,menu) in gutterMenu
        {
            if menu as! String != ""
            {
                alertController.addAction(UIAlertAction(title: "\(menu)", style: .default, handler:{ (UIAlertAction) -> Void in
                    self.filterDic.removeAll(keepingCapacity: false)
                    // Set Feed Filter Option Title
                    let fitertext = "\(menu)" + " " + searchFilterIcon
                    self.feedFilter.setTitle(fitertext, for: .normal)
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    self.filterDic["orderby"] = "\(key)"
                    self.showSpinner = true
                    self.browseVideo()
                    
                    
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
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.feedFilter.frame.origin.y+self.feedFilter.frame.size.height + TOPPADING),y: view.bounds.width/2, width: 0,height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
    }
    @objc func showFeedFilterOptions2(_ sender: UIButton){
        self.myAdvVideoTableView.setContentOffset(CGPoint.zero, animated: true)
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        filterDic2.removeAll(keepingCapacity: false)
        for (key,menu) in gutterMenu1
        {
            if menu as! String != ""
            {
                alertController.addAction(UIAlertAction(title: "\(menu)", style: .default, handler:{ (UIAlertAction) -> Void in
                    
                    self.filterDic2.removeAll(keepingCapacity: false)
                    // Set Feed Filter Option Title
                    let fitertext = "\(menu)" + " " + searchFilterIcon
                    self.feedFilter2.setTitle(fitertext, for: .normal)
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    self.filterDic2["orderby"] = "\(key)"
                    self.showSpinner = true
                    self.browseVideo()
                    
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
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.feedFilter.frame.origin.y+self.feedFilter.frame.size.height + TOPPADING),y: view.bounds.width/2, width: 0,height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
    }
    func updateMyVideoMenuAction(_ url : String){
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
            // Send Server Request to Explore Video Contents with Video_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Video Detail
                        // Update Group Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        updateAfterAlert = false
                        self.browseVideo()
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
    
    //MARK: Server calling
    @objc func browseVideo(){
        
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            var path = ""
            var parameters = [String:String]()
            //            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
            //                if showOnlyMyContent == true
            //                {
            //                    videoBrowseType = 1
            //                }
            //                else
            //                {
            //                    videoBrowseType = 0
            //                }
            //
            //            }
            if self.videoTypeCheck == "listings"{
                path = url
                if sitevideoPluginEnabled_mlt == 1
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","listingtype_id" : String(listingTypeId),"subject_type":"sitereview_listing","subject_id":"\(user_id!)"]
                }
                else
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","listingtype_id" : String(listingTypeId)]
                }
                self.videoSlideShowView.isHidden = true
                self.videoSlideShowView.frame.size.height = 0.000001
                self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                
                
            }
            else if self.videoTypeCheck == "sitegroup"
            {
                path = url
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            }
            else
            {
                // Set Parameters for Browse/Myvideo
                let tag = videoBrowseType
                switch tag
                {
                case 0:
                    if self.videoTypeCheck == "listings"{
                        
                        path = "" + String(user_id)
                    }
                    else
                    {
                        if self.featuredVideosResponse.count == 0
                        {
                            if sitevideoPluginEnabled_event == 1 || sitevideoPluginEnabled_group == 1 || sitevideoPluginEnabled_store == 1 || sitevideoPluginEnabled_page == 1 || sitevideoPluginEnabled_mlt == 1
                            {
                            }
                            else
                            {
                                getFeaturedVideos()
                            }
                        }
                        
                        if sitevideoPluginEnabled_event == 1 || sitevideoPluginEnabled_group == 1 || sitevideoPluginEnabled_store == 1 || sitevideoPluginEnabled_page == 1
                        {
                            path = "advancedvideos/index/\(user_id!)"
                        }
                        else
                        {
                            check_videotitle = 1
                            path = "advancedvideos/browse"
                        }
                        
                    }
                    
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        if sitevideoPluginEnabled_event == 1 || sitevideoPluginEnabled_group == 1 || sitevideoPluginEnabled_store == 1 || sitevideoPluginEnabled_mlt == 1 || sitevideoPluginEnabled_page == 1
                        {
                            parameters = ["subject_type":subject_type,"subject_id":"\(user_id!)"]
                        }
                        else{
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
                        }
                        
                    }else{
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                    }
                    if self.filterDic.count > 0
                    {
                        // Set Parameters for Search
                        parameters.merge(self.filterDic)
                    }
                    break
                case 1:
                    
                    if logoutUser == true
                    {
                        path = "advancedvideos/categories"
                        parameters = ["showCount" : "1"]
                    }
                    else
                    {
                        path = "advancedvideos/manage"
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                        if self.filterDic2.count > 0
                        {
                            // Set Parameters for Search
                            parameters.merge(self.filterDic2)
                        }
                    }
                    
                    break
                    
                case 2:
                    path = "advancedvideos/categories"
                    parameters = ["showCount" : "1"]
                    break
                    
                    
                default:
                    break
                    
                }
                
            }
            
            
            if (showSpinner){
                //   spinner.center = self.view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = self.view.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //     activityIndicatorView.center = self.view.center
                
                activityIndicatorView.startAnimating()
            }
            self.scrollView.isUserInteractionEnabled = false
            // Send Server Request to Browse video Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.refresher1.endRefreshing()
                    self.refresher2.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    
                    self.advVideoTableView.tableFooterView?.isHidden = true
                    self.myAdvVideoTableView.tableFooterView?.isHidden = true
                    
                    if msg
                    {
                        self.isPageRefresing = false
                        if logoutUser == true
                        {
                            if self.videoBrowseType == 1
                            {
                                self.videoBrowseType = 2
                            }
                        }
                        if succeeded["body"] != nil
                        {
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                    self.createNavigationbuttons()
                                    //                                    if self.check_videotitle != 1
                                    //                                    {
                                    //                                        self.title = "Videos (" + String(self.totalItems)+")"
                                    //                                    }
                                }
                                if self.videoBrowseType == 0
                                {
                                    self.advVideoTableView.isHidden = false
                                    if self.pageNumber == 1 ||  self.filterDic.count > 0
                                    {
                                        self.videosResponse.removeAll(keepingCapacity: false)
                                    }
                                    
                                    if let responsearr = response["response"] as? NSArray{
                                        
                                        self.videosResponse = self.videosResponse + (responsearr as [AnyObject])
                                        
                                        
                                    }
                                    if let menu = response["filter"] as? NSDictionary
                                    {
                                        if let guttermenu = menu["multiOptions"] as? NSDictionary
                                        {
                                            self.gutterMenu = guttermenu
                                        }
                                    }
                                    //var videotitle : String = ""
                                    for tempMenu in self.videosResponse
                                    {
                                        if let tempDic = tempMenu as? NSDictionary
                                        {
                                            if tempDic["title"] is NSString
                                            {
                                                //videotitle = tempDic["title"] as! String
                                            }
                                            else if tempDic["title"] is NSNumber
                                            {
                                                //videotitle = String(describing: tempDic["title"])
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    if self.videoTypeCheck == "AdvEventVideo"{
                                        
                                        if (response["canCreate"] as? Int == 1)
                                        {
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceVideoViewController.searchItem))
                                            searchItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -20.0)
                                            let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AdvanceVideoViewController.addNewVideo))
                                            addBlog.imageInsets = UIEdgeInsetsMake(0,-20, 0, 0)
                                            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            
                                            searchItem.tintColor = textColorPrime
                                            addBlog.tintColor = textColorPrime
                                            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            
                                            
                                        }
                                        if response["totalItemCount"] != nil
                                        {
                                            self.totalItems = response["totalItemCount"] as! Int
                                            self.title = "Videos (" + String(self.totalItems)+")"
                                            
                                        }
                                        
                                    }
                                    if self.videoTypeCheck == "listings"{
                                        if (response["canCreate"] as? Bool == true){
                                            
                                            let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AdvanceVideoViewController.addNewVideo))
                                            self.navigationItem.rightBarButtonItem = addVideo
                                            
                                        }
                                    }
                                    else
                                    {
                                        
                                        
                                        if self.showOnlyMyContent == false{
                                            
                                            if (response["canCreate"] as? Bool == true)
                                            {
                                                
                                                let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceVideoViewController.searchItem))
                                                let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AdvanceVideoViewController.addNewVideo))
                                                self.navigationItem.setRightBarButtonItems([addVideo,searchItem], animated: true)
                                                searchItem.tintColor = textColorPrime
                                                addVideo.tintColor = textColorPrime
                                                
                                               self.showAppTour()
                                                
                                            }
                                            else
                                            {
                                                let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceVideoViewController.searchItem))
                                                
                                                self.navigationItem.rightBarButtonItem = searchItem
                                                searchItem.tintColor = textColorPrime
                                            }
                                        }
                                        
                                    }
                                    //Reload Video Tabel
                                    self.advVideoTableView.reloadData()
                                    if self.videosResponse.count == 0{
                                        self.emptylistingMessage(msg:"Video entries.")
                                        
                                    }
                                }
                                else if self.videoBrowseType == 1
                                {
                                    self.myAdvVideoTableView.isHidden = false
                                    if self.pageNumber == 1 || self.filterDic2.count > 0
                                    {
                                        self.myvideosResponse.removeAll(keepingCapacity: false)
                                    }
                                    if let responsearr = response["response"] as? NSArray{
                                        
                                        self.myvideosResponse = self.myvideosResponse + (responsearr as [AnyObject])
                                        
                                    }
                                    if let menu = response["filter"] as? NSDictionary
                                    {
                                        if let guttermenu = menu["multiOptions"] as? NSDictionary
                                        {
                                            self.gutterMenu1 = guttermenu
                                        }
                                    }
                                    if self.videoTypeCheck == "listings"{
                                        if (response["canCreate"] as! Bool == true){
                                            
                                            let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AdvanceVideoViewController.addNewVideo))
                                            self.navigationItem.rightBarButtonItem = addVideo
                                            
                                        }
                                    }
                                    self.myAdvVideoTableView.reloadData()
                                    if self.myvideosResponse.count == 0{
                                        self.emptylistingMessage(msg: "Video entries.")
                                        
                                    }
                                }
                                else if self.videoBrowseType == 2
                                {
                                    self.categoryTableView.isHidden = false
                                    if self.pageNumber == 1
                                    {
                                        self.categoryResponse.removeAll(keepingCapacity: false)
                                    }
                                    if let response = succeeded["body"] as? NSDictionary
                                    {
                                        if response["categories"] != nil
                                        {
                                            if let blog = response["categories"] as? NSArray
                                            {
                                                self.categoryResponse = self.categoryResponse + (blog as [AnyObject])
                                            }
                                        }
                                        
                                        if response["totalItemCount"] != nil
                                        {
                                            self.totalItems = response["totalItemCount"] as! Int
                                        }
                                        
                                    }
                                    self.isPageRefresing = false
                                    if self.categoryResponse.count == 0{
                                        self.emptylistingMessage(msg: "Category")
                                        
                                    }
                                    self.categoryTableView.reloadData()
                                    
                                }
                            }
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                    }else{
                        // Handle Server Side Error
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
    //Get Stores according to requirements (Liked, Featured)
    func getFeaturedVideos(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            var path = ""
            var parameters = [String:String]()
            if sitevideoPluginEnabled_event == 1
            {
                path = "advancedvideos/index/\(user_id!)"
                parameters = ["subject_type":"siteevent_event","subject_id":"\(user_id!)"]
            }
            else if sitevideoPluginEnabled_group == 1
            {
                path = "advancedvideos/index/\(user_id!)"
                parameters = ["subject_type":"sitegroup_group","subject_id":"\(user_id!)"]
            }
            else if sitevideoPluginEnabled_store == 1
            {
                path = "advancedvideos/index/\(user_id!)"
                parameters = ["subject_type":"sitestore_store","subject_id":"\(user_id!)"]
            }
            else if sitevideoPluginEnabled_page == 1
            {
                path = "advancedvideos/index/\(user_id!)"
                parameters = ["subject_type":"sitepage_page","subject_id":"\(user_id!)"]
            }
            else
            {
                path = "advancedvideos/browse"
            }
            
            parameters["orderby"] = "featured"
            activityIndicatorView.startAnimating()
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.featuredVideosResponse.removeAll(keepingCapacity: false)
                        }
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil {
                                if let listing = response["response"] as? NSArray {
                                    self.featuredVideosResponse = self.featuredVideosResponse + (listing as [AnyObject])
                                    
                                }
                            }
                        }
                        if self.videoBrowseType == 0 && self.featuredVideosResponse.count > 1{
                            self.videoSlideshow.browseContent(contentItems: self.featuredVideosResponse,comingFrom : "Advanced Video")
                            self.dynamicHeaderHeight = 185
                            self.videoSlideShowView.isHidden = false
                            self.advVideoTableView.reloadData()
                        }
                        else{
                            
                            self.videoSlideShowView.frame.size.height = 0.000001
                            self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                            self.videoSlideShowView.isHidden = true
                            
                        }
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            self.videoSlideShowView.isHidden = false
                            self.videoSlideShowView.frame.size.height = ButtonHeight + 5
                            self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                            
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Video Icon Action
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        if self.videoBrowseType == 0
        {
            videoInfo = videosResponse[sender.tag] as! NSDictionary
        }
        else
        {
            videoInfo = myvideosResponse[sender.tag] as! NSDictionary
        }
        let attachment_video_type = videoInfo["type"] as? Int ?? 0
        var attachment_video_url = videoInfo["video_url"] as? String ?? ""
        let attachment_video_code = videoInfo["code"] as? String ?? ""
        if self.videoTypeCheck == "listings"{
            implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
        }
        else
        {
            if(videoInfo["allow_to_view"] as! Int == 1){
                var type : Int = 0
                
                if let ty = videoInfo["type"] as? Int {
                    type = ty
                }
                else if let ty = videoInfo["type"] as? String
                {
                    if ty == "stream"
                    {
                        type = 3
                    }
                }
                
                if  type == 1 || type == 2 || type == 3 || type == 4 ||  type == 5 || type == 6
                {
                    if let url = videoInfo["video_url"] as? String
                    {
                        attachment_video_url = url
                    }
                }
                else
                {
                    attachment_video_url = videoInfo["content_url"] as! String
                }
                
                implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
            }
            else{
                self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            }
        }
        
        
    }
    @objc func btnVideoIconClosedAction()
    {
        let window = UIApplication.shared.keyWindow!
        if let view = window.viewWithTag(200123)
        {
            view.alpha = 0.0
            window.viewWithTag(200123)?.removeFromSuperview()
            //            UIView.animate(withDuration: 0.5, animations: {
            //                view.alpha = 0.0
            //            }) { (isComplete) in
            //                window.viewWithTag(200123)?.removeFromSuperview()
            //            }
        }
        player?.pause()
        player?.replaceCurrentItem(with: nil)
    }
    var originalPosition = CGPoint(x: 0, y: 0)
    var player : AVPlayer?
    // MARK: - Player & Webview Implimentation
    func implemnetPlayer(videoType : Int, videoURL : String, videoCode : String, sender : UIButton)
    {
        if videoType == 3
        {
            if let url = URL(string:videoURL)
            {
                player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                
                present(vc, animated: true) {
                    vc.player?.play()
                }
            }
            
        }
        else
        {
            let window = UIApplication.shared.keyWindow!
            viewSubview = UIView(frame:CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height + tabBarHeight + TOPPADING))
            viewSubview.backgroundColor = .black
            viewSubview.tag = 200123
            viewSubview.alpha = 0
            let imageButton = createButton(CGRect(x: -10,y: 10 ,width: 100 , height:100) , title: "Close", border: false, bgColor: false, textColor: textColorLight)
            imageButton.addTarget(self, action: #selector(self.btnVideoIconClosedAction), for: .touchUpInside)
            //  viewSubview.addSubview(imageButton)
            
            var playerHeight: CGFloat = 800
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                playerHeight = 500
            }
            //self.navigationItem.rightBarButtonItem = nil
            playerHeight += TOPPADING - contentPADING
            
            let videoWebView = UIWebView()
            videoWebView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
            videoWebView.center = viewSubview.convert(viewSubview.center, from:viewSubview.superview)
            videoWebView.isOpaque = false
            videoWebView.backgroundColor = UIColor.black
            videoWebView.scrollView.bounces = false
            videoWebView.delegate = self
            videoWebView.allowsInlineMediaPlayback = true
            videoWebView.mediaPlaybackRequiresUserAction = false
            let jeremyGif = UIImage.gifWithName("progress bar")
            // Use the UIImage in your UIImageView
            let imageView = UIImageView(image: jeremyGif)
            imageView.tag = 2002134
            imageView.frame = CGRect(x: view.bounds.width/2 - 60,y: self.view.bounds.height/2 ,width: 120, height: 7)
            
            var url = ""
            if videoURL.length != 0
            {
                let videoUrl1 : String = videoURL
                let find = videoUrl1.contains("http")
                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5 && find == false{
                    
                    url = "https://" + videoURL
                }
                else
                {
                    url = videoURL
                }
            }
            
            if let videoURL =  URL(string:url)
            {
                var request = URLRequest(url: videoURL)
                if videoType == 1 {
                    request.setValue("http://www.youtube.com", forHTTPHeaderField: "Referer")
                    let embededHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(view.frame.size.width)' height='\(view.frame.size.height - TOPPADING - 30)' src='http://www.youtube.com/embed/\(videoCode)?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'></body></html>"
                    let videoURLYouTube =  URL(string:"http://www.youtube.com")
                    videoWebView.loadHTMLString(embededHTML, baseURL: videoURLYouTube)
                }
                else
                {
                    // videoWebView.frame.origin.y = viewSubview.bounds.height/8
                    // videoWebView.center = window.convert(window.center, from:window.superview)
                    // videoWebView.center = CGPoint(x: viewSubview.bounds.midX,                                                  y: viewSubview.bounds.midY - (playerHeight/6))
                    videoWebView.center = view.convert(view.center, from:view.superview)
                    videoWebView.loadRequest(request)
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch let error as NSError {
                    //print(error)
                }
                
            }
            else
            {
                if videoType == 6
                {
                    videoWebView.loadHTMLString(videoURL, baseURL: nil)
                }
            }
            viewSubview.addSubview(videoWebView)
            videoWebView.addSubview(imageView)
            
            
            window.addSubview(viewSubview)
            originalPosition = self.viewSubview.center
            
            viewSubview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrage(_:))))
            
            UIView.animate(withDuration: 0.5, animations: {
                self.viewSubview.alpha = 1.0
            }, completion: nil)
            
        }
        
        
    }
    
    @objc func onDrage(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: viewSubview)
        
        if panGesture.state == .changed {
            viewSubview.frame.origin = CGPoint(
                x:  viewSubview.frame.origin.x,
                y:  viewSubview.frame.origin.y + translation.y
            )
            panGesture.setTranslation(CGPoint.zero, in: self.viewSubview)
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: viewSubview)
            if velocity.y >= 150 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.viewSubview.frame.origin = CGPoint(
                            x: self.viewSubview.frame.origin.x,
                            y: self.viewSubview.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.btnVideoIconClosedAction()
                        // self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewSubview.center = self.originalPosition
                })
            }
        }
    }
    
    // MARK: - WebView delegate
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = false
        }
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = true
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        //print("WebView Video Error \(error.localizedDescription)")
    }
}

