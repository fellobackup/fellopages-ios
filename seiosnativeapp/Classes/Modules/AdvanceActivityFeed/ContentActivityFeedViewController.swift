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
//  ContentActivityFeedViewController.swift
//  seiosnativeapp


// VIEW CONTROLLER FOR MEMBER PROFILE PAGE
import UIKit
import CoreData
import NVActivityIndicatorView
import Instructions

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
protocol pinrefresh{
    func reloadpin()
    
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
    
}


class ContentActivityFeedViewController: UIViewController, UITableViewDelegate, TTTAttributedLabelDelegate,pinrefresh , CoachMarksControllerDataSource, CoachMarksControllerDelegate , UITabBarControllerDelegate{
    let mainView = UIView()
    var subjectId:Int!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int! = 0                              // MinID for New Feeds
    var myTimer:Timer!                        // Timer for Update feed after particular time repeation
    var myTimer1:Timer!
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempuserFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var gutterMainMenu: NSArray = []
    var fromDashboard : Bool!
   // var userImageCache = [String:UIImage]()
    
    var userProfilePicUrl : String!
    var titleHeight:CGFloat = 0
    var actionIdArray = [Int]()
    var info : UILabel!
    var UserId:Int!
  //  var imageCache = [String:UIImage]()
    var action_id:Int!
    
    var shareTitle:String!
    var userNameString : String!
    var mainSubView:UIView!
    var coverImageView:UIImageView!
    var userName:UILabel!
    var extraMenuLeft:UIButton!
    var extraMenuRight:UIButton!
    var tabsContainerMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var profilePic: UIImageView!
    var myTitle:String!
    var contentview : UIView!
    var navBarTitle : UILabel!
    var contentName : UILabel!
    var fromActivity : Bool!
    var temptitleInfo : String = ""
    var noPost : Bool = true
    var toastView : UIView!
    var noCommentMenu:Bool = false
    var postView:UIView!
     var userImage : UIImageView!
    var menuView = UIView()
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    var marqueeHeader = MarqueeLabel()
    var memberProfileTabMenu: NSArray = []
    
    //For Profile and cover image
    var memberProfilePhoto:UIImageView!
    var userCoverPicUrl : String!
    var topMainView : UIView!
    var contentSelection : UIButton!
    var profilePhotoMenu: NSArray = []
    var coverPhotoMenu: NSArray = []
    var imageMenus: NSArray = []
    var profileOrCoverChange: Bool!
    var popAfterDelay:Bool!
    var camIconOnCover: UILabel!
    var camIconOnProfile: UILabel!
    var isCoverEnabled = true
    var feedObj = FeedTableViewController()
    var leftBarButtonItem : UIBarButtonItem!
    var profileOfUserId : Int! = 0
    var showMenu = [String]()
    var showIcon = [String]()
    var moreMenu = [String]()
    var nameMenu = [String]()
    var moreNameMenu = [String]()
    var rightBarButtonItem: UIBarButtonItem!
    var strProfileImageUrl = ""
    var strUserName = ""
     var targetCheckValue : Int = 1
    var coachMarksController = CoachMarksController()
    var showFirstMessage = ""
    var showSecondMessage = ""
    var showThirdMessage = ""
    var showFourthMessage = ""
    
   // var overlaid = TranslucentOverlayStyleManager()
    // Initialize Class
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableViewFrameType = "ContentActivityFeedViewController"
//        var abc = TranslucentOverlayStyleManager(color : textColorMedium)
//        abc.setColor = textColorMedium
        
      //  overlaid.color = textColorMedium.withAlphaComponent(0.5)
        //Checks of Modules Enabled
        if enabledModules != nil && enabledModules.contains("siteusercoverphoto"){
            isCoverEnabled = true
        }else{
            isCoverEnabled = false
        }
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            
        }
        //self.coachMarksController.dataSource = self
        
        // Set BackgroundColor of ActivityFeed
        view.backgroundColor = aafBgColor
        navigationController?.navigationBar.isHidden = false
        searchDic.removeAll(keepingCapacity: false)
        self.tabBarController?.delegate = self
       // notScroll = false
        maxid = 0       // Set Default maxid for browseFeed
        feedUpdate = true
        NotificationCenter.default.addObserver(self, selector: #selector(ContentActivityFeedViewController.ScrollingactionContentActivityFeed(_:)), name: NSNotification.Name(rawValue: "ScrollingactionContentActivityFeed"), object: nil)
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        subject_unique_id = subjectId
        subject_unique_type = "user"
        var height = 25
        var yAxis = -12
        if DeviceType.IS_IPHONE_X
        {
            yAxis = -18
            height = 35
        }
        let footerView = UIView(frame: CGRect(x: 0, y: yAxis, width: Int(self.view.bounds.width), height: height))
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = footerView.center//CGPoint(x:(footerView.bounds.width - 25)/2, y:0.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
        
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        userFeedArray.removeAll(keepingCapacity: false)
        
        self.feedObj.view.backgroundColor =   UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        // Initial table to show Activity Feeds
        feedObj.willMove(toParent: self)
        mainView.addSubview(feedObj.view)
        self.addChild(feedObj)
        self.feedObj.userFeeds = true
        feedObj.feedShowingFrom = "UserFeed"
        feedObj.delegatepin = self
        //MARK: Work for new layout type
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            topMainView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 360 + 20), borderColor: UIColor.clear, shadow: false)
            if !isCoverEnabled
            {
                topMainView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 300 + 50), borderColor: UIColor.clear, shadow: false)
            }
        }
        else
        {
            topMainView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 300 + 20), borderColor: UIColor.clear, shadow: false)
            if !isCoverEnabled{
                topMainView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 270 + 50), borderColor: UIColor.clear, shadow: false)
            }
        }
        topMainView.backgroundColor = UIColor.white
        feedObj.tableView.addSubview(topMainView)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 330), borderColor: borderColorDark, shadow: false)
        }else{
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        mainSubView.backgroundColor = aafBgColor
        mainSubView.layer.borderColor = UIColor.clear.cgColor
        topMainView.addSubview(mainSubView)
        
         
        coverImageView = CoverImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height))
        coverImageView.layer.masksToBounds = true
        coverImageView.tag = 123
        coverImageView.isUserInteractionEnabled = true
        coverImageView.contentMode = UIView.ContentMode.scaleAspectFill
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.showProfileCoverImageMenu(_:)))
        coverImageView.addGestureRecognizer(tap1)
        if !isCoverEnabled || (logoutUser == true){
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.onImageViewTap(_:)))
            coverImageView.addGestureRecognizer(tap1)
        }
        mainSubView.addSubview(coverImageView)
        
        
        camIconOnCover = createLabel(CGRect(x: coverImageView.bounds.width - 25, y: coverImageView.bounds.height - 25, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = true
        coverImageView.addSubview(camIconOnCover)
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            memberProfilePhoto = createImageView(CGRect(x: 30, y: coverImageView.bounds.height - (2 * contentPADING) - 80, width: 120, height: 120 ), border: true)
        }else{
            memberProfilePhoto = createImageView(CGRect(x: 10, y: coverImageView.bounds.height - (2 * contentPADING) - 60, width: 100, height: 100), border: true)
        }
        memberProfilePhoto.layer.borderColor = UIColor.white.cgColor
        memberProfilePhoto.layer.borderWidth = 2.5
        memberProfilePhoto.layer.cornerRadius = memberProfilePhoto.frame.size.width / 2
        memberProfilePhoto.backgroundColor = placeholderColor
        memberProfilePhoto.contentMode = UIView.ContentMode.scaleAspectFill
        memberProfilePhoto.layer.masksToBounds = true
      //  memberProfilePhoto.image = UIImage(named: "user_profile_image.png")
        if let url = URL(string: strProfileImageUrl)
        {
            self.memberProfilePhoto.kf.indicatorType = .activity
            (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        memberProfilePhoto.tag = 321
        memberProfilePhoto.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.showProfileCoverImageMenu(_:)))
        memberProfilePhoto.addGestureRecognizer(tap2)
        if isCoverEnabled && (logoutUser == true){
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(ContentActivityFeedViewController.onImageViewTap(_:)))
            memberProfilePhoto.addGestureRecognizer(tap2)
        }
        topMainView.addSubview(memberProfilePhoto)
        
        if !isCoverEnabled{
            memberProfilePhoto.isHidden = true
        }
        if isCoverEnabled{
            menuView = createView(CGRect(x: (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width) - 10, y:   topMainView.bounds.height - 45 , width: view.bounds.width, height: 50), borderColor: UIColor.clear, shadow: false)
        }
        else{
            menuView = createView(CGRect(x: 0 , y:  topMainView.bounds.height - 50, width: view.bounds.width, height: 50), borderColor: UIColor.clear, shadow: false)
        }
        menuView.isHidden = true
        menuView.backgroundColor  =  TabMenubgColor
        topMainView.addSubview(menuView)

        
        camIconOnProfile = createLabel(CGRect(x: (memberProfilePhoto.bounds.width/2) - 15, y: memberProfilePhoto.bounds.height - 30, width: 30, height: 30), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnProfile.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnProfile.layer.shadowColor = shadowColor.cgColor
        camIconOnProfile.layer.shadowOpacity = shadowOpacity
        camIconOnProfile.layer.shadowRadius = shadowRadius
        camIconOnProfile.layer.shadowOffset = shadowOffset
        camIconOnProfile.isHidden = true
        memberProfilePhoto.addSubview(camIconOnProfile)
        
        contentview = createView(CGRect(x: memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width + 10, y: coverImageView.bounds.height - (2 * contentPADING) - 60, width: view.bounds.width - memberProfilePhoto.bounds.width - 30 , height: 70), borderColor: UIColor.clear, shadow: false)
        
        if !isCoverEnabled
        {
            contentview = createView(CGRect(x: 10, y: coverImageView.bounds.height - (2 * contentPADING) - 60, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
            
        }
        
        contentview.backgroundColor = UIColor.clear
        coverImageView.addSubview(contentview)
        
        userName = createLabel(CGRect(x: 10, y: coverImageView.bounds.height - (2 * contentPADING) - 60, width: view.bounds.width-160, height: 30), text: "", alignment: .left, textColor: textColorLight)
        userName.font = UIFont(name: fontBold, size: FONTSIZELarge)
        userName.numberOfLines = 0
        userName.layer.shadowColor = shadowColor.cgColor
        userName.layer.shadowOpacity = shadowOpacity
        userName.layer.shadowRadius = shadowRadius
        userName.layer.shadowOffset = shadowOffset
        userName.font = UIFont(name: fontName, size: 30.0)
        contentview.addSubview(userName)
        userName.isHidden = true
        
        navBarTitle = createLabel(CGRect(x: 0, y: 0, width: view.bounds.width, height: TOPPADING), text: "", alignment: .center, textColor: textColorLight)
        navBarTitle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        feedObj.tableView.addSubview(navBarTitle)
        navBarTitle.isHidden = true
        
        
        extraMenuLeft  = createButton(CGRect(x: 0,y: 300 , width: 20, height: ButtonHeight), title: "", border: false,bgColor: false, textColor: textColorDark)
        extraMenuLeft.backgroundColor = cellBackgroundColor
        extraMenuLeft.isHidden = true
        feedObj.tableView.addSubview(extraMenuLeft)
        
        extraMenuRight  = createButton(CGRect(x: view.bounds.width-20,y: 300 , width: 20, height: ButtonHeight), title: "", border: false,bgColor: false, textColor: textColorDark)
        extraMenuRight.backgroundColor = cellBackgroundColor
        extraMenuRight.isHidden = true
        feedObj.tableView.addSubview(extraMenuRight)
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: 0, y: 450, width: view.bounds.width, height: ButtonHeight + 10))
        tabsContainerMenu.delegate = self
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        tabsContainerMenu.isHidden = true
        feedObj.tableView.addSubview(tabsContainerMenu)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
//        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ContentActivityFeedViewController.refresh), for: UIControl.Event.valueChanged)
        feedObj.tableView.addSubview(refresher)
        
        removeNavigationImage(controller: self)
        
        popAfterDelay = false
        
        if subjectType == "user"{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                profilePic = createImageView(CGRect(x: (2 * contentPADING),  y: coverImageView.bounds.height - (2 * contentPADING) - 120,width: 120 ,height: 120 ), border: true)
            }else{
                profilePic = createImageView(CGRect(x: (2 * contentPADING),  y: coverImageView.bounds.height - (2 * contentPADING) - 80 ,width: 80 , height: 80 ), border: true)
            }
            
            profilePic.contentMode =  UIView.ContentMode.scaleAspectFill //UIView.ContentMode.center
            profilePic.layer.masksToBounds = true
            profilePic.backgroundColor = placeholderColor
            profilePic.layer.borderWidth = 2.0
            profilePic.layer.borderColor = borderColorLight.cgColor
            coverImageView.addSubview(profilePic)
            
            profilePic.isHidden = true
            
            userName.textColor = textColorDark
            userName.frame.origin.x = profilePic.bounds.width + profilePic.frame.origin.x + contentPADING
            userName.frame.origin.y = coverImageView.bounds.height + contentPADING
            
            contentName = createLabel(CGRect(x: contentPADING, y: 0, width: contentview.bounds.width - 5, height: contentview.bounds.height - 5), text: "", alignment: .left, textColor: textColorLight)
            
            contentName.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
            contentName.numberOfLines = 0
            contentName.layer.shadowColor = shadowColor.cgColor
            contentName.layer.shadowOpacity = shadowOpacity
            contentName.layer.shadowRadius = shadowRadius
            contentName.layer.shadowOffset = shadowOffset
            contentName.lineBreakMode = NSLineBreakMode.byTruncatingTail
            //contentName.font = UIFont.boldSystemFontOfSize(30)
            contentview.addSubview(contentName)
            contentName.text = strUserName
        }
        
        
        self.automaticallyAdjustsScrollViewInsets = false;
      
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        let topMostViewController = UIApplication.shared.topMostViewController()
        if topMostViewController == self {

        if self.profileOfUserId == currentUserId {
        return 3
        }
        return 4
        }
        else{
            return 0
        }
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        
        var coachMark : CoachMark
        
        
        switch(index) {
        case 0:
            //  self.postView.layer.cornerRadius = self.postView.frame.width / 2
            //   skipView.isHidden = false
            var   coachMark1 : CoachMark
            var origin_x : CGFloat = 0.0
            var gapPoint : CGFloat = 0.0
            
            
            if !(DeviceType.IS_IPHONE_X) {
                
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                    
                
                    switch height
                    {
                    case 568.0:
                        
                        if self.isCoverEnabled {
                            let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                            origin_x = totalWidth/CGFloat(3)
                            gapPoint = 2 * origin_x
                        }
                        else{
                            let totalWidth = view.bounds.width
                            origin_x = totalWidth/CGFloat(3)
                            origin_x = origin_x - 5 // self.profilePic.frame.size.width + 66
                            gapPoint =  origin_x - 40
                        }
                        
                    case 736.0:
                        
                        if self.isCoverEnabled {
                            origin_x =  self.profilePic.frame.size.width + 70
                            gapPoint = origin_x
                        }
                        else{
                            let totalWidth = view.bounds.width
                            origin_x = totalWidth/CGFloat(3)
                            origin_x = origin_x - 5
                            gapPoint =  (origin_x) - 65
                        }
                    case 667.0:
                        
                        if self.isCoverEnabled {
                            let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                            origin_x = totalWidth/CGFloat(3)
                            gapPoint = 2 * origin_x - 35
                        }
                        else{
                            let totalWidth = view.bounds.width
                            origin_x = totalWidth/CGFloat(3)
                            origin_x = origin_x - 5 // self.profilePic.frame.size.width + 66
                            gapPoint =  origin_x - 60
                        }
                        
                        
                        
                        
                    default:
                        
                        if self.isCoverEnabled {
                            let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                            origin_x = totalWidth/CGFloat(3)
                            gapPoint = 2 * origin_x
                        }
                        else{
                            let totalWidth = view.bounds.width
                            origin_x = totalWidth/CGFloat(3)
                            origin_x = origin_x - 5 // self.profilePic.frame.size.width + 66
                            gapPoint =  origin_x - 40
                        }
                        
                    }
            }
            else{
                if self.isCoverEnabled {
                    origin_x =  self.profilePic.frame.size.width + 66
                    gapPoint = origin_x
                }
                else{
                    let totalWidth = view.bounds.width
                    origin_x = totalWidth/CGFloat(3)
                    origin_x = origin_x - 5
                    gapPoint =  (origin_x) - 55
                }
            }
                    
            
            
//            if self.isCoverEnabled {
//                let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
//                origin_x = totalWidth/CGFloat(3)
//                gapPoint = 2 * origin_x
//            }
//            else{
//                let totalWidth = view.bounds.width
//                origin_x = totalWidth/CGFloat(3)
//                origin_x = origin_x - 5 // self.profilePic.frame.size.width + 66
//                gapPoint =  origin_x - 40
//            }
//            if (DeviceType.IS_IPHONE_X) {
//                if self.isCoverEnabled {
//                    origin_x =  self.profilePic.frame.size.width + 66
//                    gapPoint = origin_x
//                }
//                else{
//                    let totalWidth = view.bounds.width
//                    origin_x = totalWidth/CGFloat(3)
//                    origin_x = origin_x - 5
//                    gapPoint =  (origin_x) - 55
//                }
//            }
            coachMark1 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: gapPoint + 1,y: self.coverImageView.frame.size.height + 26), radius: CGFloat(48), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
               
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            //  coachMark1.disableOverlayTap = true
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            // We'll also enable the ability to touch what's inside
            // the cutoutPath.
            
            return coachMark1
        case 1:
            
            var  coachMark2 : CoachMark
            var origin_x : CGFloat = 0.0
            var gapPoint : CGFloat = 0.0
            
            if !(DeviceType.IS_IPHONE_X) {
                
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                
                
                switch height
                {
                case 568.0:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 3 * origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 2 * origin_x - 35
                    }
                    
                case 736.0:
                    
                    if self.isCoverEnabled {
                        origin_x =  self.profilePic.frame.size.width + 175
                        gapPoint = origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5
                        gapPoint = 2 * (origin_x ) - 60
                    }
                case 667.0:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 3 * origin_x - 28
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 2 * origin_x - 55
                    }
                    
                    
                    
                    
                default:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 3 * origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 2 * origin_x - 35
                    }
                }
            }
            else{
                if self.isCoverEnabled {
                    origin_x =  self.profilePic.frame.size.width + 155
                    gapPoint = origin_x
                }
                else{
                    let totalWidth = view.bounds.width
                    origin_x = totalWidth/CGFloat(3)
                    origin_x = origin_x - 5
                    gapPoint = 2 * (origin_x ) - 50
                }
            }
            
            
            
            
            
//            if self.isCoverEnabled {
//                let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
//                origin_x = totalWidth/CGFloat(3)
//                gapPoint = 3 * origin_x
//            }
//            else{
//                let totalWidth = view.bounds.width
//                origin_x = totalWidth/CGFloat(3)
//                origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
//                gapPoint = 2 * origin_x - 35
//            }
//            if (DeviceType.IS_IPHONE_X) {
//                if self.isCoverEnabled {
//                    origin_x =  self.profilePic.frame.size.width + 155
//                    gapPoint = origin_x
//                }
//                else{
//                    let totalWidth = view.bounds.width
//                    origin_x = totalWidth/CGFloat(3)
//                    origin_x = origin_x - 5
//                    gapPoint = 2 * (origin_x ) - 50
//                }
//            }
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
               let circlePath = UIBezierPath(arcCenter: CGPoint(x: gapPoint,y: self.coverImageView.frame.size.height + 25), radius: CGFloat(42), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            // coachMark2.disableOverlayTap = true
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            
            // coachMark2.allowTouchInsideCutoutPath = true
            return coachMark2
            
        case 2:
            
            var  coachMark2 : CoachMark
             var origin_x : CGFloat = 0.0
            var gapPoint : CGFloat = 0.0
            
            if !(DeviceType.IS_IPHONE_X) {
                
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                
                
                switch height
                {
                case 568.0:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 4 * origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 3 * origin_x - 35
                    }
                    
                case 736.0:
                    
                    if self.isCoverEnabled {
                        origin_x =  view.bounds.width - 50//self.profilePic.frame.size.width + 246
                        gapPoint = origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5
                        gapPoint = 3 * (origin_x ) - 55
                    }
                case 667.0:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 4 * origin_x - 24
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 3 * origin_x - 50
                    }
                    
                    
                    
                    
                    
                default:
                    
                    if self.isCoverEnabled {
                        let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
                        origin_x = totalWidth/CGFloat(3)
                        gapPoint = 4 * origin_x
                    }
                    else{
                        let totalWidth = view.bounds.width
                        origin_x = totalWidth/CGFloat(3)
                        origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
                        gapPoint = 3 * origin_x - 35
                    }
                    
                }
            }
            else{
                if self.isCoverEnabled {
                    origin_x =  self.profilePic.frame.size.width + 246
                    gapPoint = origin_x
                }
                else{
                    let totalWidth = view.bounds.width
                    origin_x = totalWidth/CGFloat(3)
                    origin_x = origin_x - 5
                    gapPoint = 3 * (origin_x ) - 50
                }
            }
            
            
            
//            if self.isCoverEnabled {
//                let totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
//                origin_x = totalWidth/CGFloat(3)
//                gapPoint = 4 * origin_x
//            }
//            else{
//                let totalWidth = view.bounds.width
//                origin_x = totalWidth/CGFloat(3)
//                origin_x = origin_x - 5 // self.profilePic.frame.size.width + 246
//                gapPoint = 3 * origin_x - 35
//            }
//            if (DeviceType.IS_IPHONE_X) {
//                if self.isCoverEnabled {
//                    origin_x =  self.profilePic.frame.size.width + 246
//                    gapPoint = origin_x
//                }
//                else{
//                    let totalWidth = view.bounds.width
//                    origin_x = totalWidth/CGFloat(3)
//                    origin_x = origin_x - 5
//                    gapPoint = 3 * (origin_x ) - 50
//                }
//            }
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: gapPoint ,y: self.coverImageView.frame.size.height + 25), radius: CGFloat(42), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 3:
            var  coachMark3 : CoachMark
            let origin_x : CGFloat = self.view.bounds.width - 30
            let originy : CGFloat = 50.0
            let radious : CGFloat = 50.0
          
//            if self.profileOfUserId == currentUserId {
//               origin_x = 60.0
//                originy = (self.coverImageView.frame.size.height - 21)
//                radious = 60
//            }
//            else{
            feedObj.tableView.contentOffset.y = TOPPADING + 2
 //           }
            coachMark3 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x ,y: originy), radius: radious, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            coachMark3.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark3
       
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
    
        func coachMarksController(_ coachMarksController: CoachMarksController,
                                  willLoadCoachMarkAt index: Int) -> Bool {
           
            if nameMenu.contains("disble_message") && index == 1 {
           
                return false
            }
            return true
            }
    
        
    
    
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 4:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        var baseIndex = 3
        if self.profileOfUserId != currentUserId {
            baseIndex = 4
        }
       
        
        switch(index) {
           
        case 0:
            coachViews.bodyView.hintLabel.text = "\(showFirstMessage)"
            coachViews.bodyView.countTourLabel.text = " 1/\(baseIndex)"
            coachViews.bodyView.nextLabel.text = "Next "
        case 1:
            coachViews.bodyView.hintLabel.text = "\(showSecondMessage)"
            coachViews.bodyView.countTourLabel.text = " 2/\(baseIndex)"
            coachViews.bodyView.nextLabel.text = "Next "
        case 2:
            coachViews.bodyView.hintLabel.text = "\(showThirdMessage)"
            coachViews.bodyView.countTourLabel.text = " 3/\(baseIndex)"
            if baseIndex == 3 {
            coachViews.bodyView.nextLabel.text = "Finish "
            }
            else{
                coachViews.bodyView.nextLabel.text = "Next "
            }
        case 3:
            
            coachViews.bodyView.hintLabel.text = "\(showFourthMessage)"
            coachViews.bodyView.countTourLabel.text = " 4/\(baseIndex)"
            
            coachViews.bodyView.nextLabel.text = "Finish "
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        
        
//        let defaults = UserDefaults.standard
//        if let name = defaults.object(forKey: "showUserProfilePageAppTour")
//        {
//            if  UserDefaults.standard.object(forKey: "showUserProfilePageAppTour") != nil {
//
//                targetCheckValue = name as! Int
//
//
//            }
//
//        }
//
//        if targetCheckValue == 1 {
//
//            UserDefaults.standard.set(2, forKey: "showUserProfilePageAppTour")
//            coachMarksController.dataSource = self
//            coachMarksController.delegate = self
//            coachMarksController.overlay.allowTap = true
//            coachMarksController.overlay.fadeAnimationDuration = 0.5
//            coachMarksController.start(on: self)
//        }
//
        
        
    }
    
    
    func reloadpin(){
        maxid = 0
        let indexPath = IndexPath(row: 0, section: 0)
        self.feedObj.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
        feed_filter = 0
        browseFeed()
    }
    
    // Show Post Feed Option Selection (Status, Photos, Checkin)
    @objc func openPostFeed(_ sender:UIButton){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        //stopMyTimer()
        
        let presentedVC = AdvancePostFeedViewController()
        if (sender.tag - 1990) == 1 {
            presentedVC.openfeedStyle = 0//(sender.tag - 1990)
        }
        else{
            presentedVC.openfeedStyle = (sender.tag - 1990)
        }
        if sender.tag == 3{
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
            
        }else{
            if presentedVC.openfeedStyle == 3
            {
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }
            else
            {
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:true, completion: nil)
                
            }
            
        }
    }
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Handle Swipes
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            
        }
        
    }
    
    
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool) {
        self.browseEmoji(contentItems: reactionsDictionary)
        feedObj.feedShowingFrom = "UserFeed"
        tableViewFrameType = "ContentActivityFeedViewController"
//        NotificationCenter.default.addObserver(self, selector: #selector(ContentActivityFeedViewController.ScrollingactionContentActivityFeed(_:)), name: NSNotification.Name(rawValue: "ScrollingactionContentActivityFeed"), object: nil)
        subject_unique_id = subjectId
        subject_unique_type = "user"
        removeNavigationImage(controller: self)
        
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        self.marqueeHeader.text = NSLocalizedString("", comment: "" )
        if feedUpdate == true
        {
            // Set Default & request to hard Refresh
            feedUpdate = false
            maxid = 0
            showSpinner = true
            feed_filter = 1
            exploreContent()
        }
        else
        {
            globalFeedHeight = self.headerHeight
            // Updating array when coming from comment or photoviewer
            if contentfeedArrUpdate == true {
                self.feedObj.globalArrayFeed = userFeedArray
                contentfeedArrUpdate = false
            }
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                delay(2.0) {
                    self.feedObj.tableView.reloadData()
                }
            }else{
                fromExternalWebView = false
            }

        }
    }
    
    // Show Post Feed Option to User based on Permission from Server & Save these options
    func postFeedOption1()
    {
        var postPermission_variabel : Int = 0
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? NSData{
            if data.length != 0
            {
                for ob in postView.subviews
                {
                    if ob.tag != 108
                    {
                        ob.removeFromSuperview()
                    }
                    
                }
                postPermission = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                var postMenu = [String]()
                var menuIcon = [String]()
                var colorIcon = [UIColor]()
                if postPermission.count > 0{
                    if let status = postPermission["video"] as? Bool{
                        if status{
                            postMenu.append(NSLocalizedString(" Video", comment: ""))
                            menuIcon.append(videoIcon)
                            colorIcon.append(videoIconColor)
                            postPermission_variabel = 1
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
                            postMenu.append(NSLocalizedString(" Photo", comment: ""))
                            menuIcon.append("\u{f030}")
                            colorIcon.append(PhotoIconColor)
                        }
                    }
                    if apiServerKey != ""{
                        if let checkIn = postPermission["checkin"] as? Bool{
                            if checkIn{
                                postMenu.append(NSLocalizedString(" Check In", comment: ""))
                                menuIcon.append("\u{f041}")
                                colorIcon.append(CheckInIconColor)
                                
                            }
                        }
                    }
                }


                let  feedTextView = createButton(CGRect(x: 60 + PADING,y: 0 ,width: view.bounds.width-(60 + PADING),height: 64), title: NSLocalizedString("What's on your mind?",comment: "") , border: false ,bgColor: false, textColor: textColorMedium)
                feedTextView.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
                
                let border = CALayer()
                let width = CGFloat(0.5)
                let borderColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
                border.borderColor = borderColor.cgColor
                border.frame = CGRect(x: 0, y: 69, width: postView.frame.size.width , height: 1)
                
                border.borderWidth = width
                postView.layer.addSublayer(border)
                postView.layer.masksToBounds = true
                
                feedTextView.tag = 1990
                feedTextView.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                feedTextView.addTarget(self, action: #selector(ContentActivityFeedViewController.openPostFeed(_:)), for: .touchUpInside)
                feedTextView.backgroundColor = lightBgColor
                postView.addSubview(feedTextView)
                
                //Add Post Feed Option
                for i in 0 ..< postMenu.count
                {
                    let origin_x = (CGFloat(i) * (view.bounds.width/CGFloat(postMenu.count)))
                    let postFeed = createButton(CGRect(x: origin_x,y: 70 ,width: view.bounds.width/CGFloat(postMenu.count),height: 35), title: "" , border: false ,bgColor: false, textColor: textColorMedium )
                    switch i {
                    case 0:
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string:  menuIcon[0])
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                          attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[0], range: NSMakeRange(0, attrString.length))
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[0])",comment: ""))
                        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                        descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                        attrString.append(descString);
                        
                        postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                        break
                    case 1:
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[1])
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[1], range: NSMakeRange(0, attrString.length))
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[1])",comment: ""))
                        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                         descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                        attrString.append(descString);
                        
                        postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                        break
                    case 2:
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[2])
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[2], range: NSMakeRange(0, attrString.length))
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[2])",comment: ""))
                        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                         descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                        attrString.append(descString);
                        
                        postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                        break
                    default:
                        break
                    }
                    
                    postFeed.backgroundColor = lightBgColor
                    if postPermission_variabel == 1 {
                        postFeed.tag = i+1 + 1990
                    }
                    else{
                        postFeed.tag = i+2 + 1990
                    }
                    postFeed.titleLabel?.textAlignment = NSTextAlignment.center
                    postFeed.addTarget(self, action: #selector(ContentActivityFeedViewController.openPostFeed(_:)), for: .touchUpInside)
                    postView.addSubview(postFeed)
                }
                postMenu.removeAll(keepingCapacity: false)
            }
        }
    }

    // Pull to Request Action
    @objc func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            maxid = 0
            
            feed_filter = 1
            exploreContent()
            //browseFeed()
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
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        //  updateScrollFlag = true
        stop()
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    // Request to Show New Stories Feed
    @objc func updateNewFeed(){
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Variables
            maxid = 0
            
            feed_filter = 0
            browseFeed()
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
    }
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        var origin_x:CGFloat = 0
        var button_title : String!
        var tempLabelCount = 0
        for tempArray in memberProfileTabMenu {
            
            let memberProfileTabMenuDic = tempArray as! NSDictionary
            if memberProfileTabMenuDic["totalItemCount"] as? Int > 0{
                tempLabelCount += 1
            }
            if memberProfileTabMenuDic["name"] as! String == "update"{
                tempLabelCount += 1
            }
            
            if memberProfileTabMenuDic["name"] as! String == "info"{
                
                tempLabelCount += 1
            }
        }
        
        for menu in memberProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                if menuItem["totalItemCount"] as? Int > 0 || menuItem["name"] as! String == "update" || menuItem["name"] as! String == "info" {
                    button_title = menuItem["label"] as! String
                    
                    let butn_forum = menuItem["name"] as! String
                    
                    if butn_forum != "forum_topics"{
                        if let totalItem = menuItem["totalItemCount"] as? Int{
                            
                            if totalItem > 0{
                                button_title = button_title + " (\(totalItem))"
                                
                            }
                            
                        }
                        
                        var width : CGFloat = 100.0
                        
                        switch(tempLabelCount)
                        {
                        case 1:
                            width = UIScreen.main.bounds.width
                            
                        case 2:
                            width = UIScreen.main.bounds.width/2
                            
                        case 3:
                            width = UIScreen.main.bounds.width/3
                            
                        default:
                            width = findWidthByText(button_title) + 10//100.0
                        }
                        
                        
                        let menu = createNavigationButton(CGRect(x: origin_x,y: 10 ,width: width , height: tabsContainerMenu.bounds.height) , title: button_title, border: true, selected: false)
                        if menuItem["name"] as! String == "update"
                        {
                            menu.setSelectedButton()
                        }
                        else
                        {
                            menu.setUnSelectedButton()
                        }
                  
                        menu.backgroundColor  =  TabMenubgColor
                        menu.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        menu.tag = 101
                        menu.addTarget(self, action: #selector(ContentActivityFeedViewController.tabMenuAction(_:)), for: .touchUpInside)
                        tabsContainerMenu.addSubview(menu)
                        origin_x += width
                    }
                    
                    
                    if origin_x > view.bounds.width{
                        extraMenuRight.setTitle("", for: UIControl.State())
                    }
                    
                    tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
                    
                }}
        }
    }
    
    //FUNCTION TO SHOW THE MEMBER PROFILE TABS
    @objc func tabMenuAction(_ sender:UIButton){
        
        for menu in memberProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                
                // if button_title != "Fourms Posts" {
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                        
                    }
                }
                
                if sender.titleLabel?.text == button_title{
                    
                    if menuItem["name"] as! String == "info"{
                        let presentedVC = UserInfoViewController()
                        presentedVC.user_id = subjectId
                        navigationController?.pushViewController(presentedVC,animated:true)
                    }
                    
                    if menuItem["name"] as! String == "friends"{
                        let presentedVC = MemberViewController()
                        presentedVC.fromTab = true
                        presentedVC.contentType = "user"
                        presentedVC.contentId = subjectId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    if menuItem["name"] as! String == "music"{
                        MusicObject().redirectToMusicFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString,username: userNameString)
                        
                    }
                    
                    if menuItem["name"] as! String == "blog"{
                        BlogObject().redirectToBlogFromContentFeed(self, userId : subjectId, title : button_title + " : " + userNameString)
                    }
                    
                    if menuItem["name"] as! String == "album"{
                        let presentedVC = AlbumViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        presentedVC.countListTitle = button_title + " : " + userNameString
                        presentedVC.username = userNameString
                        navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    if menuItem["name"] as! String == "video"{
                        
                        if menuItem["isAdvancedModuleEnabled"] != nil && menuItem["isAdvancedModuleEnabled"] as! Bool == true
                        {
                            SitevideoObject().redirectToAdvVideoFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString, videoTypeCheck : "",userName: userNameString)
                        }
                        else
                        {
                            VideoObject().redirectToVideoFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString, videoTypeCheck : "")
                        }
                        
                    }
                    if menuItem["name"] as! String == "channel"{
                        let presentedVC = ChannelViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        presentedVC.showOnlyMyContent = true
                        presentedVC.countChannel = button_title
                       

                        self.navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "classified"{
                        ClassifiedObject().redirectToClassifiedFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString)
                    }
                    
                    if menuItem["name"] as! String == "group"{
                        GroupObject().redirectToBrowsePageFromContentFeed(self, id: subjectId, title: button_title + " : " + userNameString)
                    }
                    
                    if  menuItem["name"] as! String == "following"{
                        let presentedVC = MemberViewController()
                        presentedVC.fromTab = true
                        presentedVC.contentType = "userFollow"
                        presentedVC.contentId = subjectId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    
                    if menuItem["name"] as! String == "followers" {
                        let presentedVC = MemberViewController()
                        presentedVC.contentType = "userFollower"
                        presentedVC.fromTab = true
                        // presentedVC.url = "advancedmember/followers"
                        presentedVC.contentId = subjectId
                        
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    

               
                    
                    if menuItem["name"] as! String == "sitereview_listing"{
                        
                        let listingTypeId = menuItem["listingtype_id"] as! Int
                        if listingBrowseViewTypeArr[listingTypeId] != nil{
                        var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
                        let browseType = tempBrowseViewTypeDic["browseType"]!
                        let viewType = tempBrowseViewTypeDic["viewType"]!
                            SiteMltObject().redirectToMltFromContentFeed(self, id: subjectId, title: button_title + " : " + userNameString, browseTypeValue : browseType , viewTypeValue : viewType , listingTypeIdValue : listingTypeId , nameLabel : menuItem["label"] as! String , path : "",username:userNameString)
                        }
                        else{
                           
                            let browseType = 1
                            let viewType = 1
                            SiteMltObject().redirectToMltFromContentFeed(self, id: subjectId, title: button_title + " : " + userNameString, browseTypeValue : browseType , viewTypeValue : viewType , listingTypeIdValue : listingTypeId , nameLabel : menuItem["label"] as! String , path : "",username:userNameString)
                        }
                    }
                    
                    if menuItem["name"] as! String == "event"
                    {
                        if menuItem["isAdvancedModuleEnabled"] != nil && menuItem["isAdvancedModuleEnabled"] as! Bool == true
                        {
                            let presentedVC = AdvancedEventViewController()
                            presentedVC.user_id = subjectId
                            presentedVC.showOnlyMyContent = true
                            presentedVC.fromTab = true
                            
                            if menuItem["totalItemCount"] as? Int != nil {
                                presentedVC.eventCount = menuItem["totalItemCount"] as! Int
                            }
                            navigationController?.pushViewController(presentedVC, animated: true)
                            
                        }
                        else
                        {
                            let presentedVC = EventViewController()
                            presentedVC.user_id = subjectId
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = true
                            presentedVC.countListTitle = button_title + " : " + userNameString
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    
                    if menuItem["name"] as! String == "poll"{
                        let presentedVC = PollViewController()
                        presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        presentedVC.showOnlyMyContent = true
                        presentedVC.countListTitle = button_title + " : " + userNameString
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    if menuItem["name"] as! String == "sitepage"{
                        SitePageObject().redirectToPageFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString,userName: userNameString)
                    }
                    
                    if menuItem["name"] as! String == "sitegroup"{
                        SiteAdvGroupObject().redirectToAdvGroupFromContentFeed(self, userId: subjectId, title: button_title + " : " + userNameString,userName: userNameString)
                    }

                }
            }
        }
    }
    
    // MARK: - Activity Feed Actions for Like, Comment & Share
    // MARK: - Updation in Core Data & Feed Array From  Server Response
    
    // Make Updation in Core Data for every Recent Activity Feed (All Updates)
    func updateActivityFeed(_ feeds:[ActivityFeed]){
        // Save Response in Core Data
        
        let request:NSFetchRequest<ActivityFeedData>
        
        if #available(iOS 10.0, *){
            request = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
        }else{
            request = NSFetchRequest(entityName: "ActivityFeedData")
        }
        
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0){
            
            // If exist than Delete all entries
            for result: AnyObject in results! {
                context.delete(result as! NSManagedObject)
            }
            do {
                try context.save()
            } catch _ {
            }
            // Update Saved Feed
            updateSavedFeed(feeds)
        }
        else
        {
            // Update Saved Feed
            updateSavedFeed(feeds)
        }
    }
    
    // Updates Saved Feed in Core Data For Recent Feed
    func updateSavedFeed(_ feeds:[ActivityFeed]){
        var i = 0
        for feed in feeds{
            // Insert FeedData in Entity ActivityFeedData
            let newfeed = NSEntityDescription.insertNewObject(forEntityName: "ActivityFeedData", into: context) as NSManagedObject
            
            
            if feed.action_id != nil{
                newfeed.setValue( feed.action_id , forKey: "action_Id")
            }
            if feed.subject_id != nil{
                newfeed.setValue( feed.subject_id , forKey: "subject_Id")
            }
            if feed.share_params_id != nil{
                newfeed.setValue( feed.share_params_id , forKey: "share_params_id")
            }
            if feed.share_params_type != nil{
                newfeed.setValue( feed.share_params_type , forKey: "share_params_type")
            }
            
            
            if feed.attachment != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.attachment!) , forKey: "attachment")
            }
            if feed.feed_reactions != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_reactions!) , forKey: "feed_reactions")
            }
            if feed.my_feed_reaction != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.my_feed_reaction!) , forKey: "my_feed_reaction")
            }
            
            if feed.attactment_Count != nil{
                newfeed.setValue( feed.attactment_Count , forKey: "attachmentCount")
            }
            if feed.comment != nil{
                newfeed.setValue( feed.comment , forKey: "canComment")
            }
            if feed.delete != nil{
                newfeed.setValue( feed.delete , forKey: "canDelete")
            }
            if feed.share != nil{
                newfeed.setValue( feed.share , forKey: "canShare")
            }
            if feed.comment_count != nil{
                newfeed.setValue( feed.comment_count , forKey: "commentCount")
            }
            if feed.feed_createdAt != nil{
                newfeed.setValue( feed.feed_createdAt , forKey: "creationDate")
            }
            if feed.feed_menus != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_menus!) , forKey: "feedMenu")
            }
            if feed.feed_footer_menus != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_footer_menus!) , forKey: "feed_footer_menus")
            }
            if feed.feed_title != nil{
                newfeed.setValue( feed.feed_title , forKey: "feedTitle")
            }
            if feed.feed_Type != nil{
                newfeed.setValue( feed.feed_Type , forKey: "feedType")
            }
            if feed.is_like != nil{
                newfeed.setValue( feed.is_like , forKey: "isLike")
            }
            if feed.likes_count != nil{
                newfeed.setValue( feed.likes_count , forKey: "likeCount")
            }
            if feed.subject_image != nil{
                newfeed.setValue( feed.subject_image , forKey: "subjectAvatarImage")
            }
            if feed.photo_attachment_count != nil{
                newfeed.setValue( feed.photo_attachment_count , forKey: "photo_attachment_count")
            }
            if feed.object_id != nil{
                newfeed.setValue( feed.object_id , forKey: "object_id")
            }
            if feed.object_type != nil{
                newfeed.setValue( feed.object_type , forKey: "object_type")
            }
            if feed.params != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.params!) , forKey: "params")
            }
            if feed.tags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.tags!) , forKey: "tags")
            }
            if feed.action_type_body_params != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.action_type_body_params!) , forKey: "action_type_body_params")
            }
            if feed.action_type_body != nil{
                newfeed.setValue( feed.action_type_body , forKey: "action_type_body")
            }
            if feed.object != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.object!) , forKey: "object")
            }
            if feed.hashtags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.hashtags!) , forKey: "hashtags")
            }
            if feed.userTag != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.userTag!) , forKey: "userTag")
            }
            if feed.wordStyle != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.wordStyle!) , forKey: "wordStyle")
            }
            if feed.isNotificationTurnedOn != nil{
                 newfeed.setValue( feed.isNotificationTurnedOn , forKey: "isNotificationTurnedOn")
            }
            if feed.pin_post_duration != nil{
                newfeed.setValue( feed.pin_post_duration , forKey: "pin_post_duration")
            }
            if feed.isPinned != nil{
                newfeed.setValue( feed.isPinned , forKey: "isPinned")
            }

            
            do {
                try context.save()
            } catch _ {
            }
            i += 1
            
        }
        
    }
    
    // Update/ Sink userFeedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArray(_ feeds:[ActivityFeed]){
        
        var existingFeedIntegerArray = [Int]()
        
        for tempFeedArrays in userFeedArray {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as! Int)
        }
        
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
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
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
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
            }
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            

            
            let actionId  = newDictionary["action_id"] as! Int
            
            if !existingFeedIntegerArray.contains(actionId){
                userFeedArray.append(newDictionary)
            }
            
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
        if logoutUser == false
        {
            globalFeedHeight = self.headerHeight
        }
        else
        {
            globalFeedHeight = self.headerHeight
        }
        self.feedObj.globalArrayFeed = userFeedArray
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        
    }
    
    // MARK: - Server Connection For Activity Feeds Updation
    
    func newfeedsUpdate(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            if subjectId == 0 && subjectType == ""{
                parameters = ["limit": "\(limit)", "minid":String(minid), "feed_count_only":"1","getAttachedImageDimention":"0"]
            }else{
                parameters = ["limit": "\(limit)", "minid":String(minid), "feed_count_only":"1","getAttachedImageDimention":"0", "subject_id":String(subjectId), "subject_type": subjectType]
            }
            
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // Reset Object after Response from server
                    userInteractionOff = true
                    
                    // On Success Update Feeds
                    if msg{
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            if let newFeedCount = response["response"] as? Int{
                                for ob in self.view.subviews{
                                    if ob.tag == 2020{
                                        ob.removeFromSuperview()
                                    }
                                }
                                
                                if newFeedCount > 0{
                                    
                                    //Show New Feed Option for new Stories
                                    let newFeedCount =  String(format: NSLocalizedString("%d new stories", comment:""),newFeedCount)
                                    
                                    let newFeeds = createButton(CGRect( x: 0, y: self.headerHeight + TOPPADING + ButtonHeight , width: findWidthByText(newFeedCount) + 40 , height: ButtonHeight - PADING),title: newFeedCount, border: false,bgColor: true, textColor: textColorLight)
                                    newFeeds.tag = 2020
                                    newFeeds.center = CGPoint(x: self.view.center.x, y: newFeeds.frame.origin.y)
                                    newFeeds.layer.cornerRadius = newFeeds.bounds.height/2
                                    
                                    newFeeds.addTarget(self, action: #selector(ContentActivityFeedViewController.updateNewFeed), for: .touchUpInside)
                                    
                                    self.mainView.addSubview(newFeeds)
                                    
                                }
                            }
                            
                        }
                        
                    }else{
                        // Show Message on Failour
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
    
    // Explore Group Detail
    func exploreContent(){
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            mainView.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            
            var url = ""
            var parameters = ["gutter_menu": "1", "profile_tabs" : "1"]
            if subjectType == "user"{
                parameters["user_id"] = String(self.subjectId)
                url = "user/profile/" + String(self.subjectId)
            }else if subjectType == "group"{
                parameters["group_id"] = String(self.subjectId)
                url = "groups/view/" + String(self.subjectId)
            }
            
            // Send Server Request to Explore Group Contents with Group_ID
            post( parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        self.browseFeed()
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        if succeeded["body"] != nil{
                            // On Success Update Group Detail
                            if let userInfo = succeeded["body"] as? NSDictionary {
                                
                                if let menu = userInfo["profile_tabs"] as? NSArray{
                                    self.memberProfileTabMenu = menu
                                    self.tabsContainerMenu.isHidden = false
                                }
                                
                                
                                
                                if let response = userInfo["response"] as? NSDictionary{
                                    
                                    if self.subjectType == "user"{
                                        self.marqueeHeader.text = response["owner_title"] as? String
                                    }else{
                                        self.marqueeHeader.text = response["title"] as? String
                                    }
                                    
                                    self.mainSubView.isHidden = false
                                    
                                    
                                    if let photoId = response["photo_id"] as? Int{
                                        if photoId != 0{
                                            if let url = URL(string: response["image"] as! String)
                                            {
                                                self.memberProfilePhoto.kf.indicatorType = .activity
                                                (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    if let imgT = image
                                                    {
                                                        if !self.isCoverEnabled{
                                                            let tempCoverWidth = Double(self.coverImageView.bounds.width)
                                                            let tempCoverHeight = Double(self.coverImageView.bounds.height)
                                                            self.coverImageView.image = cropToBounds(imgT, width: tempCoverWidth, height: tempCoverHeight)
                                                        }
                                                    }

                                                })
                                                
                                                self.userProfilePicUrl = response["image"] as! String
                                                if !self.isCoverEnabled{
                                                    self.userCoverPicUrl = response["image"] as! String
                                                }
                                            }
                                            
                                        }else{
                                            
                                            self.memberProfilePhoto.image =  imageWithImage( UIImage(named: "user_profile_image.png")!, scaletoWidth: self.memberProfilePhoto.bounds.width)
                                            self.userProfilePicUrl = ""
                                            
                                            if !self.isCoverEnabled{
                                                self.coverImageView.image =  imageWithImage( UIImage(named: "user_profile_image.png")!, scaletoWidth: self.coverImageView.bounds.width)
                                                self.userCoverPicUrl = ""
                                            }
                                            
                                            // Alert user to upload a profile photo
                                            let alert = UIAlertController(title: "Upload your profile picture", message: "It makes your account legit and professional.", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                                                NSLog("Ok is click")
                                                let presentedVC = EditProfilePhotoViewController()
                                                presentedVC.currentImageUrl = self.userProfilePicUrl
                                                presentedVC.url = "user/profilepage/upload-cover-photo/user_id/" + String(self.subjectId) + "/special/profile"
                                                presentedVC.pageTitle = NSLocalizedString("Edit Profile Photo", comment: "")
                                                presentedVC.showCameraButton = true
                                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                            }))
                                            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: {_ in
                                                NSLog("Not Now is click")
                                            }))
                                            self.present(alert,animated:true, completion:nil)
                                        }
                                    }
                                    
                                    if let mainPhotoMenu = response["mainPhotoMenu"] as? NSArray{
                                        
                                        self.profilePhotoMenu = mainPhotoMenu
                                    }
                                    
                                    
                                    if self.isCoverEnabled{
                                        self.coverImageView.contentMode = .scaleAspectFill
                                        if (response["cover"] as? String) != nil{
                                            if let url =  URL(string: response["cover"] as! String){
                                                self.userCoverPicUrl = response["cover"] as! String

                                                self.coverImageView.kf.indicatorType = .activity
                                                (self.coverImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.coverImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    if let img = image
                                                    {
                                                        let tempCoverWidth = Double(self.coverImageView.bounds.width)
                                                        let tempCoverHeight = Double(self.coverImageView.bounds.height)
                                                       
                                                        self.coverImageView.image = cropToBounds(img, width: tempCoverWidth, height: tempCoverHeight)
                                                    }
                                                })
                                            }
                                        }else{
                                            
                                            self.coverImageView.image =  imageWithImage( UIImage(named: "user_profile_image.png")!, scaletoWidth: self.coverImageView.bounds.width)
                                            self.userCoverPicUrl = ""
                                            
                                        }
                                    }
                                    
                                    
                                    if let coverPhotoMenu = response["coverPhotoMenu"] as? NSArray{
                                        self.coverPhotoMenu = coverPhotoMenu
                                    }
                                    
                                    if logoutUser == false{
                                        if let profileUserId = response["user_id"] as? Int{
                                            self.profileOfUserId = profileUserId
                                            if profileUserId != 0 && profileUserId == currentUserId && self.isCoverEnabled{
                                                self.camIconOnProfile.isHidden = false
                                                self.camIconOnCover.isHidden = false
                                            }
                                        }
                                    }
                                
                                    self.userName.text = response["owner_title"] as? String
                                    
                                    self.contentName.text = response["displayname"] as? String
                                    
                                    self.userNameString = response["displayname"] as? String
                                    
                                    self.userName.lineBreakMode = NSLineBreakMode.byCharWrapping
                                    self.userName.sizeToFit()
                                    self.userName.frame.origin.y = self.coverImageView.bounds.height - (self.userName.bounds.height + contentPADING)
                                    let origin_y:CGFloat!
                                    if let gutterMenu = userInfo["gutterMenu"] as? NSArray{
                                        self.gutterMainMenu = gutterMenu
                                        self.menuView.isHidden = false
                                        self.showFourthMessage = "Get access to more options like Block, Report etc."
                                        self.showMenus()
                                         if self.isCoverEnabled {
                                         origin_y  = (self.topMainView.bounds.height + self.topMainView.frame.origin.y )
                                        }
                                         else{
                                            origin_y  = (self.topMainView.bounds.height + self.topMainView.frame.origin.y )
                                        }
                                    }
                                    else{
                                        self.browseasguest()
                                        self.menuView.isHidden = false//true
                                        if self.isCoverEnabled//!self.isCoverEnabled
                                        {
                                        origin_y = (self.topMainView.bounds.height + self.topMainView.frame.origin.y )
                                        }
                                        else{
                                            origin_y = (self.topMainView.bounds.height + self.topMainView.frame.origin.y)
                                        }
                                    }
                                    self.tabsContainerMenu.frame.origin.y = origin_y
                                    if(UIDevice.current.userInterfaceIdiom == .pad){
                                        self.tabsContainerMenu.frame.origin.y = origin_y + contentPADING - 20
                                    }
                                    
                                    self.extraMenuLeft.frame.origin.y = origin_y + contentPADING
                                    self.extraMenuRight.frame.origin.y = origin_y + contentPADING
                                    self.extraMenuRight.isHidden = false
                                    self.extraMenuLeft.isHidden = false
                                    
                                    self.headerHeight =  self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + contentPADING - 2
                                    
                                    
                                    self.showtabMenu()
                                    
                                   
                                    
                                    if (logoutUser == false){
                                        
                                      let heightOfPostView =  self.headerHeight 
                                        self.postView =  createView(CGRect(x: 0,y:heightOfPostView,width: self.view.bounds.width,height: 110), borderColor: borderColorMedium , shadow: true)
                                        
                                        self.feedObj.tableView.addSubview(self.postView)
                                        self.userImage = createImageView(CGRect(x:PADING,y:9,width: 50,height: 50), border: true)
                                        self.userImage.image = UIImage(named: "user_profile_image.png")
                                        self.userImage.tag = 108
                                        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
                                        self.userImage.clipsToBounds = true

                                        self.postView.addSubview(self.userImage)
                                        
                                        
                                        let profile = createButton(CGRect(x: PADING,y: 9,width: 50,height: 50), title: "", border: false, bgColor: false, textColor: textColorLight)
                                        self.postView.addSubview(profile)
                                        profile.tag = 108
                                        
                                        // Download userprofile
                                        if coverImage != nil {
                                            let coverImageUrl = NSURL(string: coverImage)
                                            if coverImageUrl != nil {
                                        
                                                self.userImage.kf.indicatorType = .activity
                                                (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.userImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                   coverPhotoImage = image
                                                    
                                                })
                                                
                                            }
                                            
                                        }
                                        let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                        rightNavView.backgroundColor = UIColor.clear
                                        
                                        if logoutUser == false{
                                             if self.profileOfUserId != currentUserId{
                                            let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                            optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                            optionButton.addTarget(self, action: #selector(ContentActivityFeedViewController.showMainGutterMenu1), for: .touchUpInside)
                                            
                                            rightNavView.addSubview(optionButton)
                                            
                                            self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                            }
                                        }

                                        // Show Feed Option only to LoginUser
                                        self.postFeedOption1()
                                        self.headerHeight = self.headerHeight + self.postView.frame.size.height
                                    }
                                    else{
                                     self.headerHeight = self.headerHeight + contentPADING
                                    }
                                    self.feedObj.refreshLikeUnLike = true
                                    self.feedObj.tableView.reloadData()
                                   /*
                                    if self.profileOfUserId == currentUserId {
                                    let defaults = UserDefaults.standard
                                    if let name = defaults.object(forKey: "showUserProfilePageAppTour")
                                    {
                                        if  UserDefaults.standard.object(forKey: "showUserProfilePageAppTour") != nil {
                                            
                                            self.targetCheckValue = name as! Int
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    if self.targetCheckValue == 1 {
                                        
                                        UserDefaults.standard.set(2, forKey: "showUserProfilePageAppTour")
                                        self.coachMarksController.dataSource = self
                                        self.coachMarksController.delegate = self
                                        self.coachMarksController.overlay.allowTap = true
                                        self.coachMarksController.overlay.fadeAnimationDuration = 0.5
                                        self.coachMarksController.start(on: self)
                                        
                                    }
                                    }
                                    else{
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "showOtherUserProfilePageAppTour")
                                        {
                                            if  UserDefaults.standard.object(forKey: "showOtherUserProfilePageAppTour") != nil {
                                                
                                                self.targetCheckValue = name as! Int
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        if self.targetCheckValue == 1 {
                                            
                                            UserDefaults.standard.set(2, forKey: "showOtherUserProfilePageAppTour")
                                            self.coachMarksController.dataSource = self
                                            self.coachMarksController.delegate = self
                                            self.coachMarksController.overlay.allowTap = true
                                            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
                                            self.coachMarksController.start(on: self)
                                            
                                        }
                                    }
                                    
                                   */
                                }                                
                            }
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            
                            
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            let message = succeeded["message"] as? String
                            if message == "You do not have the access of this page."
                            {
                                self.popAfterDelay = true
                                self.createTimer(self)
                                
                            }
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
        
    }
    
    func showAppTour(){
        if self.profileOfUserId == currentUserId {
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "showUserProfilePageAppTour")
            {
                if  UserDefaults.standard.object(forKey: "showUserProfilePageAppTour") != nil {
                    
                    self.targetCheckValue = name as! Int
                    
                    
                }
                
            }
            
            if self.targetCheckValue == 1 {
                
                UserDefaults.standard.set(2, forKey: "showUserProfilePageAppTour")
                self.coachMarksController.dataSource = self
                self.coachMarksController.delegate = self
                self.coachMarksController.overlay.allowTap = true
                self.coachMarksController.overlay.fadeAnimationDuration = 0.5
                self.coachMarksController.start(on: self)
                
            }
        }
        else{
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "showOtherUserProfilePageAppTour")
            {
                if  UserDefaults.standard.object(forKey: "showOtherUserProfilePageAppTour") != nil {
                    
                    self.targetCheckValue = name as! Int
                    
                    
                }
                
            }
            
            if self.targetCheckValue == 1 {
                
                UserDefaults.standard.set(2, forKey: "showOtherUserProfilePageAppTour")
                self.coachMarksController.dataSource = self
                self.coachMarksController.delegate = self
                self.coachMarksController.overlay.allowTap = true
                self.coachMarksController.overlay.fadeAnimationDuration = 0.5
                self.coachMarksController.start(on: self)
                
            }
        }
        
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    func browseFeed(){
        // Check Internet Connectivity
        if reachability.connection != .none {
            removeAlert()
            //stopMyTimer()
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob in mainView.subviews{
                if ob.tag == 10000{
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2020{
                    ob.removeFromSuperview()
                }
            }
            for ob1 in self.self.feedObj.tableView.subviews
            {
                if  ob1.tag == 1000{
                    ob1.removeFromSuperview()
                }
            }
            
            
            // Reset Objects for Hard Refresh Request
            if (maxid == 0){
                
                
                if userFeedArray.count == 0{
                    
                    feedObj.tableView.reloadData()
                }
                
            }
            
            
            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                mainView.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            if subjectId == 0 && subjectType == ""{
                parameters = ["maxid":String(maxid), "limit": "\(limit)", "feed_filter": "\(feed_filter)", "object_info":"1","getAttachedImageDimention":"0"]
            }else{
                parameters = ["maxid":String(maxid), "limit": "\(limit)", "subject_id":String(subjectId), "subject_type": subjectType, "feed_filter": "1","object_info":"1","getAttachedImageDimention":"0"]
            }
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Send Server Request for Activity Feed
            post(
                
            parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                 //   userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }else{
                        self.refresher.endRefreshing()
                       // self.showSpinner = true
                    }
                    self.showSpinner = false
                    self.feedObj.tableView.tableFooterView?.isHidden = true
                    // On Success Update Feeds
                    if msg{
                        // If Message in Response show the Message
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        
                        
                        // Reset userFeedArray for Sink with Feed Results
                        if self.maxid == 0{
                            userFeedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
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
                            // Check that whether Sticker Plugin is enable or not
                            if let stickersEnable = response["stickersEnabled"] as? Bool{
                                if stickersEnable == true{
                                    StickerPlugin = true
                                }
                            }
                            
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update userFeedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
                            }
                            self.showAppTour()
                            userInteractionOff = true
                            // update Recent Feeds in Core Data
                            if self.maxid == 0 && searchDic.count == 0  && self.subjectType == ""{
                                self.updateActivityFeed(self.activityFeeds)
                            }
                            
                            
                            // Set MaxId for Feeds Result
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            // Check for Post Feed Options
                            
                            if response["feed_post_menu"] != nil{
                                if let _ = response["feed_post_menu"] as? NSDictionary{
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: postPermission), forKey: "postMenu")
                                if (logoutUser == false){
                                    self.postFeedOption1()
                                }
                                
                            }
                            }
                            
                            
                            
                            // Set Label If their is no feed in response
                            if userFeedArray.count == 0 {
                                self.info  = createLabel(CGRect(x: 10,y: self.headerHeight + 5,width: self.view.bounds.width - 20 , height: 30), text: NSLocalizedString("Nothing has been posted here yet - be the first!",  comment: "") , alignment: .center, textColor: textColorDark)
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.backgroundColor = UIColor.clear
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.info.tag = 1000
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false
                            }
                            
                            
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
                            //self.startMyTimer()    // Create Timer for Check UPdtes Repeatlly
                        }
                        
                    }else{
                         userInteractionOff = true
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }else{
             userInteractionOff = true
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")

        }
        
    }
    
    func browseEmoji(contentItems: NSDictionary){
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
        }
        var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as! Dictionary<String, AnyObject>
        var width   = contentItems.count
        width =  (6 * width ) +  (40 * width)
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
            let   v = allReactionsValueDic[key]!
            if let icon = v["icon"] as? NSDictionary{
                menuWidth = 40
                let   emoji = createButton(CGRect(x: origin_x,y: 5,width: menuWidth,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                emoji.addTarget(self, action: #selector(ContentActivityFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                emoji.tag = v["reactionicon_id"] as! Int
                let imageUrl = icon["reaction_image_icon"] as? String
                
                
                let url = NSURL(string:imageUrl!)
                if url != nil
                {
                    emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
                }
                scrollViewEmoji.addSubview(emoji)
                //                                origin_x += menuWidth
                origin_x = origin_x + menuWidth  + 5
                i = i + 1
                
                
            }
            
            
        }
        //
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
        
        let feed = userFeedArray[scrollViewEmoji.tag] as! NSDictionary
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
    
    
    // MARK: - Start Work for tabs of add friend , message , and more menu
    func showMenus(){
        
        let countLoops  = 3
        var xGap : CGFloat! = 0
        var totalWidth: CGFloat! = 0
        var widthXgap : CGFloat! = 0
        var conditionName = ""
        showMenu.removeAll(keepingCapacity: false)
        showIcon.removeAll(keepingCapacity: false)
        nameMenu.removeAll(keepingCapacity: false)
        moreNameMenu.removeAll(keepingCapacity: false)
        
        if self.isCoverEnabled {
            totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
            widthXgap = totalWidth/CGFloat(countLoops)
        }
        else{
            totalWidth = view.bounds.width
            widthXgap = totalWidth/CGFloat(countLoops)
            widthXgap = widthXgap - 5
        }
        
        
        
        for menu in gutterMainMenu{
            if let dic = menu as? NSDictionary{
                
                let condition = dic["name"] as! String
                
                if   profileOfUserId != currentUserId {
                    
                    if condition == "add_friend" || condition ==  "member_follow"
                    {
                        showMenu.append(NSLocalizedString(dic["label"] as! String, comment: ""))
                        showIcon.append("addFriend")
                        nameMenu.append(condition)
                        showFirstMessage = "Add friend from here."
                    }
                    else  if  condition == "cancel_request" ||   condition == "cancel_follow"
                    {
                        showMenu.append(NSLocalizedString(dic["label"] as! String, comment: ""))
                        showIcon.append("cancelFriendRequest")
                        nameMenu.append(condition)
                        showFirstMessage = "Cancel request from here."
                    }
                    else if  condition == "remove_friend" ||  condition == "member_unfollow"
                    {
                        showMenu.append(NSLocalizedString(dic["label"] as! String, comment: ""))
                        showIcon.append("removeFriend")
                        nameMenu.append(condition)
                        showFirstMessage = "Remove friend from here."
                    }
                    else if  condition == "accept_request"
                    {
                        showMenu.append(NSLocalizedString(dic["label"] as! String, comment: ""))
                        showIcon.append("cancelFriendRequest")
                        nameMenu.append(condition)
                        showFirstMessage = "Accept Member from here."
                    }
                    else  if condition == "user_profile_send_message"{
                        
                        showMenu.append(NSLocalizedString("Message", comment: ""))
                        showIcon.append("messageIcon")
                        nameMenu.append(condition)
                        showSecondMessage = "Start a conversation and get to know your friends."
                        
                    }
                       
                    else{
                        if !(condition == "following" || condition == "follow"){
                        moreMenu.append(NSLocalizedString(dic["label"] as! String, comment: ""))
                        moreNameMenu.append(condition)
                        }
                    }
                }
                else{
                    if condition == "user_home_edit"{
                        showMenu.append(NSLocalizedString("Edit Profile", comment: ""))
                        showIcon.append("editInfo")
                        nameMenu.append(condition)
                        showFirstMessage = "Edit your Profile Information."
                        
                        
                        showMenu.append(NSLocalizedString("Edit Photo", comment: ""))
                        nameMenu.append("user_photo_edit")
                        showIcon.append("editPhoto")
                        showSecondMessage = "Edit your Profile Photo."
                        
                        showMenu.append(NSLocalizedString("Friends", comment: ""))
                        showIcon.append("friends")
                        nameMenu.append("friends")
                        showThirdMessage = "Check your Friend List from here."
                        
                    }
                    
                }
            }
        }
        
        for menu in gutterMainMenu{
            if let dic = menu as? NSDictionary{
                
                let condition = dic["name"] as! String
        
        if profileOfUserId != currentUserId{
            if showMenu.count == 1{
                showMenu.append(NSLocalizedString("Message", comment: ""))
                nameMenu.append("disble_message")
                showIcon.append("messageIcon")
                if condition == "following" || condition == "follow" {
                if condition == "following"{
                    showMenu.append(NSLocalizedString("\(dic["label"] as! String)", comment: ""))
                    nameMenu.append("\(dic["name"] as! String)")
                    showIcon.append("followSubscribe")
                    showThirdMessage = "Following the member to see their public Posts."
                }
                if condition == "follow"{
                    showMenu.append(NSLocalizedString("\(dic["label"] as! String)", comment: ""))
                    nameMenu.append("\(dic["name"] as! String)")
                    showIcon.append("followSubscribe")
                    showThirdMessage = "Follow the members to see their Public Posts."
                }
                }
                
                
            }
            else { //if showMenu.count == 2{
            if condition == "following" || condition == "follow" {
                if condition == "following"{
                    showMenu.removeLast()
                    showIcon.removeLast()
                    nameMenu.removeLast()
                    showMenu.append(NSLocalizedString("\(dic["label"] as! String)", comment: ""))
                    nameMenu.append("\(dic["name"] as! String)")
                    showIcon.append("followSubscribe")
                    showThirdMessage = "Following the member to see their Public Posts."
                }
                if condition == "follow"{
                    showMenu.removeLast()
                    showIcon.removeLast()
                    nameMenu.removeLast()
                    showMenu.append(NSLocalizedString("\(dic["label"] as! String)", comment: ""))
                    nameMenu.append("\(dic["name"] as! String)")
                    showIcon.append("followSubscribe")
                    showThirdMessage = "Follow the members to see their Public Posts."
                }
                }
                else{
                if !showMenu.contains("More"){
                    showMenu.append(NSLocalizedString("More", comment: ""))
                    showIcon.append("moreIcon")
                    nameMenu.append("more")
                }
                }


            }
            
        }
            }
        }
        
        
        
        for i in 0 ..< countLoops{
            
            var menu = UIButton()
            if isCoverEnabled {
                menu = createButton(CGRect(x: xGap,y: 0 , width: widthXgap, height: 60), title: "", border: false,bgColor: false, textColor: textColorMedium)
            }
            else{
                menu  = createButton(CGRect(x: xGap,y: 0 , width: widthXgap, height: 60), title: "", border: false,bgColor: false, textColor: textColorMedium)
            }
            menu.backgroundColor =  TabMenubgColor
            conditionName = nameMenu[i]
            
            
            if conditionName == "disble_message"{
                menu.isEnabled = false
                menu.alpha = 0.7
            }
            
            
            menu.isHidden = false
            menu.titleLabel?.numberOfLines = 0
            menu.tag = i
            menu.addTarget(self, action: #selector(ContentActivityFeedViewController.openMenus(_:)), for: .touchUpInside)
            menuView.addSubview(menu)
            
            
              let  icon = createButton(CGRect(x: widthXgap/2 - 12, y: 5, width: 25, height: 25), title: "", border: false, bgColor: false, textColor: iconColor)
            let image = UIImage(named: "\(showIcon[i])")
            let tintedImage = image?.withRenderingMode(.alwaysTemplate)
            icon.setBackgroundImage(tintedImage, for: UIControl.State.normal)
            icon.tag = i
            icon.addTarget(self, action: #selector(ContentActivityFeedViewController.openMenus(_:)), for: .touchUpInside)
              icon.isHidden = false
            icon.clipsToBounds = true
            icon.tintColor = iconColor
            menu.addSubview(icon)
            
            let  iconText = createLabel(CGRect(x: 0, y: icon.frame.origin.y + icon.bounds.height + 2, width: widthXgap, height: 20), text: "", alignment: .center, textColor: iconColor)
            iconText.text = showMenu[i]
            iconText.font = UIFont(name: fontName, size: 11.0)
            iconText.isHidden = false
            iconText.numberOfLines = 0
            iconText.sizeToFit()
            menu.addSubview(iconText)
            iconText.frame.size.width = menu.frame.size.width
             iconText.textAlignment = NSTextAlignment.center
            
            if  conditionName == "remove_friend" ||  conditionName == "member_unfollow" || conditionName == "cancel_request" ||   conditionName == "cancel_follow" || conditionName == "following" {
                iconText.textColor = navColor
                icon.tintColor = navColor
            }
            else{
                iconText.textColor = iconColor
                icon.tintColor = iconColor
            }
            
            xGap = xGap + menu.bounds.width + 5
            menu.frame.size.height = iconText.frame.origin.y + iconText.frame.size.height
         }
        
        
    }
    
    func browseasguest()
    {
        var xGap : CGFloat! = 0
        var totalWidth: CGFloat! = 0
        var widthXgap : CGFloat! = 0
        showMenu.removeAll(keepingCapacity: false)
        showIcon.removeAll(keepingCapacity: false)
        moreNameMenu.removeAll(keepingCapacity: false)
        
        if self.isCoverEnabled {
            totalWidth = view.bounds.width - (memberProfilePhoto.frame.origin.x + memberProfilePhoto.bounds.width)
            widthXgap = totalWidth/CGFloat(3)
        }
        else{
            totalWidth = view.bounds.width
            widthXgap = totalWidth/CGFloat(3)
            widthXgap = widthXgap - 5
        }
        
        showIcon.append("addFriend")
        showIcon.append("messageIcon")
        showIcon.append("moreIcon")
        
        showMenu.append("Add Friend")
        showMenu.append("Message")
        showMenu.append("More")
        
        
        for i in 0 ..< 3{
            
            var menu = UIButton()
            if isCoverEnabled {
                menu = createButton(CGRect(x: xGap,y: 0 , width: widthXgap, height: 60), title: "", border: false,bgColor: false, textColor: textColorMedium)
            }
            else{
                menu  = createButton(CGRect(x: xGap,y: 0 , width: widthXgap, height: 60), title: "", border: false,bgColor: false, textColor: textColorMedium)
            }
            menu.backgroundColor =  TabMenubgColor
            menu.alpha = 0.7
            menu.isEnabled = false
            menu.isHidden = false
            menu.titleLabel?.numberOfLines = 0
            menu.tag = i
            menu.addTarget(self, action: #selector(ContentActivityFeedViewController.openMenus(_:)), for: .touchUpInside)
            menuView.addSubview(menu)
            
            
            let  icon = createButton(CGRect(x: widthXgap/2 - 12, y: 5, width: 25, height: 25), title: "", border: false, bgColor: false, textColor: iconColor)
            let image = UIImage(named: "\(showIcon[i])")
            let tintedImage = image?.withRenderingMode(.alwaysTemplate)
            icon.setBackgroundImage(tintedImage, for: UIControl.State.normal)
            icon.tag = i
            icon.addTarget(self, action: #selector(ContentActivityFeedViewController.openMenus(_:)), for: .touchUpInside)
            icon.isHidden = false
            icon.clipsToBounds = true
            icon.tintColor = iconColor
            menu.addSubview(icon)
            
            let  iconText = createLabel(CGRect(x: 0, y: icon.frame.origin.y + icon.bounds.height + 2, width: widthXgap, height: 20), text: "", alignment: .center, textColor: iconColor)
            iconText.text = showMenu[i]
            iconText.font = UIFont(name: fontName, size: 11.0)
            iconText.isHidden = false
            iconText.numberOfLines = 0
            iconText.sizeToFit()
            menu.addSubview(iconText)
            iconText.frame.size.width = menu.frame.size.width
            iconText.textAlignment = NSTextAlignment.center
            
            iconText.textColor = iconColor
            icon.tintColor = iconColor
            
            xGap = xGap + menu.bounds.width + 5
            menu.frame.size.height = iconText.frame.origin.y + iconText.frame.size.height
        }

    }
    
    
    // click on tab of add friend, message and more menu, edit photo, edit info menus
    @objc func openMenus(_ sender : UIButton){
        if  !(showIcon.contains("followSubscribe")) && profileOfUserId != currentUserId{
       if sender.tag == 2 && profileOfUserId != currentUserId{
            showMainGutterMenu1()
        }
       else{
        let option : String = nameMenu[sender.tag]
        if option == "user_photo_edit" || option == "friends"{
            self.redirection(condition : option, dic : [:])
        }
        else  if option != "disble_message"{
            for menu in gutterMainMenu{
                if let dic = menu as? NSDictionary{
                    let condition = dic["name"] as! String
                    if condition == option{
                        self.redirection(condition : condition, dic : dic)
                    }
                }
            }
        }
            }
        }
        else{
            let option : String = nameMenu[sender.tag]
            if option == "user_photo_edit" || option == "friends"{
                self.redirection(condition : option, dic : [:])
            }
            else  if option != "disble_message"{
                for menu in gutterMainMenu{
                    if let dic = menu as? NSDictionary{
                        let condition = dic["name"] as! String
                        if condition == option{
                            self.redirection(condition : condition, dic : dic)
                        }
                    }
                }
            }
        }
    }
    
    // action after click
    @objc func showMainGutterMenu1(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in gutterMainMenu{
            if let dic = menu as? NSDictionary{
                
                if self.moreNameMenu.contains(dic["name"] as! String){
                    alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                        // Write For Edit Album Entry
                        let condition = dic["name"] as! String
                        self.redirection(condition : condition, dic : dic)

                    }))
                }
                
                if dic["name"] as! String == "user_home_edit"{
                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("Edit My photo",comment: ""), style: .default, handler:{(UIAlertAction) -> Void in
                        let presentedVC = EditProfilePhotoViewController()
                        presentedVC.currentImageUrl = self.userProfilePicUrl
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }))
                }
            }
        }
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    // redirection
    func redirection(condition : String, dic : NSDictionary){
        switch(condition){
        case "user_home_edit":
            let presentedVC = EditProfileViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
            
        case "accept_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "add_friend":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "user_profile_unblock":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to unblock this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
            
            
        case "cancel_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "user_profile_block":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to block this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "user_profile_report":
            let presentedVC = ReportContentViewController()
            
            presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
            
            presentedVC.url = dic["url"] as! String
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        case "user_profile_send_message":
            
            let presentedVC = MessageCreateController()
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            presentedVC.userID = self.subjectId
            presentedVC.fromProfile = true
            presentedVC.profileName =  self.userNameString
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        case "remove_profiel_photo":
            var message = ""
            let params: NSDictionary = ["user_id": self.subjectId]
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to remove your profile photo?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(params, url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "profile_photo":
            
            var message = ""
            let params: NSDictionary = ["user_id": self.subjectId]
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to remove your profile photo?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(params, url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "remove_friend" :
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to  remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
        case "follow":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to follow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
        case "following":
            
            var message = ""
            let title = "Unfollow"//dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to unfollow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
        case "member_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "member_unfollow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want  to remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "cancel_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
            }
            self.present(alert, animated: true, completion: nil)
        case "user_photo_edit":
            let presentedVC = EditProfilePhotoViewController()
            presentedVC.currentImageUrl = self.userProfilePicUrl
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
            
            
        case "friends":
                let presentedVC = MemberViewController()
                presentedVC.fromTab = true
                presentedVC.contentType = "user"
                presentedVC.contentId = subjectId
                navigationController?.pushViewController(presentedVC, animated: true)
            
            
        default:
            self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
            
            
        }
        
    }
    // Finish :- code of showing add friend, more menus and message
    
    func updateUser(_ param:NSDictionary, url: String){
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
             self.view.isUserInteractionEnabled = false
            var dic = Dictionary<String, String>()
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of: "delete") != nil || url.range(of: "remove-profile-photo") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                     self.view.isUserInteractionEnabled = true
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                            
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
    
    @objc func ScrollingactionContentActivityFeed(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        if updateScrollFlag{
            // Check for PAGINATION
            if feedObj.tableView.contentSize.height > feedObj.tableView.bounds.size.height{
                if feedObj.tableView.contentOffset.y >= (feedObj.tableView.contentSize.height - feedObj.tableView.bounds.size.height){
                    if reachability.connection != .none {
                        
                        if userFeedArray.count > 0{
                            
                            if maxid == 0 {
                                
                                if noPost == true
                                {
                                    feedObj.tableView.tableFooterView?.isHidden = true
                                    toastView = createView(CGRect(x: 0,y: (feedObj.tableView.bounds.size.height) - 20 , width: view.bounds.width, height: 20), borderColor: UIColor.clear, shadow: false)
                                    toastView.backgroundColor = UIColor.clear
                                    self.toastView.makeToast(NSLocalizedString("There are no more posts to show.",  comment: "") , duration: 5, position: "bottom")
                                    view.addSubview(toastView)
                                    self.toastView.hideToastActivity()
                                    
                                    noPost = false
                                }
                               
                                
                            }else{
                                // Request for Pagination
                                feedObj.tableView.tableFooterView?.isHidden = false
                                updateScrollFlag = false
                                feed_filter = 0
                               // showSpinner = false
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
        
        if (scrollOffset > 60.0){
            let barAlpha = max(0, min(1, (scrollOffset/125)))
            setNavigationImage(controller: self)
            self.marqueeHeader.text = self.userNameString
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.textColor = textColorPrime
            self.marqueeHeader.alpha = barAlpha
            self.contentName.alpha = 1-barAlpha
            self.profilePic.alpha = 1-barAlpha
        }else{
            self.marqueeHeader.text = ""
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            
            if (scrollOffset < 10.0){
                if self.contentName != nil {
                    self.contentName.alpha = 1
                }
                if self.profilePic != nil{
                    self.profilePic.alpha = 1
                }
                
            }
            
        }
        
        
    }
    
    // MARK:  TTTAttributedLabelDelegate
    
    // Make Custom Links from Activity Feed
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        
        let type = components["type"] as! String
        
        
        switch(type){
        case "sitereview_listing":
            
            let listingId = components["id"] as! Int
            
            if let listingtype_id = components["listingtype_id"] as? Int{
                let listingTypeId = listingtype_id
                if listingTypeId != 0{
                    
                    var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
                    let viewType = tempBrowseViewTypeDic["viewType"]!
                    
                    switch viewType{
                    case 2:
                        
                        let presentedVC = MLTClassifiedSimpleTypeViewController()
                        presentedVC.listingId = listingId
                        presentedVC.listingTypeId = listingTypeId
                        presentedVC.subjectType = "sitereview_listing"
                        navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case 3:
                        
                        let presentedVC = MLTClassifiedAdvancedTypeViewController()
                        presentedVC.listingId = listingId
                        presentedVC.listingTypeId = listingTypeId
                        presentedVC.subjectType = "sitereview_listing"
                        navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    default:
                        
                        let presentedVC = MLTBlogTypeViewController()
                        presentedVC.listingId = listingId
                        presentedVC.listingTypeId = listingTypeId
                        presentedVC.subjectType = "sitereview_listing"
                        navigationController?.pushViewController(presentedVC, animated: true)
                        break
                    }
                }
            }
            
            
            break
            
        case "sitereview_wishlist":
            
            let presentedVC = WishlistDetailViewController()
            
            if let _ = components["wishlistId"] as? Int{
                presentedVC.subjectId = components["wishlistId"] as! Int
                presentedVC.wishlistName = components["wishlistTitle"] as! String
                presentedVC.descriptionWishlist = components["wishlistBody"] as! String
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            
            break
            
            
            
        default:
            if components["objectUrl"] != nil{
                let presentedVC = ExternalWebViewController()
                presentedVC.url = components["objectUrl"]! as! String
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
            }
            
            
            
        }
        
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
         feedObj.tableView.tableFooterView?.isHidden = true
        tableViewFrameType = ""
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        setNavigationImage(controller: self)
       // var ab  = FlowManager.self
        coachMarksController.stop(immediately: true)
       // coachMarksController.didEndShowingBySkipping(false)
       // coachMarksController.stop()
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    @objc func goBack()
    {
       // coachMarksController.didEndShowingBySkipping(false)
        coachMarksController.stop(immediately: true)
        
        if((self.fromDashboard != nil) && (self.fromDashboard == true) )
        {
            let presentedVC = AdvanceActivityFeedViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        }else{
            membersUpdate1 = false
            _ = self.navigationController?.popViewController(animated: false)
            
            
        }
    }
    
    @objc func onImageViewTap(_ sender: UITapGestureRecognizer)
    {
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
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            for menu in imageMenus{
                if let dic = menu as? NSDictionary{
                    
                    
                    if dic["name"] as! String == "remove_photo" || dic["name"] as! String == "remove_cover_photo"{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            // Delete Activity Feed Entry
                            if dic["name"] as! String == "remove_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Profile Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this profile photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                    let urlParams = Dictionary<String, String>()
                                    
                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                            else if dic["name"] as! String == "remove_cover_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Cover Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this cover photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                    let urlParams = Dictionary<String, String>()
                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                        
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                            case "upload_cover_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userCoverPicUrl
                                presentedVC.url = "user/profilepage/upload-cover-photo/user_id/" + String(self.subjectId)
                                presentedVC.pageTitle = NSLocalizedString("Edit Cover Photo", comment: "")
                                presentedVC.showCameraButton = false
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "choose_from_album":
                                
                                let presentedVC = ChooseFromAlbumsViewController()
                                presentedVC.showOnlyMyContent = true
                                presentedVC.profileOrCoverChange = isProfileOrCover
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_cover_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                                
                            case "upload_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userProfilePicUrl
                                presentedVC.url = "user/profilepage/upload-cover-photo/user_id/" + String(self.subjectId) + "/special/profile"
                                presentedVC.pageTitle = NSLocalizedString("Edit Profile Photo", comment: "")
                                presentedVC.showCameraButton = true
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_profile_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = dic["url"] as! String
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
    
    // Show user profile
    func showProfile()
    {
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = currentUserId
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
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
            }else{
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
                        updateUserData()
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

extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
