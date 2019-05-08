
//
//  NativeVideoCellTableViewCell.swift
//  seiosnativeapp
//
//  Created by Ankit on 23/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeVideoCellTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var cellView: UIView!
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: PADING, y: 0 ,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 230), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: PADING, y: 0,width: (UIScreen.main.bounds.width - 2*PADING) , height: 230), borderColor: borderColorMedium, shadow: false)
        }
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2 + PADING), y: 0,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 230), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.shadowColor = shadowColor.cgColor
            cellView2.layer.shadowOpacity = shadowOpacity
            cellView2.layer.shadowRadius = shadowRadius
            cellView2.layer.shadowOffset = shadowOffset
            self.addSubview(cellView2)
            
            contentImage2 = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            contentImage2.layer.masksToBounds = true
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill //UIView.ContentMode.ScaleAspectFill
            cellView2.addSubview(contentImage2)
            
            
            videoDuration2 = createLabel(CGRect(x: (contentImage2.bounds.width-50), y: 0, width: 50,height: 30), text: "", alignment: .center, textColor: textColorLight)
            videoDuration2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            videoDuration2.backgroundColor = UIColor.black
            videoDuration2.isHidden = true
            contentImage2.addSubview(videoDuration2)
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage2.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.cgColor
            contentName2.layer.shadowOpacity = shadowOpacity
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
            
//            videoPlayLabel2 = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "\u{f04b}", alignment: .center, textColor: textColorLight)
//            videoPlayLabel2.frame = contentImage2.frame
//            videoPlayLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
//            videoPlayLabel2.textAlignment = NSTextAlignment.center
//            cellView.addSubview(videoPlayLabel2)
            
        
           
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage2.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorDark
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage2.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
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
            imgVideo2.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            contentSelection2.addSubview(imgVideo2)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
