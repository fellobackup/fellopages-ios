//
//  ClassifiedViewController.swift
//  seiosnativeapp
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


import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions

var musicUpdate = true
var browseOrMyMusic = true
// Flag to refresh Blog

class MusicViewController: UIViewController , UITableViewDataSource, UITableViewDelegate ,GADNativeAppInstallAdLoaderDelegate,GADNativeContentAdLoaderDelegate,FBNativeAdDelegate,FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var username : String = ""
    var editPlaylistID:Int = 0                              // Edit ClassifiedID
    let mainView = UIView()                                 // true for Browse Classified & false for My Classified
    var showSpinner = true                                  // not show spinner at pull to refresh
    var musicResponse = [AnyObject]()                       // For response come from Server
    var isPageRefresing = false                             // For Pagination
    var musicTableView:UITableView!                         // TAbleView to show the Classified Contents
    var browseMusic:UIButton!                               // Classified Types
    var myMusic:UIButton!
    var refresher:UIRefreshControl!                         // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                             // Paginatjion Flag
    var dynamicHeight:CGFloat = 165                         // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var customSegmentControl:UISegmentedControl!
    var countListTitle : String!
    var user_id : Int!
    var fromTab : Bool! = false
   // var imageCache = [String:UIImage]()
   // var imageCache1 = [String:UIImage]()
    var responseCache = [String:AnyObject]()
    
    // AdMob Variable
    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var nativeAdArray = [AnyObject]()
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
    var adsCellheight:CGFloat = 0.0
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    // Initialization of class Object
    override func viewDidLoad() {
     
        if fromTab == false{
            setDynamicTabValue()
        }

        removeMarqueFroMNavigaTion(controller: self)
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        musicUpdate = false
        
       setNavigationImage(controller: self)
        
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        mainView.frame = view.frame
        mainView.backgroundColor = UIColor.clear
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        let items = ["Browse Music", "My Music"]
        customSegmentControl = UISegmentedControl(items: items)
        customSegmentControl.addTarget(self, action: #selector(MusicViewController.indexChanged(_:)), for: UIControlEvents.valueChanged)
        customSegmentControl.frame = CGRect(x: PADING,y: TOPPADING, width: view.bounds.width - 2*PADING, height: ButtonHeight)
        customSegmentControl.selectedSegmentIndex = 0
 
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MusicViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        if showOnlyMyContent == false {
            self.title = NSLocalizedString("Music", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
            }

            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MusicViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
        }
    
        // Initialize Blog Types
        browseMusic = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) ,  title: NSLocalizedString("Browse Music",  comment: "") , border: true, selected: true)
        browseMusic.tag = 11
        browseMusic.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        browseMusic.addTarget(self, action: #selector(MusicViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browseMusic)
        
        browseMusic.isHidden = false
        
        myMusic = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) ,  title: NSLocalizedString("My Music",  comment: "") , border: true, selected: false)
        myMusic.tag = 22
        myMusic.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        myMusic.addTarget(self, action: #selector(MusicViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myMusic)
        
        myMusic.isHidden = false
        
        
        
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: 0,height: 0), title: fiterIcon , border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: #selector(MusicViewController.filterSerach), for: .touchUpInside)
        mainView.addSubview(filter)
        filter.isHidden = true
        
        // Initialize Classified Table
        if tabBarHeight > 0{
            musicTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING - 18 + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            musicTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        musicTableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "Cell")
        musicTableView.dataSource = self
        musicTableView.delegate = self
        musicTableView.estimatedRowHeight = 165.0
        musicTableView.rowHeight = UITableViewAutomaticDimension
        musicTableView.backgroundColor = UIColor.clear
        musicTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            musicTableView.estimatedRowHeight = 0
            musicTableView.estimatedSectionHeaderHeight = 0
            musicTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(musicTableView)
        
        //    musicTableView.tableHeaderView = customSegmentControl
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        //    refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(MusicViewController.refresh), for: UIControlEvents.valueChanged)
        musicTableView.addSubview(refresher)
        
        //    self.shyNavBarManager.scrollView = musicTableView
        
        
        if logoutUser == true || showOnlyMyContent == true{
            browseMusic.isHidden = true
            myMusic.isHidden = true
            filter.frame.origin.y = TOPPADING
            musicTableView.frame.origin.y = TOPPADING
            musicTableView.frame.size.height = view.bounds.height - (TOPPADING) - tabBarHeight
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(MusicViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
            
        }

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        musicTableView.tableFooterView = footerView
        musicTableView.tableFooterView?.isHidden = true
        
       browseEntries()
        
        if adsType_music != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(MusicViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
    }
   
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
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
        case 0:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
            //        case 0:
            //            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
            //            coachViews.bodyView.nextLabel.text = "Next"
            
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 1/1"
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
        if let name = defaults.object(forKey: "showSearchPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSearchPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showSearchPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        musicTableView.tableFooterView?.isHidden = true
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showMusicContent")
        {
            if  UserDefaults.standard.object(forKey: "showMusicContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showMusicContent")
        }
        
    }

    
    
    // Check for Classified Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool)
    {
        
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        
        //playlistResponse.removeAll()
        if musicUpdate == true
        {
            showSpinner = true
            pageNumber = 1
            musicUpdate = false
            browseEntries()
        }
        else
        {
            musicTableView.reloadData()
        }

        
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_music == 1
        {
            if kFrequencyAdsInCells_music > 4 && placementID != ""
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
                       musicTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_music == 0
        {
            if kFrequencyAdsInCells_music > 4 && adUnitID != ""
            {
                showNativeAd()
            }        }
        else if adsType_music == 2 {
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
            
            dic["type"] =  "\(adsType_music)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_music)"
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
                                            self.musicTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(MusicViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                imageButton.addTarget(self, action: #selector(MusicViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
        dictionary["type"] =  "\(adsType_music)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_music)"
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

    // MARK: - FacebookAd Delegate
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
            musicTableView.reloadData()
        }
        
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
//
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
        self.fbView.backgroundColor = UIColor.clear
        
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
//                    musicTableView.reloadData()
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
//        self.fbView.backgroundColor = UIColor.clear
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
//            nativeAd.callToAction, for: UIControlState())
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
//
//        if nativeAdArray.count == 10
//        {
//            musicTableView.reloadData()
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
            self.musicTableView.reloadData()
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
            self.musicTableView.reloadData()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
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
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            musicUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "music/browse-search-form"
            presentedVC.serachFor = "music"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    
    // Handle Browse Classified or My Classified PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
//        let currentTask: URLSessionTask = URLSessionTask.init()
//        currentTask.cancel()
        // true for Browse Classified & false for My Classified
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            browseOrMyMusic = false
        }else if sender.tag == 11 {
            browseOrMyMusic = true
        }
        musicTableView.tableFooterView?.isHidden = true
        self.musicResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Classified
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if musicResponse.count != 0{
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
    
    // For delete  a Classified
    func updateMusicMenuAction(_ url : String){
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
            //        for (key, value) in parameter{
            //
            //            if let id = value as? NSNumber {
            //                dic["\(key)"] = String(id as! Int)
            //            }
            //
            //            if let receiver = value as? NSString {
            //                dic["\(key)"] = receiver
            //            }
            //        }
            
            // Send Server Request to Explore Classified Contents with Classified_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Classified Detail
                        // Update Classified Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        feedUpdate = true
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyMusic = true
            self.browseEntries()
        case 1:
            
            browseOrMyMusic = false
            self.browseEntries()
        default:
            break;
        }
    }
    
    // Update Classified
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.connection != .none
        {
            
//            if showOnlyMyContent == true
//            {
//                browseOrMyMusic = false
//            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            var path = ""
            var parameters = [String:String]()
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyMusic = true
            }
            
            
            // Set Parameters for Browse/myMusic
            if browseOrMyMusic {
                path = "music"
                
                
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id)]
                }else{
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                }
                
                myMusic.setUnSelectedButton()
                browseMusic.setSelectedButton()
                
                
            }else{
                path = "music/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                myMusic.setSelectedButton()
                browseMusic.setUnSelectedButton()
                
            }
            
            if (self.pageNumber == 1)
            {
                self.musicResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]
                    {
                        self.musicResponse = responseCacheArray as! [AnyObject]
                        self.musicTableView.reloadData()
                    }
                    
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            
            if (showSpinner){
               // spinner.center = mainView.center
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
           //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
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
                    self.musicTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1
                        {
                            self.musicResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["response"] != nil
                            {
                                if let classified = response["response"] as? NSArray
                                {
                                    self.musicResponse = self.musicResponse + (classified as [AnyObject])
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = classified
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            if self.showOnlyMyContent == true {
                            self.title_update()
                            }
                            if self.showOnlyMyContent == false {
                                
                                if (response["canCreate"] as! Bool == true)
                                {
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MusicViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime

                                }else{
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MusicViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                }
                                self.showAppTour()
                                
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Classified Tabel
                        self.musicTableView.reloadData()
                       
                        if self.musicResponse.count == 0
                        {
                            if (self.pageNumber == 1)
                            {
                                let arrresponse = NSArray()
                                self.responseCache["\(path)"] = arrresponse
                                
                            }
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(classifiedIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Music entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
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
                            self.refreshButton.addTarget(self, action: #selector(MusicViewController.browseEntries), for: UIControlEvents.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                        }
                        //   }
                        // })
                        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 0 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_music) == (kFrequencyAdsInCells_music)-1))
        {
            if adsType_music == 2
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
            else if adsType_music == 0
            {
                return 265
            }
            return 250
        }
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 430
        }
        return dynamicHeight
    }
    
    // Set Classified Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            rowcount = 2*(kFrequencyAdsInCells_music-1)
            if musicResponse.count > rowcount
            {
                let b = Int(ceil(Float(musicResponse.count)/2))
                adsCount = b/(kFrequencyAdsInCells_music-1)
                let Totalrowcount = adsCount+b
                if b%(kFrequencyAdsInCells_music-1) == 0 && musicResponse.count % 2 != 0
                {
                    if adsCount%2 != 0
                    {
                        
                        return Totalrowcount - 1
                    }
                }
                else if musicResponse.count % 2 != 0 && adsCount % 2 == 0
                {
                    
                    return Totalrowcount - 1
                }
                
                return Totalrowcount
                
            }
            else
            {
                
                return Int(ceil(Float(musicResponse.count)/2))
            }
            
        }
        
        return Int(ceil(Float(musicResponse.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_music) == (kFrequencyAdsInCells_music)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            musicTableView.register(NativeMusicCell.self, forCellReuseIdentifier: "Cell1")
            let cell = musicTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeMusicCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_music-1)
            
            for _ in stride(from: 0, to: 10, by: 1){
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
                let adcount = row/kFrequencyAdsInCells_music
                var index:Int!
                index = (row * 2) - adcount
                
                if musicResponse.count > (index)
                {
                    cell.contentSelection1.isHidden = false
                    cell.classifiedImageView1.isHidden = false
                    cell.classifiedName1.isHidden = false
                    cell.MusicPlays1.isHidden = false
                    
                    cell.classifiedImageView1.image = nil
                    if let musicInfo = musicResponse[index] as? NSDictionary {
                        
                        if let url = URL(string: musicInfo["image"] as! String){

                            cell.classifiedImageView1.kf.indicatorType = .activity
                            (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                let imageLabelView = createLabel(CGRect(x: cell.classifiedImageView1.bounds.width/2 - 12, y: cell.classifiedImageView1.bounds.height/2 - 8, width: 22, height: 22), text: "\u{f01d}", alignment: .center, textColor: textColorLight)
                                imageLabelView.font = UIFont(name: "FontAwesome", size: 24)
                                imageLabelView.layer.shadowColor = UIColor.black.cgColor
                                imageLabelView.isOpaque = true
                                imageLabelView.backgroundColor = UIColor.clear
                                imageLabelView.shadowOffset = CGSize(width: 10, height: 10);
                                imageLabelView.layer.shadowOpacity = shadowOpacity
                                imageLabelView.layer.shadowRadius = shadowRadius
                                imageLabelView.layer.shadowOffset = shadowOffset
                                imageLabelView.layer.masksToBounds = false
                                cell.classifiedImageView1.addSubview(imageLabelView)
                            })
                        }
                        
                        cell.classifiedName1.text = musicInfo["title"] as? String
                        cell.contentSelection1.tag = musicInfo["playlist_id"] as! Int
                        cell.contentSelection1.addTarget(self, action: #selector(MusicViewController.showMusic(_:)), for: .touchUpInside)
                        
                        if browseOrMyMusic {
                            
                            cell.menu1.isHidden = true
                        }else{
                            // Set MenuAction
                            cell.menu1.addTarget(self, action:#selector(MusicViewController.showMenu(_:)) , for: .touchUpInside)
                            cell.menu1.isHidden = false
                        }
                        
                        var totalView = ""
                        if let views = musicInfo["play_count"] as? Int{
                            let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
                            
                            totalView += " \(a)  "
                            
                        }
                        
                        cell.MusicPlays1.text = "\(totalView)  "
                        
                    }
                    
                }
                else{
                    cell.contentSelection1.isHidden = true
                    cell.classifiedImageView1.isHidden = true
                    cell.classifiedName1.isHidden = true
                    cell.MusicPlays1.isHidden = true
                }
            }
            else{
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
                cell.MusicPlays1.isHidden = true
            }
            
            return cell
            
        }
        else
        {
            if kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_music)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MusicTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            var index:Int!
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 0)
                {
                    let adcount = row/(kFrequencyAdsInCells_music-1)
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
            
            if musicResponse.count > index {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.classifiedName.isHidden = false
                
                cell.MusicPlays.isHidden = false
                cell.classifiedImageView.image = nil
                
                
                
                if let musicInfo = musicResponse[index] as? NSDictionary {
                    // LHS
                    if let url = URL(string: musicInfo["image"] as! String){
                        cell.classifiedImageView.kf.indicatorType = .activity
                        (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            let imageLabelView = createLabel(CGRect(x: cell.classifiedImageView.bounds.width/2 - 12, y: cell.classifiedImageView.bounds.height/2 - 8, width: 22, height: 22), text: "\u{f01d}", alignment: .center, textColor: textColorLight)
                            imageLabelView.font = UIFont(name: "FontAwesome", size: 24)
                            imageLabelView.layer.shadowColor = UIColor.black.cgColor
                            imageLabelView.isOpaque = true
                            imageLabelView.backgroundColor = UIColor.clear
                            imageLabelView.shadowOffset = CGSize(width: 10, height: 10);
                            imageLabelView.layer.shadowOpacity = shadowOpacity
                            imageLabelView.layer.shadowRadius = shadowRadius
                            imageLabelView.layer.shadowOffset = shadowOffset
                            imageLabelView.layer.masksToBounds = false
                            cell.classifiedImageView.addSubview(imageLabelView)
                        })
                        
                    }
                    
                    cell.classifiedName.text = musicInfo["title"] as? String
                    cell.contentSelection.tag = musicInfo["playlist_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(MusicViewController.showMusic(_:)), for: .touchUpInside)
                    
                    if browseOrMyMusic {
                        
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                        
                    }else{
                        
                        cell.menu.addTarget(self, action:#selector(MusicViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu1.addTarget(self, action:#selector(MusicViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                        
                    }
                    
                    
                    var totalView = ""
                    if let views = musicInfo["play_count"] as? Int{
                        let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
                        
                        totalView += " \(a)  "
                        
                    }
                    
                    cell.MusicPlays.text = "\(totalView)  "
                    
                }
                
                
            }
            else{
                cell.contentSelection.isHidden = true
                cell.classifiedImageView.isHidden = true
                cell.classifiedName.isHidden = true
                cell.MusicPlays.isHidden = true
                
                
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
                cell.MusicPlays1.isHidden = true
            }
            
            
            if musicResponse.count > (index + 1){
                cell.contentSelection1.isHidden = false
                cell.classifiedImageView1.isHidden = false
                cell.classifiedName1.isHidden = false
                cell.MusicPlays1.isHidden = false
                
                cell.classifiedImageView1.image = nil
                if let musicInfo = musicResponse[index + 1] as? NSDictionary {
                    
                    if let url = URL(string: musicInfo["image"] as! String){
                        cell.classifiedImageView1.kf.indicatorType = .activity
                        (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            let imageLabelView = createLabel(CGRect(x: cell.classifiedImageView1.bounds.width/2 - 12, y: cell.classifiedImageView1.bounds.height/2 - 8, width: 22, height: 22), text: "\u{f01d}", alignment: .center, textColor: textColorLight)
                            imageLabelView.font = UIFont(name: "FontAwesome", size: 24)
                            imageLabelView.layer.shadowColor = UIColor.black.cgColor
                            imageLabelView.isOpaque = true
                            imageLabelView.backgroundColor = UIColor.clear
                            imageLabelView.shadowOffset = CGSize(width: 10, height: 10);
                            imageLabelView.layer.shadowOpacity = shadowOpacity
                            imageLabelView.layer.shadowRadius = shadowRadius
                            imageLabelView.layer.shadowOffset = shadowOffset
                            imageLabelView.layer.masksToBounds = false
                            cell.classifiedImageView1.addSubview(imageLabelView)
                        })
                        
                    }
                    
                    cell.classifiedName1.text = musicInfo["title"] as? String
                    cell.contentSelection1.tag = musicInfo["playlist_id"] as! Int
                    cell.contentSelection1.addTarget(self, action: #selector(MusicViewController.showMusic(_:)), for: .touchUpInside)
                    
                    if browseOrMyMusic {
                        cell.menu.isHidden = true
                        cell.menu1.isHidden = true
                    }else{
                        cell.menu.addTarget(self, action:#selector(MusicViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu.isHidden = false
                        cell.menu1.addTarget(self, action:#selector(MusicViewController.showMenu(_:)) , for: .touchUpInside)
                        cell.menu1.isHidden = false
                    }
                    
                    var totalView = ""
                    if let views = musicInfo["play_count"] as? Int{
                        let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
                        
                        totalView += " \(a)  "
                        
                    }
                    
                    cell.MusicPlays1.text = "\(totalView)  "
                    
                }
                
            }
            else{
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.classifiedName1.isHidden = true
                cell.MusicPlays1.isHidden = true
            }
            
            return cell
        }
    }
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    // MARK:  UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        musicTableView.tableFooterView?.isHidden = false
                       // if searchDic.count == 0{
                            if adsType_music == 2{
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
                    musicTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    @objc func searchItem(){
        let presentedVC = MusicSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    @objc func showMenu(_ sender:UIButton){
        var musicInfo:NSDictionary
        musicInfo = musicResponse[sender.tag] as! NSDictionary
        editPlaylistID = musicInfo["playlist_id"] as! Int
        if (musicInfo["menu"] != nil){
            let menuOption = musicInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.destructive, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this playlist ?",comment: "") , otherButton: NSLocalizedString("Delete Playlist", comment: "")) { () -> () in
                                    self.updateMusicMenuAction(menuItem["url"] as! String)
                                    
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                                
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
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
        
    }
    
    @objc func showMusic(_ sender:UIButton){
        
        //        var musicInfo:NSDictionary
        //        musicInfo = musicResponse[sender.tag] as! NSDictionary
        let presentedVC = MusicPlayListViewController() //MusicPlayerViewController()
        presentedVC.playListId = sender.tag
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We update the title when we delete the data from profile page
    func title_update()
    {
        self.title = String(format: NSLocalizedString(" %@ ", comment: ""), "Music " + "(" + "\(self.totalItems)" + ")" + " : " + self.username)
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
