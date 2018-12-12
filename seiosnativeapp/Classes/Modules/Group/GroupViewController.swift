//
//  GroupViewController.swift
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

var groupUpdate = true

class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate, FBNativeAdDelegate,FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{

    let mainView = UIView()
    var browseGroup:UIButton!
    var myGroup:UIButton!
    var groupTableView:UITableView!
    var refresher:UIRefreshControl!
    var browseOrMyGroup = true                   // true for Browse Group & false for My Group
    var groupResponse = [AnyObject]()
    var showSpinner = true                      // not show spinner at pull to refresh
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var user_id : Int!
    var fromTab : Bool! = false
    var countListTitle : String!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    //    var imageCache = [String:UIImage]()
    //    var imageCache2 = [String:UIImage]()
    var customSegmentControl : UISegmentedControl!
    var responseCache = [String:AnyObject]()
    
    
    // AdMob Variable
    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var nativeAdArray = [AnyObject]()
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
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        removeMarqueFroMNavigaTion(controller: self)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        if fromTab == false{
            setDynamicTabValue()
        }
        setNavigationImage(controller: self)
        
        category_filterId = nil
        globFilterValue = ""
        updateAfterAlert = true
        searchDic.removeAll(keepingCapacity: false)
        openMenu = false
        groupUpdate = true
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GroupViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
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
            self.title = NSLocalizedString("Groups", comment: "")
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(GroupViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        
        
        browseGroup = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) ,  title: NSLocalizedString("Browse Groups",  comment: "") , border: true, selected: true)
        browseGroup.tag = 11
        browseGroup.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        browseGroup.addTarget(self, action: #selector(GroupViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browseGroup)
        
        myGroup = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) ,  title: NSLocalizedString("My Groups",  comment: "") , border: true, selected: false)
        myGroup.tag = 22
        myGroup.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        myGroup.addTarget(self, action: #selector(GroupViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myGroup)
        myGroup.isHidden = false
        
        
        let items = ["Browse Groups", "My Groups"]
        customSegmentControl = UISegmentedControl(items: items)
        
        customSegmentControl.addTarget(self, action: Selector(("indexChanged:")), for: UIControlEvents.valueChanged)
        
        customSegmentControl.frame = CGRect(x: PADING,y: TOPPADING, width: view.bounds.width - 2*PADING, height: ButtonHeight)
        customSegmentControl.selectedSegmentIndex = 0
        //        customSegmentControl.tintColor = navColor
        customSegmentControl.isHidden = true
        
        //        mainView.addSubview(customSegmentControl)
        
        
        
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: Selector(("filterSerach")), for: .touchUpInside)
        
        mainView.addSubview(filter)
        filter.isHidden = true
        
        
        if tabBarHeight > 0{
            groupTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING  + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            groupTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        
        
        groupTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree")
        groupTableView.rowHeight = 253.0
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.isOpaque = false
        groupTableView.backgroundColor = bgColor
        groupTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            groupTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(groupTableView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(GroupViewController.refresh), for: UIControlEvents.valueChanged)
        groupTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            browseGroup.isHidden = true
            myGroup.isHidden = true
            filter.frame.origin.y = TOPPADING
            groupTableView.frame.origin.y = TOPPADING
            groupTableView.frame.size.height = view.bounds.height - (TOPPADING) - tabBarHeight //(CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y)
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(GroupViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        groupTableView.tableFooterView = footerView
        groupTableView.tableFooterView?.isHidden = true

        if adsType_group != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(GroupViewController.checkforAds),
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
        if let name = defaults.object(forKey: "showGroupContent")
        {
            if  UserDefaults.standard.object(forKey: "showGroupContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showGroupContent")
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
            let presentedVC = ContentFeedViewController()//GroupDetailViewController()
            presentedVC.subjectId = createResponse["group_id"] as! Int
            presentedVC.subjectType = "group"
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    // Check for Group Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if groupUpdate {
            /*   if !isFilterSerch{
             searchDic.removeAll(keepingCapacity: false)
             }*/
            showSpinner = true
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
        
        
        if fromActivityFeed == true{
            fromActivityFeed = false
            let presentedVC  = ContentFeedViewController()
            presentedVC.subjectId = objectId
            presentedVC.subjectType = "group"
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_group == 1
        {
            if kFrequencyAdsInCells_group > 4 && placementID != ""
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
                        groupTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_group == 0
        {
            if kFrequencyAdsInCells_group > 4 && adUnitID != ""
            {
                showNativeAd()
            }
        }
        else if adsType_group == 2 {
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
            
            dic["type"] =  "\(adsType_group)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_group)"
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
                                            self.groupTableView.reloadData()
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
                
                adsImage = createImageView(CGRect(x: 0, y: 10, width: 18, height: 15), border: true)
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
                adCallToActionButton.addTarget(self, action: #selector(GroupViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                imageButton.addTarget(self, action: #selector(GroupViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
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
        dictionary["type"] =  "\(adsType_group)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_group)"
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
            groupTableView.reloadData()
        }
        
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
        
        //        if ((self.nativeAd) != nil) {
        //            self.nativeAd.unregisterView()
        //        }
        //
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 250))
            
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250))
            
        }
        self.fbView.backgroundColor = UIColor.white
        self.fbView.tag = 1001001
        
        Adiconview = createImageView(CGRect(x: self.fbView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        
        self.adIconImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        nativeAd.icon?.loadAsync(block: { (iconImage) -> Void in
            if let image = iconImage {
                self.adIconImageView.image = image
            }
            
        })
        self.fbView.addSubview(self.adIconImageView)
        
        
        adTitleLabel = UILabel(frame: CGRect(x: self.adIconImageView.bounds.width + 10 , y: 5, width: self.fbView.bounds.width-(self.adIconImageView.bounds.width + 55), height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontName, size: 16)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            adImageView = FBMediaView(frame: CGRect(x: 0 , y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y, width: self.fbView.bounds.width, height: 140))
        }
        else
        {
            adImageView = FBMediaView(frame: CGRect(x: 0 , y: self.adIconImageView.bounds.height+10+self.adIconImageView.frame.origin.y, width: self.fbView.bounds.width, height: 140))
        }
        self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        self.fbView.addSubview(adImageView)
        
        
        adBodyLabel = UILabel(frame: CGRect(x: 10 , y: adImageView.bounds.height + 10 + adImageView.frame.origin.y, width: self.fbView.bounds.width-100, height: 40))
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.font = UIFont(name: "FontAwesome", size: 14)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        self.fbView.addSubview(adBodyLabel)
        
        
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: adImageView.bounds.height + 15 + adImageView.frame.origin.y, width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControlState())
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
        
    }
    
    public func nativeAdsFailedToLoadWithError(_ error: Error)
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
        if nativeAdArray.count == 10
        {
            groupTableView.reloadData()
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
            self.groupTableView.reloadData()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if groupResponse.count != 0{
        if reachability.connection != .none {
            searchDic.removeAll(keepingCapacity: false)
            self.groupTableView.isUserInteractionEnabled = false
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        // }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search_text"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    // Handle Browse Blog or My Blog PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Browse Blog & false for My Blog
        if refresher.isRefreshing
        {
            refresher.endRefreshing()
        }
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22
        {
            browseOrMyGroup = false
        }
        else if sender.tag == 11
        {
            browseOrMyGroup = true
        }
        groupTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Blog
        browseEntries()
    }
    
    // Create Group Form
    @objc func addNewGroup(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Create New Group", comment: "")
            presentedVC.contentType = "group"
            presentedVC.param = [ : ]
            presentedVC.url = "groups/create"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
            
        }
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
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
    
    @objc func showGroup(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var groupInfo:NSDictionary!
        groupInfo = groupResponse[sender.tag] as! NSDictionary
        
        if(groupInfo["allow_to_view"] as! Int == 1){
            let presentedVC = ContentFeedViewController()//GroupDetailViewController()
            presentedVC.subjectId = groupInfo["group_id"] as! Int
            presentedVC.subjectType = "group"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            
        }
    }

    @objc func groupMenu(_ sender:UIButton){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        var groupInfo:NSDictionary
        groupInfo = groupResponse[sender.tag] as! NSDictionary
        // editGroupID = groupInfo["group_id"] as! Int
        if(groupInfo["menu"] != nil){
            let menuOption = groupInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                                
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Group", comment: ""),message: NSLocalizedString("Are you sure you want to delete this group?", comment: "") , otherButton: NSLocalizedString("Delete Group", comment: "")) { () -> () in
                                    self.updateGroupMenuAction(menuItem["url"] as! String)
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
                                // self.openGroupForm()
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Group", comment: "")
                                presentedVC.contentType = "group"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                                
                            case "leave_group":
                                displayAlertWithOtherButton(NSLocalizedString("Leave Group", comment: ""),message: NSLocalizedString("Are you sure you want to leave this group?", comment: "") , otherButton: NSLocalizedString("Leave Group", comment: "")) { () -> () in
                                    self.updateGroupMenuAction(menuItem["url"] as! String)
                                    
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
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func updateGroupMenuAction(_ url : String){
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
            
            var method = "POST"
            
            
            if (url.range(of: "delete") != nil){
                method = "DELETE"
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Blog Detail
                        // Update Group Detail
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
            // info.removeFromSuperview()
            
            //            if showOnlyMyContent == true{
            //                browseOrMyGroup = false
            //            }
            
            
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            var path = ""
            var parameters = [String:String]()
            
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyGroup = true
            }
            
            
            // Set Parameters for Browse/MyBlog
            if browseOrMyGroup {
                path = "groups/browse"
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id)]
                }else{
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                }
                browseGroup.setSelectedButton()
                myGroup.setUnSelectedButton()
            }else{
                path = "groups/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                browseGroup.setUnSelectedButton()
                myGroup.setSelectedButton()
            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            if (self.pageNumber == 1)
            {
                self.groupResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true
                {
                    removeAlert()
                    
                    if let responseCacheArray = self.responseCache["\(path)"]
                    {
                        groupResponse = responseCacheArray as! [AnyObject]
                        //  showSpinner = false
                    }
                    
                    self.groupTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
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
                //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.groupTableView.isUserInteractionEnabled = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.groupTableView.tableFooterView?.isHidden = true
                    self.groupResponse.removeAll(keepingCapacity: false)
                    if msg{
                        
                        self.isPageRefresing = false
                        
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSDictionary{
                                if let group = response["response"] as? NSArray {
                                    self.groupResponse = self.groupResponse + (group as [AnyObject])
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = group
                                    }
                                }
                                if self.showOnlyMyContent == false{
                                    if (response["canCreate"] as! Bool == true){
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(GroupViewController.searchItem))
                                        let addGroup = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(GroupViewController.addNewGroup))
                                        
                                        self.navigationItem.setRightBarButtonItems([addGroup,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addGroup.tintColor = textColorPrime
                                        
                                        self.showAppTour()
                                    }else{
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(GroupViewController.searchItem))
                                        
                                        self.navigationItem.rightBarButtonItem = searchItem
                                        searchItem.tintColor = textColorPrime
                                    }
                                }
                                if response["totalItemCount"] != nil{
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                            }
                        }
                        
                        if self.groupResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(groupIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Group entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
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
                            self.refreshButton.addTarget(self, action: #selector(GroupViewController.browseEntries), for: UIControlEvents.touchUpInside)
                            
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                        }
                        //Reload Blog Tabel
                        if self.groupResponse.count > 0
                        {
                            self.groupTableView.reloadData()
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
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    // MARK: - Orientation
    
    // MARK:  TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        //print(components)
        
        
        let type = components["type"] as! String
        
        switch(type){
            
        case "user":
            print("user")
        default:
            print("default")
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_group > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_group) == (kFrequencyAdsInCells_group)-1))
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 430
            }
            else if adsType_event == 0
            {
                return 265
            }
            else
            {
                return adsCellheight
            }
        }
        else
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 430
            }
            else
            {
                return 250
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
        
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                rowcount = 2*(kFrequencyAdsInCells_group-1)
            }
            else
            {
                rowcount = (kFrequencyAdsInCells_group-1)
            }
            if groupResponse.count > rowcount
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let b = Int(ceil(Float(groupResponse.count)/2))
                    adsCount = b/(kFrequencyAdsInCells_group-1)
                    if adsCount > 1 || groupResponse.count%2 != 0
                    {
                        adsCount = adsCount/2
                    }
                    let Totalrowcount = adsCount+b
                    if b%(kFrequencyAdsInCells_group-1) == 0 && groupResponse.count % 2 != 0
                    {
                        if adsCount%2 != 0
                        {
                            return Totalrowcount - 1
                        }
                    }
                    else if groupResponse.count % 2 != 0 && adsCount % 2 == 0
                    {
                        
                        return Totalrowcount - 1
                    }
                    return Totalrowcount
                }
                else
                {
                    let b = groupResponse.count
                    adsCount = b/(kFrequencyAdsInCells_group-1)
                    let Totalrowcount = adsCount+b
                    if Totalrowcount % kFrequencyAdsInCells_group == 0
                    {
                        return Totalrowcount-1
                    }
                    else
                    {
                        return Totalrowcount
                    }
                }
            }
            else
            {
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(groupResponse.count)/2))
                }
                else
                {
                    return groupResponse.count
                }
            }
            
        }
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(groupResponse.count)/2))
        }else{
            return groupResponse.count
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if self.groupResponse.count > 0
        {
            var row = (indexPath as NSIndexPath).row as Int
            if (kFrequencyAdsInCells_group > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_group) == (kFrequencyAdsInCells_group)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                groupTableView.register(NativeGroupCell.self, forCellReuseIdentifier: "Cell1")
                let cell = groupTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeGroupCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_group-1)
                
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
                    
                    var groupInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_video
                    if(groupResponse.count > ((row)*2-adcount) ){
                        groupInfo2 = groupResponse[((row)*2-adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2-adcount)
                        cell.menu2.tag = ((row)*2-adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    if browseOrMyGroup {
                        cell.contentSelection2.frame.size.height = 250
                    }else{
                        cell.contentSelection2.frame.size.height = 175
                    }
                    
                    // Select Group Action
                    cell.contentSelection2.addTarget(self, action: #selector(GroupViewController.showGroup(_:)), for: .touchUpInside)
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(GroupViewController.groupMenu(_:)) , for: .touchUpInside)
                    
                    // Set Group Image
                    
                    
                    if let photoId = groupInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            cell.contentImage2.backgroundColor = placeholderColor
                            
                            if let url = URL(string: groupInfo2["image"] as! NSString as String){
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            
                        }else{
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Group Name
                    let name = groupInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = groupInfo2["owner_title"] as? String
                    let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
                    
                    let members = groupInfo2["member_count"] as? Int
                    let fontIcon1 = "\u{f007}"
                    
                    _ = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 20)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    
                    cell.totalMembers2.frame = CGRect(x: 10, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-20), height: 20)
                    cell.totalMembers2.text = "\u{f19d} \(text)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 100, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(fontIcon1)  \(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.left
                    cell.eventTime2.textColor = textColorLight
                    cell.eventTime2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    if browseOrMyGroup {
                        cell.menu2.isHidden = true
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 10)
                    }else{
                        cell.menu2.isHidden = false
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    }
                    
                }
                
                return cell
                
            }
            else
            {
                
                if kFrequencyAdsInCells_group > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_group)
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! GroupTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.backgroundColor = bgColor
                if browseOrMyGroup {
                    cell.contentSelection.frame.size.height = 250
                }else{
                    cell.contentSelection.frame.size.height = 175
                }
                
                
                // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
                
                var groupInfo:NSDictionary!
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    
                    if (kFrequencyAdsInCells_group > 4 && nativeAdArray.count > 0)
                    {
                        let adcount = row/(kFrequencyAdsInCells_group-1)
                        if(groupResponse.count > ((row)*2+adcount))
                        {
                            groupInfo = groupResponse[((row)*2+adcount)] as! NSDictionary
                            cell.contentSelection.tag = ((row)*2+adcount)
                            cell.menu.tag = ((row)*2+adcount)
                            
                        }
                    }
                    else
                    {
                        if(groupResponse.count > (row)*2)
                        {
                            groupInfo = groupResponse[(row)*2] as! NSDictionary
                            cell.contentSelection.tag = (row)*2
                            cell.menu.tag = (row)*2
                            
                        }
                    }
                    
                }
                else
                {
                    groupInfo = groupResponse[row] as! NSDictionary
                    cell.contentSelection.tag = row
                    cell.menu.tag = row
                }
                
                //Select Group Action
                cell.contentSelection.addTarget(self, action: #selector(GroupViewController.showGroup(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.menu.addTarget(self, action:#selector(GroupViewController.groupMenu(_:)) , for: .touchUpInside)
                
                // Set Group Image
                if let photoId = groupInfo["photo_id"] as? Int{
                    if photoId != 0{
                        cell.contentImage.image = nil
                        cell.contentImage.backgroundColor = placeholderColor
                        if let url1 = URL(string: groupInfo["image"] as! NSString as String){
                            cell.contentImage.kf.indicatorType = .activity
                            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                    }
                    else{
                        cell.contentImage.image = nil
                        cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
                }
                
                // Set Group Name
                let name = groupInfo["title"] as? String
                let tempString = name! as NSString
                var value : String
                if tempString.length > 30{
                    value = tempString.substring(to: 27)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                let owner = groupInfo["owner_title"] as? String
                //        let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
                let tempStringValue = owner! as NSString
                var stringValue : String
                if tempStringValue.length > 17{
                    stringValue = tempStringValue.substring(to: 14)
                    stringValue += NSLocalizedString("...",  comment: "")
                }else{
                    stringValue = "\(tempStringValue)"
                }
                let text = String(format: NSLocalizedString("led by %@", comment:""),stringValue)
                
                let members = groupInfo["member_count"] as? Int
                let fontIcon1 = "\u{f007}"
                
                let a = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 20)
                cell.contentName.text = " \(value)"
                cell.contentName.font = UIFont(name: fontBold, size: FONTSIZENormal)
                
                cell.totalMembers.frame = CGRect(x: 10, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
                cell.totalMembers.text = "\u{f19d} \(text)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 100, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
                cell.eventTime.text = "\(fontIcon1)  \(a)"
                cell.eventTime.textAlignment = NSTextAlignment.left
                cell.eventTime.textColor = textColorLight
                cell.eventTime.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
                // Set Menu
                if browseOrMyGroup {
                    cell.menu.isHidden = true
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
                }else{
                    cell.menu.isHidden = false
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
                }
                
                // RHS
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var groupInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_video-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    
                    if(groupResponse.count > ((row)*2+1+adcount) ){
                        groupInfo2 = groupResponse[((row)*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2+1+adcount)
                        cell.menu2.tag = ((row)*2+1+adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    if browseOrMyGroup {
                        cell.contentSelection2.frame.size.height = 250
                    }else{
                        cell.contentSelection2.frame.size.height = 175
                    }
                    
                    // Select Group Action
                    cell.contentSelection2.addTarget(self, action: #selector(GroupViewController.showGroup(_:)), for: .touchUpInside)
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(GroupViewController.groupMenu(_:)) , for: .touchUpInside)
                    
                    // Set Group Image
                    
                    
                    if let photoId = groupInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            cell.contentImage2.backgroundColor = placeholderColor
                            
                            if let url = URL(string: groupInfo2["image"] as! NSString as String){
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            
                        }else{
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Group Name
                    let name = groupInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = groupInfo2["owner_title"] as? String
                    let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
                    
                    let members = groupInfo2["member_count"] as? Int
                    let fontIcon1 = "\u{f007}"
                    
                    _ = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 20)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: "FontAwesome", size: 18)
                    
                    cell.totalMembers2.frame = CGRect(x: 10, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                    cell.totalMembers2.text = "\u{f19d} \(text)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 100, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(fontIcon1)  \(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.left
                    cell.eventTime2.textColor = textColorLight
                    cell.eventTime2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    if browseOrMyGroup {
                        cell.menu2.isHidden = true
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 10)
                    }else{
                        cell.menu2.isHidden = false
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    }
                    
                }
                
                return cell
            }
            
        }

        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! GroupTableViewCell
            return cell
        }
    }
    
    // Handle Blog Table Cell Selection
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
                if (!isPageRefresing  && limit*pageNumber < totalItems)
                {
                    if reachability.connection != .none
                    {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        groupTableView.tableFooterView?.isHidden = false
                       // if searchDic.count == 0{
                            if adsType_group == 2 || adsType_group == 4
                            {
                                delay(0.1)
                                {
                                    self.checkforAds()
                                }
                            }
                    }
                    browseEntries()
                }
                else
                {
                    groupTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    
    @objc func searchItem(){
        let presentedVC = GroupSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "groups/search-form"
        loadFilter(url)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFB.invalidate()
        groupTableView.tableFooterView?.isHidden = true
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

