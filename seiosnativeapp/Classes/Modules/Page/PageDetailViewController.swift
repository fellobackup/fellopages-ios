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
//  PageDetailViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

var pageDetailUpdate = true
var sitevideoPluginEnabled_page : Int = 0
class PageDetailViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate, UITextViewDelegate , UITabBarControllerDelegate{
    
    var RedirectText : String!
    var like_comment : UIView!
    var lastContentOffset: CGFloat = 0
    var subjectId:Int!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var feedFilter: UIButton!                   // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempcontentFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var contentUrl : String!
    var shareDescription : String!
    var coverImageUrl : String! = ""
    var productMoreOrLess : UIButton!
    var productMoreOrLessView :UIView!
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var contentName:UILabel!
    var tabsContainerMenu:UIScrollView!
    var staticTabMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var detailWebView : UITextView!
    var maxHeight : CGFloat!
    var contentTitle : String!
    var shareTitle:String!
    var user_id : Int!
    var ownerName : UILabel!
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 320.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 100.0 // The distance between the bottom of the Header and the top of the White Label
    var contentview : UIView!
    var deleteContent : Bool!
    var popAfterDelay:Bool!
    var gutterMenu:NSMutableArray = []
    var filterGutterMenu: NSArray = []
    var topView: UIView!
    var imgUser: UIImageView!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var info : UILabel!
    var toastView : UIView!
    var UserId:Int!
 //   var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var action_id:Int!
    var actionIdArray = [Int]()
    var noCommentMenu:Bool = false
    var descRedirectionButton : UIButton!
    var mainView = UIView()
    var deleteListingEntry:Bool!
    var webviewText : String!
    var feedObj = FeedTableViewController()
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var profileView = UIView()
    var tabMenuPage: NSArray = []
    var followUrl = ""
    var reviewUrl = ""
    var StaticView : UITextView!
    var checkUpdate : Bool = false
    var marqueeHeader : MarqueeLabel!
    var leftBarButtonItem : UIBarButtonItem!
    var contactInfo = NSDictionary()
    var isowner = Bool()
    let subscriptionNoticeLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    
    // For Cover Photo
    
    var memberProfilePhoto:UIImageView!
    var userCoverPicUrl : String!
    var topMainView : UIView!
    var contentSelection : UIButton!
    var profilePhotoMenu: NSArray = []
    var coverPhotoMenu: NSArray = []
    var imageMenus: NSArray = []
    var profileOrCoverChange: Bool!
    var camIconOnCover: UILabel!
    var camIconOnProfile: UILabel!
    var userProfilePicUrl : String!
    var coverValue : Int! = 0
    var profileValue : Int! = 0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = aafBgColor//UIColor.white
        navigationController?.navigationBar.isHidden = false
        maxid = 0       // Set Default maxid for browseFeed
        
        pageUpdate = false
        checkUpdate = false
        tableViewFrameType = "Pages"
        pageDetailUpdate = true
        deleteListingEntry = false
        contentFeedArray.removeAll(keepingCapacity: false)
        self.feedObj.globalArrayFeed = contentFeedArray
        self.tabBarController?.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        feedObj.willMove(toParentViewController: self)
        self.view.addSubview(feedObj.view)
        self.addChildViewController(feedObj)
        NotificationCenter.default.addObserver(self, selector: #selector(PageDetailViewController.ScrollingactionPage(_:)), name: NSNotification.Name(rawValue: "ScrollingactionPage"), object: nil)
        
        removeNavigationImage(controller: self)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        else
        {
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        mainSubView.backgroundColor = aafBgColor
        self.feedObj.tableView.addSubview(mainSubView)
        
        coverImage = CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height))
        coverImage.contentMode = UIViewContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = placeholderColor
        coverImage.tag = 123
        coverImage.isUserInteractionEnabled = true
        mainSubView.addSubview(coverImage)
        
        contentview = createView(CGRect(x: 0, y: coverImage.bounds.height-45, width: view.bounds.width, height: 115), borderColor: UIColor.clear, shadow: false)
        contentview.backgroundColor = UIColor.clear
        coverImage.addSubview(contentview)
        
        contentName = createLabel(CGRect(x: contentPADING, y: 0, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        contentName.font = UIFont(name: fontBold, size: 25)
        contentName.numberOfLines = 3
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        contentview.addSubview(contentName)
        
        topView = createView(CGRect(x: 0, y: coverImage.bounds.height , width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor //UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        self.feedObj.tableView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        label1 = TTTAttributedLabel(frame:CGRect(x: PADING,y: 10,width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label3 = TTTAttributedLabel(frame:CGRect(x: PADING,y: 10,width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label1.isHidden = true
        label1.backgroundColor = UIColor.clear
        label3.backgroundColor = UIColor.clear
        label3.isHidden = true
        
        profileView.addSubview(label1)
        profileView.addSubview(label3)
        
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        imgUser.image = UIImage(named: "user_profile_image.png")
        topView.addSubview(imgUser)
        
        StaticView = createTextView(CGRect(x: PADING,y: TOPPADING , width: view.bounds.width - 2 * PADING, height: 10), borderColor: borderColorMedium, corner: false )
        StaticView.backgroundColor = textColorLight
        StaticView.isHidden = true
        view.addSubview(StaticView)
        
        detailWebView = createTextView(CGRect(x: PADING,y: mainSubView.bounds.height+TOPPADING+6 , width: view.bounds.width - 2 * PADING, height: 10), borderColor: borderColorMedium, corner: false )
        detailWebView.backgroundColor = bgColor
        detailWebView.isUserInteractionEnabled = true
        detailWebView.isEditable = false
        detailWebView.delegate = self
        detailWebView.text = NSLocalizedString("",  comment: "")
        detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
        detailWebView.textColor = textColorDark
        detailWebView.layer.borderWidth = 0.0
        detailWebView.isHidden = true
        mainSubView.addSubview(detailWebView)
        
        productMoreOrLessView = createView(CGRect(x: PADING, y: detailWebView.frame.size.height + detailWebView.frame.origin.y ,  width: view.bounds.width - 2 * PADING, height: 30), borderColor: UIColor.white, shadow: false)
        productMoreOrLessView.isHidden = true
        productMoreOrLessView.backgroundColor = UIColor.white
        mainSubView.addSubview(productMoreOrLessView)
        
        productMoreOrLess = createButton(CGRect(x: self.view.bounds.width - 50, y: 0 ,  width: 40, height: 30), title: "More", border: false,bgColor: false, textColor: navColor)
        productMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        productMoreOrLess.isHidden = true
        productMoreOrLess.addTarget(self, action: #selector(PageDetailViewController.showFeedFilterOptions), for: .touchUpInside)
        productMoreOrLessView.addSubview(productMoreOrLess)
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: PADING, y: 350,width: view.bounds.width-2*PADING ,height: ButtonHeight ))
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.isHidden = true
        self.feedObj.tableView.addSubview(tabsContainerMenu)
        
        staticTabMenu = UIScrollView(frame: CGRect(x: PADING, y: TOPPADING,width: view.bounds.width-2*PADING ,height: ButtonHeight ))
        staticTabMenu.isHidden = true
        staticTabMenu.backgroundColor = TabMenubgColor
        view.addSubview(staticTabMenu)
        
        feedFilter = createButton(CGRect(x: PADING, y: 2*contentPADING , width: view.bounds.width - 2 * PADING, height: ButtonHeight),title: NSLocalizedString("Everyone",  comment: "") , border: false, bgColor: false,textColor: textColorMedium)
        feedFilter.isEnabled = false
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedFilter.isHidden = true
        feedFilter.addTarget(self, action: #selector(PageDetailViewController.showFeedFilterOption(_:)), for: .touchUpInside)
        self.feedObj.tableView.addSubview(feedFilter)
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(PageDetailViewController.refresh), for: UIControlEvents.valueChanged)
        self.feedObj.tableView.addSubview(refresher)
        
        // Cover Photo and Profile Photo
        
        camIconOnCover = createLabel(CGRect(x: coverImage.bounds.width - 30, y: coverImage.bounds.height - 30, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = true
        coverImage.addSubview(camIconOnCover)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            memberProfilePhoto = createImageView(CGRect(x: 20, y: coverImage.bounds.height - (2 * contentPADING) - 100, width: 100, height: 100 ), border: true)
        }else{
            memberProfilePhoto = createImageView(CGRect(x: 10, y: coverImage.bounds.height - (2 * contentPADING) - 80, width: 80, height: 80), border: true)
        }
        
        memberProfilePhoto.layer.borderColor = UIColor.white.cgColor
        memberProfilePhoto.layer.borderWidth = 2.5
        memberProfilePhoto.layer.cornerRadius = memberProfilePhoto.frame.size.width / 2
        memberProfilePhoto.backgroundColor = placeholderColor
        memberProfilePhoto.contentMode = UIViewContentMode.scaleAspectFill
        memberProfilePhoto.layer.masksToBounds = true
        memberProfilePhoto.image = UIImage(named: "user_profile_image.png")
        memberProfilePhoto.tag = 321
        memberProfilePhoto.isUserInteractionEnabled = true
        mainSubView.addSubview(memberProfilePhoto)
        
        memberProfilePhoto.isHidden = true
       
        camIconOnProfile = createLabel(CGRect(x: (memberProfilePhoto.bounds.width/2) - 15, y: memberProfilePhoto.bounds.height - 30, width: 30, height: 30), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnProfile.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        
        camIconOnProfile.layer.shadowColor = shadowColor.cgColor
        camIconOnProfile.layer.shadowOpacity = shadowOpacity
        camIconOnProfile.layer.shadowRadius = shadowRadius
        camIconOnProfile.layer.shadowOffset = shadowOffset
        camIconOnProfile.isHidden = true
        memberProfilePhoto.addSubview(camIconOnProfile)
        
        
        self.automaticallyAdjustsScrollViewInsets = false;
        // Do any additional setup after loading the view.
        
  
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.browseEmoji(contentItems: reactionsDictionary)
        //  updateAfterAlert = false
        tableViewFrameType = "Pages"
        NotificationCenter.default.addObserver(self, selector: #selector(PageDetailViewController.ScrollingactionPage(_:)), name: NSNotification.Name(rawValue: "ScrollingactionPage"), object: nil)
        removeNavigationImage(controller: self)
        //scrollopoint = CGPointMake(0, 0)
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        let allviews = view.subviews
        for obj in allviews
        {
            if obj .isKind(of: Like_CommentView.self)
            {
                obj.removeFromSuperview()
            }
        }
        
        likeCommentContent_id = subjectId
        likeCommentContentType = "sitepage_page"
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        like_comment.alpha = 1
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
        subject_unique_id =  subjectId
        subject_unique_type = "sitepage_page"
        
        if pageDetailUpdate == true{
            IsRedirctToVideoProfile(videoTypeCheck : "Pages",navigationController:navigationController!)
            if(UIDevice.current.userInterfaceIdiom == .pad){
                profileView = createView(CGRect(x: PADING, y: 460, width: view.bounds.width - 2 * PADING, height: 100), borderColor: borderColorDark, shadow: false)
            }
            else{
                profileView = createView(CGRect(x: PADING, y: 345, width: view.bounds.width - 2 * PADING, height: 100), borderColor: borderColorDark, shadow: false)
            }
            profileView.layer.borderWidth = 0.0
            // profileView.backgroundColor = UIColor.white
            mainSubView.addSubview(profileView)
            
            label1.isHidden = true
            label3.isHidden = true
            profileView.isHidden = true
            
            // Set Default & request to hard Refresh
            pageDetailUpdate = false
            feedUpdate = false
            maxid = 0
            
            showSpinner = true
            feed_filter = 1
            exploreContent()
        }
        else{
            staticTabMenu.isHidden = true
            if logoutUser == false
            {
                globalFeedHeight = self.feedFilter.frame.origin.y + 10 + ButtonHeight
            }
            else
            {
                globalFeedHeight = getBottomEdgeY(inputView: self.feedFilter)
            }
            self.feedObj.globalArrayFeed = contentFeedArray
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                feedObj.tableView.reloadData()
            }else{
                fromExternalWebView = false
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        feedObj.tableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        tableViewFrameType = ""
        removeMarqueFroMNavigaTion(controller: self)
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = textColorPrime
        self.navigationController?.navigationBar.alpha = 1
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Activity Feed Filter Options & Gutter Menu
    
    // Show Feed Filter Options Action
    @objc func showFeedFilterOption(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        //      if logoutUser != true {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in filterGutterMenu{
            if let dic = menu as? NSDictionary{
                alertController.addAction(UIAlertAction(title: (dic["tab_title"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    // Set Feed Filter Option Title
                    self.feedFilter.setTitle((dic["tab_title"] as! String), for: UIControlState())
                    self.feedFilterFlag = true
                    
                    // Set Parameters for Feed Filter
                    if let params = dic["urlParams"] as? NSDictionary{
                        for (key, value) in params{
                            if let id = value as? NSNumber {
                                searchDic["\(key)"] = String(id as! Int)
                            }
                            
                            if let receiver = value as? NSString {
                                searchDic["\(key)"] = receiver as String
                            }
                        }
                    }
                    
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    contentFeedArray.removeAll(keepingCapacity: false)
                    self.dynamicRowHeight.removeAll(keepingCapacity: false)
                    self.maxid = 0
                    self.feed_filter = 1
                     self.showSpinner = true
                    self.browseFeed()
                    
                }))
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    func exploreContent(){
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

            
            // Send Server Request to Explore Page Contents with Page_ID
            post([ "gutter_menu": "1"], url: "sitepage/view/" + String(subjectId), method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Page Detail
                        
                        if let listing = succeeded["body"] as? NSDictionary {
                            if let sitevideoPluginEnabled = listing["sitevideoPluginEnabled"] as? Int
                            {
                                sitevideoPluginEnabled_page = sitevideoPluginEnabled
                            }
                            if let owner_id = listing["owner_id"] as? Int{
                                self.user_id = owner_id
                            }
                            
                            if let menu = listing["gutterMenu"] as? NSArray{
                                var isCancel = false
                                self.gutterMenu  = menu as NSArray as! NSMutableArray
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        if tempDic["name"] as! String == "share" {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                    }
                                }
                                
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControlState())
                                    shareButton.addTarget(self, action: #selector(PageDetailViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControlState())
                                    optionButton.addTarget(self, action: #selector(PageDetailViewController.showGutterMenu), for: .touchUpInside)
                                //    rightNavView.addSubview(optionButton)
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    let barButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = barButtonItem
                                }
                                
                            }
                            
                            // Update Group tabContainer Menu
                            if let tabsContainerMenuItems = listing["profile_tabs"] as? NSArray
                            {
                                self.tabMenuPage = tabsContainerMenuItems as NSArray
                                self.tabsContainerMenu.isHidden = false
                            }
                            
                            let response = listing
                            
                            if response.count > 0{
                                
                                // set Page Title
                                self.shareTitle = response["title"] as? String
                                self.contentName.font = UIFont(name: fontName, size: 30)
                                
                                self.ownerName.text = response["owner_title"] as? String
                                if let url = URL(string: response["owner_image_normal"] as! String){
                             
                                    self.imgUser.kf.indicatorType = .activity
                                    (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        if let img = image{
                                          self.imgUser.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                        }
                                        
                                    })
                                    
                                }
                                
                                 if let _ : Int = response["default_cover"] as? Int{
                               
                                    
                                    let tap1 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.showProfileCoverImageMenu(_:)))
                                    self.coverImage.addGestureRecognizer(tap1)
                                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.showProfileCoverImageMenu(_:)))
                                    self.memberProfilePhoto.addGestureRecognizer(tap2)
                                    
                                    if let cover : Int = response["default_cover"] as? Int{
                                        
                                        if (response["cover_image"] as? String) != nil{
                                            
                                            
                                            if cover == 1{
                                                self.coverValue = 0
                                            }
                                            else{
                                                self.coverValue = 1
                                            }
                                        }
                                        else{
                                            self.coverValue = cover
                                        }
                                        
                                    }
                                    
                                    
                                   // self.coverValue = response["default_cover"] as! Int
                                    
                                    self.contentName.text = response["title"] as? String
                                    
                                    if let _ = response["title"] as? String
                                    {
                                        self.contentTitle = (response["title"] as? String)!
                                        self.contentName.font = UIFont(name: fontBold, size: 27)
                                        self.contentview.frame.origin.x = self.memberProfilePhoto.bounds.width + 15
                                        self.contentview.frame.origin.y = self.coverImage.bounds.height-60
                                        self.contentName.frame.size.width = self.view.bounds.width - (self.memberProfilePhoto.bounds.width + 20)
                                        self.contentview.frame.size.width = self.view.bounds.width - (self.memberProfilePhoto.bounds.width + 15)
                                        if self.contentTitle.length > 15{
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-70
                                        }
                                        if self.contentTitle.length > 20{
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-90
                                        }
                                        if self.contentTitle.length > 42
                                        {
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-110
                                        }
                                    }
                                    
                                    self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.contentName.sizeToFit()
                                    

                                    if let photoId = response["photo_id"] as? Int
                                    {
                                        
                                        if photoId != 0{
                                            self.profileValue = 1
                                        }
                                        if (response["cover_image"] as? String) != nil{
                                            self.coverImageUrl = response["cover_image"] as! String
                                        }

                                        
                                        self.userCoverPicUrl = self.coverImageUrl
                                        
                                        if self.coverImageUrl != ""{
                                            if let url = URL(string: response["cover_image"] as! String){
                                                self.coverImage.kf.indicatorType = .activity
                                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    
                                                })
                                            }}else{
                                            self.coverImage.image =  imageWithImage( UIImage(named: "plain-backgrounds.jpg")!, scaletoWidth: self.coverImage.bounds.width)
                                            
                                        }
                                    }
                                    self.getCoverGutterMenu()
                                    self.memberProfilePhoto.isHidden = false
                                    
                                    self.userProfilePicUrl = response["image"] as! String
                                   
                                    if (response["cover_image"] as? String) != nil{
                                        
                                        self.userCoverPicUrl = response["cover_image"] as! String
                                    }

                                    //self.camIconOnProfile.isHidden  = false
                                    if let url = URL(string: response["image"] as! String){
                                 
                                        self.memberProfilePhoto.kf.indicatorType = .activity
                                         (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            if let img = image{
                                                  self.memberProfilePhoto.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                            }
                                            
                                        })
                                        
                                    }

 
                                }
                                 
                                else{
                                
                                let tap1 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.onImageViewTap))
                                    self.coverImage.addGestureRecognizer(tap1)
                                    self.contentName.text = response["title"] as? String
                                    
                                    if let _ = response["title"] as? String
                                    {
                                        self.contentTitle = (response["title"] as? String)!
                                        if self.contentTitle.length > 20{
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-75
                                        }
                                        if self.contentTitle.length > 42
                                        {
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-110
                                        }
                                    }
                                    
                                    self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.contentName.sizeToFit()
   
                                    
                                if let photoId = response["photo_id"] as? Int
                                {
                                    self.coverImageUrl = response["image"] as! String
                                    
                                    if photoId != 0{
                                        if let url = URL(string: response["image"] as! String){
                                            self.coverImage.kf.indicatorType = .activity
                                            (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                
                                            })
                                        }}else{
                                        self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                                        
                                    }
                                }
                                }
                                
                                
                                self.contentUrl =  response["content_url"] as! String
                                
                                var origin_labelheight_y = self.topView.bounds.height + self.topView.frame.origin.y + 20
                                var origin_labelheight_y2 = self.topView.bounds.height + self.topView.frame.origin.y + 20
                                
                                var labelKey : String!
                                var labelDesc : String!
                                
                                var labelKey2 : String!
                                var labelDesc2 : String!
                                
                                var profileFieldString = ""
                                var profileFieldString2 = ""
                                
                                var flag : Bool = false
                                if listing["profile_fields"] != nil {
                                    
                                    if let profileField = listing["profile_fields"] as? NSDictionary{
                                        
                                        self.profileView.isHidden = false
                                        self.profileView.backgroundColor = UIColor.white
                                        if profileField.count > 0{
                                            flag = true
                                            var loop : Int = 0
                                            for(k,v) in profileField{
                                                
                                                if loop % 2 == 0{
                                                    
                                                    self.label1 = TTTAttributedLabel(frame:CGRect(x: 2 * PADING,y: origin_labelheight_y,width: self.mainSubView.bounds.width/2 - 2 * PADING , height: 30) )
                                                    self.label1.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                    self.label1.textColor = textColorDark
                                                    self.label1.isHidden = false
                                                    
                                                    labelKey = ((k as? String)! + ": ")
                                                    
                                                    if v is NSInteger
                                                    {
                                                        labelDesc = "\(v)"
                                                        profileFieldString = labelKey + "\(labelDesc!)" + "\n" + "\n"
                                                    }
                                                    else if v is CGFloat
                                                    {
                                                        labelDesc = String(describing: v)
                                                        profileFieldString = labelKey + labelDesc + "\n" + "\n"
                                                    }
                                                    else
                                                    {
                                                        labelDesc = (v as? String)
                                                        profileFieldString = ((labelKey as String) + (labelDesc as String)) + "\n" + "\n"
                                                    }
                                                    
                                                    //      profileFieldString = ((labelKey as! String) + (labelDesc as! String)) as AnyObject
                                                    
                                                    self.label1.longPressLabel()
                                                    self.label1.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                    self.label1.numberOfLines = 0
                                                    self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                    
                                                    self.label1.text = profileFieldString
                                                    self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                        
                                                        
                                                        let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal , nil)
                                                        
                                                        let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                        
                                                        return mutableAttributedString
                                                    })
                                                    
                                                    self.label1.sizeToFit()
                                                    
                                                    origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height
                                                    
                                                    loop = loop + 1
                                                    
                                                    self.mainSubView.addSubview(self.label1)
                                                }
                                                else
                                                {
                                                    
                                                    loop = loop + 1
                                                    
                                                    self.label3 = TTTAttributedLabel(frame:CGRect(x: self.mainSubView.bounds.width/2 + 2 * PADING,y: origin_labelheight_y2,width: self.mainSubView.bounds.width/2 - 3 * PADING, height: 30) )
                                                    
                                                    self.label3.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                    self.label3.textColor = textColorDark
                                                    self.label3.longPressLabel()
                                                    self.label3.isHidden = false
                                                    
                                                    labelKey2 = ((k as? String)! + ": ") as AnyObject as! String
                                                    
                                                    
                                                    
                                                    if v is NSInteger
                                                    {
                                                        labelDesc2 = "\(v)"
                                                        profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                    }
                                                    else if v is CGFloat
                                                    {
                                                        labelDesc2 = String(describing: v)
                                                        profileFieldString2 = labelKey2 + labelDesc2 + "\n" + "\n"
                                                    }
                                                    else
                                                    {
                                                        labelDesc2 = (v as? String)
                                                        profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                    }
                                                    
                                                    self.label3.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                    self.label3.numberOfLines = 0
                                                    self.label3.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                    
                                                    self.label3.text = profileFieldString2
                                                    
                                                    self.label3.setText(profileFieldString2 , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                        
                                                        let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                        
                                                        let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                        mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                        
                                                        
                                                        return mutableAttributedString
                                                    })
                                                    
                                                    self.label3.sizeToFit()
                                                    
                                                    origin_labelheight_y2  = origin_labelheight_y2 + self.label3.bounds.height
                                                    
                                                    self.mainSubView.addSubview(self.label3)
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                            
                                        else
                                        {
                                            
                                            origin_labelheight_y = origin_labelheight_y - 15
                                        }
                                        self.profileView.sizeToFit()
                                        
                                    }
                                }
                                else{
                                    origin_labelheight_y = origin_labelheight_y - 25
                                    origin_labelheight_y2 = origin_labelheight_y2 - 25
                                }
                                
                                
                                if origin_labelheight_y2 > origin_labelheight_y{
                                    
                                    self.detailWebView.frame.origin.y = origin_labelheight_y2 + 33
                                    self.profileView.frame.size.height = origin_labelheight_y2 - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    
                                }
                                else if origin_labelheight_y2 < origin_labelheight_y{
                                    self.detailWebView.frame.origin.y = origin_labelheight_y + 33
                                    self.profileView.frame.size.height = origin_labelheight_y - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    
                                }
                                else{
                                    if flag == false{
                                        self.detailWebView.frame.origin.y = origin_labelheight_y
                                        self.profileView.frame.size.height = origin_labelheight_y - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    }
                                    else{
                                        self.detailWebView.frame.origin.y = origin_labelheight_y + 33
                                        self.profileView.frame.size.height = origin_labelheight_y - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    }
                                }
                                
                                if let contactDic = response["contactInfo"] as? NSDictionary{
                                    self.contactInfo = contactDic
                                }
                                if let is_owner = response["isOwner"] as? Bool{
                                    self.isowner = is_owner
                                    self.setUpContact()
                                }else{
                                    if self.contactInfo.count>0{
                                        self.isowner = false
                                        self.setUpContact()
                                    }
                                }

                                for tempMenu in self.gutterMenu
                                {
                                    if let tempDic = tempMenu as? NSDictionary
                                    {
                                        
                                        let wishListPading : CGFloat = 20
                                        if (tempDic["name"] as! String == "follow" || tempDic["name"] as! String == "unfollow")
                                        {
                                            let writeReview = createButton(CGRect(x: wishListPading, y: self.detailWebView.frame.origin.y + 5, width: self.mainSubView.bounds.width - 2 * wishListPading, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorPrime)


                                            if tempDic["name"] as! String == "follow" || tempDic["name"] as! String == "unfollow"
                                            {
                                                writeReview.tag = 61
                                                self.followUrl = tempDic["url"] as! String
                                            }
                                            writeReview.setTitle(tempDic["label"] as? String, for: UIControlState())
                                            writeReview.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)!
                                            writeReview.backgroundColor = navColor
                                            //  writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                            writeReview.addTarget(self, action: #selector(PageDetailViewController.performReviewOrWishlistAction(_:)), for: .touchUpInside)
                                            
                                            
                                            // self.urlDictionary["reviewUrl"] = tempDic["url"] as? String
                                            self.mainSubView.addSubview(writeReview)
                                            self.detailWebView.frame.origin.y = self.detailWebView.frame.origin.y + ButtonHeight + 15
                                            
                                        }
                                        
                                        
                                    }
                                    
                                }
                                var topicDescription = ""
                                if let description = response["body"] as? String
                                {
                                    topicDescription = description
                                    self.RedirectText = description
                                }
                                //let topicDescription = (response["body"] as! String)
                                //self.RedirectText = (response["body"] as! String)
                                if response["overview"] != nil {
                                    self.webviewText = String(describing: response["overview"]! as AnyObject)
                                }
                                
                                let lineCount = findHeightByText(topicDescription)
                                
                                self.detailWebView.text = topicDescription.html2String
                                self.detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal )
                                self.detailWebView.textContainer.maximumNumberOfLines = 4
                                self.detailWebView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                self.detailWebView.backgroundColor = textColorLight//aafBgColor
                                self.detailWebView.isHidden = false
                                self.detailWebView.sizeToFit()
                                
                                self.StaticView.text = topicDescription.html2String
                                self.StaticView.textContainer.maximumNumberOfLines = 4
                                self.StaticView.sizeToFit()
                                
                                if lineCount >= 4{
                                    self.productMoreOrLess.isHidden = false
                                    self.productMoreOrLessView.isHidden = false
                                    self.productMoreOrLessView.frame.origin.y = self.detailWebView.frame.size.height + self.detailWebView.frame.origin.y
                                    
                                }
                                else{
                                    self.productMoreOrLessView.frame.size.height = 0.0
                                }
                                
                                self.detailWebView.frame.size.width = self.view.bounds.width - 2 * PADING
                                
                                self.mainSubView.isHidden = false
                                self.mainSubView.frame.size.height = self.detailWebView.bounds.height + self.detailWebView.frame.origin.y + self.productMoreOrLessView.frame.size.height
                                self.showtabMenu()
                                self.showTabMenu1()
                                
                                
                                self.headerHeight =  self.detailWebView.bounds.height + self.detailWebView.frame.origin.y + self.productMoreOrLessView.frame.size.height + 10
                                
                                // self.feedFilter.isHidden = false
                                self.tabsContainerMenu.isHidden = false
                                self.tabsContainerMenu.frame.origin.y = self.headerHeight + 10
                                if logoutUser == true{
                                    
                                    self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + 10
                                }

                                self.browseFeed()
                                self.feedObj.refreshLikeUnLike = true
                                self.feedObj.tableView.reloadData()
                            }
                            
                        }
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
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
    
    // Set up contact button UI
    func setUpContact(){
        let wishListPading : CGFloat = 20
        let writeReview = createButton(CGRect(x: wishListPading, y: self.detailWebView.frame.origin.y - 15, width: self.mainSubView.bounds.width - 2 * wishListPading, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorPrime)
        writeReview.tag = 50
        writeReview.setTitle(NSLocalizedString("Contact", comment: ""), for: UIControlState())
        writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)!
        writeReview.backgroundColor = navColor
        writeReview.addTarget(self, action: #selector(PageDetailViewController.contactAction(_:)), for: .touchUpInside)
        self.mainSubView.addSubview(writeReview)
        self.detailWebView.frame.origin.y = self.detailWebView.frame.origin.y + ButtonHeight
    }
    func getCoverGutterMenu(){
        
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
            post(["subject_type": subjectType , "subject_id": String(subjectId) , "special": "both" , "cover_photo" : String(coverValue) , "profile_photo" : String(profileValue)], url: "coverphoto/get-cover-photo-menu", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let coverData = response["response"] as? NSDictionary {
                                    if let coverPhotoMenu = coverData["coverPhotoMenu"] as? NSArray{
                                        self.coverPhotoMenu = coverPhotoMenu
                                        self.camIconOnCover.isHidden = false
                                    }
                                    if let mainPhotoMenu = coverData["profilePhotoMenu"] as? NSArray{
                                        
                                        self.profilePhotoMenu = mainPhotoMenu
                                        self.camIconOnProfile.isHidden = false
                                    }

                                }
                            }
                        }
                    
                        
                        //self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
                    }
                    else{
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
    
    @objc func showProfileCoverImageMenu(_ sender: UITapGestureRecognizer){
        
        var isProfileOrCover = true
        if sender.view!.tag == 123{
            imageMenus = coverPhotoMenu
            isProfileOrCover = false
        }else if sender.view!.tag == 321{
            imageMenus = profilePhotoMenu
            isProfileOrCover = true
        }
        
        if imageMenus.count > 0{
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for menu in imageMenus{
                if let dic = menu as? NSDictionary{
                    
                    
                    if dic["name"] as! String == "remove_photo" || dic["name"] as! String == "remove_cover_photo"{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertActionStyle.destructive , handler:{ (UIAlertAction) -> Void in
                            // Delete Activity Feed Entry
                            if dic["name"] as! String == "remove_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Profile Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this profile photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                     var urlParams : NSDictionary = [:]
                                    
                                    urlParams = (dic["urlParams"] as? NSDictionary)!
                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                            else if dic["name"] as! String == "remove_cover_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Cover Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this cover photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                    var urlParams : NSDictionary = [:]
                                    
                                    urlParams = (dic["urlParams"] as? NSDictionary)!

                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                        
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertActionStyle.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                            case "upload_cover_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userCoverPicUrl
                                presentedVC.url = "coverphoto/upload-cover-photo/"
                                presentedVC.pageTitle = NSLocalizedString("Edit Cover Photo", comment: "")
                                presentedVC.contentType = "sitepage_page"
                                presentedVC.contentId = self.subjectId
                                presentedVC.showCameraButton = false
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "choose_from_album":
                                
                                let presentedVC = ChooseFromAlbumsViewController()
                                presentedVC.showOnlyMyContent = true
                                presentedVC.profileOrCoverChange = isProfileOrCover
                                presentedVC.contentType = "sitepage_page"
                                presentedVC.contentId = self.subjectId
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_cover_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = self.userCoverPicUrl//dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                                
                            case "upload_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userProfilePicUrl
                                
                                presentedVC.url = "coverphoto/upload-cover-photo/"
                                presentedVC.pageTitle = NSLocalizedString("Edit Profile Photo", comment: "")
                                presentedVC.contentType = "sitepage_page"
                                presentedVC.contentId = self.subjectId
                                presentedVC.special = "profile"

                                presentedVC.showCameraButton = true
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_profile_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = self.userProfilePicUrl//dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                                
                            }
                            
                            
                        }))}
                    
                    
                }
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else{
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                alertController.popoverPresentationController?.sourceView = view
                alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
                alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(alertController, animated:true, completion: nil)
        }
        else{
            if sender.view!.tag == 123{
                if self.userCoverPicUrl != nil && self.userCoverPicUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.userCoverPicUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    present(nativationController, animated:false, completion: nil)
                }
            }else if sender.view!.tag == 321{
                if self.userProfilePicUrl != nil && self.userProfilePicUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.userProfilePicUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    present(nativationController, animated:false, completion: nil)
                }
            }
        }
        
        
    }
    
    // Update Feed Gutter Menu
    func performPhotoActions(_ parameter: NSDictionary , url : String){
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method: String!
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }
            else{
                method = "POST"
            }
            
            
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    
                    if msg{
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        //updateUserData()
                        self.coverImageUrl = ""
                        self.exploreContent()
                        
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
    @objc func contactAction(_ sender:UIButton){
        let VC = CotactDetailViewController()
        profileField = self.contactInfo
        VC.isowner  = isowner
        VC.subjectId = subjectId
        self.navigationController?.pushViewController(VC, animated: false)
    }
    @objc func performReviewOrWishlistAction(_ sender:UIButton)
    {
        
        switch (sender.tag)
        {
        case 59:
            
            let presentedVC = AdvancePostFeedViewController()
            presentedVC.openfeedStyle = 4
            presentedVC.subjectId = subjectId!
            presentedVC.subjectType = subjectType!
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)

            break
            
        case 60:
            
            globFilterValue = ""
            
            let presentedVC = FormGenerationViewController()
            if sender.titleLabel!.text != nil
            {
                presentedVC.formTitle = NSLocalizedString("\(sender.titleLabel!.text!)", comment: "")
            }
            else
            {
                presentedVC.formTitle = ""
            }
            presentedVC.contentType = "Review"
            presentedVC.param = [ : ]
            presentedVC.url = self.reviewUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
            
        case 61:
            
            let param: NSDictionary = [ : ]
            self.updateListing(param as NSDictionary, url: followUrl)
            break
            
        default:
            break
        }
    }
    
    // MARK: - Browse pages server calling
    func browseFeed(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            removeAlert()
            
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob1 in self.self.feedObj.tableView.subviews
            {
                if  ob1.tag == 1000{
                    ob1.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2020{
                    ob.removeFromSuperview()
                }
            }
            
            // Reset Objects for Hard Refresh Request
            if maxid == 0{
                
                if contentFeedArray.count == 0{
                    self.feedObj.tableView.reloadData()
                }
                
            }
            
            
            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight/4))
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            
            parameters = ["maxid": String(maxid), "limit": "\(limit)", "subject_type": subjectType , "subject_id": String(subjectId), "post_menus":"1", "feed_filter": "1", "object_info":"1","getAttachedImageDimention":"0"]
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds/", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }else{
                        self.refresher.endRefreshing()
                        
                    }
                    self.feedObj.tableView.tableFooterView?.isHidden = true
                    self.showSpinner = false
                    // On Success Update Feeds
                    if msg{
                        // If Message in Response show the Message
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                        }
                        
                        // Reset contentFeedArray for Sink with Feed Results
                        if self.maxid == 0
                        {
                            contentFeedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.feedFilter.isEnabled = true
                                self.filterGutterMenu = menu as NSArray
                            }
                            // Check that whether Reaction Plugin is enable or not
                            if let reactionsEnable = response["reactionsEnabled"] as? Bool{
                                if reactionsEnable == true{
                                    if let reactions = response["reactions"] as? NSDictionary
                                    {
                                        reactionsDictionary = reactions
                                        ReactionPlugin = true
                                        self.browseEmoji(contentItems: reactions)
                                    }
                                }
                            }
                            else{
                                ReactionPlugin = false
                            }
                            
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update contentFeedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
                            }
                            
                            if self.feedFilter.isHidden == true{
                                self.feedFilter.isHidden = false
                            }
                            
                            
                            // Set MaxId for Feeds Result
                            
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            

                            // Check for Post Feed Options
                            if response["feed_post_menu"] != nil{
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: postPermission), forKey: "postMenu")
                                if (logoutUser == false){
                                    self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + ButtonHeight + 36
                                    self.postFeedOption()
                                }
                            }
                            else{
                                self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + 15
                            }
                            
                            globalFeedHeight =  self.feedFilter.frame.origin.y + 10 + ButtonHeight
                            
                            if contentFeedArray.count == 0 {
                                
                                self.info  = createLabel(CGRect(x: 10,y: self.feedFilter.frame.origin.y + 10 + ButtonHeight,width: self.view.bounds.width - 20 , height: 30), text: NSLocalizedString("Nothing has been posted here yet - be the first!",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.backgroundColor = UIColor.clear
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.tag = 1000
                                self.feedObj.tableView.frame.size.height = self.view.bounds.height - 40 - tabBarHeight
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false
                                
                            }
                            self.feedObj.globalArrayFeed = contentFeedArray
                            // Reload Tabel After Updation
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                            if afterPost == true{
                                afterPost = false
                                
                                DispatchQueue.main.async(execute: {
                                    soundEffect("post")
                                })
                                
                            }
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                        }
                        
                    }else{
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            self.view.makeToast(network_status_msg , duration: 5, position: "bottom")
            
        }
    }
    
    // MARK: - Checkin wideget server calling
    
    func browseEmoji(contentItems: NSDictionary){
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
        }
        var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as! Dictionary<String, AnyObject>
        var width = contentItems.count
        width = (6 * width) + (40 * width)
        let  width1 = CGFloat(width)
        scrollViewEmoji.frame = CGRect(x:0,y: TOPPADING,width: width1,height: 50)
        scrollViewEmoji.backgroundColor = UIColor.white //UIColor.clear
        scrollViewEmoji.layer.borderWidth = 2.0
        scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
        scrollViewEmoji.layer.cornerRadius = 20.0 //5.0
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 5.0
        var i : Int = 0
        
        for key in allReactionsValueDic.keys.sorted(by: <) {
            let v = allReactionsValueDic[key]!
            
            if let icon = v["icon"] as? NSDictionary{
                
                menuWidth = 40
                
                let   emoji = createButton(CGRect(x: origin_x,y: 5,width: menuWidth,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                emoji.addTarget(self, action: #selector(PageDetailViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                emoji.tag = v["reactionicon_id"] as! Int
                let imageUrl = icon["reaction_image_icon"] as? String
                
                let url = NSURL(string:imageUrl!)
                if url != nil
                {
                    emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
                }
                
                scrollViewEmoji.addSubview(emoji)
                
                origin_x = origin_x + menuWidth  + 5
                i = i + 1
            }
        }
        
        scrollViewEmoji.contentSize = CGSize(width: origin_x + 5, height: 30)
        scrollViewEmoji.bounces = false
        scrollViewEmoji.isUserInteractionEnabled = true
        scrollViewEmoji.showsVerticalScrollIndicator = false
        scrollViewEmoji.showsHorizontalScrollIndicator = false
        scrollViewEmoji.alwaysBounceHorizontal = true
        scrollViewEmoji.alwaysBounceVertical = false
        scrollViewEmoji.isDirectionalLockEnabled = true;
        scrollViewEmoji.isHidden = true
        
    }
    
    @objc func feedMenuReactionLike(sender:UIButton){
        
        let feed = contentFeedArray[scrollViewEmoji.tag] as! NSDictionary
        let action_id = feed["action_id"] as! Int
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        
        var reaction = ""
        
        for (_,v) in reactionsDictionary
        {
            var updatedDictionary = Dictionary<String, AnyObject>()
            let v = v as! NSDictionary
            if  let reactionId = v["reactionicon_id"] as? Int
            {
                if reactionId == sender.tag
                {
                    
                    reaction = (v["reaction"] as? String)!
                    updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                    updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                    if let icon  = v["icon"] as? NSDictionary{
                        
                        updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"]  as AnyObject?
                        
                    }
                    
                    var url = ""
                    
                    url = "advancedactivity/like"
                    
                    DispatchQueue.main.async(execute: {
                        soundEffect("Like")
                    })
                    
                    feedObj.updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag)
                    
                }
            }
        }
        
        
        
    }


    func postFeedOption(){
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? Data{
            if data.count != 0{
                for ob in view.subviews{
                    if ob.tag == 1 || ob.tag == 2 || ob.tag == 3{
                        ob.removeFromSuperview()
                    }
                }
                
                postPermission = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                
                var postMenu = [String]()
                if postPermission.count > 0{
                    if let status = postPermission["status"] as? Bool{
                        if status{
                            postMenu.append(NSLocalizedString("\(statusIcon) Status", comment: ""))
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
                            postMenu.append(NSLocalizedString("\(cameraIcon) Photo", comment: ""))
                        }
                    }
                    if let checkIn = postPermission["checkin"] as? Bool{
                        if checkIn{
                            postMenu.append(NSLocalizedString("\(locationIcon) Check In", comment: ""))
                        }
                    }
                }
                
                
                for ob in self.feedObj.tableView.subviews{
                    if ob.tag >= 1991 && ob.tag <= 1993{
                        ob.removeFromSuperview()
                    }
                }
                
                
                //Add Post Feed Option
                for i in 0 ..< postMenu.count {
                    let origin_x = PADING + (CGFloat(i) * ((view.bounds.width - (2 * PADING))/CGFloat(postMenu.count)))
                    let postFeed = createButton(CGRect(x: origin_x, y: tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + contentPADING + 15, width: view.bounds.width/CGFloat(postMenu.count), height: ButtonHeight - PADING), title: postMenu[i] , border: false ,bgColor: false, textColor: textColorMedium)
                    postFeed.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
                    postFeed.backgroundColor = lightBgColor
                    postFeed.tag = i+1 + 1990
                    postFeed.addTarget(self, action: #selector(PageDetailViewController.openPostFeed(_:)), for: .touchUpInside)
                    self.feedObj.tableView.addSubview(postFeed)
                }
                
                postMenu.removeAll(keepingCapacity: false)
            }
        }
    }
    
    @objc func openPostFeed(_ sender:UIButton){
        
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        let presentedVC = AdvancePostFeedViewController()
       // presentedVC.openfeedStyle = (sender.tag - 1990)
        
        if (sender.tag - 1990) == 1 {
            presentedVC.openfeedStyle = 0//(sender.tag - 1990)
        }
        else{
            presentedVC.openfeedStyle = (sender.tag - 1990)
        }
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
    }
    
    func updateFeedsArray(_ feeds:[ActivityFeed]){
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
                
            }
            
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            contentFeedArray.append(newDictionary)
            self.feedObj.globalArrayFeed = contentFeedArray
            
            if logoutUser == false
            {
                globalFeedHeight = self.feedFilter.frame.origin.y + 10 + ButtonHeight
            }
            else
            {
                globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y )
            }
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
            
            
        }
        
    }
    
    @objc func ScrollingactionPage(_ notification: Foundation.Notification)
    {
        
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true

        if self.feedObj.tableView.contentOffset.y +  7 > detailWebView.frame.origin.y + self.productMoreOrLessView.frame.size.height + detailWebView.frame.size.height - ButtonHeight {
            
            staticTabMenu.frame.size.width = self.view.bounds.width
            staticTabMenu.isHidden = false
            
        }
        else{
            staticTabMenu.isHidden = true
        }
        
        if updateScrollFlag{
            
            // Check for PAGINATION
            if self.feedObj.tableView.contentSize.height > self.feedObj.tableView.bounds.size.height{
                if self.feedObj.tableView.contentOffset.y >= (self.feedObj.tableView.contentSize.height - self.feedObj.tableView.bounds.size.height){
                    if reachability.connection != .none {
                        if contentFeedArray.count > 0{
                            if maxid == 0{
//                                toastView = createView(CGRect(x: 0,y: (self.feedObj.tableView.bounds.size.height) - (30 + tabBarHeight), width: view.bounds.width, height: 20), borderColor: UIColor.clear, shadow: false)
//                                toastView.backgroundColor = UIColor.clear
//                                self.toastView.makeToast(NSLocalizedString("There are no more posts to show.",comment: ""), duration: 5, position: "bottom")
//                                view.addSubview(toastView)
//                                self.toastView.hideToastActivity()
                                
                                feedObj.tableView.tableFooterView?.isHidden = true

                                
                            }else{
                                // Request for Pagination
                                updateScrollFlag = false
                                feed_filter = 0
                               // showSpinner = true
                                feedObj.tableView.tableFooterView?.isHidden = false

                                if adsType_feeds == 2 || adsType_feeds == 4{
                                    delay(0.1) {
                                        self.feedObj.checkforAds()
                                    }
                                }
                                browseFeed()
                            }
                        }
                    }
                }
            }
        }
        
        let scrollOffset = scrollopoint.y
        if (scrollOffset > 60){
            
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            self.marqueeHeader.text = self.contentTitle
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.alpha = barAlpha
            self.marqueeHeader.textColor = textColorPrime
            self.contentName.alpha = 1-barAlpha
            
            if (self.lastContentOffset > scrollOffset) {
                // move up
                self.like_comment.fadeIn()
            }
            else if (self.lastContentOffset < scrollOffset){
                // move down
                self.like_comment.fadeOut()
            }
            
            // update the new position acquired
            self.lastContentOffset = scrollOffset
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.marqueeHeader.text = ""
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            self.contentName.alpha = 1-barAlpha
            
            self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
                self.like_comment.alpha = 1
            }
        }
        
        
        
    }
    
    // Show Gutter Menus
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        deleteContent = false
        let confirmationTitle = ""
        let message = ""
        var url = ""
        var confirmationAlert = true
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                
                var params = Dictionary<String, AnyObject>()
//                if dic["name"] as! String == "videoCreate"{
//                    continue
//                }
                
                if dic["name"] as! String != "share"{
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertActionStyle.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Page entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.deleteListingEntry = true
                                    let params: NSDictionary = [:]
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    // self.updateContentAction(param,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertActionStyle.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "videoCreate" :
                                addvideo_click = 1
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "Advanced Video"
                                if sitevideoPluginEnabled_page == 1
                                {
                                    let subject_type = dic["subject_type"] as! String
                                    let subject_id =   dic["subject_id"] as! Int
                                    presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                                }
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                            case "create" :
                                if dynamicEventPackageEnabled == 1
                                {
                                    isCreateOrEdit = true
                                    let presentedVC = PackageViewController()
                                    presentedVC.contentType = "advancedevents"
                                    presentedVC.url = "advancedevents/packages"
                                    presentedVC.extensionParam = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    url = dic["url"] as! String
                                    presentedVC.extensionUrl = url
                                    presentedVC.eventExtensionCheck = true
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                }
                                else{
                                
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = dic["label"] as! String
                                presentedVC.contentType = "advancedevents"
                                presentedVC.eventExtensionCheck = true
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                }
                                
                            case "tellafriend":
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = dic["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                                
                            case "report":
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "edit":
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                isCreateOrEdit = false
                                presentedVC.formTitle = NSLocalizedString("Edit Page", comment: "")
                                //presentedVC.listingTypeId = self.listingTypeId
                                presentedVC.contentType = "Page"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            case "share":
                                //confirmationAlert = false
                                let presentedVC = AdvanceShareViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.Sharetitle = self.shareTitle
                                presentedVC.ShareDescription = self.detailWebView.text
                                presentedVC.imageString = self.coverImageUrl
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "create_review":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "update_review":
                                
                                isCreateOrEdit = false
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "close", "open" , "follow" , "unfollow":
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "messageowner":
                                
                                confirmationAlert = false
                                let presentedVC = MessageOwnerViewController();
                                presentedVC.url = dic["url"] as! String
                                
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "subscribe":
                                
                                Reload = "Not Refresh"
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "unsubscribe":
                                
                                Reload = "Not Refresh"
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "package_payment":
                                
                                confirmationAlert = false
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            case "upgrade_package":
                                let presentedVC = PackageViewController()
                                presentedVC.contentType = "Page"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.urlParams = dic["urlParams"] as! NSDictionary
                                presentedVC.isUpgradePackageScreen = true
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    // self.updateContentAction(param,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                        
                    }
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func updateListing(_ params: NSDictionary, url: String){
        
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
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in params{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Page Contents with Page_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        // On Success Update Listing Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        
                        if self.deleteListingEntry == true{
                            pageUpdate = true
                            feedUpdate = true
                            _ = self.navigationController?.popViewController(animated: false)
                            return
                        }
                        self.exploreContent()
                        
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
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        
        var tempLabelCount = 0
        for tempArray in tabMenuPage {
            let tempTabMenuPage = tempArray as! NSDictionary
            if tempTabMenuPage["totalItemCount"] as? Int > 0{
                tempLabelCount += 1
            }
            if tempTabMenuPage["name"] as! String == "update"{
                tempLabelCount += 1
            }
            
            if tempTabMenuPage["name"] as! String == "info"{
                tempLabelCount += 1
            }
        }
        
        var origin_x:CGFloat = 0
        
        for menu in tabMenuPage{
            //origin_x = 0
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                let width = findWidthByText(button_title) + 10
                
               // if tempLabelCount < 5 {
               //     width = UIScreen.main.bounds.width / CGFloat(tempLabelCount)
                //}
                
                // let menu = createButton(CGRect(x:origin_x,0 ,width , CGRectGetHeight(tabsContainerMenu.bounds)),title: button_title , border: false,bgColor: false, textColor: textColorDark)
                let menu = createNavigationButton(CGRect(x: origin_x,y: 0 ,width: width , height: tabsContainerMenu.bounds.height ) , title: button_title, border: true, selected: false)
                
                if menuItem["name"] as! String == "update"{
                    menu.setSelectedButton()
                }
                else{
                    menu.setUnSelectedButton()
                }
                menu.backgroundColor = TabMenubgColor
                
                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                menu.tag = 101
                menu.addTarget(self, action: #selector(PageDetailViewController.tabMenuAction(_:)), for: .touchUpInside)
                tabsContainerMenu.addSubview(menu)
                
                origin_x += width
                
                if button_title == "Updates"{
                    menu.setTitleColor(textColorDark, for: UIControlState())
                }
                else{
                    menu.setTitleColor(textColorMedium, for: UIControlState())
                }
                
            }
        }
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    func showTabMenu1(){
        
        
        var origin_x1:CGFloat = 0
        
        var tempLabelCount = 0
        for tempArray in tabMenuPage {
            
            let tempTabMenuPageDic = tempArray as! NSDictionary
            
            if tempTabMenuPageDic["totalItemCount"] as? Int > 0{
                tempLabelCount += 1
            }
            if tempTabMenuPageDic["name"] as! String == "update"{
                tempLabelCount += 1
            }
            
            if tempTabMenuPageDic["name"] as! String == "info"{
                tempLabelCount += 1
            }
        }
        
        
        for menu1 in tabMenuPage{
            
            if let menuItem = menu1 as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                let width = findWidthByText(button_title) + 10
                
               // if tempLabelCount < 5 {
                 //   width = UIScreen.main.bounds.width / CGFloat(tempLabelCount)
               // }
                
                
                // let menu = createButton(CGRect(x:origin_x,0 ,width , CGRectGetHeight(tabsContainerMenu.bounds)),title: button_title , border: false,bgColor: false, textColor: textColorDark)
                let menu1 = createNavigationButton(CGRect(x: origin_x1,y: 0 ,width: width , height: tabsContainerMenu.bounds.height ) , title: button_title, border: true, selected: false)
                
                if menuItem["name"] as! String == "update"{
                    menu1.setSelectedButton()
                }
                else{
                    menu1.setUnSelectedButton()
                }
                menu1.backgroundColor  =  TabMenubgColor
                
                
                menu1.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                menu1.tag = 102
                menu1.addTarget(self, action: #selector(PageDetailViewController.tabMenuAction(_:)), for: .touchUpInside)
                // tabsContainerMenu.addSubview(menu)
                staticTabMenu.addSubview(menu1)
                origin_x1 += width
                
                if button_title == "Updates"{
                    menu1.setTitleColor(textColorDark, for: UIControlState())
                }
                else{
                    menu1.setTitleColor(textColorMedium, for: UIControlState())
                }
                
            }
            
        }
        
        staticTabMenu.contentSize = CGSize(width: origin_x1, height: tabsContainerMenu.bounds.height)
        
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        for menu in tabMenuPage{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                
                
                // if button_title != "Fourms Posts" {
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                if sender.titleLabel?.text == button_title{
                    if menuItem["name"] as! String == "information"{
                        if self.detailWebView != nil{
                            let presentedVC = MLTInfoViewController()
                            presentedVC.infoUrl = menuItem["url"] as! String
                            presentedVC.containText = false
                        navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    if menuItem["name"] as! String == "overview"{
                        
                        if self.detailWebView != nil{
                            let presentedVC = OverViewViewController()
                            presentedVC.label1 = self.webviewText
                            navigationController?.pushViewController(presentedVC, animated: false)
                        }
                    }
                    
                    if menuItem["name"] as! String == "video"{
                        
                        if sitevideoPluginEnabled_page == 1
                        {
                            let presentedVC = AdvanceVideoViewController()
                            presentedVC.user_id = subjectId
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = false
                            presentedVC.countListTitle = button_title
                            presentedVC.other_module = true
                            presentedVC.videoTypeCheck = "Pages"
                            presentedVC.url = menuItem["url"] as! String//"advancedvideos/index/\(self.subjectId)"
                            presentedVC.subject_type = menuItem["subject_type"] as! String
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            let presentedVC = VideoBrowseViewController()
                            presentedVC.showOnlyMyContent = true
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.videoTypeCheck = "Pages"
                            presentedVC.listingId = subjectId
                            presentedVC.fromTab = true
                            presentedVC.countListTitle =  button_title
                            
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        
                    }
                    if menuItem["name"] as! String == "advevents"{
                        let presentedVC = AdvancedEventViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.sitegroupCheck = "sitepage"
                        if menuItem["totalItemCount"] as? Int != nil {
                            presentedVC.eventCount = menuItem["totalItemCount"] as! Int
                        }
                        if let dic1 = menuItem["urlParams"] as? NSDictionary{
                            presentedVC.user_id = dic1["subject_id"] as! Int
                        }
                        presentedVC.fromTab = true
                        
                        
                        navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = PageReviewViewController()
                        presentedVC.mytitle = contentTitle //"\((self.title)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.contentType = "Pages"
                        
                        if let totalItem = menuItem["totalItemCount"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.currentReviewcount = totalItem
                                
                            }
                            
                        }
                        
                        
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                        
                    }
                    
                    if menuItem["name"] as! String == "photos"{
                        let presentedVC = AlbumViewController()
                        presentedVC.contentType = "sitepage_photo"
                        presentedVC.countListTitle = button_title
                        // presentedVC.listingId = listingId
                        presentedVC.showOnlyMyContent = true
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.path = tempUrl
                        
                        
                        presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                    
                    
                }
            }
            
        }
    }
    
    @objc func goBack(){
        if self.checkUpdate == true{
            
            pageUpdate = true
            
        }
        sitevideoPluginEnabled_page = 0
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @objc func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            updateAfterAlert = false
            exploreContent()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    @objc func openProfile(){
        if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = user_id
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    func showUserProfile(_ sender:UIButton){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = sender.tag
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func shareItem(){
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            
            let presentedVC = AdvanceShareViewController()
            presentedVC.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            presentedVC.url = self.shareUrl
            presentedVC.Sharetitle = self.shareTitle
            if (self.RedirectText != nil) {
                presentedVC.ShareDescription = self.RedirectText
            }
            if self.coverImageUrl != nil && self.coverImageUrl != ""{
                presentedVC.imageString = self.coverImageUrl
            }
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertActionStyle.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.contentTitle {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
                if(activityViewController.popoverPresentationController != nil) {
                    activityViewController.popoverPresentationController?.sourceView = self.view;
                    let frame = UIScreen.main.bounds
                    activityViewController.popoverPresentationController?.sourceRect = frame;
                }
                
            }
            else
            {
                
                let presentationController = activityViewController.popoverPresentationController
                presentationController?.sourceView = self.view
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    @objc func onImageViewTap()
    {
        if self.coverImageUrl != nil && self.coverImageUrl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    
    @objc func showFeedFilterOptions(){
        if self.detailWebView != nil{
            let presentedVC = MLTInfoViewController()
            presentedVC.label1 = self.RedirectText
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
