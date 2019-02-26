
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

//  AdvanceActivityFeedViewController.swift
protocol scrollDelegate{
    func didScroll()
    
}

import CoreLocation
import GoogleMobileAds
import FBAudienceNetwork
import UIKit
import CoreData
import AVFoundation
import NVActivityIndicatorView
import Kingfisher
import Instructions


var comingFromPlaylist : Bool = false
// Advance video common tableview Y frmae
var tableframeY : CGFloat = 0.0
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
var feedUpdate:Bool!
var contentfeedArrUpdate:Bool = false // For assigning updated userfeedarray to table in case of comments and activityphotoviewcontroller
var feedArray = [AnyObject]()
var contentFeedArray = [AnyObject]()
var userFeedArray = [AnyObject]()
var postPermission = NSDictionary()                       // Timer for Update feed after particular time repeation
var checkMiniMenuTimer:Timer!
var coverPhotoImage : UIImage!
var addSeeMore:Bool  = false
//var globalImageCache = [String:UIImage]()
var afterPost :Bool = false
var ReactionPlugin : Bool  = false
var StickerPlugin : Bool = false
var emojiEnabled : Bool = false       // Check that whether Image Attachment for comments is enable or not
var reactionsDictionary : NSDictionary! = [:]
let scrollViewEmoji = UIScrollView()
let scrollviewEmojiLikeView = UIScrollView() // All Reaction View in case of Content Like
var videoattachmentType = NSDictionary()
var isshimmer = false
var fromExternalWebView = false
var isfeedfilter = 1
var userSuggestions = [Any]() // Containing Suggetions
var bannerArray = [AnyObject]()
var decorationDictionary = NSDictionary()
var greetingsArray = [AnyObject]()
var usersBirthday = [AnyObject]()
var feedCharLength : Int = 0
var feedFontStyle = ""
var feedFontSize : Int = 0
var feedTextColor  = ""
var bannerFeedLength : Int = 0

var removeGreetingsId = [Int]()
var removeBirthdayId = [Int]()
var isViewWillAppearCall = 0

class AdvanceActivityFeedViewController: UIViewController, UIPopoverPresentationControllerDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate,UISearchBarDelegate,UITabBarControllerDelegate,scrollDelegate,CLLocationManagerDelegate, UIWebViewDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate, StoryNotUploadedCell{
    var locationManager = CLLocationManager()
    /// Called when native content is received.
    
    let mainView = UIView()
    var audioPlayer = AVAudioPlayer()
    
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int! = 0                           // MinID for New Feeds
    var info : UILabel!
    var titleInfo: UILabel!
    var menuLike : UIButton!
    //    var activityFeedTableView:UITableView!      // activityFeedTable to display Activity Feeds
    var feedObj = FeedTableViewController()
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var rightAddBarButtonItem:UIBarButtonItem!
    var rightAddBarButtonItem2:UIBarButtonItem!
    var rightAddBarButtonItem3:UIBarButtonItem!
    var userImage : UIImageView!
    var UserId:Int!
    var notLabel:UILabel!
    var msgLabel:UILabel!
    var reqLabel:UILabel!
    // var imageCache = [String:UIImage]()
    //  var userImageCache = [String:UIImage]()
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var gutterMenu1: NSArray = []
    var noPost : Bool = true
    var action_id:Int!
    var postView = UIView()
    var storiesView : StoriesView? //stories
    var storiesViewHeight : CGFloat = 0.0
    var storyNotUploaded : StoryNotUploaded!
    var shareTitle:String!
    var actionIdArray = [Int]()
    var updateDashboard:Timer!
    var noCommentMenu:Bool = false
    var updateNewFeed = false
    var newFeedUpdateCounter = 0
    var footerView = UIView()
    var defaultFeedCount : Int = 0
    var hidingNavBarManager: HidingNavigationBarManager?
    let subscriptionNoticeLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
    var tourCount = 4
    private var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    fileprivate var popoverOptionsUp: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var popoverTableView:UITableView!
    var tableHeaderHight: CGFloat = 0
    var scrollableCategory = UIScrollView()
    var openAppRating = false
    var currentButton : UIButton?
    // Initialize Class
    var myTimer:Timer!
    var greetingsWebView = UIWebView()
    var crossView = UIButton()
    var birthdayView = UIView()
    var birthdayImage = UIImageView()
    var birthdayTitle = UILabel()
    var bdayMsgButton = UIButton()
    var bdayPostbutton = UIButton()
    var birthdayUserimage = UIImageView()
    var birthdayUserName = UILabel()
    var birthdaybuttonsFrame = UIView()
    var frndsbirthdayPost = UIButton()
    var frndsBirthdayMsg = UIButton()
    
    var dictCheckValue  = [Int:String]()
    var dictBirthdayValue = [Int:String]()
    var userBirthdayName = [Int:String]()
    var userBirthdayImage = [Int:String]()
    var crossBdayView = UIButton()
    var webframe = UIView()
    
    var day : Int = 0
    var month : Int = 0
    var year : Int = 0
    
    var greetingsId = [Int]()
    var firstGreetings = false
    var didFindLocation = false
    
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
  //  var blackScreen: UIView!
   // let skipView = CoachMarkSkipDefaultView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
     
        NotificationCenter.default.addObserver(self,selector:#selector(AdvanceActivityFeedViewController.applicationWillEnterForeground),name: .UIApplicationWillEnterForeground,object: nil)
        tableViewFrameType = "AdvanceActivityFeedViewController"
        if UserDefaults.standard.string(forKey: "isAppRated") != nil
        {
            openAppRating = false
        }
        else
        {
            openAppRating = true
        }
 
        globalTypeSearch = ""
        firstGreetings = true
        subject_unique_type = nil
        subject_unique_id = nil
        openSideMenu = false
        feedUpdate = false
        isshimmer = true
        
        let defaults = UserDefaults.standard
        
        if  defaults.bool(forKey: "AppInstalled") == false
        {
            self.view.isUserInteractionEnabled = false
            if let tabBarObject = self.tabBarController?.tabBar
            {
                tabBarObject.isUserInteractionEnabled = false
            }
            navigationController?.navigationBar.isUserInteractionEnabled = false
            defaults.set(true, forKey: "AppInstalled")
        }
        searchDic.removeAll(keepingCapacity: false)
        maxid = 0
        frndTagValue.removeAll()
        
        // self.coachMarksController.dataSource = self
        setNavigationcontroller()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.checkService), name: NSNotification.Name(rawValue: "checkService"), object: nil)
        
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        }
        
        // Create container view
        mainView.frame = view.frame
        mainView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)//aafBgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // For getting Location response
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.userLoggedIn(_:)), name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.showContent(userInfo:)), name: NSNotification.Name(rawValue: "appNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.showMassNotification(userInfo:)), name: NSNotification.Name(rawValue: "massNotification"), object: nil)
        
        // Set navigation right item on basis of location
        if #available(iOS 9.0, *) {
            getLocationdata()
        } else {
            // Fallback on earlier versions
        }
        
        // For customize header having searchbar in center
        getheaderSetting()
        
        contentIcon = createLabel(CGRect(x:0,y:0,width:0,height:0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x:0,y:0,width:0,height:0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        info = createLabel(CGRect(x:0,y:0,width:0,height:0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(info)
        info.isHidden = true
        
        // For hiding navigation bar while scrolling
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: feedObj.tableView)
        
        mainView.addSubview(feedObj.view)
        self.addChildViewController(feedObj)
        
//        let offset = CGPoint.init(x: 0, y: -(TOPPADING))
//        feedObj.tableView.setContentOffset(offset, animated: true)
        DispatchQueue.main.async {
            let offset = CGPoint.init(x: 0, y: -(TOPPADING))
            self.feedObj.tableView.setContentOffset(offset, animated: false)
            self.viewMethodCalled()
        }
        
    }
    
    func viewMethodCalled()
    {
        feedObj.feedShowingFrom = "ActivityFeed"
        feedObj.delegateScroll = self
        if logoutUser == false
        {
            //Stories View
            if show_story == 1
            {
                storiesViewHeight = 115.0
                storiesView =  StoriesView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: storiesViewHeight))
                storiesView?.objAAF = self
                storiesView?.delegateStoryNotUploaded = self
                storiesView?.layer.borderWidth = 0.0
                storiesView?.layer.borderColor = cellBackgroundColor.cgColor
                self.feedObj.tableView.addSubview(storiesView!)
            }
            else
            {
                storiesViewHeight = 0.0
            }
            storyNotUploaded = StoryNotUploaded(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            storyNotUploaded.isHidden = true
            storyNotUploaded.objAAF = self
            self.view.addSubview(storyNotUploaded)
            
            
            postView =  createView(CGRect(x: 0,y: storiesViewHeight + 5,width: view.bounds.width,height: 110), borderColor: cellBackgroundColor , shadow: true)
            postView.layer.borderWidth = 0.0
            postView.layer.borderColor = cellBackgroundColor.cgColor
            self.feedObj.tableView.addSubview(postView)
            
            userImage = createImageView(CGRect(x:PADING,y:9,width: 50,height: 50), border: true)
            userImage.image = UIImage(named: "user_profile_image.png")
            imageProfile = userImage.image
            self.storiesView?.collectionViewStories?.reloadData()
            userImage.tag = 108
            userImage.layer.cornerRadius = userImage.frame.size.width/2
            userImage.clipsToBounds = true
            postView.addSubview(userImage)
            
            
            let profile = createButton(CGRect(x: PADING,y: 9,width: 60,height: 60), title: "", border: false, bgColor: false, textColor: textColorLight)
            profile.addTarget(self, action: #selector(AdvanceActivityFeedViewController.showProfile), for: .touchUpInside)
            postView.addSubview(profile)
            profile.tag = 108
            
            postFeedOption()
            
            
            birthdayView = UIView(frame: CGRect(x: PADING , y: postView.frame.size.height + 5 + storiesViewHeight ,width : view.bounds.width , height : 215 ))
            birthdayView.isHidden = true
            birthdayView.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(birthdayView)
            
            birthdayImage = createImageView(CGRect(x: PADING , y:  5 ,width : view.bounds.width , height : 100 ), border: false)
            birthdayImage.layer.masksToBounds = true
            birthdayView.addSubview(birthdayImage)
            
            birthdayUserimage = createImageView(CGRect(x: view.bounds.width/2 - 35 , y:  birthdayImage.frame.size.height - 40 ,width : 70 , height : 70 ), border: false)
            birthdayUserimage.layer.cornerRadius = birthdayUserimage.frame.size.width / 2;
            birthdayUserimage.layer.masksToBounds = true
            birthdayView.addSubview(birthdayUserimage)
            
            birthdayUserName = createLabel(CGRect(x: PADING , y:  148 ,width : view.bounds.width - 2*PADING , height : 20 ), text: "", alignment: .center, textColor: textColorDark)
            birthdayUserName.font = UIFont(name: fontBold, size: 15.0)
            birthdayView.addSubview(birthdayUserName)
            
            birthdayTitle = createLabel(CGRect(x: PADING , y: 180 ,width : view.bounds.width - 2*PADING , height : 20 ), text: "", alignment: .center, textColor: textColorDark)
            
            birthdayTitle.font = UIFont(name: fontNormal, size: FONTSIZENormal)
            birthdayView.addSubview(birthdayTitle)
            
            crossBdayView = createButton(CGRect(x: view.bounds.width - 30 , y :  5 , width : 30 , height : 30), title: "X", border: false, bgColor: false, textColor: textColorDark)
            crossBdayView.isHidden = true
            birthdayView.addSubview(crossBdayView)
            
            birthdaybuttonsFrame = UIView(frame: CGRect(x: PADING , y: 215 + postView.frame.size.height + 5 + storiesViewHeight,width : view.bounds.width , height : 40 ))
            birthdaybuttonsFrame.isHidden = true
            birthdaybuttonsFrame.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(birthdaybuttonsFrame)
            
            frndsbirthdayPost = createButton(CGRect(x: 5 , y :  5 , width : view.bounds.width/2 - 10 , height : 30), title: "\(editFeedIcon)"+NSLocalizedString(" Write a post",comment: ""), border: true, bgColor: false, textColor: navColor)
            frndsbirthdayPost.layer.borderColor = navColor.cgColor
            frndsbirthdayPost.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            birthdaybuttonsFrame.addSubview(frndsbirthdayPost)
            
            frndsBirthdayMsg = createButton(CGRect(x: view.bounds.width/2  , y :  5 , width : view.bounds.width/2 - 15 , height : 30), title: "", border: true, bgColor: false, textColor: navColor)
            //    let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
            let iconFont = CTFontCreateWithName(("fontAwesome" as CFString?)!, FONTSIZENormal, nil)
            let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
            let iconPart = NSMutableAttributedString(string: "\(messagebda)", attributes: [NSAttributedStringKey.font:iconFont ,  NSAttributedStringKey.foregroundColor : navColor])
        
            let textPart = NSMutableAttributedString(string: NSLocalizedString(" Message",comment: ""), attributes: [NSAttributedStringKey.font:textFont , NSAttributedStringKey.foregroundColor : navColor])
             iconPart.append(textPart)
            
            frndsBirthdayMsg.setAttributedTitle(iconPart, for: .normal)
            birthdaybuttonsFrame.addSubview(frndsBirthdayMsg)
            
            webframe = UIView(frame: CGRect(x: PADING , y: postView.frame.size.height + 7 + storiesViewHeight ,width : view.bounds.width , height : 1 ))

            webframe.isHidden = true
            webframe.backgroundColor = textColorLight
            webframe.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(webframe)
            
            greetingsWebView = UIWebView(frame: CGRect(x: 0 , y : 0 , width : view.bounds.width , height : 1))
            greetingsWebView.clipsToBounds = true
            greetingsWebView.backgroundColor = textColorLight
            greetingsWebView.isHidden = true
            greetingsWebView.delegate = self
            greetingsWebView.scrollView.bounces = false
            greetingsWebView.scrollView.isScrollEnabled = false
            webframe.addSubview(greetingsWebView)
            crossView = createButton(CGRect(x: view.bounds.width - 30 , y :  0 , width : 30 , height : 70), title: "", border: false, bgColor: false, textColor: textColorDark)
            crossView.setTitle(solidCross, for: .normal)
            crossView.titleLabel?.font = UIFont(name: "fontAwesome", size: 17.0)
            crossView.contentVerticalAlignment = .center
            crossView.contentHorizontalAlignment = .center
            crossView.isHidden = true
            greetingsWebView.addSubview(crossView)
            
            tableHeaderHight = postView.frame.size.height + 5 + storiesViewHeight
            
            // Download userprofile
            if coverImage != nil {
                let coverImageUrl = NSURL(string: coverImage)
                if coverImageUrl != nil {
                    self.userImage.kf.indicatorType = .activity
                    (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    self.userImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        coverPhotoImage = image
                        imageProfile = image
                        self.storiesView?.collectionViewStories?.reloadData()
                    })
                    
                }
                
            }
            // Show Feed Option only to LoginUser
            
            
        }
        else
        {
            self.title = ""
        }
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        let attr = [NSAttributedStringKey.foregroundColor:textColorMedium]
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""),attributes: attr)
        refresher.addTarget(self, action: #selector(AdvanceActivityFeedViewController.refresh), for: UIControlEvents.valueChanged)
        feedObj.tableView.addSubview(refresher)
        
        
        // Stuff when there is no feed Start
        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-40, width: 60 ,height: 40), text: NSLocalizedString("\(classifiedIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.contentIcon.font = UIFont(name: "FontAwesome", size: 40)
        self.contentIcon.isHidden = true
        self.mainView.addSubview(self.contentIcon)
        
        self.info  = createLabel(CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8 ,height: 30), text: NSLocalizedString("No Activity Feeds",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.center = self.view.center
        self.info.frame.origin.y = self.view.bounds.height/2 + 5
        self.info.backgroundColor = UIColor.clear
        self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.info.tag = 1000
        self.info.isHidden = true
        self.mainView.addSubview(self.info)
        
        
        self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING ),width: 80,height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        self.refreshButton.backgroundColor = aafBgColor
        self.refreshButton.layer.borderColor = navColor.cgColor
        self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        self.refreshButton.addTarget(self, action: #selector(AdvanceActivityFeedViewController.browseFeed), for: UIControlEvents.touchUpInside)
        self.refreshButton.layer.cornerRadius = 5.0
        self.refreshButton.layer.masksToBounds = true
        self.refreshButton.isHidden = true
        self.mainView.addSubview(self.refreshButton)
        // Stuff when there is no feed End
        
        if logoutUser == false
        {
            if coverImage != nil
            {
                if coverPhotoImage != nil
                {
                    self.userImage.image = coverPhotoImage
                    imageProfile = coverPhotoImage
                    self.storiesView?.collectionViewStories?.reloadData()
                }
                else
                {
                    if let coverImageUrl = NSURL(string: coverImage)
                    {
                        self.userImage.kf.indicatorType = .activity
                        (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        self.userImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            coverPhotoImage = image
                            imageProfile = image
                            self.storiesView?.collectionViewStories?.reloadData()
                        })
                    }
                }
            }
            //getSuggestions()
            
        }
        // Get stored feed and show
        
        getchacheFeed()
        showSpinner = false
        browseFeed()
        

        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.getSuggestions), name: NSNotification.Name(rawValue: "Suggestion"), object: nil)
        
        CreateFooter()
        

        API_CheckVideoSize()
    }
    @objc func checkService()
    {
        if (CLLocationManager.locationServicesEnabled())
        {
            let defaults = UserDefaults.standard
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
            //    print("No access")
                if AppLauchForLocation == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
                    AppLauchForLocation = false
                    // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                    if defaults.bool(forKey: "showMsg")
                    {
                        currentLocation(controller: self)
                    }
                    defaults.set(true, forKey: "showMsg")
                }
            case .authorizedAlways, .authorizedWhenInUse:
               // print("Access")
                if updateLocation == false
                {
                    setLocation = true
                }
            }
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        else
        {
            if AppLauch == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 {
                setLocation = true
                AppLauch = false
                gpsLocation(controller: self)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let defaults = UserDefaults.standard
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
          //  print("No access")
            if defaults.bool(forKey: "appTour")
            {
                self.showAppTour()
            }
            defaults.set(true, forKey: "appTour")
        case .authorizedAlways, .authorizedWhenInUse:
         //   print("Access")
            defaults.set(true, forKey: "appTour")
            self.showAppTour()
        }
        
    }
    
    func getGreetings(){
        if reachability.connection != .none
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/feelings/greeting-manage", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["greetings"] != nil {
                                greetingsArray =  ((response["greetings"] as! NSArray) as [AnyObject])
                            }
                            if response["usersBirthday"] != nil {
                                usersBirthday = ((response["usersBirthday"] as! NSArray) as [AnyObject])
                            }
                            
                            
                            let date = Date()
                            let calendar = Calendar.current
                            let currentday = calendar.component(.day, from: date)
                            if UserDefaults.standard.value(forKey: "Gday") != nil {
                                if currentday == UserDefaults.standard.value(forKey: "Gday") as! Int
                                {
                                    //print(currentday)
                                    let defaults = UserDefaults.standard
                                    let array = defaults.array(forKey: "SavedGreetingsArray")  as? [Int] ?? [Int]()
                                    removeGreetingsId = array
                                    if removeGreetingsId.count != greetingsArray.count {
                                        if array.count > 0 {
                                            for i  in 0 ..< greetingsArray.count {
                                                // if greetingsArray[i] != nil {
                                                
                                                if let dic = greetingsArray[i] as? NSDictionary{
                                                    let id  = dic["greeting_id"] as! Int
                                                    if array.contains(id){
                                                        // greetingsArray.remove(at: i )
                                                        //print("count")
                                                        //print(greetingsArray.count)
                                                        
                                                    }
                                                }
                                                //}
                                            }
                                        }
                                    }
                                    
                                }
                                else{
                                    
                                    removeGreetingsId.removeAll()
                                    
                                    UserDefaults.standard.removeObject(forKey: "SavedGreetingsArray")
                                }
                            }
                            
                            if UserDefaults.standard.value(forKey: "Bday") != nil {
                                if currentday == UserDefaults.standard.value(forKey: "Bday") as! Int
                                {
                                    
                                    let defaults = UserDefaults.standard
                                    var array = defaults.array(forKey: "SavedbirthdayArray")  as? [Int] ?? [Int]()
                                    removeBirthdayId = array
                                    if removeBirthdayId.count != usersBirthday.count {
                                        
                                        if array.count > 0 {
                                            let count1 = usersBirthday.count
                                            for i  in 0 ..< count1 {
                                                
                                                
                                                
                                                if let dic = usersBirthday[i] as? NSDictionary{
                                                    let id  = dic["user_id"] as! Int
                                                    if array.contains(id){
                                                        // usersBirthday.remove(at: i )
                                                        //print("count")
                                                        array.remove(object: id)
                                                        //print(usersBirthday.count)
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else{
                                    
                                    removeBirthdayId.removeAll()
                                    UserDefaults.standard.removeObject(forKey: "SavedbirthdayArray")
                                    
                                }
                            }
                            
                            
                            
                            //  Birthday
                            
                            
                            
                            
                            if usersBirthday.count > 0 {
                                
                                
                                var counter = 0
                                for dict in usersBirthday
                                {
                                    
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:dict), forKey: "Birthdays\(counter)")
                                    counter = counter + 1
                                }
                            }
                            
                            if greetingsArray.count > 0 {
                                var counter1 = 0
                                
                                
                                for dict in greetingsArray
                                {
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:dict), forKey: "Greetings\(counter1)")
                                    counter1 = counter1 + 1
                                }
                            }
                            self.getUIOfGreetings()
                        }
                    }
                    
                })
                
            }
        }
    }
    
    //    func webViewDidFinishLoad(_ webView: UIWebView) {
    //        scrollableCategory.frame.origin.y = postView.frame.size.height + webView.bounds.height + 5
    //        tableHeaderHight = postView.frame.size.height + webView.bounds.height + 10
    //        globalFeedHeight = tableHeaderHight
    //        feedObj.tableView.reloadData()
    //
    //    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.url!.absoluteString
        // Restrict WebView to Open URLs
        
        if urlString == "about:blank"{
            return true
        }else{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = urlString
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
            return false
        }
        
    }

    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        let height = webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight")
        //let webViewTextSize = self.greetingsWebView.sizeThatFits(CGSize(width: 1.0,height: 1.0))
        //var webFrame = self.greetingsWebView.frame
        //webFrame.size.height = webViewTextSize.height
        self.greetingsWebView.frame.size.height = CGFloat((height! as NSString).floatValue)
        self.webframe.frame.size.height = self.greetingsWebView.frame.size.height
        updateAfterWebView()
        print("Finish Loading!")
    }
    
    func updateAfterWebView()
    {
        self.webframe.frame.size.height = self.greetingsWebView.frame.size.height
        self.webframe.isHidden = false
        self.greetingsWebView.isHidden = false
        //self.scrollableCategory.frame.origin.y = self.webframe.frame.size.height + 5
        tableHeaderHight = storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
        //tableHeaderHight = self.webframe.frame.size.height + 5
        globalFeedHeight = tableHeaderHight
        feedObj.tableView.reloadData()
        showfeedFilter()
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        
        if locationOnhome != 1 || isChangeManually != 1
        {
            tourCount = 3
        }
        return tourCount
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
            //  self.postView.layer.cornerRadius = self.postView.frame.width / 2
            //   skipView.isHidden = false
            var   coachMark1 : CoachMark
            coachMark1 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.bounds.width - 15,y: self.view.bounds.height - 20), radius: CGFloat(80), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            //  coachMark1.disableOverlayTap = true
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            // We'll also enable the ability to touch what's inside
            // the cutoutPath.
            //  coachMark1.allowTouchInsideCutoutPath = true
            return coachMark1
        case 1:
            
            var  coachMark2 : CoachMark
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: 140,y: 110 + self.storiesViewHeight + 5), radius: CGFloat(70), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            // coachMark2.disableOverlayTap = true
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            
            // coachMark2.allowTouchInsideCutoutPath = true
            return coachMark2
            
        case 2:
            
            var  coachMark2 : CoachMark
            var origin_x : CGFloat = 80.0
            var radious : Int = 50
            if isshow_app_name == 1{
                //   skipView.isHidden = true
                origin_x = self.view.bounds.width - 15.0
                radious = 30
            }
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
        case 3:
            // skipView.isHidden = true
            var  coachMark3 : CoachMark
            var origin_x : CGFloat = self.view.bounds.width - 15.0
            var radious : Int = 50
            if isshow_app_name == 1{
                origin_x = self.view.bounds.width - 75.0
                radious = 40
            }
            coachMark3 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            // coachMark3.disableOverlayTap = true
            coachMark3.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            // coachMark2.allowTouchInsideCutoutPath = true
            
            // coachMark2.disableOverlayTap = true
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
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 0:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        case 2:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
         coachViews.bodyView.hintLabel.text = "App Dashboard to Navigate across the app."
         coachViews.bodyView.nextLabel.text = "Next "
        coachViews.bodyView.countTourLabel.text = " 1/\(self.tourCount)"
        case 1:
            coachViews.bodyView.hintLabel.text = "Wondering how to share updates with your friends ? Tap here to add new posts, Photos, Videos and a lot more."
            coachViews.bodyView.nextLabel.text = "Next "
             coachViews.bodyView.countTourLabel.text = " 2/\(self.tourCount)"
        case 2:
            coachViews.bodyView.hintLabel.text = "Want to Search anything in particular? Search from here."
            if self.tourCount == 3
            {
                coachViews.bodyView.nextLabel.text = "Finish "
            }
            else
            {
                coachViews.bodyView.nextLabel.text = "Next "
            }
             coachViews.bodyView.countTourLabel.text = " 3/\(self.tourCount)"
        case 3:
            coachViews.bodyView.hintLabel.text = "Set App's Location for Location Based Result across the app."
            coachViews.bodyView.nextLabel.text = "Finish "
            coachViews.bodyView.countTourLabel.text = " 4/4"
            
            
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
        
        if logoutUser == false {
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "showHomePageAppTour")
            {
                if  UserDefaults.standard.object(forKey: "showHomePageAppTour") != nil {
                    
                    targetCheckValue = name as! Int
                    
                    
                }
                
            }
            
            if targetCheckValue == 1 {
                
                UserDefaults.standard.set(2, forKey: "showHomePageAppTour")
                coachMarksController.dataSource = self
                coachMarksController.delegate = self
                coachMarksController.overlay.allowTap = true
                coachMarksController.overlay.fadeAnimationDuration = 0.5
                coachMarksController.start(on: self)
            }
        }
        
    }
    
    func getUIOfGreetings (){
        if usersBirthday.count > 0 && (removeBirthdayId.count != usersBirthday.count){
            
            if usersBirthday.count > 0 {
                var counter = 0
                var userName = [String]()
                var userImage = [String]()
                //var birthdayTitle = [String]()
                for _ in usersBirthday {
                    
                    if let data = UserDefaults.standard.object(forKey: "Birthdays\(counter)") as? NSData{
                        if data.length != 0
                        {
                            counter = counter + 1
                            
                            let save = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                            
                            userName.append(save["displayname"] as! String)
                            userImage.append(save["image"] as! String)
                            userBirthdayName.updateValue(save["displayname"] as! String, forKey: save["user_id"]  as! Int)
                            userBirthdayImage.updateValue(save["image"] as! String, forKey: save["user_id"]  as! Int)
                            // birthdayTitle.append(save["birthday_title"] as! String)
                            dictBirthdayValue.updateValue(save["birthday_title"] as! String, forKey: save["user_id"]  as! Int)
                            
                        }
                        
                    }
                }
                
                var showFirstBirthday = true
                var loopCheckCount = 0
                for (key ,value) in dictBirthdayValue {
                    if showFirstBirthday == true {
                        if !(removeBirthdayId.contains(key)){
                            
                            birthdayView.isHidden = false
                            let fileUrl = NSURL(string: userBirthdayImage[key] as String? ?? "")
                            
                            
                            birthdayUserimage.kf.indicatorType = .activity
                            (birthdayUserimage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            birthdayUserimage.kf.setImage(with: fileUrl! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                            birthdayImage.image = UIImage(named: "BirthdayImage.png")
                            birthdayTitle.text = value
                            birthdayTitle.numberOfLines = 2
                            birthdayTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                            birthdayTitle.sizeToFit()
                            birthdayTitle.frame.size.width = view.bounds.width - 2*PADING
                            birthdayUserName.text = userBirthdayName[key] ?? ""//userName[loopCheckCount] as! String
                            //   crossBdayView.isHidden = false
                            crossBdayView.tag = key
                            frndsbirthdayPost.tag = key
                            frndsBirthdayMsg.tag = key
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.imageTapped(gesture:)))
                            birthdayUserimage.addGestureRecognizer(tapGesture)
                            birthdayUserimage.tag = key
                            birthdayUserimage.isUserInteractionEnabled = true
                            frndsbirthdayPost.addTarget(self, action: #selector(AdvanceActivityFeedViewController.postBirthday(sender:)), for: .touchUpInside)
                            frndsBirthdayMsg.addTarget(self, action: #selector(AdvanceActivityFeedViewController.postMsg(sender:)), for: .touchUpInside)
                            crossBdayView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.RemoveBId(sender:)), for: .touchUpInside)
                            showFirstBirthday = false
                            if key != currentUserId {
                                birthdaybuttonsFrame.isHidden = false
                            }
                            else{
                                birthdaybuttonsFrame.isHidden = true
                            }
                            loopCheckCount = loopCheckCount + 1
                            
                        }
                        else{
                            loopCheckCount = loopCheckCount + 1
                        }
                    }
                }
                if isVisible(view: birthdaybuttonsFrame){
                    scrollableCategory.frame.origin.y = postView.frame.size.height + 225 + birthdaybuttonsFrame.frame.size.height + storiesViewHeight
                    tableHeaderHight = postView.frame.size.height + 225 + birthdaybuttonsFrame.frame.size.height + storiesViewHeight
                    globalFeedHeight = tableHeaderHight
                    feedObj.tableView.reloadData()
                }
                else{
                    scrollableCategory.frame.origin.y = postView.frame.size.height + 225 + storiesViewHeight
                    tableHeaderHight = postView.frame.size.height + 225 + storiesViewHeight
                    globalFeedHeight = tableHeaderHight
                    feedObj.tableView.reloadData()
                }
                
                
                
                
            }
            
            if self.feedObj.tableView.viewWithTag(2017) == nil{
                if isfeedfilter == 1
                {
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.showfeedFilter()
                    //  })
                    
                }
            }
        }
        else
        {
            
            if greetingsArray.count > 0  && (removeGreetingsId.count != greetingsArray.count){
                
                scrollableCategory.frame.origin.y = postView.frame.size.height + greetingsWebView.bounds.height + 5 + storiesViewHeight
                tableHeaderHight = postView.frame.size.height + greetingsWebView.bounds.height + 10 + storiesViewHeight
                globalFeedHeight = tableHeaderHight
                feedObj.tableView.reloadData()
                var counter1 = 0
                greetingsId.removeAll()
                //var greetingsId = [Int]()
                //var body = ""
                for _ in greetingsArray {
                    
                    if let data = UserDefaults.standard.object(forKey: "Greetings\(counter1)") as? NSData{
                        if data.length != 0
                        {
                            counter1 = counter1 + 1
                            
                            let save = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                            
                            greetingsId.append(save["greeting_id"]  as! Int)
                            //body = (save["body"] as! String)
                            dictCheckValue.updateValue(save["body"] as! String, forKey: save["greeting_id"]  as! Int)
                            
                            
                        }
                        
                    }
                }
                
                var showFirstImage = true
                for (key ,value) in dictCheckValue {
                    if showFirstImage == true {
                        if !(removeGreetingsId.contains(key)){
                            let aString = "\(value)"
                            let newString = aString.replacingOccurrences(of: "[USER_NAME]", with: "\(displayName!)", options: .literal, range: nil)
                            greetingsWebView.tag = key
                            //webframe.isHidden = false
                            //greetingsWebView.isHidden = false
                            
                            //    crossView.isHidden = false
                            showFirstImage = false
                            crossView.tag = key
                            crossView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.RemoveId(sender:)), for: .touchUpInside)
                            greetingsWebView.loadHTMLString(newString, baseURL: nil)
                            //greetingsWebView.sizeToFit()
                        }
                    }
                }
            }
            
            if self.feedObj.tableView.viewWithTag(2017) == nil{
                if isfeedfilter == 1
                {
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.showfeedFilter()
                    // })
                    
                }
            }
        }
    }
    
    @objc func imageTapped(gesture : UITapGestureRecognizer){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = gesture.view?.tag
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func postBirthday(sender: UIButton){
        removeBirthdayId.append(sender.tag)
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            
            scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 65 + storiesViewHeight
            }
            else{
                tableHeaderHight = postView.frame.size.height + 5 + storiesViewHeight
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
        }
        
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        
        
        getUIOfGreetings ()
        
        subject_unique_id = sender.tag
        subject_unique_type = "user"
        let presentedVC = AdvancePostFeedViewController()
        // greetingsCheck = true
        presentedVC.checkfrom = "Greetings"
        presentedVC.openfeedStyle = 0
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
    }
    
    @objc func postMsg(sender: UIButton){
        removeBirthdayId.append(sender.tag)
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            
            scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 65 + storiesViewHeight
            }
            else{
                tableHeaderHight = postView.frame.size.height + 5 + storiesViewHeight
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            
        }
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        
        
        getUIOfGreetings ()
        
        let presentedVC = MessageCreateController()
        
        //greetingsCheck = true
        presentedVC.checkfrom = "Greetings"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        presentedVC.userID = sender.tag
        presentedVC.fromProfile = true
        
        if userBirthdayName[sender.tag] != nil && userBirthdayName[sender.tag] != ""   {
            presentedVC.profileName =  userBirthdayName[sender.tag]
        }
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    
    @objc func RemoveBId(sender: UIButton){
        crossBdayView.isHidden = true
        crossView.isHidden = true
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        removeBirthdayId.append(sender.tag)
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            
            
            scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 8 + storiesView!.frame.size.height
            }
            else{
                tableHeaderHight = postView.frame.size.height + 8 + storiesView!.frame.size.height

            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            
            
        }
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        getUIOfGreetings ()
        
    }
    
    @objc func RemoveId(sender: UIButton){
        crossView.isHidden = true
        removeGreetingsId.append(sender.tag)
        let defaults = UserDefaults.standard
        defaults.set(removeGreetingsId, forKey: "SavedGreetingsArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Gday")
        if removeGreetingsId.count == dictCheckValue.count {
            crossView.removeFromSuperview()
            greetingsWebView.removeFromSuperview()
            webframe.removeFromSuperview()
            scrollableCategory.frame.origin.y = postView.frame.size.height + 8 + storiesView!.frame.size.height
            tableHeaderHight = postView.frame.size.height + 65 + storiesView!.frame.size.height

            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            //                showfeedFilter()
            
            
        }
        else{
            
            self.webframe.frame.size.height = 1
            self.greetingsWebView.frame.size.height = 1
            if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
                // myButton already existed
                newFeedsButton.removeFromSuperview()
                
            }
        }
        
        
        getUIOfGreetings ()
        
        
        
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        if setLocation == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                  //  print("No access")
                    if AppLauchForLocation == true {
                        AppLauchForLocation = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        setLocation = true
                        defaults.set(true, forKey: "showMsg")
                    }
                case .authorizedAlways, .authorizedWhenInUse:
                 //   print("Access")
                    if updateLocation == false
                    {
                        setLocation = true
                    }
                }
                
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
            else
            {
                if AppLauch == true {
                    setLocation = true
                    AppLauch = false
                    gpsLocation(controller: self)
                }
            }
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation :CLLocation = locations[0] as CLLocation
        if didFindLocation == false && setLocation == true
        {
            updateLocation = true
            setLocation = false
            self.didFindLocation = true
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil){
                    print("error in reverseGeocode")
                }
                
                if placemarks != nil {
                    let placemark = placemarks! as [CLPlacemark]
                    
                    if placemark.count>0{
                        let placemark = placemarks![0]
                       // print("\(placemarks!)")
                        var subLocality : String = ""
                        var locality : String = ""
                        var administrativeArea : String = ""
                        var country : String = ""
                        var postalCode : String = ""
                        
                        var state : String = ""
                        var city : String = ""
                        var countryCode : String = ""
                        
                        if placemark.addressDictionary != nil
                        {
                            if let State = placemark.addressDictionary!["State"] as? String
                            {
                                state = State
                            }
                            
                            if let City = placemark.addressDictionary!["State"] as? String
                            {
                                city = City
                            }
                            
                            if let cd = placemark.addressDictionary!["State"] as? String
                            {
                                countryCode = cd
                            }
                        }
                        
                        if placemark.postalCode != nil
                        {
                            postalCode = placemark.postalCode!
                        }
                        
                        
                        let defaults = UserDefaults.standard
                        
                       // print(postalCode)
                        var prePostalCode = defaults.string(forKey:"postalCode")
                        if prePostalCode == nil
                        {
                            prePostalCode = "0"
                        }
                      //  print(prePostalCode!)
                        //                        postalCode != prePostalCode! && locationOnhome == 1
                        if locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1
                        {
                            
                            if placemark.subLocality != nil
                            {
                                subLocality = placemark.subLocality!
                                defaultlocation = "\(subLocality),"
                            }
                            if placemark.locality != nil
                            {
                                locality = placemark.locality!
                                defaultlocation.append(" \(locality),")
                            }
                            if placemark.administrativeArea != nil
                            {
                                administrativeArea = placemark.administrativeArea!
                                defaultlocation.append(" \(administrativeArea),")
                            }
                            if placemark.country != nil
                            {
                                country = placemark.country!
                                defaultlocation.append(" \(country)")
                            }
                            
                            //                            defaultlocation = "\(subLocality),\(locality), \(administrativeArea), \(country)"
                            
                            defaults.set(postalCode, forKey: "postalCode")
                            
                            defaults.set(defaultlocation, forKey: "Location")
                            self.view.makeToast("Your current location is set \(defaultlocation).", duration: 5, position: "bottom")
                            
                            let location = locations.last! as CLLocation
                            let currentLatitude = location.coordinate.latitude
                            let currentLongitude = location.coordinate.longitude
                            
                            defaults.set(currentLatitude, forKey: "Latitude")
                            defaults.set(currentLongitude, forKey: "Longitude")
                            
                           // print(currentLatitude)
                           // print(currentLongitude)
                            
                            setDeviceLocation(location: defaultlocation, latitude: currentLatitude, longitude: currentLongitude, country: country, state: state, zipcode: postalCode, city: city, countryCode: countryCode)
                        }
                    }
                }
            }
        }
    }
    

    func showfeedFilter()
    {
        
        let buttonPadding:CGFloat = 0
        var xOffset:CGFloat = 0
        //  if logoutUser == false {
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        //  }
        
        if isfeedfilter == 1
        {
            if logoutUser == true
            {
                tableHeaderHight = 5
            }
            
            crossBdayView.isHidden = false
            crossView.isHidden = false
            birthdaybuttonsFrame.isUserInteractionEnabled = true
            scrollableCategory = UIScrollView(frame: CGRect(x: 0, y: tableHeaderHight , width: view.bounds.width, height: 60))
            view.addSubview(scrollableCategory)
            scrollableCategory.tag = 2017
            scrollableCategory.translatesAutoresizingMaskIntoConstraints = false
            scrollableCategory.showsHorizontalScrollIndicator = false
            var i = 0
            let width = (scrollableCategory.frame.size.width)/5
            let height: CGFloat = 60
            
            var viewFilter = UIView()
            for menu in gutterMenu1{
                if let dic = menu as? NSDictionary{
                    
                    if let dicparam = dic["urlParams"] as? NSDictionary
                    {
                        if let filtertype = dicparam["filter_type"] as? String
                        {
                            if i < 4
                            {
                                
                                
                                viewFilter = createView(CGRect(x: xOffset, y: CGFloat(buttonPadding), width: width, height: height), borderColor: UIColor.clear, shadow: false)
                                viewFilter.tag = i
                                scrollableCategory.addSubview(viewFilter)
                                
                                let button   = UIButton()
                                button.tag = i
                                button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.feedFilterAction(sender:)), for: .touchUpInside)
                                button.frame = CGRect(x: width/2 - 17, y: 5, width: 35, height: 35)
                                button.titleLabel?.font = UIFont(name: "FontAwesome", size: 14.0)
                                button.alpha = 0.3
                                button.layer.cornerRadius =  button.bounds.size.width/2
                                button.clipsToBounds = true
                                
                                switch filtertype {
                                case "all":
                                    button.setTitle("\u{f0ac}", for: .normal)
                                    button.backgroundColor = color7
                                    button.titleLabel?.font = UIFont(name: "FontAwesome", size: 18.0)
                                    button.alpha = 0.8
                                    break
                                    
                                case "membership":
                                    button.setTitle("\u{f2c0}", for: .normal)
                                    button.backgroundColor = colorFriends
                                    break
                                    
                                case "photo":
                                    
                                    button.setTitle("\u{f03e}", for: .normal)
                                    button.backgroundColor = colorPhoto
                                    break
                                    
                                case "video":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = colorVideo
                                    break
                                    
                                case "sitepage":
                                    button.setTitle("\u{f15c}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "posts":
                                    button.setTitle("\u{f03e}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitenews":
                                    button.setTitle("\u{f09e}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "siteevent":
                                    button.setTitle("\u{f073}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "group":
                                    button.setTitle("\u{f0c0}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "hidden_post":
                                    button.setTitle("\u{f070}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "schedule_post":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "memories":
                                    button.setTitle("\u{f274}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "like":
                                    button.setTitle("\u{f164}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "advertise":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "classified":
                                    button.setTitle("\u{f03a}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "poll":
                                    button.setTitle("\u{f080}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitestore":
                                    button.setTitle("\u{f290}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitestoreproduct":
                                    button.setTitle("\u{f291}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "user_saved":
                                    button.setTitle("\u{f0c7}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                    
                                case "sitereview_listtype_11":
                                    button.setTitle("\u{f040}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_14":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "music":
                                    button.setTitle("\u{f001}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_19":
                                    button.setTitle("\u{f072}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                    
                                case "sitereview_listtype_18":
                                    button.setTitle("\u{f15c}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_20":
                                    button.setTitle("\u{f0f2}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "network_list":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitetagcheckin":
                                    button.setTitle("\u{f041}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                default:
                                    button.setTitle("\u{f17d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                }
                                
                                viewFilter.addSubview(button)
                                let titlelbl = UILabel()
                                titlelbl.tag = i
                                titlelbl.text = (dic["tab_title"] as! String)
                                titlelbl.font = UIFont(name: fontName, size: FONTSIZEMedium - 2)
                                titlelbl.frame = CGRect(x: 0, y: button.frame.size.height + button.frame.origin.y - 0, width: width, height: 20)
                                titlelbl.textColor = textColorMedium
                                titlelbl.textAlignment = .center
                                titlelbl.backgroundColor = textColorLight
                                viewFilter.addSubview(titlelbl)
                                xOffset = xOffset + width
                                i = i+1
                            }
                        }
                    }
                    
                }
            }
            
            viewFilter = createView(CGRect(x: xOffset, y: CGFloat(buttonPadding), width: width, height: height), borderColor: UIColor.clear, shadow: false)
            viewFilter.tag = i
            scrollableCategory.addSubview(viewFilter)
            let button   = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.showFeedFilterOptions(sender:)), for: .touchUpInside)
            button.frame = CGRect(x: width/2 - 17, y: 5, width: 35, height: 35)
            button.titleLabel?.font = UIFont(name: "FontAwesome", size: 18.0)
            button.setTitle(optionIcon, for: .normal)
            button.alpha = 0.3
            button.layer.cornerRadius =  button.bounds.size.width/2
            button.clipsToBounds = true
            //  button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
            button.backgroundColor = colorFriends
            viewFilter.addSubview(button)
            
            let titlelbl = UILabel()
            titlelbl.tag = i
            titlelbl.text = NSLocalizedString("More",comment: "")
            titlelbl.font = UIFont(name: fontName, size: FONTSIZEMedium - 2)
            titlelbl.frame = CGRect(x: 0, y: button.frame.size.height + button.frame.origin.y - 0, width: width, height: 20)
            titlelbl.textColor = textColorMedium
            titlelbl.textAlignment = .center
            titlelbl.backgroundColor = textColorLight
            viewFilter.addSubview(titlelbl)
            xOffset = xOffset + width
            i = i+1
            scrollableCategory.contentSize = CGSize(width: xOffset, height: scrollableCategory.frame.height)
            feedObj.tableView.addSubview(scrollableCategory)
            tableHeaderHight = tableHeaderHight + scrollableCategory.frame.size.height
            // if logoutUser == false {
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            // }
        }
        
    }
    // MARK: - Activity Feed Filter Options & Gutter Menu
    
    // Show Feed Filter Options Action for more options
    @objc func showFeedFilterOptions(sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let currentButton = sender as UIButton
        currentButton.isHighlighted = true
        if currentButton.isHighlighted == true
        {
            currentButton.alpha = 0.8
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        var i = 0
        for menu in gutterMenu1{
            if let dic = menu as? NSDictionary
            {
                self.feedFilterFlag = true
                if i >= 4
                {
                    alertController.addAction(UIAlertAction(title: (dic["tab_title"] as? String ?? ""), style: .default, handler:{ (UIAlertAction) -> Void in
                        let views = self.scrollableCategory.subviews
                        for obj in views
                        {
                            if (obj .isKind(of: UIView.self))
                            {
                                let buttons = obj.subviews
                                for obj in buttons
                                {
                                    if (obj .isKind(of: UIButton.self))
                                    {
                                        if obj != currentButton
                                        {
                                            (obj as! UIButton).isHighlighted = false
                                            (obj as! UIButton).alpha = 0.3
                                        }
                                    }
                                }
                            }
                            
                        }
                        print(dic["urlParams"])
                        // Set Parameters for Feed Filter
                        if let params = dic["urlParams"] as? NSDictionary{
                            for (key, value) in params{
                                if let id = value as? NSNumber {
                                    searchDic["\(key)"] = String(id as? Int ?? 0)
                                }
                                
                                if let receiver = value as? NSString {
                                    searchDic["\(key)"] = receiver as String
                                }
                            }
                        }
                        print(searchDic)
                        // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                        feedArray.removeAll(keepingCapacity: false)
                        self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        self.maxid = 0
                        self.feed_filter = 1
                        self.showSpinner = true
                        self.browseFeed()
                        
                        
                    }))
                }
                i = i+1
            }
            
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:{ (action: UIAlertAction!) in
                
                currentButton.isHighlighted = false
                if currentButton.isHighlighted == false
                {
                    currentButton.alpha = 0.4
                }
                
            }))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.scrollableCategory.frame.origin.y+self.scrollableCategory.frame.size.height + TOPPADING),y: view.bounds.width/2, width: 0,height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    func checkAndAskForReview ()
    {
        guard let appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        
        switch(appOpenCount)
        {
        case _ where appOpenCount % 30 == 0 :
            requestReview()
        default :
            //print("App Run Count is : \(appOpenCount)")
            break
        }
    }
    
    func requestReview ()
    {
        var appId: Int {
            get {
                return UserDefaults.standard.integer(forKey: "appItunesId")
            }
        }
        
        if appId != 0
        {
            let alert = UIAlertController(title: "Rate App", message: "Are you enjoying the app? Please rate our app", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "Rate Now", style: .default, handler: {
                (UIAlertAction) -> Void in
                
                UserDefaults.standard.setValue("Yes", forKey: "isAppRated")
                let mainId = String(appId)
                let appURLString: String
                appURLString = "itms-apps://itunes.apple.com/app/id\(mainId)?mt=8&action=write-review"
                UIApplication.shared.openURL(URL(string: appURLString)!)
            })
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
        //AdvanceActivityFeedViewController().rateApp()
        //ConfigurationFormViewController().rateApp()
    }
    
    
    func rateApp ()
    {
        let alert = UIAlertController(title: "Rate App", message: "Are you enjoying the app? Please rate our app", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Rate Now", style: .default, handler: {
            (UIAlertAction) -> Void in
            let appURLString: String
            appURLString = "https://itunes.apple.com/us/app/fellopages/id1250487313?mt=8"
            UIApplication.shared.openURL(URL(string: appURLString)!)
        })
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func feedFilterAction(sender : UIButton)
    {
        let currentButton = sender as UIButton
        currentButton.isHighlighted = true
        if currentButton.isHighlighted == true
        {
            currentButton.alpha = 0.8
        }
        let views = scrollableCategory.subviews
        for obj in views
        {
            if (obj .isKind(of: UIView.self))
            {
                let buttons = obj.subviews
                for obj in buttons
                {
                    if (obj .isKind(of: UIButton.self))
                    {
                        if obj != currentButton
                        {
                            (obj as! UIButton).isHighlighted = false
                            (obj as! UIButton).alpha = 0.3
                        }
                    }
                }
            }
            
        }
        searchDic.removeAll(keepingCapacity: false)
        if let dic = gutterMenu1[sender.tag] as? NSDictionary
        {
            self.feedFilterFlag = true
            // Set Parameters for Feed Filter
            if let params = dic["urlParams"] as? NSDictionary{
                for (key, value) in params{
                    if let id = value as? NSNumber {
                        searchDic["\(key)"] = String(id as? Int ?? 0)
                    }
                    
                    if let receiver = value as? NSString {
                        searchDic["\(key)"] = receiver as String
                    }
                }
            }
            
            // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
            feedArray.removeAll(keepingCapacity: false)
            self.dynamicRowHeight.removeAll(keepingCapacity: false)
            self.maxid = 0
            self.feed_filter = 1
            self.showSpinner = true
            self.browseFeed()
        }
        
        
    }
    
    func setNavigationcontroller()
    {
        
        self.navigationItem.title = app_title
        setNavigationImage(controller: self)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
        leftNavView.addGestureRecognizer(tapView)
        
        if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0))
        {
            let countLabel = createLabel(CGRect(x:17,y:3,width:17,height:17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
            countLabel.backgroundColor = UIColor.red
            countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
            countLabel.layer.masksToBounds = true
            countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            leftNavView.addSubview(countLabel)
        }
        
        // self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    func browseEmoji(contentItems: NSDictionary)
    {
        // var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        if let allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as? Dictionary<String, AnyObject>
        {
            var width   = contentItems.count
            width =  (6 * width) +  (40 * width)
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
                if let   v = allReactionsValueDic[key]
                {
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = 40
                        let   emoji = createButton(CGRect(x: origin_x,y: 5,width: menuWidth,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(AdvanceActivityFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
                        if let imageUrl = icon["reaction_image_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        scrollViewEmoji.addSubview(emoji)
                        origin_x = origin_x + menuWidth  + 5
                        i = i + 1
                    }
                    
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
    }
    
    @objc func feedMenuReactionLike(sender:UIButton)
    {
        
        if  let feed = feedArray[scrollViewEmoji.tag] as? NSDictionary
        {
            let action_id = feed["action_id"] as? Int ?? 0
            if openSideMenu{
                openSideMenu = false
                
                return
            }
            var reaction = ""
            for (_,v) in reactionsDictionary
            {
                var updatedDictionary = Dictionary<String, AnyObject>()
                if let v = v as? NSDictionary
                {
                    if  let reactionId = v["reactionicon_id"] as? Int
                    {
                        if reactionId == sender.tag
                        {
                            
                            reaction = (v["reaction"] as? String ?? "")
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
                            
                            feedObj.updateReaction(url: url, reaction: reaction, action_id: action_id, updateMyReaction: updatedDictionary as NSDictionary, feedIndex: scrollViewEmoji.tag)
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func addNewEvent()
    {
        let packagesEnabled = 1
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        else
        {
            if packagesEnabled == 1
            {
                isCreateOrEdit = true
                let presentedVC = PackageViewController()
                presentedVC.isFromHome = true
                presentedVC.contentType = "advancedevents"
                presentedVC.url = "advancedevents/packages"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//                let nativationController = UINavigationController(rootViewController: presentedVC)
//                self.present(nativationController, animated:false, completion: nil)
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
                /*isCreateOrEdit = true
                let presentedVC = AdvancedEventViewController()
                presentedVC.contentType = "advancedevents"
                presentedVC.url = "advancedevents/packages"
                presentedVC.fromPage = NSLocalizedString("Home", comment: "")
                presentedVC.fromTab = true
                self.navigationController?.pushViewController(presentedVC, animated: true)
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)*/
            }
            /*else
            {
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Create New Event", comment: "")
                presentedVC.contentType = "advancedevents"
                presentedVC.param = [ : ]
                presentedVC.url = "advancedevents/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }*/
            
            
        }
        
    }
    
    @objc func LocationAction()
    {
        if Locationdic != nil
        {
            if let type = Locationdic["locationType"] as? String
            {
                if type == "notspecific"
                {
                    let view = BrowseLocationViewController()
                    view.iscomingFrom = "feed"
                    self.navigationController?.pushViewController(view, animated: true)
                    
                }
                else
                {
                    let view = BrowseSpecificLocationViewController()
                    view.iscomingFrom = "feed"
                    self.navigationController?.pushViewController(view, animated: true)
                }
            }
        }
    }
    func messageAction()
    {
        let VC = MessageViewController()
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @objc func userLoggedIn(_ notification: NSNotification)
    {
        if #available(iOS 9.0, *) {
            getLocationdata()
        } else {
            // Fallback on earlier versions
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
    }
    func getheaderSetting()
    {
        if isshow_app_name == 0
        {
            let searchBar = UISearchBar()
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.blue
                textfield.textAlignment = .center
                if let backgroundview = textfield.subviews.first {
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 15
                    backgroundview.clipsToBounds = true
                    backgroundview.backgroundColor = UIColor.clear
                    
                }
            }
            _ = SearchBarContainerView(self, customSearchBar:searchBar, isKeyboardAppear:false)
            searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
            searchBar.delegate = self
            
            
            setNavigationImage(controller: self)
            
        }
    }
    func getLocationdata()
    {
        
        if isshow_app_name == 0
        {
            if Locationdic != nil
            {
                let isLoggedIn = (UserDefaults(suiteName: "\(shareGroupname)")?.string(forKey: "oauth_token")!.isEmpty)!
                //print("Oauth Token: ", UserDefaults.standard.string(forKey: "oauth_token")!)
                /*if locationOnhome == 1 && isChangeManually == 1
                {*/
                    
//                    let button   = UIButton(type: UIButtonType.system) as UIButton
//                    button.frame = CGRect(x: self.view.bounds.size.width-100,y: 0,width: 18,height: 18)
//                    button.backgroundColor = UIColor.clear
//                    let loctionimg = UIImage(named: "Location")!.maskWithColor(color: textColorPrime)
//                    button.setImage(loctionimg , for: UIControlState.normal)
//                    button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.LocationAction), for: UIControlEvents.touchUpInside)
//                    let locButton = UIBarButtonItem()
//                    locButton.customView = button
//                    self.navigationItem.setRightBarButtonItems([locButton], animated: true)
                
                let searchButton = UIBarButtonItem()
                
                if !isLoggedIn {
                    let button2 = UIButton(type: .custom)
                    let searchIconImage = UIImage(named: "search_icon.png")!.maskWithColor(color: textColorPrime)
                    //button2.setImage(searchIconImage, for: UIControlState.normal)
                    button2.imageView?.contentMode = .scaleAspectFit
                    button2.setBackgroundImage(searchIconImage, for: .normal)
                    button2.contentMode = .scaleAspectFit
                    button2.clipsToBounds = true
                    button2.addTarget(self, action: #selector(AdvanceActivityFeedViewController.searchItem), for: UIControlEvents.touchUpInside)
                
                    
                    if #available(iOS 11.0, *) {
                        let currWidth = button2.widthAnchor.constraint(equalToConstant: 26)
                        let currHeight = button2.heightAnchor.constraint(equalToConstant: 26)
                        currWidth.isActive = true
                        currHeight.isActive = true
                    } else {
                        button2.frame = CGRect(x: self.view.bounds.width-36, y: 0, width: 26, height: 26)
                    }
                    searchButton.customView = button2
                    
                }
              /*  let button = UIButton(type: .custom)
                //button.backgroundColor = UIColor.green
                //button.sizeToFit()
                //button.clipsToBounds = true
                let loctionimg = UIImage(named: "event_icon.png")!.maskWithColor(color: textColorPrime)
                button.setImage(loctionimg , for: UIControlState.normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.addNewEvent), for: UIControlEvents.touchUpInside)
                let eventButton = UIBarButtonItem()
                
                
                if #available(iOS 11.0, *) {
                    let currWidth = button.widthAnchor.constraint(equalToConstant: 26)
                    let currHeight = button.heightAnchor.constraint(equalToConstant: 26)
                    currWidth.isActive = true
                    currHeight.isActive = true
                } else {
                    button.frame = CGRect(x: self.view.bounds.width-62, y: 0, width: 26, height: 26)
                }
                eventButton.customView = button*/
                
                let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                fixedSpace.width = 7.0
                
                let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                negativeSpace.width = -7.0
                    
                self.navigationItem.setRightBarButtonItems([negativeSpace,searchButton,fixedSpace], animated: true)
                    
                    
                //}
                
            }
        else
        {
            
            if Locationdic != nil
            {
                if locationOnhome == 1 && isChangeManually == 1
                {
                    
                    let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                    let button   = UIButton(type: UIButtonType.system) as UIButton
                    button.frame = CGRect(x: self.view.bounds.size.width-100,y: 0,width: 20,height: 20)
                    button.backgroundColor = UIColor.clear
                    let loctionimg = UIImage(named: "Location")!.maskWithColor(color: textColorPrime)
                    button.setImage(loctionimg , for: UIControlState.normal)
                    button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.LocationAction), for: UIControlEvents.touchUpInside)
                    let locButton = UIBarButtonItem()
                    locButton.customView = button
                    self.navigationItem.setRightBarButtonItems([searchIcon,locButton], animated: true)
                    
                    
                }
                else
                {
                    let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                    self.navigationItem.rightBarButtonItem = searchIcon
                    
                }
            }
            else
            {
                //let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                
                let button2 = UIButton(type: .custom)
                let searchIconImage = UIImage(named: "search_icon.png")!.maskWithColor(color: textColorPrime)
                //button2.setImage(searchIconImage, for: UIControlState.normal)
                button2.imageView?.contentMode = .scaleAspectFit
                button2.setBackgroundImage(searchIconImage, for: .normal)
                button2.contentMode = .scaleAspectFit
                button2.clipsToBounds = true
                button2.addTarget(self, action: #selector(AdvanceActivityFeedViewController.searchItem), for: UIControlEvents.touchUpInside)
                let searchButton = UIBarButtonItem()
                
                if #available(iOS 11.0, *) {
                    let currWidth = button2.widthAnchor.constraint(equalToConstant: 26)
                    let currHeight = button2.heightAnchor.constraint(equalToConstant: 26)
                    currWidth.isActive = true
                    currHeight.isActive = true
                } else {
                    button2.frame = CGRect(x: self.view.bounds.width-36, y: 0, width: 26, height: 26)
                }
                searchButton.customView = button2
                
                /*
                let button = UIButton(type: .custom)
                //button.backgroundColor = UIColor.green
                //button.sizeToFit()
                //button.clipsToBounds = true
                let loctionimg = UIImage(named: "event_icon.png")!.maskWithColor(color: textColorPrime)
                button.setImage(loctionimg , for: UIControlState.normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.addNewEvent), for: UIControlEvents.touchUpInside)
                let eventButton = UIBarButtonItem()
                
                
                if #available(iOS 11.0, *) {
                    let currWidth = button.widthAnchor.constraint(equalToConstant: 26)
                    let currHeight = button.heightAnchor.constraint(equalToConstant: 26)
                    currWidth.isActive = true
                    currHeight.isActive = true
                } else {
                    button.frame = CGRect(x: self.view.bounds.width-62, y: 0, width: 26, height: 26)
                }
                eventButton.customView = button*/
                
                let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                fixedSpace.width = 15.0
                
                let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                negativeSpace.width = -7.0
                
                self.navigationItem.setRightBarButtonItems([negativeSpace,searchButton,fixedSpace], animated: true)
                
            }
        }
        
        
    }
}
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if openSideMenu{
            openSideMenu = false
            
            return
            
        }
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            feedUpdate = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
        
        
    }
    
    // Show Post Feed Option Selection (Status, Photos, Checkin)
    @objc func openPostFeed(sender:UIButton){
        
        if openSideMenu
        {
            openSideMenu = false
            
            return
        }
        
        stopMyTimer()
        
        let presentedVC = AdvancePostFeedViewController()
        presentedVC.openfeedStyle = (sender.tag - 1990)
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        
        if presentedVC.openfeedStyle == 1 || presentedVC.openfeedStyle == 2 || presentedVC.openfeedStyle == 3
        {
            self.present(nativationController, animated:false, completion: nil)
        }
        else
        {
            self.present(nativationController, animated:true, completion: nil)
            
        }
        
        
        
    }
    
    // Show Slide Menu
    @objc func openSlideMenu(){
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        //
        openSideMenu = true
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            
        }
    }
    func viewWillLoadData()
    {
        startMyTimer()
        API_getStoryCreate()
        UserDefaults.standard.removeObject(forKey: "SellSomething")
        if greetingsCheck == true {
            greetingsCheck = false
            getUIOfGreetings ()
        }
        //rateApp()
        if openAppRating
        {
            openAppRating = false
            checkAndAskForReview()
            
        }
        
       // hidingNavBarManager?.viewWillAppear(animated)
        ScheduleDisctionary.removeAll()
        TargetDictionary.removeAll()
        removeNavigationViews(controller: self)
        feedObj.feedShowingFrom = "ActivityFeed"
        if conditionalProfileForm == "AAF"
        {
            IsRedirctToProfile()
        }
        if conditionalProfileForm == "BrowsePage"
        {
            IsRedirctToProfile()
        }
        self.browseEmoji(contentItems: reactionsDictionary)
        tableViewFrameType = "AdvanceActivityFeedViewController"
        
        setNavigationImage(controller: self)
        self.navigationItem.title = app_title
        videoAttachFromAAF = ""
        openSideMenu = false
        subject_unique_type = nil
        subject_unique_id = nil
        if feedUpdate == true
        {
            // Set Default & request to hard Refresh
            
            globalFeedHeight = tableHeaderHight
            self.feedObj.refreshLikeUnLike = true
            feedObj.tableView.reloadData()
            feedUpdate = false
            maxid = 0
            showSpinner = true
            feed_filter = 1
            browseFeed()
        }
        else
        {
            
            globalFeedHeight = tableHeaderHight
            self.feedObj.globalArrayFeed = feedArray
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                feedObj.tableView.reloadData()
            }else{
                fromExternalWebView = false
            }
            
        }
    }
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.delegate = self
        if show_story == 1
        {
            if self.storiesView?.collectionViewStories != nil
            {
                self.storiesView?.collectionViewStories?.reloadData()
            }
            if isViewWillAppearCall == 0
            {
                hidingNavBarManager?.viewWillAppear(animated)
                DispatchQueue.main.async {
                    self.viewWillLoadData()
                }
            }
            else
            {
                modifyDataAsPerStoryFlow()
            }
        }
        else
        {
            hidingNavBarManager?.viewWillAppear(animated)
            DispatchQueue.main.async {
                self.viewWillLoadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
        
    }
    // Stop Timer on Disappear of Activity Feed View
    override func viewWillDisappear(_ animated: Bool)
    {
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        
        feedObj.tableView.tableFooterView?.isHidden = true
        stopMyTimer()
        hidingNavBarManager?.viewWillDisappear(animated)
        // tableViewFrameType = ""
        frndTagValue.removeAll()
        setNavigationImage(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    
    func modifyDataAsPerStoryFlow()
    {
        if isViewWillAppearCall == 2
        {
            isViewWillAppearCall = 0
            if isStoryShare == true
            {
                if isStoryPost == true
                {
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your story and feed will be posted shortly",comment: ""), duration: 3, position: "bottom")
                }
                else
                {
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your story will be posted shortly",comment: ""), duration: 3, position: "bottom")
                }
                storiesView?.updateStoriesData(isDataUpdate: true)
                API_shareStory()
            }
            else if isStoryPost == true
            {
                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your feed will be posted shortly",comment: ""), duration: 3, position: "bottom")
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                API_postStory()
            }
        }
        else if isViewWillAppearCall == 3
        {
            isViewWillAppearCall = 0
            storiesView?.updateStoriesData(isDataUpdate: true)
            API_getBrowseStories()
        }
        else if isViewWillAppearCall == 4
        {
            isViewWillAppearCall = 0
            
        }
        else if isViewWillAppearCall == 5
        {
            isViewWillAppearCall = 0
            API_getBrowseStories()
        }
        else if isViewWillAppearCall == 6
        {
            isViewWillAppearCall = 0
            API_getBrowseStories()
        }
        else
        {
            isViewWillAppearCall = 0
        }
    }
    
    func IsRedirctToProfile()
    {
        
        if conditionalProfileForm == "AAF"
        {
            conditionalProfileForm = ""
            if enabledModules.contains("sitevideo")
            {
                
                let presentedVC = AdvanceVideoProfileViewController()
                presentedVC.videoProfileTypeCheck = ""
                
                presentedVC.videoId = createResponse["video_id"] as? Int ?? 0
                presentedVC.videoType = createResponse["type"] as? Int
                presentedVC.videoUrl = createResponse["video_url"] as? String ?? ""
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            else{
                
                VideoObject().redirectToVideoProfilePage(self, videoId : createResponse["video_id"] as? Int ?? 0, videoType : createResponse["type"] as? Int ?? 0, videoUrl : createResponse["video_url"] as? String ?? "")
            }
            
        }
        
        else if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = createResponse["event_id"] as! Int
            presentedVC.subjectType = "advancedevents"
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    
    // Initialize Timer for Check Updates in Feeds
    func startMyTimer(){
        myTimer = Timer.scheduledTimer(timeInterval: 30, target:self, selector:  #selector(AdvanceActivityFeedViewController.newfeedsUpdate), userInfo: nil, repeats: true)
        
    }
    
    // Stop Timer for Check Updation
    func stopMyTimer(){
        if myTimer != nil{
            myTimer.invalidate()
        }
    }
    
    
    
    // Show Post Feed Option to User based on Permission from Server & Save these options
    func postFeedOption()
    {
        var postPermission_variable : Int = 0
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? NSData{
            if data.length != 0
            {
                if postView != nil {
                    for ob in postView.subviews
                    {
                        if ob.tag != 108
                        {
                            ob.removeFromSuperview()
                        }
                        
                    }
                }
                if let  postPermission = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? NSDictionary
                {
                    var postMenu = [String]()
                    var menuIcon = [String]()
                    var colorIcon = [UIColor]()
                    if postPermission.count > 0{
                        if let status = postPermission["video"] as? Bool{
                            if status
                            {
                                for (key,value) in videoattachmentType
                                {
                                    if key as! String == "3"
                                    {
                                        postMenu.append(NSLocalizedString(" Video", comment: ""))
                                        menuIcon.append(videoIcon)
                                        colorIcon.append(videoIconColor)
                                        postPermission_variable = 1
                                    }
                                }
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
                    
                    let  feedTextView = createButton(CGRect(x: 60 + PADING,y: 0 ,width: view.bounds.width-(60 + PADING),height:64), title: NSLocalizedString("What's on your mind?",comment: "") , border: false ,bgColor: false, textColor: textColorMedium)
                    feedTextView.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
                    
                    let border = CALayer()
                    let width = CGFloat(0.5)
                    let borderColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
                    border.borderColor = borderColor.cgColor
                    border.frame = CGRect(x: 0, y: 69, width: view.bounds.width , height: 1)
                    border.borderWidth = width
                    
                    postView.layer.addSublayer(border)
                    postView.layer.masksToBounds = true
                    
                    feedTextView.tag = 1990
                    feedTextView.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                    feedTextView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.openPostFeed(sender:)), for: .touchUpInside)
                    feedTextView.backgroundColor = lightBgColor
                    postView.addSubview(feedTextView)
                    
                    //Add Post Feed Option
                    
                    for i in 0 ..< postMenu.count
                    {
                        let origin_x = (CGFloat(i) * (view.bounds.width/CGFloat(postMenu.count)))
                        let postFeed = createButton(CGRect(x: origin_x,y: 70 ,width: view.bounds.width/CGFloat(postMenu.count),height: 35), title: "" , border: false ,bgColor: false, textColor: textColorMedium )
                        switch i {
                        case 0:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[0])
                            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: colorIcon[0], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[0])",comment: ""))
                            descString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedStringKey.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControlState.normal)
                            break
                        case 1:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[1])
                            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: colorIcon[1], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[1])",comment: ""))
                            descString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedStringKey.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControlState.normal)
                            break
                        case 2:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[2])
                            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: colorIcon[2], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[2])",comment: ""))
                            descString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedStringKey.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControlState.normal)
                            break
                        default:
                            break
                        }
                        
                        postFeed.titleLabel?.textAlignment = NSTextAlignment.center
                        postFeed.backgroundColor = lightBgColor
                        if postPermission_variable == 1{
                            postFeed.tag = i+1 + 1990
                        }
                        else {
                            postFeed.tag = i+2 + 1990
                        }
                        postFeed.addTarget(self, action: #selector(AdvanceActivityFeedViewController.openPostFeed(sender:)), for: .touchUpInside)
                        postView.addSubview(postFeed)
                    }
                    
                    postMenu.removeAll(keepingCapacity: false)
                }
            }
        }
        
    }
    
    // Pull to Request Action
    @objc func refresh(){
        
        DispatchQueue.main.async(execute:{
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if reachability.connection != .none
        {
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            maxid = 0
            feed_filter = 1
            self.updateNewFeed = false
            
            browseFeed()
            
            
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer:Bool){
        mainView.addSubview(validationMsg)
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
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if ( tabBarController.selectedIndex == 0)
        {
            scrollToTop()
        }
    }
    
    func scrollToTop()
    {
        let indexPath = IndexPath(row: 0, section: 0)
        if !((self.feedObj.tableView.indexPathsForVisibleRows?.contains(indexPath))!) {
            // Your code here
            
            
            
            if feedObj.tableView.contentOffset.y != -TOPPADING {
                feedObj.tableView.contentOffset.y = 0
            }
            
            if self.feedObj.tableView.numberOfRows(inSection: 0) > 0
            {
                
                let indexPath = IndexPath(row: 0, section: 0)
                self.feedObj.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    // Request to Show New Stories Feed
    @objc func updateNewFeed(sender:UIButton){
        
        sender.removeFromSuperview()
        self.newFeedUpdateCounter = 0
        self.updateNewFeed = false
        if searchDic.count == 0 && gutterMenu1.count > 0
        {
            if let dic = self.gutterMenu1[0] as? NSDictionary
            {
                // Set Parameters for Feed Filter
                if let params = dic["urlParams"] as? NSDictionary
                {
                    searchDic["filter_type"] = params["filter_type"] as? String
                }
            }
        }
        else
        {
            searchDic["filter_type"] = "all"
            
            
        }
        // Reload Tabel After Updation
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        self.activityFeeds.removeAll(keepingCapacity: false)
        let indexPath = IndexPath(row: 0, section: 0)
        self.feedObj.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    // Make Updation in Core Data for every Recent Activity Feed (All Updates)
    func updateActivityFeed(feeds:[ActivityFeed]){
        // Save Response in Core Data
        let request:NSFetchRequest<ActivityFeedData>
        if #available(iOS 10.0, *)
        {
            request = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
        }
        else
        {
            request = NSFetchRequest(entityName: "ActivityFeedData")
        }
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            
            // If exist than Delete all entries
            for result: AnyObject in results! {
                context.delete(result as! NSManagedObject)
            }
            do {
                try context.save()
            } catch _ {
            }
            // Update Saved Feed
            updateSavedFeed(feeds: feeds)
        }
            
        else
        {
            // Update Saved Feed
            updateSavedFeed(feeds: feeds)
        }
    }
    
    // Updates Saved Feed in Core Data For Recent Feed
    func updateSavedFeed(feeds:[ActivityFeed]){
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
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.attachment ?? []) , forKey: "attachment")
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
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_menus ?? []) , forKey: "feedMenu")
            }
            if feed.feed_footer_menus != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_footer_menus ?? [:]) , forKey: "feed_footer_menus")
            }
            if feed.feed_reactions != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_reactions ?? [:]) , forKey: "feed_reactions")
            }
            if feed.my_feed_reaction != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.my_feed_reaction ?? [:]) , forKey: "my_feed_reaction")
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
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.params ?? [:]) , forKey: "params")
            }
            if feed.tags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.tags ?? []) , forKey: "tags")
            }
            if feed.action_type_body_params != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.action_type_body_params ?? []) , forKey: "action_type_body_params")
            }
            if feed.action_type_body != nil{
                newfeed.setValue( feed.action_type_body , forKey: "action_type_body")
            }
            if feed.object != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.object ?? [:]) , forKey: "object")
                
            }
            if feed.hashtags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.hashtags ?? []) , forKey: "hashtags")
            }
            if feed.userTag != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.userTag ?? []) , forKey: "userTag")
            }
            if feed.decoration != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.decoration!) , forKey: "decoration")
            }
            if feed.wordStyle != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.wordStyle!) , forKey: "wordStyle")
            }
            if feed.publish_date != nil{
                newfeed.setValue( feed.publish_date , forKey: "publish_date")
            }
            if feed.isNotificationTurnedOn != nil{
                newfeed.setValue( feed.isNotificationTurnedOn , forKey: "isNotificationTurnedOn")
            }
            if feed.attachment_content_type != nil{
                newfeed.setValue( feed.attachment_content_type , forKey: "attachment_content_type")
            }
            
            
            
            do {
                try context.save()
            } catch _ {
            }
            i += 1
            
        }
        
        
    }
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArray(feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        
        for tempFeedArrays in feedArray {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as? Int ?? 0)
        }
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            
            
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.feed_privacy != nil{
                newDictionary["privacy"] = feed.feed_privacy
            }
            if feed.feed_privacyIcon != nil{
                newDictionary["privacy_icon"] = feed.feed_privacyIcon
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
            if feed.save_feed != nil{
                newDictionary["save_feed"] = feed.save_feed
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
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
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
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
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
            
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            
            
            
            
            let actionId  = newDictionary["action_id"] as! Int
            
            if !existingFeedIntegerArray.contains(actionId){
                
                feedArray.append(newDictionary)
            }
            
            
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
        //Header height
        globalFeedHeight =  tableHeaderHight
        self.feedObj.refreshLikeUnLike = true
        
        self.feedObj.globalArrayFeed = feedArray
        self.feedObj.tableView.reloadData()
    }
    
    // MARK: - Optimise later PhotoLayout Work
    
    // MARK: - Server Connection For Activity Feeds Updation
    @objc func newfeedsUpdate()
    {
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            // if subject_id == 0 && subject_type == ""{
            parameters = ["limit": "\(limit)" ,"minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0"]
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:{
                    // Reset Object after Response from server
                    userInteractionOff = true
                    // On Success Update Feeds
                    if msg{
                        
                        // Check response of Activity Feeds
                        if self.feed_filter == 1 {
                            if let newFeedCountInteger = succeeded["body"]  as? Int{
                                if newFeedCountInteger > 0{
                                    
                                    self.newFeedUpdateCounter += newFeedCountInteger
                                    self.maxid = 0
                                    //updateAfterAlert = false
                                    //self.feed_filter = 0
                                    self.browseFeed()
                                    self.updateNewFeed = true
                                    
                                    
                                }
                            }
                        }
                        else{
                            
                            //self.shimmeringView.isShimmering = false
                            self.feedObj.tableView.tableFooterView?.isHidden = true
                            
                            self.refresher.endRefreshing()
                        }
                        
                    }else{
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as? String ?? "", duration: 5, position: "bottom")
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
            
        }
        
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    
    
    @objc func browseFeed()
    {
        if show_story == 1
        {
          API_getBrowseStories()
        }
        contentIcon.isHidden = true
        refreshButton.isHidden = true
        info.isHidden = true
        // Check Internet Connectivity
        if reachability.connection != .none
        {
            if UserDefaults.standard.bool(forKey: "appTour")
            {
                self.showAppTour()
            }
            removeAlert()
            stopMyTimer()
            if (showSpinner)
            {
                
                activityIndicatorView.center = view.center
                
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            // Reset Objects for Hard Refresh Request
            if (maxid == 0)
            {
                if feedArray.count == 0
                {
                    feedObj.tableView.reloadData()
                    
                }
            }
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["maxid": String(maxid),"feed_filter": "\(feed_filter)","object_info":"1","getAttachedImageDimention":"0"]
            if updateScrollFlag == false{
                if defaultFeedCount > 0 {
                    parameters["limit"] = "\(defaultFeedCount)"
                }
            }
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true
            {
                parameters.merge(searchDic)
            }
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.view.isUserInteractionEnabled = true
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.showSpinner = false
                    // Stop Shimmering
                    isshimmer = false
                    // Reset Object after Response from server
                    userInteractionOff = true
                    //self.shimmeringView.isShimmering = false
                    activityIndicatorView.stopAnimating()
                    self.refresher.endRefreshing()
                    self.feedObj.tableView.tableFooterView?.isHidden = true
                    
                    // On Success Update Feeds

                    if msg
                    {
                        // If Message in Response show the Message
                        if succeeded["message"] != nil
                        {
                            self.view.makeToast(succeeded["message"] as? String ?? "", duration: 5, position: "bottom")
                            
                        }
                        
                        // Reset feedArray for Sink with Feed Results
                        if self.maxid == 0
                        {
                            feedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if let showFilterType = response["showFilterType"] as? Int
                            {
                                isfeedfilter = showFilterType
                            }
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            // Set MinId for Feeds Result
                            if let feedCount = response["defaultFeedCount"] as? Int{
                                self.defaultFeedCount = feedCount
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.gutterMenu1 = menu
                                if logoutUser == true {
                                    if self.view.viewWithTag(2017) == nil{
                                        if isfeedfilter == 1
                                        {
                                            self.showfeedFilter()
                                        }
                                    }
                                }
                                else
                                {
                                    if greetingsAllow == 0 {
                                        // if self.view.viewWithTag(2017) == nil{
                                        if isfeedfilter == 1
                                        {
                                            self.showfeedFilter()
                                        }
                                    }
                                }
                                
                                if searchDic.count == 0
                                {
                                    if let dic = self.gutterMenu1[0] as? NSDictionary
                                    {
                                        // Set Parameters for Feed Filter
                                        if let params = dic["urlParams"] as? NSDictionary{
                                            for (key, value) in params{
                                                if let id = value as? NSNumber {
                                                    searchDic["\(key)"] = String(id as? Int ?? 0)
                                                }
                                                
                                                if let receiver = value as? NSString {
                                                    searchDic["\(key)"] = receiver as String
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update feedArray
                                    self.updateFeedsArray(feeds: self.activityFeeds)
                                }
                            }
                            if greetingsAllow == 1 {
                                if self.firstGreetings {
                                    self.firstGreetings = false
                                    self.getGreetings()
                                }
                            }
                            // Check for Video Attachment type
                            
                            // update Recent Top 20 Feeds in Core Data
                            if self.maxid == 0 && searchDic.count == 0  /*&& self.subject_type == ""*/
                            {
                                self.updateActivityFeed(feeds: self.activityFeeds)
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
                            else
                            {
                                ReactionPlugin = false
                            }
                            // Check that whether Sticker Plugin is enable or not
                            if let stickersEnable = response["stickersEnabled"] as? Bool{
                                if stickersEnable == true{
                                    StickerPlugin = true
                                }
                            }
                            // Check that whether Image Attachment for comments is enable or not
                            if let emojiEnable = response["emojiEnabled"] as? Bool{
                                if emojiEnable == true{
                                    emojiEnabled = true
                                }
                            }
                            if response["video_source"] != nil
                            {
                                videoattachmentType = response["video_source"] as! NSDictionary
                            }
                            
                            // Set MaxId for Feeds Result
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            // Check for Post Feed Options
                            if response["feed_post_menu"] != nil && !(response["feed_post_menu"] is NSNull){
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                self.API_getFeedPostMenus()
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:postPermission), forKey: "postMenu")
                                if (logoutUser == false)
                                {
                                    self.postFeedOption()
                                }
                                
                                
                            }
                            // Set Label If their is no feed in response
                            if feedArray.count == 0
                            {
                                self.contentIcon.frame.origin.y = self.tableHeaderHight + 5 + 70 + iphonXTopsafeArea
                                self.info.frame.origin.y = self.contentIcon.frame.origin.y + self.contentIcon.bounds.height + 10
                                self.refreshButton.frame.origin.y = self.info.frame.origin.y + self.info.bounds.height + 10
                                self.contentIcon.isHidden = false
                                self.refreshButton.isHidden = false
                                self.info.isHidden = false
                                self.feedObj.globalArrayFeed = feedArray
                                
                            }
                            
                            if self.updateNewFeed == true && self.feedObj.tableView.contentOffset.y > 50
                            {
                                if self.newFeedUpdateCounter > 0
                                {
                                    _ = self.newFeedUpdateCounter
                                    var newFeedCount = ""
                                    newFeedCount = String(format: NSLocalizedString("%@ New Updates", comment: ""), "\u{f062}")
                                    
                                    if let newFeedsButton = self.mainView.viewWithTag(2020) {
                                        // myButton already existed
                                        newFeedsButton.removeFromSuperview()
                                        
                                    }
                                    let newFeeds = createButton(CGRect(x: 0,y: TOPPADING ,width: findWidthByText(newFeedCount) + 40 ,height: ButtonHeight - PADING),title: newFeedCount, border: false,bgColor: true, textColor: textColorLight)
                                    newFeeds.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                                    newFeeds.isHidden = false
                                    newFeeds.tag = 2020
                                    newFeeds.center = CGPoint(x:self.view.center.x, y:newFeeds.frame.origin.y)
                                    newFeeds.layer.cornerRadius = newFeeds.bounds.height/2
                                    newFeeds.addTarget(self, action: #selector(AdvanceActivityFeedViewController.updateNewFeed(sender:)), for: .touchUpInside)
                                    self.mainView.addSubview(newFeeds)
                                    self.updateScrollFlag = true
                                    self.startMyTimer()
                                    self.feedObj.refreshLikeUnLike = true
                                    self.feedObj.tableView.reloadData()
                                    
                                }
                                
                            }
                            else
                            {
                                // Reload Tabel After Updation
                                self.newFeedUpdateCounter = 0
                                self.feedObj.refreshLikeUnLike = true
                                self.feedObj.tableView.reloadData()
                                if afterPost == true{
                                    afterPost = false
                                    DispatchQueue.main.async(execute:  {
                                        soundEffect("post")
                                    })
                                    
                                }
                                self.updateScrollFlag = true
                                self.activityFeeds.removeAll(keepingCapacity: false)
                                self.startMyTimer()
                                // Create Timer for Check UPdtes Repeatlly
                            }
                            
                        }
                        
                    }
                    else
                    {
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            if feedArray.count > 0
            {
                
                self.feedObj.globalArrayFeed = feedArray
                self.feedObj.refreshLikeUnLike = true
                self.feedObj.tableView.reloadData()
            }
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
            
        }
        
        
    }
    
    // MARK:  UIScrollViewDelegate
    // Handle Scroll For Pagination
    func didScroll(){
        //func ScrollingactionAdvanceActivityFeed(_ notification: NSNotification){
        scrollViewEmoji.isHidden = true
        greetingsWebView.scrollView.contentOffset.y = 0
        // Removing new feed tip while on top
        if feedObj.tableView.contentOffset.y < 20 && self.updateNewFeed == true
        {
            if let newFeedsButton = self.mainView.viewWithTag(2020) {
                // myButton already existed
                newFeedsButton.removeFromSuperview()
            }
            self.newFeedUpdateCounter = 0
            self.updateNewFeed = false
            if searchDic.count == 0 && gutterMenu1.count > 0
            {
                if let dic = self.gutterMenu1[0] as? NSDictionary
                {
                    // Set Parameters for Feed Filter
                    if let params = dic["urlParams"] as? NSDictionary
                    {
                        
                        searchDic["filter_type"] = params["filter_type"] as? String
                        
                    }
                }
            }
            else
            {
                searchDic["filter_type"] = "all"
                
                
            }
            
        }
        if updateScrollFlag{
            // Check for PAGINATION
            if feedObj.tableView.contentSize.height > feedObj.tableView.bounds.size.height{
                if feedObj.tableView.contentOffset.y >= (feedObj.tableView.contentSize.height - feedObj.tableView.bounds.size.height)
                {
                    if reachability.connection != .none
                    {
                        if feedArray.count > 0
                        {
                            if maxid == 0
                            {
                                if noPost == true
                                {
                                    feedObj.tableView.tableFooterView?.isHidden = true
                                    self.view.makeToast(NSLocalizedString("There are no more posts to show.",  comment: ""), duration: 5, position: "bottom")
                                    noPost = false
                                }
                            }
                            else
                            {
                                feedObj.tableView.tableFooterView?.isHidden = false
                                // Request for Pagination
                                updateScrollFlag = false
                                if searchDic["filter_type"] == "schedule_post"{
                                    feed_filter = 1
                                    if noPost == true
                                    {
                                        feedObj.tableView.tableFooterView?.isHidden = true
                                        self.view.makeToast(NSLocalizedString("There are no more posts to show.",  comment: ""), duration: 5, position: "bottom")
                                        noPost = false
                                    }
                                }
                                else{
                                    feed_filter = 0
                                }
                                //    showSpinner = false
                                //                                if feedObj.tableView.tableFooterView == nil
                                //                                {
                                //                                    CreateFooter()
                                //                                }
                                if adsType_feeds == 2 || adsType_feeds == 4{
                                    
                                    delay(0.1) {
                                        self.feedObj.checkforAds()
                                    }
                                }
                                self.browseFeed()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMessage(sender:UIButton)
    {
        if logoutUser == true
        {
            
            self.view.makeToast("You are not allowed to see this page !!", duration: 5, position: "bottom")
            
        }else{
            
            let presentedVC = MessageViewController()
            (presentedVC as MessageViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    func openRequest(sender:UIButton){
        
        if logoutUser == true{
            self.view.makeToast("You are not allowed to see this page !!", duration: 5, position: "bottom")
        }else{
            let presentedVC = RequestViewController()
            presentedVC.showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    func openNotification(sender:UIButton){
        if logoutUser == true{
            self.view.makeToast("You are not allowed to see this page !!", duration: 5, position: "bottom")
            
        }else{
            let presentedVC = NotificationViewController()
            (presentedVC as NotificationViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        
    }
    
    func checkMiniMenu()
    {
        
        if (logoutUser == false && (totalNotificationCount !=  nil))
        {
            
            let leftNavView = UIView(frame: CGRect(x: 0,y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
            leftNavView.addGestureRecognizer(tapView)
            let menuImageView = createImageView(CGRect(x:0,y:12,width:22,height:22), border: false)
            menuImageView.image = UIImage(named: "dashboard_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(menuImageView)
            
            if totalNotificationCount > 0
            {
                
                let countLabel = createLabel(CGRect(x: 17, y: 3, width: 17,height: 17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
                countLabel.backgroundColor = UIColor.red
                countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
                countLabel.layer.masksToBounds = true
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
                leftNavView.addSubview(countLabel)
                let barButtonItem = UIBarButtonItem(customView: leftNavView)
                self.navigationItem.leftBarButtonItem = barButtonItem
            }
            
        }
        
        
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func changeColor(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            let presentedVC = NotificationViewController()
            (presentedVC as NotificationViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
            self.view.backgroundColor = UIColor.green
        case 2:
            self.view.backgroundColor = UIColor.blue
        default:
            self.view.backgroundColor = UIColor.purple
            
            
        }
    }
    
    @objc func showProfile()
    {
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.strProfileImageUrl = coverImage
        presentedVC.strUserName = displayName
        presentedVC.subjectType = "user"
        presentedVC.subjectId = currentUserId
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    func sideMenuWillOpen() {
        openSideMenu = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
        mainView.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = false
    }
    
    func sideMenuWillClose() {
        openSideMenu = false
        mainView.removeGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func searchItem()
    {
        if openSideMenu{
            openSideMenu = false
            //
            return
            
        }
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            feedUpdate = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
        
    }
    
    // Get suggetions from server
    @objc func getSuggestions()
    {
        if reachability.connection != .none{
            
            let parameters = ["limit": String(suggestionsLimit), "restapilocation": ""]
            userSuggestions.removeAll(keepingCapacity: false)
            let url = "suggestions/suggestion-listing"
            post(parameters, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    if msg{
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["users"] != nil {
                                if let suggestion = response["users"] as? NSArray {
                                    userSuggestions = userSuggestions + suggestion
                                    enableSuggestion = true // If we set it false then only starting suggested friends will always shown and no any further calling of api of suggestion.
                                    self.feedObj.isHomeFeeds = true
                                    self.feedObj.refreshLikeUnLike = true
                                    self.feedObj.tableView.reloadData()
                                }
                            }
                            
                        }
                        
                    }
                    else
                    {
                        // Handle Server Error
                        if succeeded["message"] != nil && enabledModules.contains("suggestion")
                        {
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
            })
        }
        
    }
    
    func CreateFooter()
    {
        var yAxis = -12
        if DeviceType.IS_IPHONE_X
        {
            yAxis = -9
        }
        
        footerView = UIView(frame: CGRect(x: 0, y: yAxis, width: Int(self.view.bounds.width), height: 25))
        footerView.backgroundColor = UIColor.clear
        
        let activityIndicator = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicator.center = footerView.center//CGPoint(x:(footerView.bounds.width - 25)/2, y:2.0)
        footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
    }
    
    func getchacheFeed()
    {
        let request:NSFetchRequest<ActivityFeedData>
        
        if #available(iOS 10.0, *)
        {
            request = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
        }
        else
        {
            request = NSFetchRequest(entityName: "ActivityFeedData")
        }
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            // If exist Token than Update
            for result: AnyObject in results!
            {
                
                let newDictionary:NSMutableDictionary = [:]
                if result.value(forKey: "subjectAvatarImage") != nil
                {
                    newDictionary["subject_image"] = result.value(forKey: "subjectAvatarImage")
                }
                if result.value(forKey: "subjectAvatarImage")  != nil{
                    newDictionary["subject_image"] = result.value(forKey:"subjectAvatarImage")
                }
                if result.value(forKey: "feedTitle")  != nil{
                    newDictionary["feed_title"] = result.value(forKey:"feedTitle")
                }
                if result.value(forKey: "creationDate")   != nil{
                    newDictionary["feed_createdAt"] = result.value(forKey:"creationDate")
                }
                if result.value(forKey: "commentCount")  != nil{
                    newDictionary["comment_count"] = result.value(forKey:"commentCount")
                }
                if result.value(forKey: "likeCount")  != nil{
                    newDictionary["likes_count"] = result.value(forKey:"likeCount")
                }
                if result.value(forKey: "attachment")  != nil{
                    newDictionary["attachment"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"attachment") as! NSData) as Data)
                }
                if result.value(forKey: "attachmentCount")  != nil{
                    newDictionary["attactment_Count"] = result.value(forKey:"attachmentCount")
                }
                if result.value(forKey: "action_Id") != nil{
                    newDictionary["action_id"] = result.value(forKey:"action_Id")
                }
                if result.value(forKey: "subject_Id") != nil{
                    newDictionary["subject_id"] = result.value(forKey:"subject_Id")
                }
                if result.value(forKey: "share_params_id") != nil{
                    newDictionary["share_params_id"] = result.value(forKey: "share_params_id")
                }
                if result.value(forKey: "share_params_type") != nil{
                    newDictionary["share_params_type"] = result.value(forKey: "share_params_type")
                }
                if result.value(forKey: "feedType")  != nil{
                    newDictionary["feed_Type"] = result.value(forKey: "feedType")
                }
                if result.value(forKey: "feedMenu")  != nil{
                    newDictionary["feed_menus"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feedMenu") as! NSData) as Data)
                }
                if result.value(forKey: "feed_footer_menus")  != nil{
                    newDictionary["feed_footer_menus"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feed_footer_menus") as! NSData) as Data)
                }
                if result.value(forKey: "feed_reactions")  != nil{
                    newDictionary["feed_reactions"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feed_reactions") as! NSData) as Data)
                }
                if result.value(forKey: "my_feed_reaction")  != nil{
                    newDictionary["my_feed_reaction"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "my_feed_reaction") as! NSData) as Data)
                }
                if result.value(forKey: "canComment")   != nil{
                    newDictionary["comment"] = result.value(forKey: "canComment")
                }
                if result.value(forKey: "canDelete")   != nil{
                    newDictionary["delete"] = result.value(forKey: "canDelete")
                }
                if result.value(forKey: "canShare")   != nil{
                    newDictionary["share"] = result.value(forKey: "canShare")
                }
                if result.value(forKey: "isLike")   != nil{
                    newDictionary["is_like"] = result.value(forKey: "isLike")
                }
                
                if result.value(forKey: "photo_attachment_count")   != nil{
                    newDictionary["photo_attachment_count"] = result.value(forKey: "photo_attachment_count")
                    
                }
                if result.value(forKey: "object_id")   != nil{
                    newDictionary["object_id"] = result.value(forKey: "object_id")
                }
                if result.value(forKey: "object_type")  != nil{
                    newDictionary["object_type"] = result.value(forKey: "object_type")
                }
                if result.value(forKey:"params")   != nil{
                    newDictionary["params"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"params") as! NSData) as Data)
                }
                if result.value(forKey:"object")  != nil{
                    newDictionary["object"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"object") as! NSData) as Data)
                }
                
                
                if result.value(forKey:"tags")   != nil{
                    newDictionary["tags"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"tags") as! NSData) as Data)
                    
                }
                if result.value(forKey:"action_type_body_params")   != nil{
                    newDictionary["action_type_body_params"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"action_type_body_params") as! NSData) as Data)
                }
                if result.value(forKey:"action_type_body")   != nil{
                    newDictionary["action_type_body"] = result.value(forKey:"action_type_body")
                }
                if result.value(forKey:"hashtags")  != nil{
                    newDictionary["hashtags"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"hashtags") as! NSData) as Data)
                }
                if result.value(forKey:"userTag")   != nil{
                    newDictionary["userTag"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"userTag") as! NSData) as Data)
                }
                if result.value(forKey:"decoration")   != nil{
                    newDictionary["decoration"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"decoration") as! NSData) as Data)
                }
                if result.value(forKey:"wordStyle")   != nil{
                    newDictionary["wordStyle"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"wordStyle") as! NSData) as Data)
                }
                if result.value(forKey: "publish_date")  != nil{
                    newDictionary["publish_date"] = result.value(forKey:"publish_date")
                }
                if result.value(forKey: "isNotificationTurnedOn")  != nil{
                    newDictionary["isNotificationTurnedOn"] = result.value(forKey:"isNotificationTurnedOn")
                    
                }
                if result.value(forKey: "attachment_content_type")  != nil{
                    newDictionary["attachment_content_type"] = result.value(forKey: "attachment_content_type")
                }
                
                // Update feedArray to show 1st Time Feed from Core Data Result
                feedArray.append(newDictionary)
                
            }
            
            do {
                try context.save()
            } catch _ {
            }
        }
        
    }
    
    @objc func showMassNotification(userInfo: NSNotification)
    {
        if let contentInfo = userInfo.userInfo
        {
            
            guard let aps = contentInfo[AnyHashable("aps")] as? NSDictionary, let alert = aps["alert"] as? NSDictionary, let body = alert["body"] as? String else
            {
                return
            }
            let alertBox = UIAlertController(title: "Notification", message: body, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertBox.addAction(action)
            self.present(alertBox, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Redirecting through push notification
    @objc func showContent(userInfo: NSNotification)
    {
        //let view1 =  feedObj.tableView.subviews
        
        
        if let contentInfo = userInfo.userInfo {
            let objectType = contentInfo["type"] as? String ?? ""
            let objectId  = contentInfo["id"] as? Int ?? 0
            let parentId  = contentInfo["parent_id"] as? Int
            let objectUrl = contentInfo["href"] as? String ?? ""
            let parentType = contentInfo["parent_type"] as? String ?? ""
            let video_type = contentInfo["video_type"] as? Int ?? 0
            let enable_module = contentInfo["enable_module"] as? String ?? ""
            
            
            switch (objectType){
            case "user":
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = objectId
                presentedVC.fromDashboard =  true
                self.navigationController?.pushViewController(presentedVC, animated: true)
                break
                
                //            case "activity_action":
                //                let presentedVC = FeedViewPageViewController()
                //                presentedVC.action_id = objectId
                //                navigationController?.pushViewController(presentedVC, animated: true)
                //                break
                
            case "activity_action":
                
                likeCommentContent_id = objectId
                likeCommentContentType = objectType
                let presentedVC = CommentsViewController()
                presentedVC.openCommentTextView = 1
                presentedVC.actionId = objectId
                //presentedVC.activityfeedIndex = indexPath.row
                presentedVC.activityFeedComment = true
                presentedVC.fromActivityFeed = true
                presentedVC.fromSingleFeed = true
                presentedVC.fromNotification = true
                presentedVC.commentPermission = 1
                presentedVC.reactionsIcon = []
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            case "activity_comment":
                
                likeCommentContent_id = parentId
                likeCommentContentType = parentType //"activity_action"//objectType
                let presentedVC = CommentsViewController()
                presentedVC.openCommentTextView = 1
                
                // Set to parentId. Earlier it was set to commentId. So error was comming when openening CommentViewController
                presentedVC.actionId = parentId
                //presentedVC.activityfeedIndex = indexPath.row
                presentedVC.activityFeedComment = true
                presentedVC.fromActivityFeed = true
                presentedVC.fromSingleFeed = true
                presentedVC.fromNotification = true
                presentedVC.commentPermission = 1
                presentedVC.reactionsIcon = []
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            case "blog":
                BlogObject().redirectToBlogDetailPage(self, blogId: objectId, title: "")
                break
                
            case "classified":
                ClassifiedObject().redirectToProfilePage(self, id: objectId)
                break
                
            case "music_playlist":
                MusicObject().redirectToPlaylistPage(self,id: objectId)
                break
                
            case "album":
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = objectId
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "group":
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "group"
                presentedVC.subjectId = objectId
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "siteevent_event":
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId = objectId
                self.navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "event":
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "event"
                presentedVC.subjectId = objectId
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "sitevideo_channel":
                SitevideoObject().redirectToChannelProfilePage(self, videoId: objectId,subjectType: objectType)
                print("channel")
                break
                
            case "sitepage_page":
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: objectId)
                break
                
            case "poll":
                let presentedVC = PollProfileViewController()
                presentedVC.pollId = objectId
                navigationController?.pushViewController(presentedVC, animated: false)
                break
                
            case "video":
                
                if enable_module == "sitevideo"{
                    if video_type == 3 {
                        let presentedVC = AdvanceVideoViewController()
                        //(presentedVC as NotificationViewController).showOnlyMyContent = false
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else{
                        SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: objectId,videoType:video_type,videoUrl: objectUrl)
                    }
                }
                else{
                    
                    VideoObject().redirectToVideoProfilePage(self, videoId : objectId, videoType : video_type, videoUrl : objectUrl)
                }
                break
                
            case "messages_conversation":
                let presentedVC = ConverstationViewController()
                presentedVC.displaysendername = ""
                presentedVC.conversation_id = objectId
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "sitereview_wishlist":
                
                let presentedVC = WishlistDetailViewController()
                presentedVC.subjectId = objectId
                presentedVC.wishlistName = "" // objectDictionary["title"] as! String
                presentedVC.descriptionWishlist = "" // objectDictionary["body"] as! String
                navigationController?.pushViewController(presentedVC, animated: true)
                
                break
                
            case "sitegroup_group":
                SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: objectId)
                break
                
            case "sitestore_store":
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: objectId)
                break
                
            case "sitestoreproduct_product":
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false, product_id:objectId)
                break
                
            case "sitestoreproduct_wishlist":
                let presentedVC = WishlistDetailViewController()
                presentedVC.productOrOthers = true
                presentedVC.subjectId = objectId
                presentedVC.wishlistName = "" // objectDictionary["title"] as! String
                presentedVC.descriptionWishlist = "" // objectDictionary["body"] as! String
                navigationController?.pushViewController(presentedVC, animated: true)
                
                break
                
            case "sitestoreproduct_order":
                SiteStoreObject().redirectToMyStore(viewController: self)
                break
                
            case "sitestoreproduct_review":
                let presentedVC = PageReviewViewController()
                presentedVC.mytitle = ""
                presentedVC.subjectId = objectId
                presentedVC.contentType = "product"
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "forum_topic":
                let presentedVC = ForumTopicViewController()
                let url =  objectUrl
                let arr = url.components(separatedBy: "/")
                let count = arr.count - 1
                presentedVC.slug = arr[count]
                presentedVC.topicId = objectId
                presentedVC.topicName = "" //dic!["title"] as! String
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
                //TODO: sitepage_review type notification is not being received or generated
                //            case "sitepage_review":
                //                break
                
                //TODO: sitegroup_review type notification is not being received or generated
                //            case "sitegroup_review":
                //                break
                
                //TODO: sitereview_review type notification is not being received or generated
                //            case "sitereview_review":
                //                break
                
                //TODO: sitereview_listing type notification is not being received or generated
                //            case "sitereview_listing":
                //                break
                
            default:
                let presentedVC = ExternalWebViewController()
                if objectUrl != ""{
                    presentedVC.url = objectUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                }
                break
            }
            
        }
        
    }
    
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //MARK: Protocol StoryNotUploaded
    func methodStoryNotUploadedCell(data: StoriesBrowseData) {
        if data.story_id != 0
        {
          //  print(data.gutterMenu)
            for customModel in data.gutterMenu
            {
                if let strName = customModel["name"] as? String, strName == "mute"
                {
                    let str = customModel["label"] as! String
                    if let first = str.components(separatedBy: " ").first
                    {
                        if first == "Mute"
                        {
                            storyNotUploaded.lblMuteUnmute.text = str
                            storyNotUploaded.imgMuteIcon.image = UIImage(named: "muteIcon")!.maskWithColor(color: navColor)
                            storyNotUploaded.isMute = true
                        }
                        else
                        {
                            storyNotUploaded.lblMuteUnmute.text = str
                            storyNotUploaded.imgMuteIcon.image = UIImage(named: "unmuteIcon")!.maskWithColor(color: navColor)
                            storyNotUploaded.isMute = false
                        }
                        storyNotUploaded.muteURl = customModel["url"] as! String
                    }
                }
            }
            storyNotUploaded.lblLongPressUser.text = "More Action for \(data.owner_title.capitalized)"
            storyNotUploaded.dataStory = data
            storyNotUploaded.viewNoStory.isHidden = true
            storyNotUploaded.viewMuteUnMuteStory.isHidden = false
            setViewHideShow(view: storyNotUploaded, hidden: false)
        }
        else
        {
            storyNotUploaded.updateData(data: data)
            storyNotUploaded.viewNoStory.isHidden = false
            storyNotUploaded.viewMuteUnMuteStory.isHidden = true
            setViewHideShow(view: storyNotUploaded, hidden: false)
        }

        
    }
    //MARK:- API Methods
    func API_getBrowseStories(){
        if reachability.connection != .none
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/stories/browse", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        var arrStoriesData = [StoriesBrowseData]()
                        if let dict = succeeded["body"] as? [String:AnyObject], let arrTemp = dict["response"] as? [AnyObject]
                        {
                          //  print(dict)
                            var userData = StoriesBrowseData()
                            for dicDataValue in arrTemp
                            {
                                let data = StoriesBrowseData()
                                data.story_id = dicDataValue["story_id"] as? Int ?? 0
                                data.owner_id = dicDataValue["owner_id"] as? Int ?? 0
                                data.photo_id = dicDataValue["photo_id"] as? Int ?? 0
                                data.file_id = dicDataValue["file_id"] as? Int ?? 0
                                data.duration = dicDataValue["duration"] as? Int ?? 0
                                data.view_count = dicDataValue["view_count"] as? Int ?? 0
                                data.comment_count = dicDataValue["comment_count"] as? Int ?? 0
                                data.mute_story = dicDataValue["mute_story"] as? Int ?? 0
                                data.status = dicDataValue["status"] as? Int ?? 0
                                data.total_stories = dicDataValue["total_stories"] as? Int ?? 0
                                data.owner_type_Stories = dicDataValue["owner_type"] as? String ?? ""
                                data.privacy = dicDataValue["privacy"] as? String ?? ""
                                data.description_Stories = dicDataValue["description"] as? String ?? ""
                                data.owner_title = dicDataValue["owner_title"] as? String ?? ""
                                data.image = dicDataValue["image"] as? String ?? ""
                                data.content_url = dicDataValue["content_url"] as? String ?? ""
                                data.owner_image_icon = dicDataValue["owner_image"] as? String ?? ""
                                data.videoUrl = dicDataValue["videoUrl"] as? String ?? ""
                                if let dicGutter = dicDataValue["gutterMenu"] as? [[String : Any]]
                                {
                                    data.gutterMenu = dicGutter
                                }
                                if let id = dicDataValue["owner_id"] as? Int, id == currentUserId
                                {
                                    userData = data
                                }
                                else if let id = dicDataValue["owner_id"] as? Int, id == 0
                                {
                                    userData = data
                                }
                                else
                                {
                                    arrStoriesData.append(data)
                                }
                                if let id = dicDataValue["isMute"] as? Int, id == 1
                                {
                                    data.isMute = 1
                                }
                                else
                                {
                                    data.isMute = 0
                                }
                            }
                            if userData.owner_id != 0
                            {
                                arrStoriesData.insert(userData , at: 0)
                            }
                            let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrStoriesData)
                            UserDefaults.standard.set(storiesBrowseData, forKey: "storiesBrowseData")
                            self.storiesView?.updateStoriesData(isDataUpdate: false)
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    func API_getStoryCreate(){
        if reachability.connection != .none
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/stories/create", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        if let arrTemp = succeeded["body"] as? [AnyObject]
                        {
                            var arrGetStoryCreate = [CustomFeedPostMenuData]()
                            if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetStoryCreate") as? Data {
                                if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                                    arrGetStoryCreate = arrStoriesDataTemp
                                    
                                }
                                
                            }
                            for dic in arrTemp
                            {
                                if let label = dic["label"] as? String, label == "View Privacy", let multiOptions = dic["multiOptions"] as? [String : String]
                                {
                                    for (key, value) in multiOptions
                                    {
                                        let data = CustomFeedPostMenuData()
                                        data.key = "\(key)"
                                        data.value = "\(value)"
                                        if !arrGetStoryCreate.contains(where: { $0.value == data.value }) {
                                            arrGetStoryCreate.append(data)
                                        }
                                    }
                                }
                            }
                            let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetStoryCreate)
                            UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetStoryCreate")
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                
                            }
                        }
                    }
                    
                })
                
            }
        }
    }
    func API_getFeedPostMenus(){
        
        if postPermission.count != 0
        {
            if  let privacy = postPermission["userprivacy"] as? NSDictionary
            {
                var arrGetFeedPostMenus = [CustomFeedPostMenuData]()
                if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetFeedPostMenus") as? Data {
                    if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                        arrGetFeedPostMenus = arrStoriesDataTemp
                        
                    }
                    
                }
                
                for (key, value) in privacy
                {
                    let data = CustomFeedPostMenuData()
                    data.key = "\(key)"
                    data.value = "\(value)"
                    if !arrGetFeedPostMenus.contains(where: { $0.value == data.value }) {
                        arrGetFeedPostMenus.append(data)
                    }
                }
                let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetFeedPostMenus)
                UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetFeedPostMenus")
                
            }
            
        }
    }
    func API_CheckVideoSize()
    {
        if reachability.connection != .none
        {
            let path = "get-server-settings"
            let parameters = [String:String]()
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                //  DispatchQueue.main.async(execute: {
                
                if msg
                {
                    if let response = succeeded["body"] as? NSDictionary
                    {
                        if  let videoSize = response["upload_max_size"] as? String
                        {
                            var name = videoSize
                            name.remove(at: name.index(before: name.endIndex))
                            UserDefaults.standard.set(name, forKey: "videoSize")
                            UserDefaults.standard.synchronize()
                            
                        }
                        if  let videoSize = response["rest_space"] as? Int
                        {
                            UserDefaults.standard.set(videoSize, forKey: "rest_space")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
                else
                {
                    UserDefaults.standard.removeObject(forKey: "rest_space")
                    UserDefaults.standard.removeObject(forKey: "videoSize")
                    UserDefaults.standard.synchronize()
                }
                // })
            }
        }
    }
    func saveFileInDocumentDirectoryForStory(_ images :[AnyObject], data : Data) ->([String]){
        var getImagePath = [String]()
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        var i = 0
        for image in images{
            i += 1
            var filename = ""
            if image is URL{
                if let str = (image as? URL)?.lastPathComponent
                {
                    filename = "\(str)" // "\((image as! URL).lastPathComponent)"
                }
            }else{
                let tempImageString = randomStringWithLength(8)
                filename = "\(tempImageString)\(i).png"
            }
            let filePathToWrite = "\(paths)/\(filename)"
            //print(filePathToWrite)
            if fileManager.fileExists(atPath: filePathToWrite){
                removeFileFromDocumentDirectoryAtPath(filePathToWrite)
            }
            
            var imageData: Data?
            if image is URL{
                //print("video case")
                if image is URL
                {
                    imageData = data//try? Data(contentsOf: imageT)
                }
                else if let imageT = image as? UIImage
                {
                    imageData =  UIImageJPEGRepresentation(imageT, 0.7)
                }
                
            }else{
                // imageData = UIImagePNGRepresentation(image as! UIImage)
                if image is UIImage
                {
                    imageData =  UIImageJPEGRepresentation(image as! UIImage, 0.7)
                }
                //print("length \(imageData.count)")
                
            }
            fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
            getImagePath.append(paths.stringByAppendingPathComponent("\(filename)"))
            
        }
        
        return getImagePath;
    }
    func API_shareStory()
    {
        
        // Check Internet Connection
        if reachability.connection != .none
        {
            var parameters = [String : AnyObject]()
            var filePathKey = ""
            var sinPhoto = true
            if let asset = arrSelectedAssests[0] as? TLPHAsset, asset.isVideoSelected == true
            {
                var arryVideo = [AnyObject]()
                filePathKey = "filedata"
                sinPhoto = true
                parameters = ["type" : "3" as AnyObject , "post_attach" : "1" as AnyObject, "description" : asset.strDescription as AnyObject, "privacy" : strPrivacykey as AnyObject, "duration" :  asset.videoDuration as AnyObject]
                mediaType = "video"
                arryVideo.append(asset.strVideoPath as AnyObject)
                arryVideo.append(asset.fullResolutionImage as AnyObject)
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectoryForStory(arryVideo, data: asset.videoData)
            }
            else
            {
                var arrImages = [UIImage]()
                mediaType = "image"
                filePathKey = "photo"
                for (index,asset) in arrSelectedAssests.enumerated()
                {
                    arrImages.append(asset.imgFinalPassAPI)
                    if index == 0
                    {
                        parameters["description"] = asset.strDescription as AnyObject
                        parameters["photo"] = "photo" as AnyObject
                        parameters["privacy"] = strPrivacykey as AnyObject
                    }
                    else
                    {
                        parameters["description\(index)"] = asset.strDescription as AnyObject
                        parameters["photo_\(index)"] = "photo" as AnyObject
                        parameters["privacy"] = strPrivacykey as AnyObject
                    }
                    
                }
                if arrImages.count>1
                {
                    sinPhoto = false
                }
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(arrImages)
            }
            
            isStoryUploadingCompleted = false
            let path = "advancedactivity/stories/create"
            postActivityForm(parameters, url: path, filePath: filePathArray, filePathKey: filePathKey, SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    isStoryUploadingCompleted = true
                    if msg{
                        self.API_getBrowseStories()
                        for path in filePathArray{
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        filePathArray.removeAll(keepingCapacity: false)
                        if isStoryPost == true
                        {
                            self.API_postStory()
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your story and feed posted successfully.",comment: ""), duration: 3, position: "bottom")
                        }
                        else
                        {
                            isStoryShare = false
                            arrSelectedAssests.removeAll()
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your story posted successfully.",comment: ""), duration: 3, position: "bottom")
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    func API_postStory()
    {
        isStoryUploadingCompleted = true
        
        // Check Internet Connection
        if reachability.connection != .none {
            if let asset = arrSelectedAssests[0] as? TLPHAsset, asset.isVideoSelected == false
            {
                API_postStoryImage()
            }
            else
            {
                API_postStoryVideo()
            }
        }
        else
        {
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
        
    }
    func API_postStoryImage()
    {
        var arrImages = [UIImage]()
        var parameters = [String : AnyObject]()
        for (_,asset) in arrSelectedAssests.enumerated()
        {
            arrImages.append(asset.imgFinalPassAPI)
        }
        parameters["type"] = "photo" as AnyObject
        parameters["body"] = "" as AnyObject
        parameters["auth_view"] = strPostkey as AnyObject
        parameters["post_attach"] = "1" as AnyObject
    //    print(parameters)
        mediaType = "image"
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectory(arrImages)
        let path = "advancedactivity/feeds/post"
        var sinPhoto = true
        if arrImages.count>1
        {
            sinPhoto = false
        }
        postActivityForm(parameters, url: path, filePath: filePathArray, filePathKey: "photo", SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.refresh()
                    for path in filePathArray{
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                    filePathArray.removeAll(keepingCapacity: false)
                    arrSelectedAssests.removeAll()
                    if isStoryShare == false
                    {
                        isStoryShare = false
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your feed posted successfully.",comment: ""), duration: 3, position: "bottom")
                    }
                    
                    
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                    }
                }
            })
            
        }
    }
    // Create video calling
    func API_postStoryVideo(){
        
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        var parameters = [String:AnyObject]()
        parameters = ["title": "" as AnyObject,"auth_view": strPostkey as AnyObject,"type" : "3" as AnyObject , "post_attach" : "1" as AnyObject ]
        var path = ""
        if enabledModules.contains("sitevideo"){
            path = "advancedvideos/create"
        }
        else{
            path = "videos/create"
        }
        mediaType = "video"
        let asset = arrSelectedAssests[0]
        var arryVideo = [AnyObject]()
        arryVideo.append(asset.strVideoPath as AnyObject)
        filePathArray.removeAll(keepingCapacity: false)
     
        filePathArray = saveFileInDocumentDirectoryForStory(arryVideo, data: asset.videoData)
        
        postActivityForm(parameters as Dictionary<String, AnyObject>, url: path, filePath: filePathArray, filePathKey: "filedata", SinglePhoto: true){ (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.refresh()
                    for path in filePathArray{
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                    filePathArray.removeAll(keepingCapacity: false)
                    arrSelectedAssests.removeAll()
                    if isStoryShare == false
                    {
                        isStoryShare = false
                        UIApplication.shared.keyWindow?.makeToast( NSLocalizedString("Your video is in queue to be processed - you will be notified when it is ready to be viewed.", comment: ""), duration: 5, position: "bottom")
                    }
                    
                    
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                    }
                }
            })
            
        }
    }
}

public func isVisible(view: UIView) -> Bool {
    
    if view.window == nil {
        return false
    }
    
    var currentView: UIView = view
    while let superview = currentView.superview {
        
        if (superview.bounds).intersects(currentView.frame) == false {
            return false;
        }
        
        if currentView.isHidden {
            return false
        }
        
        currentView = superview
    }
    
    return true
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

