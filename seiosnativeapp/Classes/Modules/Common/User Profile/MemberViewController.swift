
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
//  MembersViewController.swift
//  seiosnativeapp
import GoogleMaps
import UIKit
import NVActivityIndicatorView
import Instructions
//import MapKit
import CoreLocation
var membersUpdate1:Bool!
var go_Back = false

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var userData:Members!
    
    var userData1:NSDictionary!
    
    init(position: CLLocationCoordinate2D, name: String, userData: Members) {
        self.position = position
        self.name = name
        self.userData = userData
    }
    
    init(position: CLLocationCoordinate2D, name: String, userData1: NSDictionary) {
        self.position = position
        self.name = name
        self.userData1 = userData1
    }
}

class MemberViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , GMUClusterManagerDelegate, GMSMapViewDelegate, MapMarkerDelegate, GMUClusterRendererDelegate,CLLocationManagerDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    let mainView = UIView()
    // Variables for Likes
    var allMembers:[Members] = []
    var allMapMembers:[Members] = []
    var membersTableView:UITableView!
    var pageNumber:Int = 1
    var mapPageNumber:Int = 1
    var totalItems:Int = 0
    
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 100              // Dynamic Height fort for Cell
    var contentType:String! = ""
    var contentId:Int!
    var memberCount : Int!
    var updateScrollFlag = true
    var indexChange : Int!
    var showSpinner = true
    var navLeftIcon = false
    var leftBarButtonItem : UIBarButtonItem!
    var fromTab : Bool! = false
    
    var buttonView : UIView!
    var listbutton : UIButton!
    var mapButton : UIButton!
    var showType = "list"
    var mapView = GMSMapView()
    var clusterManager: GMUClusterManager!
    var userdata :[AnyObject] = []
    var phones = [String]()
    var imageConvert = [UIImage]()
    var nextButton = UIButton()
    var checkNext : Bool = true
    var totalMemberCount : Int = 0
    var mapTotalMemberCount : Int = 0
    var titleLabelField = UILabel()
    var mapormember : Int = 1 // 1 for listView
    var j = 0
    var deleteButton1 : UIButton!
    var customLimit : Int = 50
    var urlString: String!
    var param: NSDictionary!
    var kCameraLatitude : Double = 0.0
    var kCameraLongitude : Double = 0.0
    let defaults = UserDefaults.standard
    var viewType : String = "0"
    var firstTime : Bool = true
    
    var profileOfUserId : Int = 0
    var locationManager = CLLocationManager()
    var didFindLocation = false
    
    private var infoWindow = MapMarkerWindowView()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoWindow = loadNiB()
        
        NotificationCenter.default.addObserver(self,selector:#selector(MemberViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        
        kCameraLatitude = self.defaults.double(forKey:"Latitude")
        kCameraLongitude = self.defaults.double(forKey:"Longitude") // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        membersUpdate1 = true
        searchDic.removeAll(keepingCapacity: false)
        if fromTab == false{
            self.navigationItem.setHidesBackButton(true, animated: false)
            setDynamicTabValue()
        }
        else{
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MemberViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        if contentType == "AdvVideo"{
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MemberViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        setNavigationImage(controller: self)
        
        if self.contentType == "user"{
            let addMember = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(MemberViewController.addNewMember))
            self.navigationItem.rightBarButtonItem = addMember
        }
        
        membersTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), style: .grouped)
        membersTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.rowHeight = 80
        membersTableView.dataSource = self
        membersTableView.delegate = self
        membersTableView.bounces = false
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.membersTableView.estimatedSectionHeaderHeight = 0
        }
        
        if contentType == "members" {
            membersTableView.frame.origin.y = TOPPADING + 40
            membersTableView.frame.size.height = view.bounds.height-(TOPPADING)  - tabBarHeight - 40
            openMenu = false
            view.backgroundColor = bgColor
            membersTableView.isHidden  = true
            navigationController?.navigationBar.isHidden = false
            
            let subViews = mainView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            
            mainView.frame = view.frame
            mainView.backgroundColor = bgColor
            view.addSubview(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            
            let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MemberViewController.searchItem))
            searchIcon.tintColor = textColorPrime
            _   = UIButton(type: UIButton.ButtonType.system) as UIButton
            let filterItem = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MemberViewController.filter))
            filterItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
            filterItem.tintColor = textColorPrime
            self.navigationItem.setRightBarButtonItems([filterItem,searchIcon], animated: true)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let menuImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
            menuImageView.image = UIImage(named: "dashboard_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(menuImageView)
            
            if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
                
                let countLabel = createLabel(CGRect(x: 17,y: 3,width: 17,height: 17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
                
                countLabel.backgroundColor = UIColor.red
                countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
                countLabel.layer.masksToBounds = true
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
                leftNavView.addSubview(countLabel)
            }
            if fromTab == false{
                self.navigationItem.setHidesBackButton(true, animated: false)
                
            }
            
            // Create Filter Search Link
            let filter = createButton(CGRect(x: PADING, y: TOPPADING , width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
            filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            filter.addTarget(self, action: #selector(MemberViewController.filterSerach), for: .touchUpInside)
            mainView.addSubview(filter)
            filter.isHidden = true
            mainView.addSubview(membersTableView)
            
            buttonView = UIView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: 40))
            buttonView.backgroundColor = UIColor.clear
            mainView.addSubview(buttonView)
            
            listbutton = createButton(CGRect(x: view.bounds.width - 80, y: 0, width: 40, height: 40), title: listingDefaultIcon, border: false, bgColor: false, textColor: textColorDark)
            listbutton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            listbutton.isHidden = true
            listbutton.addTarget(self, action: #selector(MemberViewController.listView), for: .touchUpInside)
            buttonView.addSubview(listbutton)
            
            mapButton = createButton(CGRect(x: view.bounds.width - 40, y: 0, width: 40, height: 40), title: locationIcon, border: false, bgColor: false, textColor: textColorDark)
            mapButton.isHidden = true
            mapButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            mapButton.addTarget(self, action: #selector(MemberViewController.mapViewPage), for: .touchUpInside)
            buttonView.addSubview(mapButton)
            
            titleLabelField = createLabel(CGRect(x: 10,y: 10,width: view.bounds.width - 80,height: 20), text: "", alignment: .left, textColor: textColorDark)
            titleLabelField.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
            titleLabelField.isHidden = true
            buttonView.addSubview(titleLabelField)
        }
        view.addSubview(membersTableView)
        
        pageNumber = 1
        updateScrollFlag = false
        userdata.removeAll(keepingCapacity: false)
        allMembers.removeAll(keepingCapacity: true)
        findAllMembers()
        
        if self.contentType == "members"{
            if mapormember == 1{
                self.listView()
            }
            else{
                self.mapViewPage()
            }
        }
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        membersTableView.tableFooterView = footerView
        membersTableView.tableFooterView?.isHidden = true
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
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 60.0
            let radious : Int = 30
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 46 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 1:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 46.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 88 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 2:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 30
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 78), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
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
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
            //        case 0:
            //            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
            //            coachViews.bodyView.nextLabel.text = "Next"
            
        case 0:
            coachViews.bodyView.hintLabel.text = "Click here to search any particular member."
            coachViews.bodyView.countTourLabel.text = " 1/2"
            coachViews.bodyView.nextLabel.text = "Next "
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("List/Map : Choose to See Users in List or Map View", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 2/2"
            coachViews.bodyView.nextLabel.text = "Finish "
            
        case 2:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("Show Map View", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 3/3"
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
        if let name = defaults.object(forKey: "showMemberSearchPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showMemberSearchPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showMemberSearchPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if go_Back == true {
            go_Back = false
           
            if viewType == "1"
            {
                self.allMapMembers.removeAll()
                self.findAllMembers()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        membersTableView.tableFooterView?.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            
            if viewType == "0"
            {
                pageNumber = 1
                showSpinner = true
                allMembers.removeAll(keepingCapacity: false)
            }
            else
            {
                self.kCameraLatitude = 0.0
                self.kCameraLongitude = 0.0
                mapPageNumber = 1
                showSpinner = true
                allMapMembers.removeAll(keepingCapacity: false)
            }
            findAllMembers()
            filterSearchFormArray.removeAll(keepingCapacity: false)
        }
    }
    
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "members"
            presentedVC.url = "members/search-form"
            presentedVC.contentType = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "members/search-form"
            presentedVC.serachFor = "members"
            presentedVC.url = "members/search-form"
            presentedVC.contentType = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }

    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }

    // Action , when we ckick on list icon
    @objc func listView(){
        infoWindow.removeFromSuperview()
        self.titleLabelField.text = "\(self.totalMemberCount) members found"
        viewType = "0"
        membersTableView.isHidden = false
        mapView.isHidden = true
        nextButton.isHidden = true
        mapButton.setTitleColor(textColorDark, for: .normal)
        listbutton.setTitleColor(navColor, for: .normal)
        if searchDic.count > 0 {
            pageNumber = 1
            showSpinner = true
            allMembers.removeAll(keepingCapacity: false)
            findAllMembers()
            searchDic.removeAll()
            filterSearchFormArray.removeAll(keepingCapacity: false)
        }
    }
    // Action , when we ckick on map icon
    @objc func mapViewPage(){
        
        self.titleLabelField.text = "\(self.mapTotalMemberCount) members found"
        viewType = "1"
        if firstTime == true {
            googleMap()
            showSpinner = true
            findAllMembers()
        }
        membersTableView.isHidden = true
        mapView.isHidden = false
        nextButton.isHidden = false
        mapButton.setTitleColor(navColor, for: .normal)
        listbutton.setTitleColor(textColorDark, for: .normal)
    }
    
    // We frame the map
    func googleMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING + 40, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight - 40), camera: camera)
        
//        mapView.mapType =  .terrain
        
        let CameraLatitude = self.defaults.double(forKey:"Latitude")
        let CameraLongitude = self.defaults.double(forKey:"Longitude")
        let location = self.defaults.string(forKey: "Location")
        
        if CameraLatitude != 0.0 && CameraLongitude != 0.0 {
            let position = CLLocationCoordinate2D(latitude: CameraLatitude, longitude: CameraLongitude)
            let marker = GMSMarker(position: position)
            marker.title = location
            marker.tracksViewChanges = true
            marker.map = mapView
        }
      
        if CameraLatitude == 0.0 && CameraLongitude == 0.0 && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 && setLocation == true{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    if AppLauchForMember == true {
                        AppLauchForMember = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        defaults.set(true, forKey: "showMsg")
                    }
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
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
                if AppLauchForMemberGPS == true {
                    AppLauchForMemberGPS = false
                    gpsLocation(controller: self)
                }
            }
        }
        
        if setLocation == false
        {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
 
        mainView.addSubview(mapView)
        mapView.delegate = self
        
        nextButton = createButton(CGRect(x: view.bounds.width/2 - 35, y: view.bounds.height  - tabBarHeight - 40, width: 100, height: 30), title: "View More", border: false, bgColor: true, textColor: UIColor.white)
        nextButton.backgroundColor = textColorDark.withAlphaComponent(0.9)
        nextButton.addTarget(self, action: #selector(MemberViewController.nextMember), for: .touchUpInside)
        nextButton.alpha = 0.7
        nextButton.isHidden = true
        mainView.addSubview(nextButton)
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    func loadNiB() -> MapMarkerWindowView {
        let infoWindow = MapMarkerWindowView.instanceFromNib() as! MapMarkerWindowView
        var pad = 9
        if DeviceType.IS_IPHONE_X
        {
            pad = 3
        }
        var frame = infoWindow.frame
        frame.size.width = self.view.frame.size.width
        frame.origin.y = self.view.frame.size.height - frame.size.height - tabBarHeight - CGFloat(pad)
        infoWindow.frame = frame
        
       // infoWindow.btnProfileImage.layer.masksToBounds = false
        //infoWindow.btnProfileImage.clipsToBounds = true
       // infoWindow.btnProfileImage.layer.cornerRadius = infoWindow.btnProfileImage.frame.width/2
        
        
        return infoWindow
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    // In this we pass the data for infowindow
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            var markerData : Members!
            if let data = poiItem.userData{
                markerData = data
            }
            
            locationMarker = marker
            infoWindow.removeFromSuperview()
            infoWindow = loadNiB()
//            guard let location = locationMarker?.position else {
//                print("locationMarker is nil")
//                return false
//            }
            // Pass the spot data to the info window, and set its delegate to self
            infoWindow.spotData = markerData
            infoWindow.delegate = self
            // Configure UI properties of info window
            //infoWindow.alpha = 0.9
            //infoWindow.layer.cornerRadius = 12
            //infoWindow.layer.borderWidth = 2
            
            var imgFriendType = UIImageView()
            imgFriendType = UIImageView(frame: CGRect(x:infoWindow.lblView.frame.size.width/2-2,y:-5,width:20,height:20))
            imgFriendType.image = UIImage(named: "addFriend")!.maskWithColor(color: textColorPrime)
            infoWindow.lblFollowCount.addSubview(imgFriendType)
            
            if let stringUrl = markerData.image_normal{
                let url = URL(string: stringUrl)
                infoWindow.btnProfileImage.kf.setImage(with: url, for: .normal, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    self.infoWindow.btnProfileImage.clipsToBounds = true
                })
            }
            
            if let dic = markerData.mapData
            {
                infoWindow.lblView.text = dic["rv_text"] as? String
                if let viewCount = dic["rv_count"] as? Int {
                    infoWindow.lblViewCount.text = String(describing: viewCount)
                }
                
//                infoWindow.lblFollow.text = dic["af_text"] as? String
//                if let followCount = dic["af_count"] as? Int {
//                    infoWindow.lblFollowCount.text = String(describing: followCount)
//                }
                
                infoWindow.lblFriend.text = dic["ff_text"] as? String
                if let friendCount = dic["ff_count"] as? Int {
                    infoWindow.lblFriendCount.text = String(describing: friendCount)
                }
                
            }
            
            if let user_id = markerData.user_id
            {
                self.profileOfUserId = user_id
            }
            
            if let dic = markerData.menus
            {
                
                if let lblFollow = dic["label"] as? String {
                    infoWindow.lblFollow.text = lblFollow
                }
                
                let condition = dic["name"] as! String
                
                if   self.profileOfUserId != currentUserId {
                    
                    if condition == "add_friend" || condition ==  "member_follow"
                    {
                        imgFriendType.image = UIImage(named : "addFriend")!.maskWithColor(color: textColorPrime)
                    }
                    else  if  condition == "cancel_request" ||   condition == "cancel_follow"
                    {
                        imgFriendType.image = UIImage(named : "cancelFriendRequest")!.maskWithColor(color: textColorPrime)
                    }
                    else if  condition == "remove_friend" ||  condition == "member_unfollow"
                    {
                        imgFriendType.image = UIImage(named : "removeFriend")!.maskWithColor(color: textColorPrime)
                    }
                    else if  condition == "accept_request"
                    {
                        imgFriendType.image = UIImage(named : "cancelFriendRequest")!.maskWithColor(color: textColorPrime)
                    }
                    else  if condition == "user_profile_send_message"{
                        imgFriendType.image = UIImage(named : "messageIcon")!.maskWithColor(color: textColorPrime)
                    }
                }
            }
            
            let address = markerData.location ?? "Country"
            let title = markerData.displayname ?? "Unknown"
            
            infoWindow.lblAddress.text = address
            infoWindow.lblTitle.text = title
            
            // Offset the info window to be directly above the tapped marker
            //infoWindow.center = mapView.projection.point(for: location)
            //infoWindow.center.y = infoWindow.center.y - 15

            self.view.addSubview(infoWindow)
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        if (locationMarker != nil)
//        {
//            guard let location = locationMarker?.position else {
//                print("locationMarker is nil")
//                return
//            }
//            //infoWindow.center = mapView.projection.point(for: location)
//            //infoWindow.center.y = infoWindow.center.y - 15
//        }
    }

 // redirection
    func redirection(condition : String, dic : NSDictionary, userId : Int){
        let menuItem = dic
        let nameString1 = condition
        switch(condition){
        case "accept_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "add_friend":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "cancel_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "remove_friend" :
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to  remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "follow":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to follow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "following":
            
            var message = ""
            let title = "Unfollow"//dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to unfollow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "member_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "member_unfollow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want  to remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
//                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "cancel_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        default:
            self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
            
            
        }
        
    }
 // Finish :- code of showing add friend, more menus and message
 
    // We remove the infowindow , when user click anywhere on the map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // We modify the google marker from user image
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let poiItem = marker.userData as? POIItem {
            var markerData : Members!
            if let data = poiItem.userData{
                markerData = data
            }
            let imageView = UIImageView()
            imageView.frame.size.width = 40
            imageView.frame.size.height = 40
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            
            if let stringUrl = markerData.image_normal{
                let url = URL(string: stringUrl)
                imageView.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                marker.iconView = imageView
            }
        }
    }

    // MARK: - MapView Delegate
    func didTapInfoButton(data: Members) {
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = data.user_id//sender.tag
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // Redirect user location into google map or browser
    func didTapRedirectLocButton(data: Members) {
        let lat = data.latitude
        let lang = data.longitude
        let newString = data.location
//        let loc = newString?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
    let loc = newString?.replacingOccurrences(of: " ",with:"+",options: NSString.CompareOptions.literal, range:nil)
//        let loc = newString?.replacingOccurrences(of: " ", with: "+")
        
        print("https://maps.google.com/maps?f=d&daddr=\(String(describing: loc!))=&sll=\(lat),\(lang)")
        
        if let url = URL(string: "https://maps.google.com/maps?f=d&daddr=\(String(describing: loc!))=&sll=\(lat),\(lang)"){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    // Redirect user location into google map or browser
    func didTapRedirectFriendType(data: Members) {
        print(data)
        if let menu = data.menus
        {
            self.redirection(condition : menu["name"] as? String ?? "", dic : menu,userId :data.user_id)
        }
    }
    
    
    @objc func nextMember(){
        nextButton.isHidden = false
        if self.allMapMembers.count < self.mapTotalMemberCount {
            mapPageNumber  = mapPageNumber + 1
            nextButton.isEnabled = false
            findAllMembers()
        }
        else{
            self.view.makeToast("No More Members", duration: 5, position: "bottom")
        }
    }
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
//            searchDic.removeAll(keepingCapacity: false)
            membersUpdate1 = false
            filterSearchFormArray.removeAll(keepingCapacity: false)
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showMemberContent")
        {
            if  UserDefaults.standard.object(forKey: "showMemberContent") != nil {
                
                contentType = name as! String
                
            }
            UserDefaults.standard.removeObject(forKey: "showMemberContent")
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
    
    // MARK: - Server Connection For All Likes
    @objc func menuAction(_ sender:UIButton){
        // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
        // let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        // var memberInfo:NSDictionary
        if (sender.tag > -1){
            let memberInfo = allMembers[sender.tag]
            if let menuItem = memberInfo.menus{
                let nameString1 = menuItem["name"]as! String
                
                if nameString1 == "remove_friend" || nameString1 == "member_unfollow"{
                    
                    displayAlertWithOtherButton(NSLocalizedString("Remove Friend", comment: ""),message: NSLocalizedString("Are you sure you want to remove this member as a friend?",comment: "") , otherButton: NSLocalizedString("Confirm", comment: "")) { () -> () in
                        self.indexChange = sender.tag
                        self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
                if nameString1 == "cancel_request" || nameString1 == "cancel_follow"{
                    
                    displayAlertWithOtherButton(NSLocalizedString("Cancel Friend Request", comment: ""),message: NSLocalizedString("Do you want to cancel your friend request? ",comment: "") , otherButton: NSLocalizedString("Confirm", comment: "")) { () -> () in
                        self.indexChange = sender.tag
                        self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
                if nameString1 == "add_friend" || nameString1 == "member_follow"{
                    
                    displayAlertWithOtherButton(NSLocalizedString("Add Friend", comment: ""),message: NSLocalizedString("Would you like to add this member as a friend? ",comment: "") , otherButton: NSLocalizedString("Confirm", comment: "")) { () -> () in
                        self.indexChange = sender.tag
                        self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
        
    }
    
    func updateMembers(_ parameter: NSDictionary , url : String , user_id : Int,menuType : String){
        
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if url.range(of: "remove") != nil{
                            self.view.makeToast( NSLocalizedString("This person has been removed from your friends.", comment: ""), duration: 5, position: "bottom")
                            
                        }else if url.range(of: "add") != nil {
                            self.view.makeToast(NSLocalizedString("Your friend request has been sent", comment: ""), duration: 5, position: "bottom")
                            
                        }else if url.range(of: "cancel") != nil{
                            self.view.makeToast(NSLocalizedString("Your friend request has been canceled.", comment: ""), duration: 5, position: "bottom")
                            
                        }else{
                            
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            }
                        }
                        if self.viewType == "0"
                        {
                            
                        for (index,value) in self.allMembers.enumerated(){
                            if url == "delete"{
                                feedUpdate = true
                                if value.user_id == user_id{
                                    self.allMembers.remove(at: index)
                                    self.userdata.remove(at: index)
                                    // Set Updated Label Info
                                    var finalText = ""
                                    finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                                    total_Comments = total_Comments - 1
                                    finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                                    
                                }
                            }else{
                                
                                
                                if value.user_id == user_id{
                                    
                                    let tempOldMenuDictionary :NSMutableDictionary = [:]
                                    //                                    let type = menuType
                                    switch(menuType){
                                    case "add_friend":
                                        
                                        if   value.isVerified != nil && value.isVerified == 1{
                                            tempOldMenuDictionary["label"] = "Cancel Request"
                                            tempOldMenuDictionary["url"] = "user/cancel"
                                            tempOldMenuDictionary["name"] = "cancel_request"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                        }
                                        else{
                                            tempOldMenuDictionary["label"] = "Remove Friend"
                                            tempOldMenuDictionary["url"] = "user/remove"
                                            tempOldMenuDictionary["name"] = "remove_friend"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        }
                                        
                                    case "cancel_request":
                                        
                                        tempOldMenuDictionary["label"] = "Add Friend"
                                        tempOldMenuDictionary["url"] = "user/add"
                                        tempOldMenuDictionary["name"] = "add_friend"
                                        tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        
                                    case "remove_friend":
                                        
                                        tempOldMenuDictionary["label"] = "Add Friend"
                                        tempOldMenuDictionary["url"] = "user/add"
                                        tempOldMenuDictionary["name"] = "add_friend"
                                        tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        
                                        
                                    case "member_follow":
                                        if  value.isVerified != nil && value.isVerified == 1 {
                                            tempOldMenuDictionary["label"] = "Cancel Follow Request"
                                            tempOldMenuDictionary["url"] = "user/cancel"
                                            tempOldMenuDictionary["name"] = "cancel_follow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                        }
                                        else{
                                            tempOldMenuDictionary["label"] = "Unfollow"
                                            tempOldMenuDictionary["url"] = "user/remove"
                                            tempOldMenuDictionary["name"] = "member_unfollow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        }
                                        
                                    case "member_unfollow":
                                        tempOldMenuDictionary["label"] = "Follow"
                                        tempOldMenuDictionary["url"] = "user/add"
                                        tempOldMenuDictionary["name"] = "member_follow"
                                        tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        
                                        
                                    case "cancel_follow":
                                        tempOldMenuDictionary["label"] = "Follow"
                                        tempOldMenuDictionary["url"] = "user/add"
                                        tempOldMenuDictionary["name"] = "member_follow"
                                        tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                        
                                        
                                    default:
                                        print("default")
                                    }
                                    
                                    
                                    let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                                    newDictionary["image_profile"] = value.image_profile
                                    newDictionary["displayname"] = value.displayname
                                    newDictionary["user_id"] = value.user_id
                                    newDictionary["isVerified"] = value.isVerified
                                    newDictionary["menus"] = tempOldMenuDictionary
                                    
                                    var newData = Members.loadCommentsfromDictionary(newDictionary)
                                   
                                    self.allMembers[index] = newData[0] as Members
                                    self.membersTableView.reloadData()
                                }
                            }
                        }
                        }
                        else
                        {
                            self.mapView.removeFromSuperview()
                            self.googleMap()
                            for (index,value) in self.allMapMembers.enumerated(){
                                if url == "delete"{
                                    feedUpdate = true
                                    if value.user_id == user_id{
                                        self.allMapMembers.remove(at: index)
                                        self.userdata.remove(at: index)
                                        // Set Updated Label Info
                                        var finalText = ""
                                        finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                                        total_Comments = total_Comments - 1
                                        finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                                        
                                    }
                                }else{
                                    
                                    if value.user_id == user_id{
                                        
                                        let tempOldMenuDictionary :NSMutableDictionary = [:]
                                        //                                    let type = menuType
                                        switch(menuType){
                                        case "add_friend":
                                            
                                            if   value.isVerified != nil && value.isVerified == 1{
                                                tempOldMenuDictionary["label"] = "Cancel Request"
                                                tempOldMenuDictionary["url"] = "user/cancel"
                                                tempOldMenuDictionary["name"] = "cancel_request"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                                
                                            }
                                            else{
                                                tempOldMenuDictionary["label"] = "Remove Friend"
                                                tempOldMenuDictionary["url"] = "user/remove"
                                                tempOldMenuDictionary["name"] = "remove_friend"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            }
                                            
                                        case "cancel_request":
                                            
                                            tempOldMenuDictionary["label"] = "Add Friend"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "add_friend"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                        case "remove_friend":
                                            
                                            tempOldMenuDictionary["label"] = "Add Friend"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "add_friend"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        case "member_follow":
                                            if  value.isVerified != nil && value.isVerified == 1 {
                                                tempOldMenuDictionary["label"] = "Cancel Follow Request"
                                                tempOldMenuDictionary["url"] = "user/cancel"
                                                tempOldMenuDictionary["name"] = "cancel_follow"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                                
                                            }
                                            else{
                                                tempOldMenuDictionary["label"] = "Unfollow"
                                                tempOldMenuDictionary["url"] = "user/remove"
                                                tempOldMenuDictionary["name"] = "member_unfollow"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            }
                                            
                                        case "member_unfollow":
                                            tempOldMenuDictionary["label"] = "Follow"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "member_follow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        case "cancel_follow":
                                            tempOldMenuDictionary["label"] = "Follow"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "member_follow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        default:
                                            print("default")
                                        }
                                        
                                        
                                        let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                                        newDictionary["image_profile"] = value.image_profile
                                        newDictionary["displayname"] = value.displayname
                                        newDictionary["user_id"] = value.user_id
                                        newDictionary["isVerified"] = value.isVerified
                                        newDictionary["menus"] = tempOldMenuDictionary
                                        newDictionary["latitude"] = value.latitude
                                        newDictionary["longitude"] = value.longitude
                                        newDictionary["location"] = value.location
                                        newDictionary["image_normal"] = value.image_normal
                                        newDictionary["mapData"] = value.mapData
                                        
                                        var newData = Members.loadCommentsfromDictionary(newDictionary)
                                            self.infoWindow.removeFromSuperview()
                                            self.allMapMembers[index] = newData[0] as Members
                                    }
                                }
                            
                                if let listingMain = self.allMapMembers[index] as? Members{
                                    if var lat = listingMain.latitude as? Double{
                                        if var lang = listingMain.longitude as? Double{
                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                            {
                                                self.kCameraLatitude = lat
                                                self.kCameraLongitude = lang
                                                
                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,longitude: self.kCameraLongitude, zoom: 10)
                                                self.mapView.camera = camera
                                            }
                                            
                                            let extent = 0.2
                                            lat = lat + extent * self.randomScale()
                                            lang = lang + extent * self.randomScale()
                                            let name = "Item "
                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                            
                                            if self.mapView.isHidden == false {
                                                self.clusterManager.add(item)
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            if self.mapView.isHidden == false {
                                self.clusterManager.cluster()
                                self.clusterManager.setDelegate(self, mapDelegate: self)
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
    
    func findAllMembers(){
        
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            if viewType == "0"
            {
                if (self.pageNumber == 1) && allMembers.count > 0{
                    membersTableView.reloadData()
                }
            }
            
            if self.contentType == "members"{
                self.showAppTour()
            }
            
            if self.showSpinner{
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = self.view.center
                    updateScrollFlag = false
                }
                
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            if viewType == "1"
            {
                activityIndicatorView.center = self.view.center
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            var parameter = [String:String]()
            let defaults = UserDefaults.standard
            let loc = defaults.string(forKey: "Location") ?? ""
            if viewType == "0"
            {
                parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","restapilocation":"\(loc)","viewType":viewType]
            }
            else
            {
                parameter = ["limit":"\(customLimit)", "page":"\(mapPageNumber)","restapilocation":"\(loc)","viewType":viewType]
            }
            
            var url = ""
            
            switch(contentType){
                
            case "user":
                parameter.merge(["user_id": String(contentId)])
                url = "user/get-friend-list"
            case "userFollow":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/following"
            case "userFollower":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/followers"
            case "members":
                url = "members"
            case "AdvVideo":
                url = urlString
                parameter = param as! [String : String]
                break
                
            default:
                print("error")
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
            }
            searchDic.removeAll(keepingCapacity: false)
            // Send Server Request to Share Content
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                
                    self.nextButton.isEnabled = true
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if self.contentType == "members"{
                                    if let members = body["response"] as? NSArray{
                                        if self.viewType == "0"{
                                            self.allMembers +=  Members.loadMembers(members)
                                            
                                            for i in 0 ..< (self.allMembers.count) {
                                                if let listingMain = self.allMembers[i] as? Members{
                                                    if var lat = listingMain.latitude as? Double{
                                                        if var lang = listingMain.longitude as? Double{
                                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                            {
                                                                self.kCameraLatitude = lat
                                                                self.kCameraLongitude = lang
                                                                
                                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                                      longitude: self.kCameraLongitude, zoom: 10)
                                                                self.mapView.camera = camera
                                                            }
                                                            
                                                            let extent = 0.0000001
                                                            lat = lat + extent * Double(i)//self.randomScale()
                                                            lang = lang + extent * Double(i)//self.randomScale()
                                                            let name = "Item \(self.j)"
                                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                                            
                                                            if self.mapView.isHidden == false {
                                                                self.clusterManager.add(item)
                                                            }
                                                            self.j = self.j + 1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        if self.viewType == "1"{
                                            if self.mapPageNumber == 1 {
                                                
                                                if self.firstTime == false {
                                                    self.mapView.removeFromSuperview()
                                                    self.allMapMembers.removeAll(keepingCapacity: false)
                                                    self.googleMap()
                                                }
                                                else
                                                {
                                                    self.firstTime = false
                                                }
                                            }
                                            self.allMapMembers += Members.loadMembers(members)
                                            
                                            for i in 0 ..< (self.allMapMembers.count) {
                                                if let listingMain = self.allMapMembers[i] as? Members{
                                                    if var lat = listingMain.latitude as? Double{
                                                        if var lang = listingMain.longitude as? Double{
                                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                            {
                                                                self.kCameraLatitude = lat
                                                                self.kCameraLongitude = lang
                                                                
                                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                                      longitude: self.kCameraLongitude, zoom: 10)
                                                                self.mapView.camera = camera
                                                            }
                                                            
                                                            let extent = 0.00002
                                                            lat = lat + extent * Double(i)//self.randomScale()
                                                            lang = lang + extent * Double(i)//self.randomScale()
                                                            let name = "Item \(self.j)"
                                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                                            
                                                            if self.mapView.isHidden == false {
                                                                self.clusterManager.add(item)
                                                            }
                                                            self.j = self.j + 1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if self.mapView.isHidden == false {
                                            self.clusterManager.cluster()
                                            self.clusterManager.setDelegate(self, mapDelegate: self)
                                        }
                                    }
                                    
                                }
                                if self.contentType == "AdvVideo"{
                                    if let members = body["members"] as? NSArray{
                                        self.allMembers +=  Members.loadMembers(members)
                                    }
                                }
                                
                                if ((self.contentType == "user") ){
                                    if let likes = body["friends"] as? NSArray{
                                        self.userdata += likes as [AnyObject]
                                        
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                if  (self.contentType == "userFollow") || (self.contentType == "userFollower"){
                                    if let likes = body["response"] as? NSArray{
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                
                                if ((self.contentType == "members") ){
                                    
                                    self.listbutton.isHidden = false
                                    self.mapButton.isHidden = false
                                }
                                
                                if let members = body["totalItemCount"] as? Int{
                                    
                                    if self.viewType == "0"
                                    {
                                        self.totalMemberCount = members
                                    }
                                    else
                                    {
                                        self.mapTotalMemberCount = members
                                    }
                                    self.memberCount = members
                                    if self.contentType == "user"{
                                        self.title =  String(format: NSLocalizedString(" Friends (%d) ", comment: ""),self.memberCount)
                                    }
                                    else if self.contentType == "userFollow"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Following (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followings (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                    else if self.contentType == "userFollower"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Follower (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followers (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                        
                                        
                                    else if self.contentType == "AdvVideo"
                                    {
                                        self.title =  String(format: NSLocalizedString(" Subscribers (%d) ", comment: ""),self.memberCount)
                                    }
                                        
                                    else{
                                        self.title = NSLocalizedString("Members", comment: "")
                                        self.titleLabelField.text = "\(self.memberCount!) members found"
                                        self.titleLabelField.isHidden = false
                                    }
                                    
                                    self.totalItems = members
                                }
                            }
                            
                            self.isPageRefresing = false
                            self.membersTableView.reloadData()
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
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (customLimit*pageNumber < totalItems){
            return 0
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allMembers.count
    }

    @objc func redirecttolist(_ sender: UIButton)
    {
        let presentedVC = AddtolistViewController()
        let id = self.allMembers[sender.tag]
        presentedVC.friend_id = id.user_id
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let memberInfo = allMembers[(indexPath as NSIndexPath).row]
        cell.tag = (indexPath as NSIndexPath).row
        var heightForFields: CGFloat = 15.0
        
        cell.imgUser.frame = CGRect(x: 5, y: 10, width: 60, height: 60)
        cell.imgUser.image = UIImage(named: "user_profile_image.png")
        cell.memberOnlineLabel.isHidden = false
        cell.memberAge.isHidden = false
        cell.memberLocation.isHidden = true//false
        
        if contentType == "user"
        {
            cell.addtolist.isHidden = false
        }
        else
        {
            cell.addtolist.isHidden = true
        }
        cell.addtolist.tag = indexPath.row
        cell.addtolist.addTarget(self, action: #selector(redirecttolist(_:)), for: .touchUpInside)
        cell.memberMutualFriends.isHidden = true//false
        cell.memberAge.text = ""
        cell.memberLocation.text = ""
        cell.memberMutualFriends.text = ""
        cell.endDateLabel.isHidden = true
        
        cell.memberOnlineLabel.frame = CGRect(x: cell.imgUser.bounds.width - 15, y: cell.imgUser.bounds.height - 10, width: 10, height: 10)
        cell.memberOnlineLabel.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        cell.memberOnlineLabel.text = "\u{f007}"
        
        if memberInfo.memberStatus != nil{
            if memberInfo.memberStatus == 1{
                cell.memberOnlineLabel.textColor = UIColor.init(red: 101/255, green: 204/255, blue: 0, alpha: 1)
                cell.memberOnlineLabel.layer.shadowColor = shadowColor.cgColor
            }else{
                cell.memberOnlineLabel.textColor = UIColor.gray
            }
        }
        
        cell.memberOnlineLabel.sizeToFit()
        if memberInfo.memberStatus == nil || memberInfo.memberStatus == 0{
            cell.memberOnlineLabel.isHidden = true
        }
        
        //Creating an array of profile fields
        var profileFieldsDictionary = Dictionary<String, String>()
        
        if memberInfo.age != nil && memberInfo.age > 0{
            profileFieldsDictionary["age"] = "\(memberInfo.age)"
        }
        
        if memberInfo.location != nil && memberInfo.location != ""{
            profileFieldsDictionary["location"] = memberInfo.location
        }
        
        if memberInfo.mutualFriendCount != nil && memberInfo.mutualFriendCount > 0{
            profileFieldsDictionary["mutualFriends"] = "\(memberInfo.mutualFriendCount)"
        }
        
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 30)
        
        if profileFieldsDictionary.count == 0{
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.imgUser.bounds.height/2,width: (UIScreen.main.bounds.width - 75) , height: 30)
            cell.memberAge.isHidden = true
            cell.memberLocation.isHidden = true
            cell.memberMutualFriends.isHidden = true
        }
        
        // Set Name People who Likes Content
        
        if memberInfo.displayname != ""
        {
            cell.labTitle.text = memberInfo.displayname
        }
        else
        {
            cell.labTitle.text = memberInfo.username
        }
        
        
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.sizeToFit()
        
        heightForFields = 20 + cell.labTitle.bounds.height
        
        
        //For showing 1st profile field if exists
        if profileFieldsDictionary.count > 0{
            
            cell.memberAge.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width - 80), height: 20)
            cell.memberAge.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.memberAge.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
            
            if profileFieldsDictionary.index(forKey: "location") != nil{
                
                cell.memberAge.text = "\(locationIcon) " + memberInfo.location
                
                profileFieldsDictionary.removeValue(forKey: "location")
                
            }
            else if profileFieldsDictionary.index(forKey: "age") != nil{
                if memberInfo.age != 1{
                    cell.memberAge.text = "\(cakeIcon) " + String(memberInfo.age) + " years old"
                }else{
                    cell.memberAge.text = "\(cakeIcon) " + String(memberInfo.age) + " year old"
                }
                profileFieldsDictionary.removeValue(forKey: "age")
            }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                
                if memberInfo.mutualFriendCount != 1{
                    cell.memberAge.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friends"
                }else{
                    cell.memberAge.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friend"
                }
                profileFieldsDictionary.removeValue(forKey: "mutualFriends")
            }
            //cell.memberAge.sizeToFit()
            heightForFields = heightForFields + cell.memberAge.bounds.height + 2
            
            
        }else{
            if cell.memberAge.text == ""{
                cell.memberAge.isHidden = true
            }
        }
        
        //For showing 2nd profile field if exists
        if profileFieldsDictionary.count > 0{
            
            cell.memberLocation.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width - 80), height: 20)
            cell.memberLocation.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.memberLocation.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
            
            if profileFieldsDictionary.index(forKey: "location") != nil{
                
                cell.memberLocation.text = "\(locationIcon) " + memberInfo.location
                
                profileFieldsDictionary.removeValue(forKey: "location")
            }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                
                if memberInfo.mutualFriendCount != 1{
                    cell.memberLocation.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friends"
                }else{
                    cell.memberLocation.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friend"
                }
                profileFieldsDictionary.removeValue(forKey: "mutualFriends")
            }
            //cell.memberLocation.sizeToFit()
            heightForFields = heightForFields + cell.memberLocation.bounds.height + 2
        }else{
            if cell.memberLocation.text == ""{
                cell.memberLocation.isHidden = true
            }
            
        }
        
        //For showing 3rd profile field if exists
        if profileFieldsDictionary.count > 0{
            
            cell.memberMutualFriends.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width - 80), height: 20)
            cell.memberMutualFriends.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.memberMutualFriends.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
            
            if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                if memberInfo.mutualFriendCount != 1{
                    cell.memberMutualFriends.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friends"
                }else{
                    cell.memberMutualFriends.text = "\(groupIcon) " + String(memberInfo.mutualFriendCount) + " mutual friend"
                }
                profileFieldsDictionary.removeValue(forKey: "mutualFriends")
            }
            //cell.memberMutualFriends.sizeToFit()
            heightForFields = heightForFields + cell.memberLocation.bounds.height + 2
        }else{
            if cell.memberMutualFriends.text == ""{
                cell.memberMutualFriends.isHidden = true
            }
            
        }
        
        if let url = URL(string: memberInfo.image_profile!){
            
            cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })
        }
        
        if let menu = memberInfo.menus
        {
            if menu.count > 0
            {
                
                let nameString = menu["name"]as! String
                
                if (nameString == "remove_friend") ||  (nameString == "member_unfollow"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size: 16)//FONTSIZELarge
                    optionMenu.addTarget(self, action: #selector(MemberViewController.menuAction(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = (indexPath as NSIndexPath).row
                    cell.accessoryView?.frame = CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height)
                    
                    cell.accessoryView = optionMenu
                    
                }
                else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size: 16) //FONTSIZELarge
                    optionMenu.addTarget(self, action: #selector(MemberViewController.menuAction(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = (indexPath as NSIndexPath).row
                    cell.accessoryView?.frame = CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height)
                    
                    cell.accessoryView = optionMenu
                    
                }
                    
                else if (nameString == "add_friend") || (nameString == "member_follow"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorMedium)
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size: 16) //FONTSIZELarge
                    optionMenu.addTarget(self, action: #selector(MemberViewController.menuAction(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = (indexPath as NSIndexPath).row
                    cell.accessoryView?.frame = CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height)
                    
                    cell.accessoryView = optionMenu
                    
                }
            }
        }
        
        if(logoutUser == false){
            if memberInfo.user_id != nil {
                if memberInfo.user_id == currentUserId{
                    
                    cell.accessoryView = nil
                }
            }
        }
        return cell
    }
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let  memberInfo = allMembers[(indexPath as NSIndexPath).row]
        
        if let menuItem = memberInfo.menus{
            
            if let urlParam = menuItem["urlParams"] as? NSDictionary{
                
                var user_id : Int = 0
                if let id = urlParam["user_id"] as? Int
                {
                    user_id = id
                }
                else if let id = urlParam["resource_id"] as? Int
                {
                    user_id = id
                }
                
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = user_id
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            
        } else{
            if let user_id = memberInfo.user_id{
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = user_id
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
        }
        
    }
    
    @objc func searchItem(){
        filterSearchFormArray.removeAll(keepingCapacity: false)
        let presentedVC = MemberSearchViewController()
        if viewType == "1" {
            presentedVC.mapormember = 0
        }
        else
        {
            presentedVC.mapormember = 1
        }
        presentedVC.contentType = "members"
        presentedVC.viewType = viewType
        presentedVC.isComingFromMemberController = true
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && customLimit*pageNumber < totalItems){
                    
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        membersTableView.tableFooterView?.isHidden = false
                        findAllMembers()
                    }
                }
                else
                {
                    membersTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
    }

    @objc func addNewMember(){
        let presentedVC = MemberViewController()
        presentedVC.contentType = "members"
        presentedVC.navLeftIcon = true
        presentedVC.fromTab = true
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Set Location
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        
        let CameraLatitude = self.defaults.double(forKey:"Latitude")
        let CameraLongitude = self.defaults.double(forKey:"Longitude")
        
        if CameraLatitude == 0.0 && CameraLongitude == 0.0 && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 && setLocation == true{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    if AppLauchForMember == true {
                        AppLauchForMember = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        defaults.set(true, forKey: "showMsg")
                    }
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
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
                if AppLauchForMemberGPS == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
                    AppLauchForMemberGPS = false
                    gpsLocation(controller: self)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let userLocation :CLLocation = locations[0] as CLLocation
        if didFindLocation == false
        {
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
                        print("\(placemarks!)")
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
                        
                        if placemark.subLocality != nil
                        {
                            subLocality = placemark.subLocality!
                        }
                        if placemark.locality != nil
                        {
                            locality = placemark.locality!
                        }
                        if placemark.administrativeArea != nil
                        {
                            administrativeArea = placemark.administrativeArea!
                        }
                        if placemark.country != nil
                        {
                            country = placemark.country!
                        }
                        let defaults = UserDefaults.standard
                        
                        print(postalCode)
                        var prePostalCode = defaults.string(forKey:"postalCode")
                        if prePostalCode == nil
                        {
                            prePostalCode = "0"
                        }
                        print(prePostalCode!)
//                        postalCode != prePostalCode! && locationOnhome == 1
                        if locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1
                        {
                            defaultlocation = "\(subLocality),\(locality), \(administrativeArea), \(country)"
                            
                            defaults.set(postalCode, forKey: "postalCode")
                            
                            defaults.set(defaultlocation, forKey: "Location")
                            self.view.makeToast("Your current location is set \(defaultlocation).", duration: 3, position: "bottom")
                            
                            let location = locations.last! as CLLocation
                            let currentLatitude = location.coordinate.latitude
                            let currentLongitude = location.coordinate.longitude
                            
                            defaults.set(currentLatitude, forKey: "Latitude")
                            defaults.set(currentLongitude, forKey: "Longitude")
                            
                            print(currentLatitude)
                            print(currentLongitude)
                            
                            self.kCameraLatitude = currentLatitude
                            self.kCameraLongitude = currentLongitude
                            
                            setDeviceLocation(location: defaultlocation, latitude: currentLatitude, longitude: currentLongitude, country: country, state: state, zipcode: postalCode, city: city, countryCode: countryCode)
                            
                            self.findAllMembers()
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
