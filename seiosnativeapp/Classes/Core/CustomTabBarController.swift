//
//  CustomTabBarController.swift
//  seiosnativeapp
//
//  Created by bigstep on 07/06/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    var shouldRotate: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: fontName, size: FONTSIZELarge - 5.0)!], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : buttonColor], for: UIControlState.selected)
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = buttonColor
        tabBar.layer.borderWidth = 0.3
        tabBar.layer.borderColor = UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:0.2).cgColor
        tabBar.clipsToBounds = true
    }
    override var shouldAutorotate : Bool { //allow the subviews accessing the tabBarController to set whether they should rotate or not
        return self.shouldRotate
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.selectedIndex == 4 {
            let yourView = self.viewControllers![self.selectedIndex] as! UINavigationController
            yourView .popToRootViewController(animated: false)
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            tabBar.invalidateIntrinsicContentSize()

        }else{
            var tabFrame            = tabBar.frame
            tabFrame.size.height    = 45
            tabFrame.origin.y       = view.frame.size.height - 45
            tabBar.frame            = tabFrame
        }
        // For changing TabBar icon color
        if let items = tabBar.items {
            for item in items {
                item.title = nil
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
                if let image = item.image {
                    item.image = image.imageWithColor(tintColor: UIColor(red: 96/255 , green: 96/255 , blue: 96/255, alpha: 1.0)).withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
}

