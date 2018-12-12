//
//  NativeAdinstallFeedCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import GoogleMobileAds
class NativeAdinstallFeedCell: UITableViewCell
{
    
    var cellView = UIView()
    var profile_photo:UIImageView!
    var title:TTTAttributedLabel!
    var body:TTTAttributedLabel!
    var Adimageview:UIImageView!
    var Adiconview:UIImageView!
    var callToActionView:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        cellView.frame = CGRect(x: 0, y: 5,width: UIScreen.main.bounds.width ,height: 270)
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        
        cellView.backgroundColor = UIColor.white
        self.addSubview(cellView)
        if adsType_feeds == 0 || adsType_feeds == 1{
                Adiconview = createImageView(CGRect(x: cellView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
                Adiconview.image = UIImage(named: "ad_badge.png")
                cellView.addSubview(Adiconview)
        }

        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

