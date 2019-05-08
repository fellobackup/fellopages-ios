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

//  AlbumProfileViewController.swift
import UIKit
import NVActivityIndicatorView
var updateFromAlbum = false

class AlbumProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate , UITabBarControllerDelegate{

    var gutterMenu: NSArray = []                          // Array for Gutter Menu
    var ownerIcon : UIButton!
    var albumTitle: UILabel!
    var albumId :Int!
    var imgUser : UIImageView!
    var ownerName : UILabel!
    var user_id : Int!
    var selectedMoreLess:Bool = false
    var bottomView:UIView!
    var headerView : UIView!
    var headerImageView : UIImageView!
    var headerTitle : TTTAttributedLabel!
    var albumViewTile : UILabel!
    var albumCreatedOn : UILabel!
    var topView : UIView!
    var profileImageUrlString : String!
    var headerImage1 : UIImageView!
    var albumName:String!
    var ownerTitle:String!
    var popAfterDelay:Bool!
    var albumInfo : TTTAttributedLabel!
    //var allPhotos = [AnyObject]()
    var albumPhotoTableView:UITableView!
    var dynamicHeight:CGFloat = 100
    var photos:[PhotoViewer] = []
    var descriptionResult: String!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var isPageRefresing = false
    var updateScrollFlag = true
    var refresher:UIRefreshControl!
    var showSpinner = true
    var deleteAlbum: Bool!
    var descView : TTTAttributedLabel!
    var like_comment : UIView!
    var height : CGFloat = 0
 //   var imageCache = [String:UIImage]()
 //   var imageCache1 = [String:UIImage]()
    var lastContentOffset: CGFloat = 0
    var showNavColor = false
    var photoId : Int!
    var contentType = ""
    var urlPath = ""
    var pageId : Int!
    var marqueeHeader : MarqueeLabel!
    var contentId: Int!
    var leftBarButtonItem : UIBarButtonItem!
    var groupId : Int!
    var contentDescription : String!
    var coverImageUrl : String!
    var rightBarButtonItem : UIBarButtonItem!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var subjectType : String!
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        popAfterDelay = false
        deleteAlbum = false
        refreshPhotos = true
        albumUpdate = false
        subjectType = "album"
        self.tabBarController?.delegate = self

        removeNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AlbumProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        
        // Set Album Title
        albumTitle = createLabel(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - 2*PADING, height: 100), text: "", alignment: .left, textColor: textColorDark)
        albumTitle.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
        albumTitle.longPressLabel()
        albumTitle.isHidden = true
        view.addSubview(albumTitle)
        
        // Set ownerIcon
        ownerIcon = createButton(CGRect(x: PADING, y: albumTitle.bounds.height + albumTitle.frame.origin.y + contentPADING, width: ButtonHeight, height: ButtonHeight), title: "", border: true,bgColor: false, textColor: textColorLight)
        ownerIcon.layer.cornerRadius = cornerRadiusNormal
        ownerIcon.layer.masksToBounds = true
        ownerIcon.isHidden = true
        view.addSubview(ownerIcon)
        
        // Set albumInfo Detail
        albumInfo = TTTAttributedLabel(frame:CGRect(x: PADING + contentPADING + ownerIcon.bounds.width , y: ownerIcon.frame.origin.y, width: view.bounds.width - (PADING + contentPADING + ownerIcon.bounds.width) , height: 200) )
        albumInfo.numberOfLines = 0
        albumInfo.delegate = self
        albumInfo.longPressLabel()
        albumInfo.isHidden = true
        view.addSubview(albumInfo)
        
        let frame1 = CGRect(x: 0, y: 0 , width: self.view.frame.size.width, height: view.bounds.height  - tabBarHeight + 5)
        albumPhotoTableView = UITableView(frame: frame1, style: .grouped)
        albumPhotoTableView.register(PhotoViewCell.self, forCellReuseIdentifier: "Cell")
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width-30)/4
        }else{
            size = (UIScreen.main.bounds.width-15)/2
        }
        self.dynamicHeight = size
        
        albumPhotoTableView.rowHeight = size
        albumPhotoTableView.dataSource = self
        albumPhotoTableView.delegate = self
        albumPhotoTableView.bounces = false
        albumPhotoTableView.backgroundColor = tableViewBgColor
        albumPhotoTableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.albumPhotoTableView.contentInsetAdjustmentBehavior = .never
            self.albumPhotoTableView.estimatedRowHeight = 0
            self.albumPhotoTableView.estimatedSectionHeaderHeight = 0
            self.albumPhotoTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(albumPhotoTableView)

        headerView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 340))
        albumPhotoTableView.addSubview(headerView)
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 270)
        headerImageView = CoverImageViewWithGradient(frame: frame)
        headerImageView.backgroundColor = placeholderColor
        headerImageView.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(AlbumProfileViewController.onImageViewTap))
        headerImageView.addGestureRecognizer(tap1)
        headerView.addSubview(headerImageView)
        headerTitle = TTTAttributedLabel(frame:CGRect(x: 10, y: 170, width: view.bounds.width - 50 , height: 60))
        headerTitle.font = UIFont(name: fontName, size: 30.0)
        headerTitle.longPressLabel()
        headerTitle.numberOfLines = 2
        headerTitle.delegate = self
        headerImageView.addSubview(headerTitle)
        
        
        albumViewTile = createLabel(CGRect(x: view.bounds.width - 60, y: 245, width: 55, height: 20), text: "", alignment: .left, textColor: textColorLight)
        albumViewTile.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        albumViewTile.longPressLabel()
        headerImageView.addSubview(albumViewTile)
        
        albumCreatedOn = createLabel(CGRect(x: 10, y: 245, width: view.bounds.width - 80, height: 20), text: "", alignment: .left, textColor: textColorLight)
        albumCreatedOn.font = UIFont(name: fontName, size: FONTSIZESmall)
        //        albumCreatedOn.backgroundColor = UIColor.green
        headerImageView.addSubview(albumCreatedOn)
       
        
        topView = createView(CGRect(x: 0, y: headerImageView.bounds.height, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        headerView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AlbumProfileViewController.openProfile))
        topView.addGestureRecognizer(tap)
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        ownerName.longPressLabel()
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser)
        
        descView = TTTAttributedLabel(frame: CGRect(x: 2*PADING,  y: headerImageView.bounds.height + 70 + 15 , width: view.bounds.width - 4*PADING, height: 0))
        descView.delegate = self
        descView.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        //descView.backgroundColor = lightBgColor
        descView.numberOfLines = 0
        descView.longPressLabel()
        self.descView.font = UIFont(name: fontName, size: FONTSIZENormal)
        headerView.addSubview(descView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(AlbumProfileViewController.refresh), for: UIControl.Event.valueChanged)
        albumPhotoTableView.addSubview(refresher)
        
        likeCommentContent_id = albumId
        if self.contentType == "sitepage_photo"{
            likeCommentContentType = "sitepage_photo"
        }
        else{
            likeCommentContentType = "album"
        }
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumPhotoTableView.tableFooterView = footerView
        albumPhotoTableView.tableFooterView?.isHidden = true
 
    }
    override func viewDidAppear(_ animated: Bool)
    {
        like_CommentStyle = 1
        if (showNavColor == true)
        {

            setNavigationImage(controller: self)
            
        }
        else
        {
            removeNavigationImage(controller: self)
        }
        if refreshPhotos == true || updateFromAlbum == true{
            refreshPhotos = false
            updateFromAlbum = false
            exploreAlbum()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 40, y: 0, width: navigationBar.frame.width - 80, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
            
        }
        if (showNavColor == true){
            setNavigationImage(controller: self)
        }else{
            removeNavigationImage(controller: self)
        }
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        
        if timer{
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
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if reachability.connection != .none {
            showSpinner = false
            pageNumber = 1
            exploreAlbum()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
    }
    
    func updateAlbum(_ url : String){
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
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }
            
            // Send Server Request to Explore Album Contents with Album_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Album Detail
                        // Update Album Detail
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        if self.deleteAlbum == true{
                            feedUpdate = true
                            albumUpdate = true
                            self.popAfterDelay = true
                            self.createTimer(self)
                            return
                        }
                        self.exploreAlbum()
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
            showAlertMessage(view.center , msg: network_status_msg, timer: false)
        }
        
    }
    
    // Present Feed Gutter Menus
    @objc func showGutterMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if (dic["name"] as! String != "share")
                {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            if  dic["name"] as! String ==  "delete"{
                                
                                // Confirmation Alert
                                displayAlertWithOtherButton(NSLocalizedString("Delete Album", comment: ""),message: NSLocalizedString("Are you sure you want to delete this album?",comment: "") , otherButton: NSLocalizedString("Delete Album", comment: "")) { () -> () in
                                    self.deleteAlbum = true
                                    self.updateAlbum(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                    }
                    else
                    {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            if dic["name"] as! String == "add" {
                                let presentedVC = UploadPhotosViewController()
                                presentedVC.directUpload = false
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                            if dic["name"] as! String == "addphoto" {
                                let presentedVC = UploadPhotosViewController()
                                presentedVC.directUpload = false
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = [ : ]
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                            if dic["name"] as! String == "albumofday" {
                                let presentedVC = FormGenerationViewController()
                                isCreateOrEdit = true
                                presentedVC.url = dic["url"] as! String
                                presentedVC.formTitle = NSLocalizedString(" Make Album of the Day", comment: "")
                                presentedVC.param = [ : ]
                                presentedVC.contentType = "Page"
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            }
                            
                            if dic["name"] as! String == "featured" ||  dic["name"] as! String == "unfeatured"{
                                
                                self.updateAlbum(dic["url"] as! String)
                                
                            }
                            
                            if  dic["name"] as! String == "edit"{
                                
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Album Settings", comment: "")
                                presentedVC.contentType = "album"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            }
                            if  dic["name"] as! String == "report"
                            {
                                //confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
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
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    @objc func shareItem()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.albumName
            if (self.contentDescription != nil) {
                pv.ShareDescription = self.contentDescription
            }
            pv.imageString = self.profileImageUrlString
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.albumName {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.coverImageUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
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
    // MARK: - Server Connection For Album Profile
    func exploreAlbum(){
        // Check Internet Connection
        
        if reachability.connection != .none {
            removeAlert()
            if (self.pageNumber == 1){
                allPhotos.removeAll(keepingCapacity: false)
            }
            
            if (showSpinner){
             //   spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            

            switch(contentType)
            {
                case "sitepage_photo":
                    urlPath = "sitepage/photos/viewalbum/\(pageId!)/\(albumId!)"
                case "sitestore_photo":
                    urlPath = "sitestore/photos/view-album/" + String(contentId)
                case "sitegroup_photo":
                     urlPath = "advancedgroups/photos/viewalbum/\(groupId!)/\(albumId!)"
                
                default:
                    urlPath = "albums/album/view"
                    break

            }
            
            
            // Send Server Request to Explore Group Contents with Group_ID
            post(["gutter_menu": "1", "profile_tabs" : "1", "album_id" : String(albumId), "limit" :"\(limit)", "page" : "\(pageNumber)"] , url: "\(urlPath)", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true

                    if msg{
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                self.isPageRefresing = false
                                // Update Content Gutter Menu
                                if let response = body["album"] as? NSDictionary{
                                    
                                    self.albumName = response["title"] as? String
                                    self.headerTitle.textColor = textColorLight

                                    if self.albumName.length < 15{
                                        self.headerTitle.frame.origin.y   = 210
                                    }
                                    if self.albumName.length > 18{
                                        self.headerTitle.frame.origin.y   = 170
                                    }
                                    if self.albumName.length > 45{
                                        self.headerTitle.frame.origin.y   = 130
                                    }
                                    
                                    self.headerTitle.setText( self.albumName, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                                        // TODO: Clean this up...
                                        return mutableAttributedString
                                    })
                                    self.headerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.headerTitle.sizeToFit()
                                    
                                    self.headerTitle.frame.origin.y = self.headerImageView.bounds.height-(self.headerTitle.bounds.size.height + 30)
                                    
                                    self.user_id = response["owner_id"] as? Int
                                    if let views = response["view_count"] as? Int{
                                        self.albumViewTile.text = " \(views) \(viewIcon)"
                                    }else if let views = response["view_count"] as? String{
                                        self.albumViewTile.text = " \(views) \(viewIcon)"
                                    }
                                    
                                    self.ownerName.text = response["owner_title"] as? String
                                    self.descView.text = response["description"] as? String
                                    if (response["description"] as? String == "")
                                    {
                                        self.descView.frame.size.height = 0
                                        self.height = getBottomEdgeY(inputView: self.headerView)+10
                                    }
                                    else
                                    {
                                        let description = response["description"] as? String
                                        self.contentDescription = description
                                        self.descView.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            
                                            // TODO: Clean this up...
                                            return mutableAttributedString
                                        })
                                        self.descView.sizeToFit()
                                        //self.descView.textAlignment = .center
                                        self.descView.textAlignment = .justified
                                        self.headerView.frame.size.height = self.headerView.frame.size.height + self.descView.frame.size.height - 20
                                        self.height = getBottomEdgeY(inputView: self.headerView)+15
                                    }
                                    self.descriptionResult = response["description"] as? String
                                    
                                    if let postedDate = response["creation_date"] as? String
                                    {
                                        let postedOn = dateDifference(postedDate)
                                        self.albumCreatedOn.text = "\(postedOn)"
                                    }
                                    
                                    self.ownerTitle = response["owner_title"] as? String
                                    self.profileImageUrlString = response["image"] as! String
                                    let profileImageUrl = URL(string: response["image"] as! String)
                                    if  profileImageUrl != nil {
                                        self.headerImageView.kf.indicatorType = .activity
                                        (self.headerImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.headerImageView.kf.setImage(with: profileImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            
                                        })

                                    }
                                    
                                    
                                    let ownerImageUrl = URL(string: response["owner_image_normal"] as! String)
                                    self.coverImageUrl = response["owner_image_normal"] as! String
                                    
                                    if  ownerImageUrl != nil {
                                        self.imgUser.kf.indicatorType = .activity
                                         (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.imgUser.kf.setImage(with: ownerImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                          
                                        })
                                    }
                                    var description = ""
                                    if let ownerName = response["owner_title"] as? String {
                                        description = "\(ownerName)\n"
                                        
                                        if let postedDate = response["creation_date"] as? String{
                                            let postedOn = dateDifference(postedDate)
                                            description += postedOn
                                            description += "\n"
                                            
                                            let viewCount = response["view_count"] as? Int
                                            var viewInfo = ""
                                            viewInfo =  singlePluralCheck( NSLocalizedString(" view", comment: ""),  plural: NSLocalizedString(" views", comment: ""), count: viewCount!)
                                            
                                            
                                            description += "\(viewInfo)"
                                            self.albumInfo.textColor = textColorMedium
                                            self.albumInfo.font = UIFont(name: fontName, size: FONTSIZESmall)
                                            self.albumInfo.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                var boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)

                                                
                                                boldFont =  CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                                                
                                                let range1 = (description as NSString).range(of: ownerName)
                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)

                                                
                                                // TODO: Clean this up...
                                                
                                                return mutableAttributedString
                                            })
                                        }
                                    }
                                }
                                
                                
                                if let menu = body["gutterMenu"] as? NSArray
                                {
                                    self.gutterMenu = menu
                                    let menu = UIBarButtonItem(title:optionIcon, style: UIBarButtonItem.Style.plain , target:self , action: #selector(AlbumProfileViewController.showGutterMenu))

                                    menu.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], for: UIControl.State())
                                    self.navigationItem.rightBarButtonItem = menu
                                    
                                }
                                var isCancel = false
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary
                                    {
                                        if tempDic["name"] as! String == "share"
                                        {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                    }
                                }
                                if let images = body["albumPhotos"] as? NSArray{
                                    allPhotos  = allPhotos + (images as! [NSDictionary])
                                   // allPhotos = allPhotos + (images as [AnyObject])
                                }
                                self.totalItems = body["totalPhotoCount"] as! Int
                                if self.totalItems < 3
                                {
                                    self.albumPhotoTableView.frame.size.height -= 35
                                }
                                if logoutUser == false
                                {
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(AlbumProfileViewController.shareItem), for: .touchUpInside)
                                    if (self.shareUrl != nil)
                                    {
                                      rightNavView.addSubview(shareButton)
                                    }
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(AlbumProfileViewController.showGutterMenu), for: .touchUpInside)
                               
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                }
                                
                            }
                        }
                        
                        self.albumPhotoTableView.reloadData()
                        
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil
                        {
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg, timer: false)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    //set Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size:CGFloat = 0
        size = (UIScreen.main.bounds.width-15)/2
        return size + 10
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return height
        
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return Int(ceil(Float(allPhotos.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = lightBgColor
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 2
        if allPhotos.count > index {
            // cell.image1.imageView?.image = nil
             cell.photo1.image = UIImage(named : "default.png")
            let photoInfo = allPhotos[index] 

            cell.image1.isHidden = false
            cell.photo1.isHidden = false
            cell.photo1.backgroundColor = placeholderColor
            if let url1 = URL( string:photoInfo["image"] as! NSString as String){
                cell.photo1.kf.indicatorType = .activity
                (cell.photo1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo1.kf.setImage(with: url1, placeholder: UIImage(named : "default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image1.tag = index
                    cell.image1.addTarget(self, action: #selector(AlbumProfileViewController.openImage(_:)), for: .touchUpInside)
                    cell.image1.contentMode = UIView.ContentMode.scaleAspectFill
                })
            }
        }
        else{
            cell.image1.isHidden = true
            cell.image2.isHidden = true
            cell.photo1.isHidden = true
            cell.photo2.isHidden = true
            return cell
        }
        
        if allPhotos.count > (index + 1){
            cell.image2.imageView?.image = UIImage(named : "default.png")
            let photoInfo = allPhotos[index + 1] 
            
            cell.image2.isHidden = false
            cell.photo2.isHidden = false
            cell.photo2.backgroundColor = placeholderColor
            //cell.photo2.image = nil
            if let url1 = URL(string: photoInfo["image"] as! String){
                cell.photo2.kf.indicatorType = .activity
                (cell.photo2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo2.kf.setImage(with: url1, placeholder: UIImage(named : "default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image2.tag = index+1
                    cell.image2.addTarget(self, action: #selector(AlbumProfileViewController.openImage(_:)), for: .touchUpInside)
                    cell.image2.contentMode = UIView.ContentMode.scaleAspectFill
                })

            }
        }
        else
        {
            cell.image2.isHidden = true
            cell.photo2.isHidden = true
            
            return cell
        }
        return cell
    }
    @objc func openImage(_ sender:UIButton){
        
        let photoInfo = allPhotos[sender.tag] 
        let openingImage = photoInfo["image"] as! String
        let presentedVC = AdvancePhotoViewController()
        presentedVC.allPhotos = allPhotos
        presentedVC.photoID = sender.tag
        presentedVC.imageUrl = openingImage
        switch(contentType){
        case "sitepage_photo":

           // presentedVC.url = "sitepage/photos/viewalbum-data/" + String(pageId) + "/" + String(albumId)
            presentedVC.photoType = "sitepage_photo"
            presentedVC.param = ["subject_type":"sitepage_album","subject_id":String(albumId)]
        case "sitestore_photo":
           // presentedVC.url = "sitestore/photos/view-photo/" + String(contentId)
            presentedVC.param = ["subject_type":"sitestore_album","subject_id":String(albumId)]
            presentedVC.photoType = "sitestore_photo"
        case "sitegroup_photo":
            //presentedVC.url = "advancedgroups/photos/viewalbum/" + String(groupId) + "/" + String(albumId)
            presentedVC.photoType = "sitegroup_photo"
            presentedVC.param = ["subject_type":"sitegroup_album","subject_id":String(albumId)]
            presentedVC.groupId = groupId

        default:
            presentedVC.photoType = "photo"
            presentedVC.param = ["subject_type":"album","subject_id":String(albumId)]
            presentedVC.photoLimit = limit
            break
            
        }
        presentedVC.photoForViewer = photos
        presentedVC.total_items = totalItems
        presentedVC.attachmentID = albumId
        presentedVC.albumTitle = albumName
        presentedVC.ownerTitle = ownerTitle
        
        self.navigationController?.pushViewController(presentedVC, animated: false)

    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if (!isPageRefresing  && limit*pageNumber < totalItems){
                if reachability.connection != .none {
                    updateScrollFlag = false
                    pageNumber += 1
                    isPageRefresing = true
                    albumPhotoTableView.tableFooterView?.isHidden = false
                    exploreAlbum()
                }
            }
            else
            {
                albumPhotoTableView.tableFooterView?.isHidden = true
            }

        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollviewEmojiLikeView.isHidden = true
        //if updateScrollFlag{
        // Check for Page Number for Browse Album
//        if  albumPhotoTableView.contentOffset.y >= albumPhotoTableView.contentSize.height - albumPhotoTableView.bounds.size.height{
//            if (!isPageRefresing  && limit*pageNumber < totalItems){
//                if reachability.connection != .none {
//                    updateScrollFlag = false
//                    pageNumber += 1
//                    isPageRefresing = true
//                    exploreAlbum()
//                }
//            }
//            
//        }
        let scrollOffset = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.frame.size.height / 2
        
        if (scrollOffset > 60.0){
            showNavColor = true
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.marqueeHeader.text = self.albumName
            self.marqueeHeader.alpha = barAlpha
            self.marqueeHeader.textColor = textColorPrime
            self.navigationController?.navigationBar.alpha = barAlpha
            self.headerTitle.alpha = 1-barAlpha
            self.albumViewTile.alpha = 1-barAlpha
            self.albumCreatedOn.alpha = 1-barAlpha
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
                self.like_comment.fadeIn()
            }
            else if ((self.lastContentOffset < scrollView.contentOffset.y) && (scrollView.contentOffset.y < scrollViewHeight - 5 )){
                // move down
                self.like_comment.fadeOut()
            }
            
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
            
        }else{
            showNavColor = false
            let barAlpha = max(0, min(1, (scrollOffset/155)))

            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = barAlpha
            self.headerTitle.alpha = 1-barAlpha
            self.albumViewTile.alpha = 1-barAlpha
            self.albumCreatedOn.alpha = 1-barAlpha
            self.like_comment.alpha = 1
            
            if (scrollOffset < 10.0){
                self.marqueeHeader.alpha = 0
                self.headerTitle.alpha = 1
                self.albumViewTile.alpha = 1
                self.albumCreatedOn.alpha = 1
                self.headerTitle.font = UIFont(name: fontName, size: 30.0)
            }
        }
    }
    
    func moreOrLess(){
        if let description = descriptionResult{
            var tempInfo = ""
            if description != ""  {
                let tempTextLimit =  descriptionTextLimit
                if description.length > tempTextLimit{
                    if self.selectedMoreLess == false{
                        tempInfo += (description as NSString).substring(to: tempTextLimit-3)
                        tempInfo += NSLocalizedString("... more",  comment: "")
                        self.headerView.frame.size.height =  440
                    }else{
                        tempInfo += description
                        tempInfo += NSLocalizedString("... less",  comment: "")
                        self.headerView.frame.size.height = 440 + descView.bounds.height
                        
                        
                    }
                }else{
                    tempInfo += description
                    self.headerView.frame.size.height = 350
                    
                    
                }
            }
            self.descView.numberOfLines = 0
            self.descView.delegate = self
            self.descView.font = UIFont(name: fontName, size: 14)

            self.descView.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                let range2 = (tempInfo as NSString).range(of: NSLocalizedString("more",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range2)
                let range1 = (tempInfo as NSString).range(of: NSLocalizedString("less",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range1)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)

                return mutableAttributedString
            })
            self.descView.sizeToFit()
            let range = (tempInfo as NSString).range(of: NSLocalizedString("more",  comment: ""))
            self.descView.addLink(toTransitInformation: [ "type" : "moreContentInfo"], with:range)
            let range1 = (tempInfo as NSString).range(of: NSLocalizedString("less",  comment: ""))
            self.descView.addLink(toTransitInformation: ["type" : "lessContentInfo"], with:range1)
            self.descView.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "moreContentInfo":
            selectedMoreLess = true
            self.moreOrLess()
            albumPhotoTableView.reloadData()
            
        case "lessContentInfo":
            selectedMoreLess = false
            self.moreOrLess()
            albumPhotoTableView.reloadData()
        default:
            print("error")
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        albumPhotoTableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        setNavigationImage(controller: self)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    @objc func goBack(){

        if conditionalProfileForm == "BrowsePage"
        {
            albumUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: true)

        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)

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
    
    @objc func onImageViewTap(){
        if self.profileImageUrlString != nil && self.profileImageUrlString != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.profileImageUrlString
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
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
