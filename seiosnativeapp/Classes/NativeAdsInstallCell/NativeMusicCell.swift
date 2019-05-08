//
//  NativeMusicCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 25/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeMusicCell: UITableViewCell {

    var MusicPlays1 : UILabel!
    var classifiedImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            size = (UIScreen.main.bounds.width - (4 * PADING))
        }
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
         
        
        classifiedImageView1 = Content1ImageViewWithGradient(frame: CGRect(x: (2 * PADING) + size  , y: contentPADING, width: size - 2*PADING , height: 160-5))
        classifiedImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView1.layer.masksToBounds = true
        classifiedImageView1.isUserInteractionEnabled = true
        classifiedImageView1.backgroundColor = placeholderColor
        classifiedImageView1.layer.shadowOpacity =  0.0
        
        self.addSubview(classifiedImageView1)
        
        //        bottomImageView1 = createImageView(CGRect(x:(2*PADING) + size  , 150, size, 50), true)
        //        bottomImageView1.contentMode = UIView.ContentMode.ScaleAspectFill
        //        bottomImageView1.layer.masksToBounds = true
        //        bottomImageView1.backgroundColor =  UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        self.addSubview(bottomImageView1)
        //
        
        menu1 = createButton(CGRect(x: classifiedImageView1.bounds.width - 40,y: 0, width: 40, height: 35), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu1.isHidden = true
        classifiedImageView1.addSubview(menu1)
        
        
        classifiedName1 = createLabel(CGRect(x: (3*PADING) + size  , y: 110, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName1.numberOfLines = 1
        classifiedName1.text = "Classified"
        
        
        
        //        classifiedName1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        classifiedName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(classifiedName1)
        
        MusicPlays1 = createLabel(CGRect(x: 3 * PADING + size , y: 135, width: size, height: 15), text: "", alignment: .left, textColor: textColorLight)
        MusicPlays1.numberOfLines = 0
        MusicPlays1.font = UIFont(name: fontName, size: FONTSIZESmall)
        //        classifiedName.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.addSubview(MusicPlays1)
        MusicPlays1.isHidden = true
        
        
        
        
        contentSelection1 = createButton(CGRect(x: 0, y: 35, width: classifiedImageView1.bounds.width, height: classifiedImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.layer.borderWidth = 0.0
        classifiedImageView1.addSubview(contentSelection1)
        
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
