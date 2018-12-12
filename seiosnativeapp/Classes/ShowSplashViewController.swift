//
//  ShowSplashViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 16/10/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
var AppLauch : Bool = false
var AppLauchForLocation : Bool = false
var setLocation : Bool = false
var updateLocation : Bool = false

var AppLauchForMember : Bool = false
var AppLauchForMemberGPS : Bool = false

var AppLauchForMLT : Bool = false
var AppLauchForMLTGPS : Bool = false

class ShowSplashViewController: UIViewController {
  @IBOutlet weak var imageForSplash: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        AppLauch = true
        AppLauchForLocation = true
        setLocation = true
        
        AppLauchForMember = true
        AppLauchForMemberGPS = true
        
        AppLauchForMLT = true
        AppLauchForMLTGPS = true
        
        UserDefaults.standard.set(textColorDark, forKey: "linkColor")
        UserDefaults.standard.set(navColor, forKey: "activeLinkColor")
        
        self.view.backgroundColor = navColor
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.configAnimation()
        if reachability.connection != .none
        {
            let appId = UserDefaults.standard.integer(forKey: "appItunesId")
            if appId == 0
            {
               getAppId()
            }
            
        }

    }
    
    func getAppId()
    {
        let bundleID = Bundle.main.bundleIdentifier
        let bundleResponse = URL(string:"https://itunes.apple.com/lookup?bundleId=\(bundleID!)")
        let task = URLSession.shared.dataTask(with: bundleResponse!, completionHandler: { (data, response, error) -> Void in
            
            if let urlContent = data
            {
                do
                {
                    let jsonResult =  try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let jsonResults = jsonResult as? NSDictionary
                    {
                        //print(jsonResults)
                        if jsonResults["resultCount"] as! Int != 0 {
                            if jsonResults["results"] != nil{
                                
                                if let results = jsonResults["results"] as? NSArray
                                {
                                    if let result = results[0] as? NSDictionary
                                    {
                                        let appId = result["trackId"]
                                        UserDefaults.standard.set(appId, forKey: "appItunesId")
                                        
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    //print("JSON serialization failed")
                }
            }
        })
        task.resume()
    }
    
    func configAnimation()
    {
        var spalshName = ""
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            spalshName = "640_1136.png"
        case 667.0:
            spalshName = "750_1334.png"
        case 736.0:
            spalshName = "1242_2208.png"
        case 812.0:
            spalshName = "1125_2436.png"
        case 1024.0:
            spalshName = "1536_2048.png"
        default:
            spalshName = "1536_2048.png"
            
        }
        if UIImage(named:"Splash-768x1024.gif") != nil
        {
            let gifImage = UIImage(gifName: spalshName, levelOfIntegrity:0.8)
            let gifmanager = SwiftyGifManager(memoryLimit:20)
            imageForSplash.setGifImage(gifImage, manager: gifmanager, loopCount: 1)
            imageForSplash.contentMode = UIViewContentMode.scaleAspectFill
            // Do any additional setup after loading the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + splashAnimationTime) {
                // do stuff 3 seconds later
                self.redirectToLogin()
            }
            
        }
        else
        {

            imageForSplash.contentMode = UIViewContentMode.scaleAspectFill
            imageForSplash.image = UIImage(named:spalshName)
            DispatchQueue.main.asyncAfter(deadline: .now() + splashAnimationTime) {
                // do stuff 3 seconds later
                self.redirectToLogin()
            }
        }

    }
    func  redirectToLogin(){
        
        if (auth_user == true  && oauth_token != nil)
        {
            self.showHomePage()
        }
        else
        {

            let obj = DashboardViewController()
            obj.getDynamicDashboard()
            if showAppSlideShow == 1
            {
               let VC = LoginSlideShowViewController()
                self.navigationController?.pushViewController(VC, animated: true)
                
            }
            else
            {
            let VC = LoginScreenViewController()
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(VC, animated: true)
            }
           
        }
    }
    // MARK: - Member Homepage redirection
    func showHomePage () {
        menuRefreshConter = 0
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func set(_ value: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = value {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
    
}
