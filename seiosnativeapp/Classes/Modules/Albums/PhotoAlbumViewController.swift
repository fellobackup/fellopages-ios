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
//  AlbumPhotoViewController.swift
//  seiosnativeapp

import UIKit
import NVActivityIndicatorView

var allPhotos = [NSDictionary]()

class PhotoAlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    var canCreate : Bool =  false
    var param: NSDictionary!
    var editAlbumID:Int = 0                          // Edit AlbumID
    let mainView = UIView()
    var browseOrMyAlbum = true                   // true for Browse Album & false for My Album
    var showSpinner = true                      // not show spinner at pull to refresh
    var albumResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var albumTableView:UITableView!              // TAbleView to show the Album Contents
    var browseAlbum:UIButton!                    // Album Types
    var myAlbum:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var pageNumberLimit:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    //  var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var customSegmentControl: UISegmentedControl!
    var photoAlbum : UIButton!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var user_id : Int!
    var fromTab : Bool!
    var albumPhotoTableView:UITableView!
    var loadMoreFirstTime = false
    var photos:[PhotoViewer] = []
    var albumOrPhoto = true
    var popoverTableView:UITableView!      // TableView to show that either you want to create album or want to add photos
    var leftBarButtonItem : UIBarButtonItem!
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var formResponse = [AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        openMenu = false
        updateAfterAlert = true
        albumUpdate = true
        

        self.navigationItem.setHidesBackButton(true, animated: false)
        
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
        self.title = NSLocalizedString("Albums",  comment: "")
        
        
        browseAlbum = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("Albums",  comment: ""), border: true, selected: false)
        browseAlbum.tag = 11
        browseAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        browseAlbum.addTarget(self, action: #selector(PhotoAlbumViewController.openBrowseAlbum), for: .touchUpInside)
        mainView.addSubview(browseAlbum)
        
        photoAlbum = createNavigationButton(CGRect(x: view.bounds.width/3.0, y: TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("Photos",  comment: ""), border: true, selected: true)
        photoAlbum.tag = 15
        photoAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        photoAlbum.addTarget(self, action: #selector(PhotoAlbumViewController.explorePhotos), for: .touchUpInside)
        mainView.addSubview(photoAlbum)
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: Selector(("filterSerach")), for: .touchUpInside)
        mainView.addSubview(filter)
        filter.isHidden = true
        
        myAlbum = createNavigationButton(CGRect( x: 2*(view.bounds.width)/3.0, y: TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("My Albums",  comment: ""), border: true, selected: false)
        myAlbum.tag = 22
        myAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        myAlbum.addTarget(self, action: #selector(PhotoAlbumViewController.openMyAlbum), for: .touchUpInside)
        mainView.addSubview(myAlbum)
        
        albumPhotoTableView = UITableView(frame: CGRect(x: 0, y: filter.bounds.height + filter.frame.origin.y  , width: view.bounds.width, height: view.bounds.height-(filter.bounds.height + filter.frame.origin.y) - tabBarHeight), style: .grouped)
        albumPhotoTableView.register(PhotoViewCell.self, forCellReuseIdentifier: "Cell")
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width-30)/4
        }else{
            size = (UIScreen.main.bounds.width-15)/2
        }
        albumPhotoTableView.rowHeight = size
        albumPhotoTableView.dataSource = self
        albumPhotoTableView.delegate = self
        albumPhotoTableView.backgroundColor = tableViewBgColor
        albumPhotoTableView.separatorColor = UIColor.clear
        mainView.addSubview(albumPhotoTableView)
        albumPhotoTableView.isHidden = false
        albumPhotoTableView.tag = 101
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.albumPhotoTableView.estimatedSectionHeaderHeight = 0
        }
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(PhotoAlbumViewController.refresh), for: UIControlEvents.valueChanged)
        albumPhotoTableView.addSubview(refresher)
  
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumPhotoTableView.tableFooterView = footerView
        albumPhotoTableView.tableFooterView?.isHidden = true
        

        if (self.canCreate == true){
            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(PhotoAlbumViewController.searchItem))
            let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(PhotoAlbumViewController.addNewAlbum))
            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
        }else{
            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(PhotoAlbumViewController.searchItem))
            self.navigationItem.rightBarButtonItem = searchItem
        }

      //  SDImageCache.shared().shouldDecompressImages = false
      //  SDWebImageDownloader.shared().shouldDecompressImages = false

        explorePhotos()

    }
    
    
    @objc func explorePhotos(){
        if reachability.connection != .none {
            removeAlert()
            if (self.pageNumber == 1){
                allPhotos.removeAll(keepingCapacity: false)
            }
            if (showSpinner){
      //          spinner.center = view.center
                if updateScrollFlag == false {

                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height)
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                
             //   view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                
                activityIndicatorView.startAnimating()
            }
            self.updateScrollFlag = true
            
            param = ["limit" :"20", "page" : "\(pageNumber)", "order" : "order DESC"]
            
            post( param as! Dictionary<String, String> , url: "albums/photo/list", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.albumPhotoTableView.tableFooterView?.isHidden = true
                    self.showSpinner = false
                    self.refresher.endRefreshing()
                    //print(succeeded)
                    if let body = succeeded["body"] as? NSDictionary{
                        
                        self.isPageRefresing = false
                        if let images = body["photos"] as? NSArray{
                        
                            self.pageNumberLimit = images.count
                            allPhotos  = allPhotos + (images as! [NSDictionary])
                            
                            //print("Paging Count == \(self.pageNumber*self.pageNumberLimit)")
                            
                        }
                        
                        if body["totalPhotoCount"] != nil{
                            self.totalItems = body["totalPhotoCount"] as! Int
                            //print("Total Count = \(self.totalItems)")
                        }
                    
                        self.albumPhotoTableView.reloadData()
                    }
                })
            }
            
        }
    }
    // Create popover
    @objc func addNewAlbum(){
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
        let presentedVC = AlbumSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        let url : String = "albums/search-form"
        loadFilter(url)
    }
    
    // Check for Album Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
       
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        albumPhotoTableView.tableFooterView?.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.albumPhotoTableView.reloadData()
    }
    
    @objc func openImage(_ sender:UIButton){
        
        let photoInfo = allPhotos[sender.tag]
        let openingImage = photoInfo["image"] as! String
        let presentedVC = AdvancePhotoViewController()
        presentedVC.allPhotos = allPhotos
        presentedVC.photoID = sender.tag
        presentedVC.imageUrl = openingImage
        presentedVC.photoType = "photo_albim"
        presentedVC.photoForViewer = photos
        presentedVC.total_items = self.totalItems
        presentedVC.param = param
        presentedVC.attachmentID = 0
        presentedVC.albumTitle = ""
        presentedVC.ownerTitle = ""
        presentedVC.contentType = "photo"
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 11 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = albumOption[(indexPath as NSIndexPath).row]
            //            cell.backgroundColor = UIColor.red
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            
            var index:Int!
            index = (indexPath as NSIndexPath).row * 2
            if allPhotos.count > index {
                // cell.image1.imageView?.image = nil
                // cell.photo1.image = nil
                let photoInfo = allPhotos[index] 
                
                cell.image1.isHidden = false
                cell.photo1.isHidden = false
                cell.photo1.backgroundColor = placeholderColor
                cell.photo1.image = UIImage(named : "default.png")
                if let url1 = URL(string:photoInfo["image"] as! String){
                    let imageUrl = photoInfo["image"] as! String
                    if (imageUrl.range(of: ".gif") != nil){
                        cell.gifImageView.isHidden = false
                    }else{
                        cell.gifImageView.isHidden = true
                    }

                        cell.photo1.backgroundColor = placeholderColor

                        cell.photo1.kf.indicatorType = .activity
                       (cell.photo1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.photo1.kf.setImage(with: url1, placeholder: UIImage(named : "default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in

                        })
                        cell.image1.tag = index
                        cell.image1.addTarget(self, action: #selector(PhotoAlbumViewController.openImage(_:)), for: .touchUpInside)
                        cell.image1.contentMode = UIViewContentMode.scaleAspectFill
      
                }
                
                var totalView = ""
                if let likes = photoInfo["like_count"] as? Int{
                    totalView = "\(likes) \(likeIcon)"
                }
                if let comment = photoInfo["comment_count"] as? Int{
                    totalView += " \(comment) \(commentIcon)"
                }
                
                cell.likeCommentLabel.text = "\(totalView)"
                cell.likeCommentLabel.font = UIFont(name: "FontAwesome", size:FONTSIZENormal )
                
                
            }
            else{
                cell.image1.isHidden = true
                cell.image2.isHidden = true
                cell.photo1.isHidden = true
                cell.photo2.isHidden = true
                return cell
            }
            
            if allPhotos.count > (index + 1){
                // cell.image2.imageView?.image = nil
                let photoInfo = allPhotos[index + 1] 
                
                cell.image2.isHidden = false
                cell.photo2.isHidden = false
                cell.photo2.backgroundColor = placeholderColor
                cell.photo2.image = UIImage(named : "default.png")
                if let url1 = URL(string: photoInfo["image"] as! String){
                    let imageUrl = photoInfo["image"] as! String
                    if (imageUrl.range(of: ".gif") != nil){
                        cell.gifImageView1.isHidden = false
                    }else{
                        cell.gifImageView1.isHidden = true
                    }
                    
                       // cell.photo2.image = UIImage(named : "default.png")
                        cell.photo2.backgroundColor = placeholderColor
                    
                        cell.photo2.kf.indicatorType = .activity
                    (cell.photo2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.photo2.kf.setImage(with: url1, placeholder: UIImage(named : "default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        cell.image2.tag = index+1
                        cell.image2.addTarget(self, action: #selector(PhotoAlbumViewController.openImage(_:)), for: .touchUpInside)
                        cell.image2.contentMode = UIViewContentMode.scaleAspectFill
          
                }
                
                var totalView = ""
                if let likes = photoInfo["like_count"] as? Int{
                    totalView = "\(likes) \(likeIcon)"
                }
                if let comment = photoInfo["comment_count"] as? Int{
                    totalView += " \(comment) \(commentIcon)"
                }
                
                cell.likeCommentLabel1.text = "\(totalView)"
                cell.likeCommentLabel1.font = UIFont(name: "FontAwesome", size:FONTSIZENormal )
            }
            else{
                cell.image2.isHidden = true
                cell.photo2.isHidden = true
                
                return cell
            }
            return cell
        }
        
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastSectionIndex = tableView.numberOfSections - 1
//        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
//        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
//            // //print("this is the last cell")
//
//            if (pageNumberLimit*pageNumber < totalItems){ //&& loadMoreFirstTime == true{
//                if reachability.connection != .none {
//
//
//                    updateScrollFlag = false
//                    pageNumber += 1
//                    explorePhotos()
//
//                }
//            }
//
//
//        }
//    }
 
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    //    // Set Album Tabel Footer Height
    //    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    ////        if (limit*pageNumber < totalItems){
    //            return 80
    ////
    ////        }else{
    ////            return 0.00001
    ////        }
    //    }
    //
    // Set Album Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 11{
            
            return 40
            
        }else{
            var size:CGFloat = 0
            
            size = (UIScreen.main.bounds.width-15)/2
            return size + 10
        }
        
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 11{
            return 2
        }else{
            return Int(ceil(Float(allPhotos.count)/2))
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Apply condition for tableViews
        if  tableView.tag == 11{
            formResponse.removeAll(keepingCapacity: false)
            self.popover.dismiss()
            if (indexPath as NSIndexPath).row == 0{
                // Create Album Form
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Add New Photos", comment: "")
                presentedVC.contentType = "Album"
                presentedVC.param = [ : ]
                presentedVC.url = "albums/upload"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)

            }else if (indexPath as NSIndexPath).row == 1{
                // Upload Photos
                // Check Internet Connectivity
                if reachability.connection != .none {
                    view.alpha = 0.7
                    view.isUserInteractionEnabled = false
                    let parameters = [String:String]()
//                    spinner.center = mainView.center
//                    spinner.hidesWhenStopped = true
//                    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                    self.mainView.addSubview(spinner)
                    self.view.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                    post(parameters, url: "albums/upload", method: "GET") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            self.view.alpha = 1.0
                            self.view.isUserInteractionEnabled = true
                            if let response = succeeded["body"] as? NSArray{
                                self.formResponse = self.formResponse + (response as [AnyObject])
                                activityIndicatorView.stopAnimating()
                            }
                            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                            // Shows the album Options on which we can add photos
                            for key in self.formResponse{
                                if let dic = (key as? NSDictionary){
                                    if dic["label"] as! String == "Choose Album"{
                                        if let _ = dic["multiOptions"] as? NSDictionary{
                                            for(key,value) in (dic["multiOptions"] as? NSDictionary)!{
                                                if key as! String != "0"{
                                                    alertController.addAction(UIAlertAction(title: (value) as? String, style: .default, handler:{ (UIAlertAction) -> Void in
                                                        var urlParams = Dictionary<String, String>()
                                                        urlParams["album_id"] = "\(key)"
                                                        let presentedVC = UploadPhotosViewController()
                                                        presentedVC.directUpload = false
                                                        presentedVC.url = "albums/upload"
                                                        presentedVC.param =  urlParams as NSDictionary?
                                                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                                    }))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if  (UIDevice.current.userInterfaceIdiom == .phone){
                                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
                            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                                // Present Alert as! Popover for iPad
                                alertController.popoverPresentationController?.sourceView = self.view
                                alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.height/2, width: 0, height: 0)
                                alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
                            }
                            self.present(alertController, animated:true, completion: nil)
                            }
                        )}
                }
                else{
                    self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
                }
            }
            
        }
    }
    
    @objc func openBrowseAlbum(){
        photoAlbum.setUnSelectedButton()
        let presentedVC = AlbumViewController()
        presentedVC.fromPhotoBrowseView = true
        presentedVC.showOnlyMyContent = false
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func openMyAlbum(){
        photoAlbum.setUnSelectedButton()
        let presentedVC = AlbumViewController()
        presentedVC.fromPhotoBrowseView = false
        presentedVC.showOnlyMyContent = false
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if (pageNumberLimit*pageNumber < totalItems){ //&& loadMoreFirstTime == true{
                if reachability.connection != .none {
                    updateScrollFlag = false
                    pageNumber += 1
                    albumPhotoTableView.tableFooterView?.isHidden = false
                    explorePhotos()
                    
                }
            }
            else
            {
                albumPhotoTableView.tableFooterView?.isHidden = true
            }
        }
    }


    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if albumResponse.count != 0{
        if reachability.connection != .none {
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            explorePhotos()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
        //   }
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
