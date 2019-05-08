//
//  PlaylistBrowseViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 16/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView

class PlaylistBrowseViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate , UITabBarControllerDelegate{
    
    var editClassifiedID:Int = 0                          // Edit ClassifiedID
    let mainView = UIView()
    var browseOrmyListing = true                   // true for Browse Classified & false for My Classified
    var showSpinner = true                      // not show spinner at pull to refresh
    var playlistResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var classifiedTableView:UITableView!              // TAbleView to show the Classified Contents
    var browseListing:UIButton!                    // Classified Types
    var myListing:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 160              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    //var imageCache = [String:UIImage]()
    //  var imageCache1 = [String:UIImage]()
    var user_id : Int!
    var fromTab : Bool! = false
    var countListTitle : String!
    var responseCache = [String:AnyObject]()
    var nativeAdArray = [AnyObject]()
    // AdMob Variable
    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
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
    
    
    var isPlaylist:Bool = true
    var isMyPlaylist:Bool = false
    let scrollView = UIScrollView()
    var headermenuBtn:UIButton!
    var videoBrowseType:Int = 6
    var selectedTab:Int!
    var timerFB = Timer()
    // Initialization of class Object
    override func viewDidLoad() {
        
        removeMarqueFroMNavigaTion(controller: self)
        if fromTab == false{
            setDynamicTabValue()
        }
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        self.tabBarController?.delegate = self
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        classifiedUpdate = true
        globFilterValue = ""
        category_filterId = nil
        _ = self.navigationController?.navigationBar
        
        CreateScrollHeadermenu()
        
        
        mainView.frame = view.frame
        // mainView.backgroundColor = bgColor
        mainView.backgroundColor = UIColor.white
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PlaylistBrowseViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        
        
        if showOnlyMyContent == false
        {
            self.title = NSLocalizedString("Video Playlists",  comment: "")
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else
        {
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(PlaylistBrowseViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        // Initialize Classified Table
        
        if tabBarHeight > 0{
            classifiedTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            classifiedTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        
        classifiedTableView.register(ClassifiedTableViewCell.self, forCellReuseIdentifier: "Cell")
        classifiedTableView.dataSource = self
        classifiedTableView.delegate = self
        classifiedTableView.estimatedRowHeight = 160.0
        classifiedTableView.rowHeight = UITableView.automaticDimension
        classifiedTableView.backgroundColor = UIColor.clear
        classifiedTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            classifiedTableView.estimatedRowHeight = 0
            classifiedTableView.estimatedSectionHeaderHeight = 0
            classifiedTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(classifiedTableView)
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        classifiedTableView.tableFooterView = footerView
        classifiedTableView.tableFooterView?.isHidden = true
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(PlaylistBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        classifiedTableView.addSubview(refresher)
        
        browsePlaylist()
        
        if adsType_playlist != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(PlaylistBrowseViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        
    }
    
    // MARK: Create AdvancedEvent Menu
    func CreateScrollHeadermenu()
    {
        
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        //  scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if logoutUser == false
        {
            if selectedTab == nil{
                selectedTab = 106
            }
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
            menuWidth = CGFloat((view.bounds.width)/2)
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
                headermenuBtn.addTarget(self, action: #selector(PlaylistBrowseViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let index = selectedTab - 100
            scrollView.contentOffset.x = CGFloat(index) * menuWidth
            let scrollWidth = menuWidth * CGFloat(eventMenu.count)
            scrollView.contentSize = CGSize(width:scrollWidth,height:ScrollframeY)
        }
        else
        {
            if selectedTab == nil{
                selectedTab = 104
            }
            var eventMenu = [String]()
            if isChannelEnable == true
            {
                
                eventMenu = ["Videos","Categories","Channels","Channel Category"]
                if isPlaylistEnable == true{
                    eventMenu = ["Videos","Categories","Channels","Channel Category","Playlists"]
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
                headermenuBtn.addTarget(self, action: #selector(PlaylistBrowseViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let index = selectedTab - 100
            scrollView.contentOffset.x = CGFloat(index) * menuWidth
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
        mainView.addSubview(scrollView)
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
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 100
                videoObj.videoBrowseType = 0
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 1:
                
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 101
                videoObj.videoBrowseType = 1
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 2:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.videoBrowseType = 2
                videoObj.selectedTab = 102
                self.navigationController?.pushViewController(videoObj, animated: false)
                
                break
                
            case 3:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 103
                    presentedVC.videoBrowseType = 3
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else
                {
                    browseOrmyListing = true
                    self.playlistResponse.removeAll(keepingCapacity: false)
                    searchDic.removeAll(keepingCapacity: false)
                    updateScrollFlag = false
                    pageNumber = 1
                    showSpinner = true
                    // Update for Classified
                    browsePlaylist()
                }
                break
                
            case 4:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 104
                    presentedVC.videoBrowseType = 4
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else
                {
                    browseOrmyListing = false
                    self.playlistResponse.removeAll(keepingCapacity: false)
                    searchDic.removeAll(keepingCapacity: false)
                    updateScrollFlag = false
                    pageNumber = 1
                    showSpinner = true
                    // Update for Classified
                    browsePlaylist()
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
                browseOrmyListing = true
                self.playlistResponse.removeAll(keepingCapacity: false)
                searchDic.removeAll(keepingCapacity: false)
                updateScrollFlag = false
                pageNumber = 1
                showSpinner = true
                // Update for Classified
                browsePlaylist()
                break
            case 7:
                browseOrmyListing = false
                self.playlistResponse.removeAll(keepingCapacity: false)
                searchDic.removeAll(keepingCapacity: false)
                updateScrollFlag = false
                pageNumber = 1
                showSpinner = true
                // Update for Classified
                browsePlaylist()
                break
                
            default:
                break
            }
            
        }
        else
        {
            switch videoBrowseType {
            case 0:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 100
                videoObj.videoBrowseType = 0
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 1:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 101
                videoObj.videoBrowseType = 1
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 2:
                if isChannelEnable == true{
                    let presentedVC = ChannelViewController()
                    presentedVC.showOnlyMyContent = showOnlyMyContent
                    presentedVC.selectedTab = 102
                    presentedVC.videoBrowseType = 2
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else
                {
                    browseOrmyListing = true
                    self.playlistResponse.removeAll(keepingCapacity: false)
                    searchDic.removeAll(keepingCapacity: false)
                    updateScrollFlag = false
                    pageNumber = 1
                    showSpinner = true
                    browsePlaylist()
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
                browseOrmyListing = true
                self.playlistResponse.removeAll(keepingCapacity: false)
                searchDic.removeAll(keepingCapacity: false)
                updateScrollFlag = false
                pageNumber = 1
                showSpinner = true
                browsePlaylist()
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
        
    }
    // Handle Browse Classified or My Classified PreAction
    func prebrowseEntries(_ sender: UIButton){
        // true for Browse Classified & false for My Classified
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            browseOrmyListing = false
        }else if sender.tag == 11 {
            browseOrmyListing = true
        }
        classifiedTableView.tableFooterView?.isHidden = true
        self.playlistResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Classified
        browsePlaylist()
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showClassifiedContent")
        {
            if  UserDefaults.standard.object(forKey: "showClassifiedContent") != nil {
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showClassifiedContent")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        IsRedirctToProfile()
        
        //        if classifiedUpdate{
        //            pageNumber = 1
        //            showSpinner = true
        //            browsePlaylist()
        //        }
    }
    
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = ClassifiedDetailViewController()
            presentedVC.classifiedId = createResponse["playlist_id"] as! Int
            presentedVC.classifiedName = "classified"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
    }
    
    // Check for Classified Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        self.title = NSLocalizedString("Video Playlists",  comment: "")
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        //        else{
        //            classifiedTableView.reloadData()
        //        }
        
    }
    @objc func goBack(){
        
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        classifiedTableView.tableFooterView?.isHidden = true
        self.title = ""
        globalCatg = ""
        globFilterValue = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    @objc func noRedirection(_ sender: UIButton){
        self.view.makeToast("User not allowed to view this page", duration: 5, position: "bottom")
    }
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_channel == 1
        {
            if kFrequencyAdsInCells_playlist > 4 && placementID != ""
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
                        self.classifiedTableView.reloadData()
                    }
                }
                
            }
            
        }
        else if adsType_channel == 0
        {
            if kFrequencyAdsInCells_playlist > 4 && adUnitID != ""
            {
                showNativeAd()
            }
        }
        else if adsType_channel == 2{
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
            dic["type"] =  "\(adsType_channel)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_playlist)"
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
                                            self.classifiedTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(PlaylistBrowseViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    adImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(PlaylistBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
        dictionary["type"] =  "\(adsType_channel)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_playlist)"
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
        //       DispatchQueue.main.async {
        
        //            for _ in 0 ..< 10
        //            {
        //
        //                self.nativeAd = self.admanager.nextNativeAd
        //                self.fetchAds(self.nativeAd)
        //            }
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
        
        if self.nativeAdArray.count == 10
        {
            self.classifiedTableView.reloadData()
        }
        //        }
        
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
        self.fbView.tag = 1001001
        
        adImageView = FBMediaView(frame: CGRect(x: 0, y: 0, width: self.fbView.bounds.width, height: 155))
        self.adImageView.nativeAd = nativeAd
        let gradient1: CAGradientLayer = CAGradientLayer()
        gradient1.frame = adImageView.frame
        gradient1.colors = [UIColor.clear.cgColor,UIColor.gray.cgColor]
        gradient1.locations = [0.7, 1.0]
        adImageView.layer.insertSublayer(gradient1, at: 0)
        self.adImageView.clipsToBounds = true
        self.adImageView.backgroundColor = UIColor.clear
        self.fbView.addSubview(adImageView)
        
        adTitleLabel = UILabel(frame: CGRect(x: 5 , y: adImageView.bounds.height + adImageView.frame.origin.y - 40, width: self.fbView.bounds.width-100, height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorLight
        adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        adBodyLabel = UILabel(frame: CGRect(x: 5 , y: adTitleLabel.bounds.height + 10 + adTitleLabel.frame.origin.y, width: self.fbView.bounds.width-100, height: 40))
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        adBodyLabel.isHidden = true
        self.fbView.addSubview(adBodyLabel)
        
        
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControl.State())
        
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
    //                    self.classifiedTableView.reloadData()
    //                }
    //            }
    //            // nativeAd1.delegate = self
    //        }
    //
    //
    //        if(UIDevice.current.userInterfaceIdiom == .pad)
    //        {
    //            self.fbView = UIView(frame: CGRect(x: PADING, y: 2*PADING ,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 160))
    //
    //        }
    //        else
    //        {
    //            self.fbView = UIView(frame: CGRect(x: 2*PADING, y: 2*PADING,width: (UIScreen.main.bounds.width - 4*PADING) , height: 160))
    //
    //        }
    //        self.fbView.tag = 1001001
    //
    //
    //        adImageView = FBMediaView(frame: CGRect(x: 0, y: 0, width: self.fbView.bounds.width, height: 155))
    //        self.adImageView.nativeAd = nativeAd
    //        let gradient1: CAGradientLayer = CAGradientLayer()
    //        gradient1.frame = adImageView.frame
    //        gradient1.colors = [UIColor.clear.cgColor,UIColor.gray.cgColor]
    //        gradient1.locations = [0.7, 1.0]
    //        adImageView.layer.insertSublayer(gradient1, at: 0)
    //        self.adImageView.clipsToBounds = true
    //        self.adImageView.backgroundColor = UIColor.clear
    //        self.fbView.addSubview(adImageView)
    //
    //        adTitleLabel = UILabel(frame: CGRect(x: 5 , y: adImageView.bounds.height + adImageView.frame.origin.y - 40, width: self.fbView.bounds.width-100, height: 30))
    //        adTitleLabel.numberOfLines = 0
    //        adTitleLabel.textColor = textColorLight
    //        adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
    //        adTitleLabel.text = nativeAd.title
    //        self.fbView.addSubview(adTitleLabel)
    //
    //        adBodyLabel = UILabel(frame: CGRect(x: 5 , y: adTitleLabel.bounds.height + 10 + adTitleLabel.frame.origin.y, width: self.fbView.bounds.width-100, height: 40))
    //        if let _ = nativeAd.body {
    //            adBodyLabel.text = nativeAd.body
    //        }
    //        adBodyLabel.numberOfLines = 0
    //        adBodyLabel.textColor = textColorMedium
    //        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
    //        adBodyLabel.isHidden = true
    //        self.fbView.addSubview(adBodyLabel)
    //
    //
    //
    //
    //        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: 70, height: 30))
    //
    //        adCallToActionButton.setTitle(
    //            nativeAd.callToAction, for: UIControl.State())
    //
    //        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
    //        adCallToActionButton.titleLabel?.textColor = navColor
    //        adCallToActionButton.backgroundColor = navColor
    //        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
    //        adCallToActionButton.clipsToBounds = true
    //        adCallToActionButton.isHidden = true
    //        self.fbView.addSubview(adCallToActionButton)
    //
    //        nativeAd.registerView(forInteraction: self.fbView, with: self)
    //        nativeAdArray.append(self.fbView)
    //        if nativeAdArray.count == 10
    //        {
    //            classifiedTableView.reloadData()
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
            self.classifiedTableView.reloadData()
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
            self.classifiedTableView.reloadData()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
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
    func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browsePlaylist()
    }
    
    // Create Classified Form
    @objc func addNewPlaylist(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Create New Playlist", comment: "")
            presentedVC.contentType = "playlist"
            presentedVC.param = [ : ]
            presentedVC.url = "advancedvideos/playlist/create"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
        }
    }
    
    
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if playlistResponse.count != 0{
        if reachability.connection != .none {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browsePlaylist()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
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
    
    // For delete  a Classified
    func updateClassifiedMenuAction(_ url : String){
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
            // Send Server Request to Explore Classified Contents with playlist_id
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Classified Detail
                        // Update Classified Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        updateAfterAlert = false
                        self.browsePlaylist()
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
    
    func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrmyListing = true
            self.browsePlaylist()
        case 1:
            
            browseOrmyListing = false
            self.browsePlaylist()
        default:
            break;
        }
    }
    
    // Update Classified
    @objc func browsePlaylist(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            if showOnlyMyContent == true{
                browseOrmyListing = false
            }
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/myListing
            if browseOrmyListing {
                
                path = "advancedvideos/playlist/browse"
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id)]
                }else{
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                }
                //                browseListing.setSelectedButton()
                //                myListing.setUnSelectedButton()
                
            }else{
                path = "advancedvideos/playlist/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                //                browseListing.setUnSelectedButton()
                //                myListing.setSelectedButton()
            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            if (self.pageNumber == 1){
                self.playlistResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true {
                    removeAlert()
                    self.classifiedTableView.reloadData()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                        //   showSpinner = false
                        playlistResponse = responseCacheArray as! [AnyObject]
                        self.classifiedTableView.reloadData()
                    }
                }else{
                    updateAfterAlert = true
                }
            }
            
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            
            if (showSpinner){
                //    spinner.center = mainView.center
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
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrmyListing = true
            }
            self.mainView.isUserInteractionEnabled = false
            // Send Server Request to Browse Classified Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.classifiedTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.mainView.isUserInteractionEnabled = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.playlistResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let Classified = response["response"] as? NSArray {
                                    self.playlistResponse = self.playlistResponse + (Classified as [AnyObject])
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = Classified
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.showOnlyMyContent == false {
                                
                                if (response["canCreate"] as! Bool == true){
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PlaylistBrowseViewController.searchItem))
                                    
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PlaylistBrowseViewController.addNewPlaylist))
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    
                                    
                                }else{
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PlaylistBrowseViewController.searchItem))
                                    
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                    
                                }
                                
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Classified Tabel
                        self.classifiedTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.playlistResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(classifiedIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any playlist.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = textColorclear
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(PlaylistBrowseViewController.browsePlaylist), for: UIControl.Event.touchUpInside)
                            
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                            
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
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_playlist > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_playlist) == (kFrequencyAdsInCells_playlist)-1))
        {
            if adsType_channel == 2{
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return 430
                }
                return adsCellheight
            }
            else if adsType_channel == 0
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
            rowcount = 2*(kFrequencyAdsInCells_playlist-1)
            if playlistResponse.count > rowcount
            {
                let b = Int(ceil(Float(playlistResponse.count)/2))
                adsCount = b/(kFrequencyAdsInCells_playlist-1)
                if adsCount > 1 || playlistResponse.count%2 != 0
                {
                    adsCount = adsCount/2
                }
                let Totalrowcount = adsCount+b
                if b%(kFrequencyAdsInCells_playlist-1) == 0 && playlistResponse.count % 2 != 0
                {
                    if adsCount%2 != 0
                    {
                        
                        return Totalrowcount - 1
                    }
                }
                else if playlistResponse.count % 2 != 0 && adsCount % 2 == 0
                {
                    
                    return Totalrowcount - 1
                }
                
                return Totalrowcount
                
            }
            else
            {
                
                return Int(ceil(Float(playlistResponse.count)/2))
            }
            
        }
        
        return Int(ceil(Float(playlistResponse.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_playlist > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_playlist) == (kFrequencyAdsInCells_playlist)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            classifiedTableView.register(NativeClassifiedCell.self, forCellReuseIdentifier: "Cell1")
            let cell = classifiedTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeClassifiedCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_playlist-1)
            
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
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                let adcount = row/kFrequencyAdsInCells_album
                var index:Int!
                index = (row * 2) - adcount
                
                if playlistResponse.count > (index){
                    cell.contentSelection1.isHidden = false
                    cell.classifiedImageView1.isHidden = false
                    cell.classifiedName1.isHidden = false
                    
                    
                    cell.classifiedImageView1.image = nil
                    if let playlistInfo = playlistResponse[index] as? NSDictionary {
                        
                        if let url = URL(string: playlistInfo["image"] as! NSString as String){
                            cell.classifiedImageView1.kf.indicatorType = .activity
                            (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                            
                        }
                        
                        let name1 = playlistInfo["title"] as? String
                        
                        let tempString1 = name1! as NSString
                        
                        var value1 : String
                        
                        if tempString1.length > 22{
                            
                            value1 = tempString1.substring(to: 19)
                            value1 += NSLocalizedString("...",  comment: "")
                        }else{
                            value1 = "\(tempString1)"
                        }
                        cell.classifiedName1.font =  UIFont(name: fontName, size: FONTSIZENormal)
                        cell.classifiedName1.text = value1
                        
                        
                        cell.contentSelection1.tag = playlistInfo["playlist_id"] as! Int
                        if playlistInfo["allow_to_view"] != nil  {  //&& playlistInfo["allow_to_view"] as! Int = 0
                            cell.contentSelection1.addTarget(self, action: #selector(PlaylistBrowseViewController.showClassified(_:)), for: .touchUpInside)
                        }else{
                            cell.contentSelection1.addTarget(self, action: #selector(PlaylistBrowseViewController.noRedirection(_:)), for: .touchUpInside)
                        }
                        
                        
                        if browseOrmyListing {
                            
                            cell.menu1.isHidden = true
                        }else{
                            // Set MenuAction
                            
                            cell.menu1.addTarget(self, action:#selector(PlaylistBrowseViewController.showMenu(_:)) , for: .touchUpInside)
                            cell.menu1.isHidden = false
                            
                        }
                        
                    }
                    
                }
                else{
                    cell.contentSelection1.isHidden = true
                    cell.classifiedImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                }
            }
            else
            {
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
                
            }
            return cell
            
        }
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClassifiedTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblvideocount.isHidden = false
            if kFrequencyAdsInCells_playlist > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_playlist)
            }
            var index:Int!
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if (kFrequencyAdsInCells_playlist > 4 && nativeAdArray.count > 0)
                {
                    let adcount = row/(kFrequencyAdsInCells_playlist-1)
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
            
            if playlistResponse.count > index
            {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.classifiedName.isHidden = false
                cell.classifiedImageView.image = nil
                
                if let playlistInfo = playlistResponse[index] as? NSDictionary {
                    // LHS
                    if let url = URL(string: playlistInfo["image"] as! NSString as String){
                        
                        cell.classifiedImageView.kf.indicatorType = .activity
                        (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    
                    var tempString = NSString()
                    if let name = playlistInfo["title"] as? String{
                        tempString = name as NSString
                    }
                    if let name = playlistInfo["title"] as? Int{
                        tempString = String(name) as NSString
                    }
                    
                    
                    
                    var value : String
                    if tempString.length > 22{
                        value = tempString.substring(to: 19)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(tempString)"
                        
                    }
                    cell.classifiedName.frame = CGRect(x:cell.classifiedName.frame.origin.x, y:125, width :cell.classifiedName.frame.size.width, height:20)
                    cell.classifiedName.font = UIFont(name: fontName, size: FONTSIZENormal)
                    cell.classifiedName.text = value
                    
                    
                    if let videocount = playlistInfo["video_count"] as? Int
                    {
                        if videocount != 1
                        {
                            cell.lblvideocount.text = "\(videocount) Videos"
                        }
                        else
                        {
                            cell.lblvideocount.text = "\(videocount) Video"
                            
                        }
                        
                    }
                    
                    cell.contentSelection.tag = playlistInfo["playlist_id"] as! Int
                    if playlistInfo["allow_to_view"] != nil  { //&& playlistInfo["allow_to_view"] as! Int > 0
                        cell.contentSelection.addTarget(self, action: #selector(PlaylistBrowseViewController.showClassified(_:)), for: .touchUpInside)
                    }else{
                        cell.contentSelection.addTarget(self, action: #selector(PlaylistBrowseViewController.noRedirection(_:)), for: .touchUpInside)
                    }
                    
                    
                    if browseOrmyListing {
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                    }else{
                        // Set MenuAction
                        cell.menu.addTarget(self, action:#selector(PlaylistBrowseViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu1.addTarget(self, action:#selector(PlaylistBrowseViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                        
                    }
                    
                }
                
            }
            else
            {
                cell.contentSelection.isHidden = true
                cell.classifiedImageView.isHidden = true
                cell.classifiedName.isHidden = true
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
                cell.lblvideocount1.isHidden = true
            }
            
            
            
            if playlistResponse.count > (index + 1){
                cell.contentSelection1.isHidden = false
                cell.classifiedImageView1.isHidden = false
                cell.classifiedName1.isHidden = false
                cell.lblvideocount1.isHidden = false
                cell.classifiedImageView1.image = nil
                
                if let playlistInfo = playlistResponse[index + 1] as? NSDictionary {
                    
                    if let url = URL(string: playlistInfo["image"] as! NSString as String){
                        cell.classifiedImageView1.kf.indicatorType = .activity
                        (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    
                    var tempString1 = NSString()
                    if let name1 = playlistInfo["title"] as? String
                    {
                        tempString1 = name1 as NSString
                    }
                    else
                    {
                        tempString1 = ""
                    }
                    var value1 : String
                    
                    if tempString1.length > 22{
                        
                        value1 = tempString1.substring(to: 19)
                        value1 += NSLocalizedString("...",  comment: "")
                    }else{
                        value1 = "\(tempString1)"
                    }
                    
                    cell.classifiedName1.text = value1
                    cell.classifiedName1.frame = CGRect(x:cell.classifiedName1.frame.origin.x, y:125, width :cell.classifiedName1.frame.size.width, height:20)
                    
                    if let videocount = playlistInfo["video_count"] as? Int
                    {
                        if videocount != 1
                        {
                            cell.lblvideocount1.text = "\(videocount) Videos"
                        }
                        else
                        {
                            cell.lblvideocount1.text = "\(videocount) Video"
                            
                        }
                        
                        
                    }
                    cell.contentSelection1.tag = playlistInfo["playlist_id"] as! Int
                    if playlistInfo["allow_to_view"] != nil  { //&& playlistInfo["allow_to_view"] as! Int > 0
                        cell.contentSelection1.addTarget(self, action: #selector(PlaylistBrowseViewController.showClassified(_:)), for: .touchUpInside)
                    }else{
                        cell.contentSelection1.addTarget(self, action: #selector(PlaylistBrowseViewController.noRedirection(_:)), for: .touchUpInside)
                        
                    }
                    
                    
                    if browseOrmyListing {
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                    }else{
                        // Set MenuAction
                        cell.menu.addTarget(self, action:#selector(PlaylistBrowseViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu.tag = index
                        cell.menu1.addTarget(self, action:#selector(PlaylistBrowseViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                        cell.menu1.tag = index + 1
                        
                    }
                    
                }
                
            }
            else
            {
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
            }
            return cell
            
        }
    }
    
    @objc func showMenu(_ sender:UIButton){
        var classifiedInfo:NSDictionary
        classifiedInfo = playlistResponse[sender.tag] as! NSDictionary
        editClassifiedID = classifiedInfo["playlist_id"] as! Int
        
        if(classifiedInfo["menu"] != nil){
            let menuOption = classifiedInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this  playlist?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.updateClassifiedMenuAction(menuItem["url"] as! String)
                                    
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
                                
                            case "edit":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Playlist", comment: "")
                                presentedVC.contentType = "Playlist"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this  playlist?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.updateClassifiedMenuAction(menuItem["url"] as! String)
                                    
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            case "photo":
                                
                                
                                let presentedVC = UploadPhotosViewController()
                                presentedVC.directUpload = false
                                presentedVC.url = "classifieds/photo/upload/\(self.editClassifiedID)"
                                presentedVC.param = ["playlist_id":"\(self.editClassifiedID)"]
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
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
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        if scrollView.tag != 2
    //        {
    //        if updateScrollFlag{
    //            // Check for Page Number for Browse Classified
    //            if classifiedTableView.contentOffset.y >= classifiedTableView.contentSize.height - classifiedTableView.bounds.size.height{
    //                if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                    if reachability.connection != .none {
    //                        updateScrollFlag = false
    //                        pageNumber += 1
    //                        isPageRefresing = true
    //                        if searchDic.count == 0{
    //                            browsePlaylist()
    //                        }
    //                    }
    //                }
    //
    //            }
    //
    //        }
    //        }
    //
    //    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            
            if updateScrollFlag{
                // Check for Page Number for Browse Classified
                //                if classifiedTableView.contentOffset.y >= classifiedTableView.contentSize.height - classifiedTableView.bounds.size.height{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        classifiedTableView.tableFooterView?.isHidden = false
                        //  if searchDic.count == 0{
                        browsePlaylist()
                        //  }
                    }
                }
                else
                {
                    classifiedTableView.tableFooterView?.isHidden = true
                }
                
                //  }
                
            }
            
        }
        
    }
    @objc func searchItem(){
        
        let presentedVC = PlaylistSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        presentedVC.searchPath = "advancedvideos/playlist/browse"
        let url : String = "advancedvideo/playlist/search-form"
        loadFilter(url)
        
    }
    @objc func showClassified(_ sender: UIButton){
        let presentedVC = PlaylistProfileViewController()
        presentedVC.playlistId = sender.tag
        presentedVC.isplaylist = browseOrmyListing
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

