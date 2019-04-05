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
//  AppDelegate.swift

import UIKit
import CoreData
import UserNotifications
import AVFoundation
import MediaPlayer
import Kingfisher
import MessageUI
import Firebase
import Fabric

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

let reachability = Reachability()!
var auth_user:Bool!
var oauth_secret:String!
var displayName:String!
var coverImage:String!
var coverImageBackgorund:String!
var enabledModules :NSArray! = []
var isChannelEnable : Bool = true
var isPlaylistEnable : Bool = true
var context:NSManagedObjectContext!
var logoutUser:Bool!
var refreshMenu:Bool = false
var currentUserId :Int = 0
var oauth_token:String! = ""
var device_token_id : String! = ""
var device_uuid : String! = ""
var dashboardRefreshInteger : Int = 0
var browseAsGuest = false
var ios_version : String!
var isOTPEnableplugin: Int = 0
var firstCompletionTime = true
var arrRecentSearchOptions = [String]()

//let kMapsAPIKey = "AIzaSyB7oOFvRUnqAmYj-Pe9B8KUNFZ7ffmIkX4"
let kMapsAPIKey = "AIzaSyC3aV5YJDASbdHaUQppnlekizpTWn0ywsI"
let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
       
        
        let freshInstall = !UserDefaults.standard.bool(forKey: "alreadyInstalled")
        if freshInstall
        {
            application.applicationIconBadgeNumber = 0
            UserDefaults.standard.set(true, forKey: "alreadyInstalled")
        }
        if kMapsAPIKey.isEmpty {
            fatalError("Please provide an API Key using kMapsAPIKey")
        }
        GMSServices.provideAPIKey(kMapsAPIKey)
        
        if #available(iOS 10.0, *)
        {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            let types: UNAuthorizationOptions = [UNAuthorizationOptions.badge, UNAuthorizationOptions.alert, UNAuthorizationOptions.sound]
            center.requestAuthorization(options: types, completionHandler: { (granted, error) in
                //print(granted)
                if (granted){
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            })
            
        }
        else
        {
            let types: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings( types: types, categories: nil )
            application.registerUserNotificationSettings( settings )
            application.registerForRemoteNotifications()
            // Fallback on earlier versions
        }

        
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            ios_version = version
        }
        else
        {
            ios_version = "1.5"
        }
        
        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
        userDefaults!.set(ios_version, forKey: "ios_version")
        userDefaults!.set(baseUrl, forKey: "baseUrl")
        userDefaults!.set(oauth_consumer_secret, forKey: "oauth_consumer_secret")
        userDefaults!.set(oauth_consumer_key, forKey: "oauth_consumer_key")
        userDefaults!.synchronize()
        // Override point for customization after application launch.
        _ = UserDefaults.standard.object(forKey: "menuRefreshLimit") as? String
        // make the status bar white
        application.statusBarStyle = .lightContent
        menuRefreshConter = 0
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = buttonColor
        
        
        
        let barAppearace = UIBarButtonItem.appearance()
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -80), for:UIBarMetrics.default)
        
        UINavigationBar.appearance().barStyle = UIBarStyle.default
        
        UINavigationBar.appearance().barTintColor = buttonColor
        UINavigationBar.appearance().tintColor = textColorPrime
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : textColorPrime, NSAttributedStringKey.font: UIFont(name: fontName, size: FONTSIZELarge + 3.0)!]
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        
//        let navigationBarAppearace = UINavigationBar.appearance()
//        navigationBarAppearace.setBackgroundImage(imagefromColor(navColor), for: .default)
//        navigationBarAppearace.shadowImage = imagefromColor(navColor)
//        navigationBarAppearace.isTranslucent = true
//        navigationBarAppearace.tintColor = textColorPrime
//        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName : textColorPrime, NSFontAttributeName: UIFont(name: fontName, size: FONTSIZELarge + 3.0)!]
//
//
//        let barAppearace = UIBarButtonItem.appearance()
//        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -80), for:UIBarMetrics.default)
        
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = nil
        }
        
        if #available(iOS 9.0, *) {
            //UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = navColor
            UINavigationBar.appearance(whenContainedInInstancesOf: [MFMessageComposeViewController.self]).barTintColor = navColor
            UINavigationBar.appearance(whenContainedInInstancesOf: [MFMessageComposeViewController.self]).titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font: UIFont(name: fontName, size: FONTSIZELarge + 3.0)!]
        } else {
            // Fallback on earlier versions
        }
        
        // Get Data From Core Data
        getDataFromCoredata()
        StoreReviewHelper.incrementAppOpenedCount()
        
        if (logoutUser == true)
        {
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        else
        {
            
            return true
        }
        
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //        reachability.stopNotifier()
        //        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
        //print("didReceiveMemoryWarning")
        let cache = KingfisherManager.shared.cache
        // Clear memory cache right away.
        cache.clearMemoryCache()
        // Clear disk cache. This is an async operation.
        cache.clearDiskCache()
        // Clean expired or size exceeded disk cache. This is an async operation.
        cache.cleanExpiredDiskCache()
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        //        reachability.startNotifier()
        firstCompletionTime = true
        application.applicationIconBadgeNumber = 0//notificationCount
        arrGlobalFacebookAds.removeAll()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func getDataFromCoredata()
    {
        context = managedObjectContext!
        
        let request: NSFetchRequest<UserInfo>
        
        if #available(iOS 10.0, *){
            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
        }else{
            request = NSFetchRequest(entityName: "UserInfo")
        }
        
        request.returnsObjectsAsFaults = false
        
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            for result: AnyObject in results!
            {
                if let token = result.value(forKey: "oauth_token") as? String
                {
                    oauth_token = token
                    
                    
                    let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                    userDefaults!.set(oauth_token, forKey: "oauth_token")
                    
                    if let auth_secret = result.value(forKey: "oauth_secret") as? String
                    {
                        oauth_secret = auth_secret
                        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                        userDefaults!.set(oauth_secret, forKey: "oauth_secret")
                    }
                    
                    if let displayCoverImage = result.value(forKey: "cover_image") as? String{
                        coverImage = displayCoverImage
                    }
                    if let displayUserName = result.value(forKey: "display_name") as? String{
                        displayName = displayUserName
                    }
                    if let tempCurrentUserId = result.value(forKey: "user_id") as? Int{
                        currentUserId = tempCurrentUserId
                    }
            
                    
                    auth_user = true
                    logoutUser = false
                    refreshMenu = true

                }
            }
            do
            {
                try context.save()
            }
            catch _ {
            }
        }
        else
        {
            auth_user = false
            logoutUser = true
            refreshMenu = true
        }
    
    }
    // fetching the device token
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        
        var deviceTokenString: String
        if #available(iOS 10.0, *){
            deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            //print(deviceTokenString)
        }else{
            let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
            
            deviceTokenString = ( deviceToken.description as NSString ).trimmingCharacters( in: characterSet ).replacingOccurrences( of: " ", with: "" ) as String
        }
        device_token_id = deviceTokenString
        device_uuid = UIDevice.current.identifierForVendor?.uuidString
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        } catch _ {
//        }
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch _ {

    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("test")
        return false
    }
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        //print( error.localizedDescription )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //print(userInfo)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         print("application_url: \(url)")
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    // MARK: - Reachability Changed
    
    func reachabilityChanged(_ note: Foundation.Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .none {
            removeAlert()
        } else {
            if userInteraction == false{
                UIApplication.shared.endIgnoringInteractionEvents()
                //print("No Internet")
            }
        }
    }
    
    // MARK: - Application Orientation stack
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if (self.window?.rootViewController?.presentedViewController as? LoginViewController) != nil {
            return UIInterfaceOrientationMask.portrait
        }else{
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        
    }
    
    
    //    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow) -> Int {
    //
    //        if self.window?.rootViewController?.presentedViewController? is PhotoViewController {
    //            if isPresented {
    //                return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    //            } else {
    //                return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    //            }
    //        } else {
    //             return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    //        }
    //
    //
    //
    //    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.seao.seiosnativeapp" in the application's documents Application Support directory.

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "seiosnativeapp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("seiosnativeapp.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption : true , NSInferMappingModelAutomaticallyOption : true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fa22il.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if baseController != nil{
            baseController.selectedIndex = 0
        }
        
        if userInfo["type"] != nil{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appNotification"), object: nil, userInfo: userInfo)
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "massNotification"), object: nil, userInfo: userInfo)
        }
        
        //Handle the notification
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState != UIApplicationState.background{
            if baseController != nil{
                baseController.selectedIndex = 0
            }
            
            if userInfo["type"] != nil{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appNotification"), object: nil, userInfo: userInfo)
            }
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "massNotification"), object: nil, userInfo: userInfo)
            }
        }
    }

    
}

