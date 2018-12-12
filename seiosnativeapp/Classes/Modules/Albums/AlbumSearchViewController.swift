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
//  AlbumSearchViewController.swift
//  seiosnativeapp

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


class AlbumSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    
    
    var searchBar = UISearchBar()
    var albumTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var albumResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
  //  var imageCache = [String:UIImage]()
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        popAfterDelay = false
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Albums",  comment: ""))
//        searchBar.delegate = self
//        searchBar.backgroundColor = UIColor.clear
//        searchBar.setTextColor(textColorPrime)
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Albums",  comment: ""))
        searchBar.delegate = self

        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AlbumSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItemStyle.plain , target:self , action: #selector(AlbumSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControlState())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        
        // Initialize Album Table
        albumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        albumTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "Cell")
        albumTableView.dataSource = self
        albumTableView.delegate = self
        albumTableView.estimatedRowHeight = 253.0
        albumTableView.rowHeight = UITableViewAutomaticDimension
        albumTableView.backgroundColor = tableViewBgColor
        albumTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            albumTableView.estimatedSectionHeaderHeight = 0
        }
        view.addSubview(albumTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumTableView.tableFooterView = footerView
        albumTableView.tableFooterView?.isHidden = true
        
         tblAutoSearchSuggestions = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 420), style: UITableViewStyle.plain)
        tblAutoSearchSuggestions.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tblAutoSearchSuggestions.dataSource = self
        tblAutoSearchSuggestions.delegate = self
        tblAutoSearchSuggestions.rowHeight = 50
        tblAutoSearchSuggestions.backgroundColor = tableViewBgColor
        tblAutoSearchSuggestions.separatorColor = TVSeparatorColor
        tblAutoSearchSuggestions.tag = 122
        tblAutoSearchSuggestions.isHidden = true
        view.addSubview(tblAutoSearchSuggestions)
        tblAutoSearchSuggestions.keyboardDismissMode = .onDrag
        
        if let arr = UserDefaults.standard.array(forKey: "arrRecentSearchOptions") as? [String]{
            arrRecentSearchOptions = arr
        }
        if arrRecentSearchOptions.count != 0
        {
            tblAutoSearchSuggestions.reloadData()
            tblAutoSearchSuggestions.isHidden = false
        }
        else
        {
            tblAutoSearchSuggestions.isHidden = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {

        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            //tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
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
        if popAfterDelay == true {
             _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // Update Album
    func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Objects
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                self.albumResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.albumTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-50 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                  //  activityIndicatorView.center = view.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyAlbum
            path = "albums"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Album Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    //                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    //})
                    
                  //  //print(succeeded, msg)
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.albumResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let album = response["response"] as? NSArray {
                                    self.albumResponse = self.albumResponse + (album as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        //Reload Album Tabel
                        if self.tblAutoSearchSuggestions.isHidden == true
                        {
                           self.albumTableView.isHidden = false
                        }
                        
                        self.albumTableView.reloadData()
                        if self.albumResponse.count == 0{
                            self.view.makeToast( NSLocalizedString("You do not have any Album entries. Get started by writing a new entry.",  comment: ""), duration: 5, position: "bottom")
                          // self.createTimer(self)
                            self.popAfterDelay = true
                            self.searchBar.resignFirstResponder()
                        }
                    }else{
                        
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            self.searchBar.resignFirstResponder()
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
             searchBar.resignFirstResponder()
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Album Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Album Tabel Header Height
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if tableView.tag == 122{
            let labTitle = createLabel(CGRect( x: 14, y: 0,width: view.bounds.width, height: 40), text: "RECENT SEARCHES", alignment: .left, textColor: textColorDark)
            labTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            vw.addSubview(labTitle)
            return vw
        }
        else
        {
            return vw
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag == 122{
            return 40
        }
        else
        {
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
        return 253
        }
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(albumResponse.count)/3))
        }else{
            return albumResponse.count
        }
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 122{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            if let blogInfo = arrRecentSearchOptions[(indexPath as NSIndexPath).row] as String?
            {
               cell.imgSearch.isHidden = false
                cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
                // cell.labTitle.center.y = cell.bounds.midY + 5
                cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
                cell.labTitle.text = blogInfo
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.numberOfLines = 2
                //  cell.labTitle.sizeToFit()
            }
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        
        
        var index:Int!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            index = (indexPath as NSIndexPath).row * 3
        }else{
            index = (indexPath as NSIndexPath).row * 1
        }
        
        if albumResponse.count > index {
            cell.contentSelection.isHidden = false
            cell.albumCoverImage.isHidden = false
            cell.createdBy.isHidden = false
            cell.albumName.isHidden = false
            cell.totalPhotos.isHidden = false
            
            cell.albumCoverImage.image = nil
            if let photoInfo = albumResponse[index] as? NSDictionary {
                // LHS
                
                let url1 = URL( string:photoInfo["image"] as! NSString as String)
                cell.albumCoverImage.kf.indicatorType = .activity
                (cell.albumCoverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.albumCoverImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
                if let photoCount = photoInfo["photo_count"] as? String{
                    if Int(photoCount) > 1 {
                        cell.photoCount.text = "\(photoCount) photos"
                    }else{
                        cell.photoCount.text = "\(photoCount) photo"
                    }
                }else if let photoCount = photoInfo["photo_count"] as? Int{
                    if photoCount > 1 {
                        cell.photoCount.text = "\(photoCount) photos"
                    }else{
                        cell.photoCount.text = "\(photoCount) photo"
                    }
                    
                }
                
             
                cell.contentSelection.accessibilityIdentifier = "\(index!)"
                cell.contentSelection.tag = photoInfo["album_id"] as! Int
                cell.contentSelection.addTarget(self, action: #selector(AlbumSearchViewController.showAlbum(_:)), for: .touchUpInside)
                cell.createdBy.text = " by " + String(photoInfo["owner_title"] as! NSString)
                cell.albumName.text = " " + String(photoInfo["title"] as! NSString)
                cell.albumName.font = UIFont(name: fontName, size:FONTSIZENormal )
                var totalView = ""
                
                if let likes = photoInfo["like_count"] as? Int{
                    totalView = "\(likes) \(likeIcon)"
                }
                if let comment = photoInfo["comment_count"] as? Int{
                    totalView += " \(comment) \(commentIcon)"
                }
                
                cell.totalMembers.text = "\(totalView)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZESmall )
                cell.totalPhotos.text = String(photoInfo["photo_count"] as! Int)
                
                
                
                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.albumCoverImage.bounds.width
                
            }
            
        }else{
            cell.contentSelection.isHidden = true
            cell.albumCoverImage.isHidden = true
            cell.createdBy.isHidden = true
            cell.albumName.isHidden = true
            cell.totalPhotos.isHidden = true
            
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                cell.contentSelection1.isHidden = true
                cell.albumCoverImage1.isHidden = true
                cell.createdBy1.isHidden = true
                cell.albumName1.isHidden = true
                cell.totalPhotos1.isHidden = true
                
                cell.contentSelection2.isHidden = true
                cell.albumCoverImage2.isHidden = true
                cell.createdBy2.isHidden = true
                cell.albumName2.isHidden = true
                cell.totalPhotos2.isHidden = true
                
            }
            
            return cell
        }
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            //Middle
            if albumResponse.count > (index + 1){
                cell.contentSelection1.isHidden = false
                cell.albumCoverImage1.isHidden = false
                cell.createdBy1.isHidden = false
                cell.albumName1.isHidden = false
                cell.totalPhotos1.isHidden = false
                
                cell.albumCoverImage1.image = nil
                if let photoInfo = albumResponse[index + 1] as? NSDictionary {
                    
                    if let url = URL(string: photoInfo["image"] as! String){
                        cell.albumCoverImage1.kf.indicatorType = .activity
                         (cell.albumCoverImage1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.albumCoverImage1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
 
                    }
                    cell.contentSelection.accessibilityIdentifier = "\(index! + 1)"
                    cell.contentSelection1.tag = photoInfo["album_id"] as! Int
                    cell.contentSelection1.addTarget(self, action: #selector(AlbumSearchViewController.showAlbum(_:)), for: .touchUpInside)
                    cell.createdBy1.text =  " by " + String(photoInfo["owner_title"] as! NSString)
                    cell.albumName1.text = " " + String(photoInfo["title"] as! NSString)
                    cell.albumName1.font = UIFont(name: fontName, size:FONTSIZENormal )
                    cell.totalPhotos1.text = String(photoInfo["photo_count"] as! Int)
                    
                    // Set Menu
                    cell.menu1.isHidden = true
                    cell.createdBy1.frame.size.width = cell.albumCoverImage1.bounds.width
                    
                }
            }else{
                cell.contentSelection1.isHidden = true
                cell.albumCoverImage1.isHidden = true
                cell.createdBy1.isHidden = true
                cell.albumName1.isHidden = true
                cell.totalPhotos1.isHidden = true
                
                cell.contentSelection2.isHidden = true
                cell.albumCoverImage2.isHidden = true
                cell.createdBy2.isHidden = true
                cell.albumName2.isHidden = true
                cell.totalPhotos2.isHidden = true
                
                
                return cell
            }
            
            
            
            //RHS
            if albumResponse.count > (index + 2){
                cell.contentSelection2.isHidden = false
                cell.albumCoverImage2.isHidden = false
                cell.createdBy2.isHidden = false
                cell.albumName2.isHidden = false
                cell.totalPhotos2.isHidden = false
                
                cell.albumCoverImage2.image = nil
                if  let photoInfo = albumResponse[index + 2] as? NSDictionary{
                    
                    if let url = URL(string: photoInfo["image"] as! String){
                        cell.albumCoverImage2.kf.indicatorType = .activity
                         (cell.albumCoverImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.albumCoverImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    cell.contentSelection.accessibilityIdentifier = "\(index! + 2)"
                    cell.contentSelection2.tag = photoInfo["album_id"] as! Int
                    cell.contentSelection2.addTarget(self, action: #selector(AlbumSearchViewController.showAlbum(_:)), for: .touchUpInside)
                    cell.createdBy2.text = " by " + String(photoInfo["owner_title"] as! NSString)
                    cell.albumName2.text = " " + String(photoInfo["title"] as! NSString)
                    cell.totalPhotos2.text = String(photoInfo["photo_count"] as! Int)
                    
                    // Set Menu
                    cell.menu2.isHidden = true
                    cell.createdBy2.frame.size.width = cell.albumCoverImage2.bounds.width
                    
                }
            }else{
                cell.contentSelection2.isHidden = true
                cell.albumCoverImage2.isHidden = true
                cell.createdBy2.isHidden = true
                cell.albumName2.isHidden = true
                cell.totalPhotos2.isHidden = true
                return cell
            }
            
            
        }
        
        return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 122{
            searchBar.text = arrRecentSearchOptions[(indexPath as NSIndexPath).row]
            arrRecentSearchOptions.remove(at: (indexPath as NSIndexPath).row)
            arrRecentSearchOptions.insert(searchBar.text!, at: 0)
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
            if searchBar.text?.range(of: "#") != nil
            {
                let hashTagString = searchBar.text!
                let singleString : String!
                
                searchDic.removeAll(keepingCapacity: false)
                
                if hashTagString.range(of: "#") != nil{
                    let original = hashTagString
                    singleString = String(original.dropFirst())
                    
                }
                else{
                    singleString = hashTagString
                }
                updateAutoSearchArray(str: hashTagString)
                searchBar.resignFirstResponder()
                searchDic.removeAll(keepingCapacity: false)
                self.albumTableView.isHidden = true
                //self.converstationTableView.isHidden = true
                
                let presentedVC = HashTagFeedViewController()
                presentedVC.completionHandler = { 
                    
                    self.searchBar.text = nil
                    self.searchBar.becomeFirstResponder()
                    self.tblAutoSearchSuggestions.reloadData()
                    
                }
                presentedVC.hashtagString = singleString
                navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            else{
                tblAutoSearchSuggestions.isHidden = true
                searchBar.resignFirstResponder()
                searchQueryInAutoSearch()
            }
            
        }
        else
        {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    // Handle Scroll For Pagination

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if tblAutoSearchSuggestions.isHidden == true
        {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Album
//                if albumTableView.contentOffset.y >= albumTableView.contentSize.height - albumTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if reachability.connection != .none {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            albumTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        albumTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
        }
    }
    
    @objc func cancel(){
        albumUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
        
    }
    
    @objc func showAlbum(_ sender: UIButton){
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = albumResponse[index] as? NSDictionary {
            if let str = photoInfo["title"] as? String
            {
               updateAutoSearchArray(str: str)
            }
        }
        let presentedVC = AlbumProfileViewController()
        presentedVC.albumId = sender.tag
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        searchBar.resignFirstResponder()
        browseEntries()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.length != 0
        {
       
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
        }
        else
        {
            activityIndicatorView.stopAnimating()
            if arrRecentSearchOptions.count != 0
            {
                tblAutoSearchSuggestions.reloadData()
                tblAutoSearchSuggestions.isHidden = false
                self.albumTableView.isHidden = true
            }
            else
            {
                tblAutoSearchSuggestions.isHidden = true
            }
        }
        
    }
    @objc func reload(_ searchBar: UISearchBar) {
        if searchBar.text?.length != 0
        {
        tblAutoSearchSuggestions.isHidden = true
        searchQueryInAutoSearch()
        }
    }
    func updateAutoSearchArray(str : String) {
        if !arrRecentSearchOptions.contains(str)
        {
            arrRecentSearchOptions.insert(str, at: 0)
            if arrRecentSearchOptions.count > 6 {
                arrRecentSearchOptions.remove(at: 6)
            }
            tblAutoSearchSuggestions.reloadData()
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
        }
    }
    func searchQueryInAutoSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
       // searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    @objc func filter(){
        
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "album"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "albums/search-form"
            presentedVC.serachFor = "album"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        setNavigationImage(controller: self)
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
               // searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
         albumTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
        if (self.isMovingFromParentViewController){
            if fromGlobSearch{
                conditionalForm = ""
                loadFilter("search")
                globSearchString = searchBar.text!
                backToGlobalSearch(self)
            }
        }
    }
    
    
    
    
    
    //    override func viewWillDisappear(animated: Bool) {
    //        view.removeGestureRecognizer(tapGesture)
    //        // searchDic.removeAll(keepingCapacity: false)
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
}
