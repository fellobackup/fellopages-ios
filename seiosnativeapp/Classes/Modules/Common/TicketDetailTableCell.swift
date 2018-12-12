//
//  TicketDetailTableCell2.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 03/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class TicketDetailTableCell: UITableViewCell
{
    var title : UILabel!
    var titleInfo : UILabel!
    var lineView:UIView!
    var cellView : UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellView = createView(CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 80), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        cellView.backgroundColor = UIColor.clear
        cellView.isUserInteractionEnabled = true
        self.addSubview(cellView)
        
        title = createLabel(CGRect(x: 10, y: 5, width: cellView.frame.size.width-40, height: 30), text: "Title", alignment: .left, textColor: textColorDark)
        title.font = UIFont(name: fontBold, size: 16)
        title.textAlignment = NSTextAlignment.left
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        title.numberOfLines = 1
        title.backgroundColor = UIColor.clear
        cellView.addSubview(title)
        
        titleInfo = createLabel(CGRect(x: 10, y: 40, width: cellView.frame.size.width-40, height: 30), text: "Detail", alignment: .left, textColor: textColorDark)
        titleInfo.font = UIFont(name: fontName, size: 16)
        titleInfo.textAlignment = NSTextAlignment.left
        titleInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleInfo.numberOfLines = 1
        titleInfo.backgroundColor = UIColor.clear
        //fileTitle.sizeToFit()
        cellView.addSubview(titleInfo)
        
        lineView = createView(CGRect(x: 0,y: cellView.frame.size.height-1,width: cellView.frame.size.width,height: 1), borderColor: borderColorMedium, shadow: false)
        lineView.layer.borderWidth = 0.0
        lineView.backgroundColor = UIColor(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1.0)
        cellView.addSubview(lineView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
