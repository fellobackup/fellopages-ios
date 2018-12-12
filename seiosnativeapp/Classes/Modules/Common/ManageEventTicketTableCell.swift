//
//  ManageEventTicketTableCell.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 02/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class ManageEventTicketTableCell: UITableViewCell
{
    var ticketTitle : UILabel!
    var cellView : UIView!
    var ticketPrice : UILabel!
    var ticketQuantity : UILabel!
    var btnMenu : UIButton!
    var lineView:UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellView = createView(CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 111), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        cellView.backgroundColor = UIColor.clear
        cellView.isUserInteractionEnabled = true
        self.addSubview(cellView)
        
        ticketTitle = createLabel(CGRect(x: 10, y: 5, width: cellView.frame.size.width-40, height: 30), text: "Title", alignment: .left, textColor: textColorDark)
        ticketTitle.font = UIFont(name: fontName, size: 16)
        ticketTitle.textAlignment = NSTextAlignment.left
        ticketTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        ticketTitle.numberOfLines = 1
        ticketTitle.backgroundColor = UIColor.clear
        //fileTitle.sizeToFit()
        cellView.addSubview(ticketTitle)
        
        ticketPrice = createLabel(CGRect(x: 10, y: 40, width: cellView.frame.size.width-40, height: 30), text: "Price", alignment: .left, textColor: textColorDark)
        ticketPrice.font = UIFont(name: fontName, size: 16)
        ticketPrice.textAlignment = NSTextAlignment.left
        ticketPrice.lineBreakMode = NSLineBreakMode.byWordWrapping
        ticketPrice.numberOfLines = 1
        ticketPrice.backgroundColor = UIColor.clear
        //downloadTitle.sizeToFit()
        cellView.addSubview(ticketPrice)
        
        ticketQuantity = createLabel(CGRect(x: 10, y: 75, width: cellView.frame.size.width-40, height: 30), text: "Quantity", alignment: .left, textColor: textColorDark)
        ticketQuantity.font = UIFont(name: fontName, size: 16)
        ticketQuantity.textAlignment = NSTextAlignment.left
        ticketQuantity.lineBreakMode = NSLineBreakMode.byWordWrapping
        ticketQuantity.numberOfLines = 1
        ticketQuantity.backgroundColor = UIColor.clear
        //extensionTitle.sizeToFit()
        cellView.addSubview(ticketQuantity)
        
        btnMenu = createButton(CGRect(x: cellView.frame.size.width-40, y: cellView.frame.size.height/2-15, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: textColorMedium)
        btnMenu.setImage(UIImage(named: "verticaldots.png"), for: UIControlState())
        //btnMenu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        cellView.addSubview(btnMenu)
        
        lineView = createView(CGRect(x: 0,y: cellView.frame.size.height-1,width: cellView.frame.size.width,height: 1), borderColor: borderColorMedium, shadow: false)
        lineView.layer.borderWidth = 0.0
        lineView.backgroundColor = UIColor(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1.0)
        cellView.addSubview(lineView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
