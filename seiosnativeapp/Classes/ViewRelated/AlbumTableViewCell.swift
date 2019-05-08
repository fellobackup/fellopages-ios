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
//  AlbumTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// Currently NOt Used

class AlbumTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //LHS
    var albumCoverImage:UIImageView!
    var albumName:UILabel!
    var totalPhotos: UILabel!
    var createdBy: UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var totalMembers: UILabel!
    var photoCount : UILabel!
    
    //Middle
    var albumCoverImage1:UIImageView!
    var albumName1:UILabel!
    var totalPhotos1: UILabel!
    var createdBy1: UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var totalMembers1: UILabel!
    var photoCount1 : UILabel!
    
    //RHS
    var albumCoverImage2:UIImageView!
    var albumName2:UILabel!
    var totalPhotos2: UILabel!
    var createdBy2: UILabel!
    var menu2: UIButton!
    var contentSelection2:UIButton!
    var totalMembers2: UILabel!
    var photoCount2 : UILabel!
    var gifImageView : UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width )/3
        }else{
            size = (UIScreen.main.bounds.width)
        }
        
        
        
        //LHS
        albumCoverImage = ContentImageViewWithGradient(frame: CGRect(x: 0 , y: 0, width: size, height: 250))
        albumCoverImage.contentMode = UIView.ContentMode.scaleAspectFill
        albumCoverImage.layer.masksToBounds = true
        albumCoverImage.isUserInteractionEnabled = true
        albumCoverImage.backgroundColor = placeholderColor
        albumCoverImage.layer.shadowColor = shadowColor.cgColor
        albumCoverImage.layer.shadowOpacity = shadowOpacity
        albumCoverImage.layer.shadowRadius = shadowRadius
        albumCoverImage.layer.shadowOffset = shadowOffset
        self.addSubview(albumCoverImage)
        
        gifImageView = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView.center = albumCoverImage.center
        gifImageView.image = UIImage(named: "gif_icon.png")
        gifImageView.isHidden = true
        albumCoverImage.addSubview(gifImageView)
        
        albumName = createLabel(CGRect(x: 0, y: 180, width: (albumCoverImage.bounds.width), height: 40), text: "", alignment: .left, textColor: textColorLight)
        albumName.font = UIFont(name: fontName, size: FONTSIZELarge)
        //        albumName.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage.addSubview(albumName)
        
        
        photoCount = createLabel(CGRect(x: 5, y: 210, width: (albumCoverImage.bounds.width), height: 30), text: "", alignment: .left, textColor: textColorLight)
        photoCount.font = UIFont(name: fontName, size: FONTSIZEMedium)
        albumCoverImage.addSubview(photoCount)
        
        
        
        totalMembers = createLabel(CGRect(x: (albumCoverImage.bounds.width) - 75, y: 210, width: 70 , height: 30), text: "", alignment: .right, textColor: textColorLight)
        totalMembers.font = UIFont(name: fontBold, size: FONTSIZELarge)
        albumCoverImage.addSubview(totalMembers)
        
        
        totalPhotos = createLabel(CGRect( x: albumCoverImage.bounds.width - 30,y: 0,width: 30, height: 30), text: "", alignment: .center, textColor: textColorDark)
        totalPhotos.font = UIFont(name: fontName, size: FONTSIZELarge)
        totalPhotos.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        albumCoverImage.addSubview(totalPhotos)
        totalPhotos.isHidden = true
        
        createdBy = createLabel(CGRect(x: 0, y: 0, width: albumCoverImage.bounds.width - 30, height: 30), text: "", alignment: .left, textColor: textColorDark)
        createdBy.font = UIFont(name: fontBold, size: FONTSIZENormal)
        createdBy.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        albumCoverImage.addSubview(createdBy)
        
        
        
        
        menu = createButton(CGRect(x: albumCoverImage.bounds.width - 40,y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.isHidden = true
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        albumCoverImage.addSubview(menu)
        
        contentSelection = createButton(CGRect(x: 0, y: 40, width: albumCoverImage.bounds.width, height: albumCoverImage.bounds.height - 60), title: "", border: false,bgColor: false, textColor: textColorLight)
        albumCoverImage.addSubview(contentSelection)
        
        
        //Middle
        albumCoverImage1 = ContentImageViewWithGradient(frame: CGRect(x: size  , y: 0, width: size, height: 250))
        albumCoverImage1.contentMode = UIView.ContentMode.scaleAspectFill
        albumCoverImage1.layer.masksToBounds = true
        albumCoverImage1.isUserInteractionEnabled = true
        albumCoverImage1.backgroundColor = placeholderColor
        albumCoverImage1.layer.shadowColor = shadowColor.cgColor
        albumCoverImage1.layer.shadowOpacity = shadowOpacity
        albumCoverImage1.layer.shadowRadius = shadowRadius
        albumCoverImage1.layer.shadowOffset = shadowOffset
        self.addSubview(albumCoverImage1)
        
        
        albumName1 = createLabel(CGRect(x: 0, y: 180, width: (albumCoverImage1.bounds.width), height: 40), text: "", alignment: .left, textColor: textColorLight)
        albumName1.font = UIFont(name: fontBold, size: FONTSIZELarge)
        //        albumName1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage1.addSubview(albumName1)
        
        photoCount1 = createLabel(CGRect(x: 5, y: 210, width: (albumCoverImage1.bounds.width), height: 30), text: "", alignment: .left, textColor: textColorLight)
        photoCount1.font = UIFont(name: fontName, size: FONTSIZELarge)
        //        albumName.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage1.addSubview(photoCount1)
        
        
        
        totalMembers1 = createLabel(CGRect(x: (albumCoverImage1.bounds.width) - 65, y: 210, width: 60, height: 30), text: "", alignment: .left, textColor: textColorLight)
        totalMembers1.font = UIFont(name: fontBold, size: FONTSIZELarge)
        //        totalMembers1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage1.addSubview(totalMembers1)
        
        
        totalPhotos1 = createLabel(CGRect(x: albumCoverImage1.bounds.width - 30,y: 0,width: 30, height: 30), text: "", alignment: .center, textColor: textColorDark)
        totalPhotos1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        totalPhotos1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        albumCoverImage1.addSubview(totalPhotos1)
        totalPhotos1.isHidden = true
        
        
        createdBy1 = createLabel(CGRect(x: 0, y: 0, width: albumCoverImage1.bounds.width - 30, height: 30), text: "", alignment: .left, textColor: textColorDark)
        createdBy1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        createdBy1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        albumCoverImage1.addSubview(createdBy1)
        
        menu1 = createButton(CGRect(x: albumCoverImage1.bounds.width - 40,y: 0,width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
        //        menu1.setImage(UIImage(named: "icon-option.png"), forState: .normal)
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu1.isHidden = true
        menu1.layer.shadowColor = shadowColor.cgColor
        menu1.layer.shadowOpacity = shadowOpacity
        menu1.layer.shadowRadius = shadowRadius
        menu1.layer.shadowOffset = shadowOffset
        
        albumCoverImage1.addSubview(menu1)
        
        contentSelection1 = createButton(CGRect(x: 0, y: 40, width: albumCoverImage1.bounds.width, height: albumCoverImage1.bounds.height - 60), title: "", border: false,bgColor: false, textColor: textColorLight)
        albumCoverImage1.addSubview(contentSelection1)
        
        
        //RHS
        albumCoverImage2 = ContentImageViewWithGradient(frame: CGRect(x: ( 2 * size)  , y: 0, width: size, height: 250))
        albumCoverImage2.contentMode = UIView.ContentMode.scaleAspectFill
        albumCoverImage2.layer.masksToBounds = true
        albumCoverImage2.isUserInteractionEnabled = true
        albumCoverImage2.backgroundColor = placeholderColor
        
        albumCoverImage2.layer.shadowColor = shadowColor.cgColor
        albumCoverImage2.layer.shadowOpacity = shadowOpacity
        albumCoverImage2.layer.shadowRadius = shadowRadius
        albumCoverImage2.layer.shadowOffset = shadowOffset
        
        self.addSubview(albumCoverImage2)
        
        albumName2 = createLabel(CGRect(x: 0, y: 180, width: (albumCoverImage2.bounds.width), height: 40), text: "", alignment: .left, textColor: textColorLight)
        albumName2.font = UIFont(name: fontBold, size: FONTSIZELarge)
        //        albumName2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage2.addSubview(albumName2)
        
        
        photoCount2 = createLabel(CGRect(x: 5, y: 210, width: (albumCoverImage2.bounds.width), height: 30), text: "", alignment: .left, textColor: textColorLight)
        photoCount2.font = UIFont(name: fontBold, size: FONTSIZELarge)
        //        albumName.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        albumCoverImage2.addSubview(photoCount2)
        
        
        totalMembers2 = createLabel(CGRect(x: (albumCoverImage2.bounds.width) - 70, y: 210, width: 65, height: 30), text: "", alignment: .left, textColor: textColorLight)
        totalMembers2.font = UIFont(name: fontBold, size: FONTSIZELarge)
        albumCoverImage2.addSubview(totalMembers2)
        //        totalMembers2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // totalMembers2.addSubview(albumName2)
        
        
        totalPhotos2 = createLabel(CGRect( x: albumCoverImage2.bounds.width - 30,y: 0,width: 30, height: 30), text: "", alignment: .center, textColor: textColorDark)
        totalPhotos2.font = UIFont(name: fontName, size: FONTSIZEMedium)
        totalPhotos2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        albumCoverImage2.addSubview(totalPhotos2)
        totalPhotos2.isHidden = true
        
        
        createdBy2 = createLabel(CGRect(x: 0, y: 0, width: albumCoverImage2.bounds.width - 30, height: 30), text: "", alignment: .left, textColor: textColorDark)
        createdBy2.font = UIFont(name: fontBold, size: FONTSIZENormal)
        //        createdBy2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //albumCoverImage2.addSubview(createdBy2)
        
        menu2 = createButton(CGRect(x: albumCoverImage2.bounds.width - 40,y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
        //        menu2.setImage(UIImage(named: "icon-option.png"), forState: .normal)
        menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu2.isHidden = true
        menu2.layer.shadowColor = shadowColor.cgColor
        menu2.layer.shadowOpacity = shadowOpacity
        menu2.layer.shadowRadius = shadowRadius
        menu2.layer.shadowOffset = shadowOffset
        albumCoverImage2.addSubview(menu2)
        
        contentSelection2 = createButton(CGRect(x: 0, y: 40, width: albumCoverImage2.bounds.width, height: albumCoverImage2.bounds.height - 60), title: "", border: false,bgColor: false, textColor: textColorLight)
        albumCoverImage2.addSubview(contentSelection2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
