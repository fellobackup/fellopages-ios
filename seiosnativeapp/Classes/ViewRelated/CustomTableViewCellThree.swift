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
//  CustomTableViewCellThree.swift
//  seiosnativeapp
//

import UIKit

// This Class is used by GroupViewController & EventViewController

class CustomTableViewCellThree: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var cellView: UIView!
    var contentImage:UIImageView!
    var contentName:UILabel!
    var totalMembers: UILabel!
    var createdBy: TTTAttributedLabel!
    var menu: UIButton!
    var eventTime :UILabel!
    var contentSelection:UIButton!
    var videoDuration : UILabel!
    var imgVideo : UIButton!
    
    var cellView2: UIView!
    var contentImage2:UIImageView!
    var contentName2:UILabel!
    var totalMembers2: UILabel!
    var createdBy2: TTTAttributedLabel!
    var menu2: UIButton!
    var eventTime2 :UILabel!
    var contentSelection2:UIButton!
    var videoDuration2 : UILabel!
    var imgVideo2 : UIButton!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS

        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: 2*PADING, y: 0 ,width: (UIScreen.main.bounds.width/2 - 4*PADING) , height: 230), borderColor: textColorclear, shadow: false)
        }else{
            cellView = createView( CGRect(x: 2*PADING, y: 0,width: (UIScreen.main.bounds.width - 4*PADING) , height: 230), borderColor: textColorclear, shadow: false)
        }
        

        self.addSubview(cellView)
        
        contentImage = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: false)
        contentImage.layer.cornerRadius = cornerRadiusSmall
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIViewContentMode.scaleAspectFill
        cellView.addSubview(contentImage)
        
        
        videoDuration = createLabel(CGRect(x: (contentImage.bounds.width-60), y: 0, width: 60,height: 25), text: "", alignment: .center, textColor: textColorLight)
        videoDuration.font = UIFont(name: fontName, size: FONTSIZENormal)
        videoDuration.backgroundColor = UIColor.black
        videoDuration.isHidden = true
        contentImage.addSubview(videoDuration)
        
        // Set

        contentName = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
        
        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        cellView.addSubview(contentName)
        
        
        totalMembers = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
        totalMembers.font = UIFont(name: fontName, size: FONTSIZESmall)
        totalMembers.textAlignment = .center
        cellView.addSubview(totalMembers)
        
   
        
        
        
        createdBy = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage.bounds.width-120, height: 40))
        createdBy.textAlignment = .right
        createdBy.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        createdBy.textColor = textColorDark
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdBy)
        
        eventTime = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.red
        cellView.addSubview(eventTime)
        
        menu = createButton(CGRect(x: contentImage.bounds.width-40, y: 140, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight )
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        cellView.addSubview(menu)
        
        contentSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height-90)
        self.addSubview(contentSelection)
        imgVideo = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentSelection.bounds.height/2) - 30, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorMedium)
        imgVideo.center = contentImage.center
        imgVideo.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControlState.normal)
        contentSelection.addSubview(imgVideo)
        

        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2 + (2*PADING)), y: 0,width: (UIScreen.main.bounds.width/2 - 4*PADING) , height: 230), borderColor: textColorclear, shadow: false)

            self.addSubview(cellView2)
            

            contentImage2 = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            contentImage2.layer.masksToBounds = true
            contentImage2.contentMode = UIViewContentMode.scaleAspectFill //UIViewContentMode.ScaleAspectFill
            cellView2.addSubview(contentImage2)
            
            
            videoDuration2 = createLabel(CGRect(x: (contentImage2.bounds.width-50), y: 0, width: 50,height: 30), text: "", alignment: .center, textColor: textColorLight)
            videoDuration2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            videoDuration2.backgroundColor = UIColor.black
            videoDuration2.isHidden = true
            contentImage2.addSubview(videoDuration2)
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            
            contentName2.numberOfLines = 0
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
    
           
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
            createdBy2.textColor = textColorDark
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            

            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRect(x: contentImage2.bounds.width-40, y: 140, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menu2.layer.shadowColor = shadowColor.cgColor

            menu2.layer.shadowOpacity = shadowOpacity
            menu2.layer.shadowRadius = shadowRadius
            menu2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(menu2)
            
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-90)
            self.addSubview(contentSelection2)
            imgVideo2 = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentSelection2.bounds.height/2) - 30, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorMedium)
            imgVideo2.center = contentImage2.center
            imgVideo2.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControlState.normal)
            contentSelection2.addSubview(imgVideo2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
