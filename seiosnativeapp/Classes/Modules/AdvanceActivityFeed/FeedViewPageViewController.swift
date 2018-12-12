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

//  ConverstationViewController.swift
//  seiosnativeapp

import UIKit
var singleFeed:Bool = false
class FeedViewPageViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate,TTTAttributedLabelDelegate {

    
    let mainView = UIView()
    var activity_id: Int!
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation                   // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var action_id : Int!
    var feedArray1 = [AnyObject]()
    var noCommentMenu:Bool = false
   // var imageCache = [String:UIImage]()
   // var userImageCache = [String:UIImage]()
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var UserId:Int!
    var actionIdArray = [Int]()
    var titleLabel = UILabel()
    var navView = UIView()
    var feedObj = FeedTableViewController()
    let subscriptionNoticeLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    

    var popAfterDelay = false
    var leftBarButtonItem : UIBarButtonItem!
    var delegate:refresh?

    // Initialize Class
    override func viewDidLoad() {
        
        tableViewFrameType = "FeedViewPageViewController"
        view.backgroundColor = aafBgColor
        navigationController?.navigationBar.isHidden = false
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = aafBgColor
        view.addSubview(mainView)
        
        searchDic.removeAll(keepingCapacity: false)
        self.title = NSLocalizedString("\(app_title)", comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(FeedViewPageViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        
        // Initial table to show Activity Feeds
        feedObj.willMove(toParentViewController: self)
        self.view.addSubview(feedObj.view)
        self.addChildViewController(feedObj)
        feedArray1.removeAll(keepingCapacity: false)
   
        browseFeed()
        
    }
    
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool) {
        
        tableViewFrameType = "FeedViewPageViewController"
        self.browseEmoji(contentItems: reactionsDictionary)
        navView.frame = CGRect(x: 30, y: 0, width: 150, height: 44)
        setNavigationImage(controller: self)
        if feedUpdate == true
        {
            // Set Default & request to hard Refresh
            self.feedObj.refreshLikeUnLike = true
            feedObj.tableView.reloadData()
            feedUpdate = false
            feedArray1.removeAll(keepingCapacity: false)
            browseFeed()
        }
        
    }
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
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
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
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
            feedArray1.append(newDictionary)
            
        }
        if logoutUser == false
        {
            globalFeedHeight = 0
        }
        else
        {
            globalFeedHeight = 0 
        }
        self.feedObj.globalArrayFeed = feedArray1
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    func browseFeed(){
        singleFeed = true
        // Check Internet Connectivity
        if reachability.connection != .none {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
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
            
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","action_id": String(self.action_id),"object_info":"1","getAttachedImageDimention":"0"]
            
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    // On Success Update Feeds
                    if msg
                    {
                        
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{

                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update feedArray
                                    self.updateFeedsArray(self.activityFeeds)
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

                                else if response["data"] as? String == ""{
                                    self.view.makeToast("This feed has been deleted", duration: 5, position: "bottom")
                                    notificationUpdate = true
                                    self.popAfterDelay = true
                                    self.createTimer(self)
                                }
                            }
                    
                            
                            // Set Label If their is no feed in response
                            if self.feedArray1.count == 0 {
                                self.mainView.makeToast(NSLocalizedString("There are no more posts to show.",  comment: ""), duration: 5, position: "bottom")
                            }
                            
                            
                            // Reload Tabel After Updation
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                        }
                        
                    }else{
                        
                        self.updateScrollFlag = true
                    }
                })
            }
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
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
                emoji.addTarget(self, action: #selector(FeedViewPageViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                emoji.tag = v["reactionicon_id"] as! Int
                let imageUrl = icon["reaction_image_icon"] as? String
                
                
                let url = NSURL(string:imageUrl!)
                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
                scrollViewEmoji.addSubview(emoji)
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
        
        let feed = feedArray1[scrollViewEmoji.tag] as! NSDictionary
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
    


    override func viewWillDisappear(_ animated: Bool) {

        titleLabel.text = ""

    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        mainView.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
             _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
}

