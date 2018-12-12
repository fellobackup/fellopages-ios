//
//  ContentSlideshowScrollView.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 8/22/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ContentSlideshowScrollView: UIScrollView {
    
    var contentView: UIView!
    var contentImage: UIImageView!
    var contentTitle: UILabel!
    var contentHeading: UILabel!
    var contentSelection: UIButton!
    var contentItemsCache: [AnyObject]!
    var iscomingFrom: String = ""
    var featureSponserlbl: UILabel!
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.tag = 898
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func browseSellContent(contentItems: [AnyObject],comingFrom : String){
        
        contentItemsCache = contentItems
        iscomingFrom = comingFrom
        var i = 0
        for ob in self.subviews{
            //  if let imageView = ob as? UIImageView {
            //      if imageView.tag != 9999{
            ob.removeFromSuperview()
            //       }
            //   }
        }
        for contentItem in contentItems{
            var widthSell : CGFloat = 0.0
            let xpoint = (CGFloat(i) * ((self.bounds.width * 6/8) + 10) + 10)
            if contentItems.count == 1 {
                widthSell = self.bounds.width - 2*xpoint
            }
            else{
                widthSell = self.bounds.width * 6/8
            }
            contentView = createView(CGRect(x:xpoint, y:5, width:widthSell, height:self.bounds.height - 10), borderColor: borderColorLight, shadow: true)
            
            self.addSubview(contentView)
            contentImage = createImageView(CGRect(x:0, y:0, width:contentView.bounds.width, height:contentView.bounds.height), border: false)
            contentImage.layer.cornerRadius = 2.0
            contentImage.layer.shadowColor = shadowColor.cgColor
            contentImage.layer.shadowOpacity = shadowOpacity
            contentImage.layer.shadowRadius = shadowRadius
            contentImage.layer.shadowOffset = shadowOffset
            
           
            if let url1 = contentItem["image_main"] as? String
            {
                let url1 = NSURL(string: url1)
                contentImage.kf.indicatorType = .activity
                (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
                contentImage.contentMode = .scaleAspectFill
                contentImage.layer.masksToBounds = true
                
            }
            else
            {
                contentImage.image = nil
                contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                
            }
            contentView.addSubview(contentImage)
            
            
           
            contentTitle = createLabel(CGRect(x:5, y:contentImage.bounds.height + 10, width:contentView.bounds.width - 10, height:20), text: " ", alignment: .center, textColor: textColorDark)
            contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            contentTitle.text = contentItem["title"] as? String
            contentTitle.lineBreakMode = .byTruncatingTail
            contentView.addSubview(contentTitle)
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
//            if comingFrom != "" {
//            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showSellPage), for: UIControlEvents.touchUpInside)
//            }
            contentSelection.tag = i
            self.addSubview(contentSelection)
            i += 1
            
        }
        var scrollWidth : CGFloat = 0.0
        if contentItems.count == 1 {
            let xpoint = (CGFloat(i) * ((self.bounds.width * 6/8) + 10) + 10)
            scrollWidth = self.bounds.width - 2*xpoint
        }
        else{
            scrollWidth = self.bounds.width * 6/8
        }
        let widthpoint = CGFloat(i) * (scrollWidth + 10) + 10
        self.contentSize = CGSize(width: widthpoint, height: 20)
    }
    
    func browseContent(contentItems: [AnyObject],comingFrom : String){
        
        contentItemsCache = contentItems
        iscomingFrom = comingFrom
        var i = 0
        for contentItem in contentItems{
            
            let xpoint = (CGFloat(i) * ((self.bounds.width * 3/8) + 10) + 10)
            contentView = createView(CGRect(x:xpoint, y:5, width:self.bounds.width * 3/8, height:self.bounds.height - 10), borderColor: borderColorLight, shadow: true)
            
            self.addSubview(contentView)
            contentImage = createImageView(CGRect(x:0, y:0, width:contentView.bounds.width, height:contentView.bounds.height - 40), border: false)
            contentImage.layer.cornerRadius = 2.0
            contentImage.layer.shadowColor = shadowColor.cgColor
            contentImage.layer.shadowOpacity = shadowOpacity
            contentImage.layer.shadowRadius = shadowRadius
            contentImage.layer.shadowOffset = shadowOffset

            if let url1 = contentItem["image"] as? String
            {
                let url1 = NSURL(string: url1)
                contentImage.kf.indicatorType = .activity
                (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
          
            else
            {
                contentImage.image = nil
                contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                
            }
            contentView.addSubview(contentImage)
            
            if iscomingFrom != ""
            {
                featureSponserlbl = createLabel(CGRect(x:5, y:0, width:60, height:20), text: " ", alignment: .center, textColor: textColorLight)
                featureSponserlbl.font = UIFont(name: fontName, size: FONTSIZESmall)
                featureSponserlbl.text = NSLocalizedString("Featured",  comment: "")
                featureSponserlbl.textAlignment = .center
                featureSponserlbl.backgroundColor = navColor
                contentImage.addSubview(featureSponserlbl)
            }
            contentTitle = createLabel(CGRect(x:5, y:contentImage.bounds.height + 10, width:contentView.bounds.width - 10, height:20), text: " ", alignment: .center, textColor: textColorDark)
            contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            contentTitle.text = contentItem["title"] as? String
            contentTitle.lineBreakMode = .byTruncatingTail
            contentView.addSubview(contentTitle)
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showStoreProfile), for: UIControlEvents.touchUpInside)
            contentSelection.tag = i
            self.addSubview(contentSelection)
            i += 1
            
        }
        
        let widthpoint = CGFloat(i) * ((self.bounds.width * 3/8) + 10) + 10
        self.contentSize = CGSize(width: widthpoint, height: 20)
    }
    
    @objc func showStoreProfile(sender: UIButton)
    {
        
        var storeInfo:NSDictionary!
        storeInfo = contentItemsCache[sender.tag] as! NSDictionary
        
        if(storeInfo["allow_to_view"] as! Int == 1)
        {
            switch iscomingFrom {
            case "Advanced Video":
                let presentedVC = AdvanceVideoProfileViewController()
                presentedVC.videoId = storeInfo["video_id"] as! Int
                presentedVC.videoType = storeInfo["type"] as? Int
                presentedVC.subjectType = "sitevideo_channel"//"core_main_sitevideo"
                if  storeInfo["type"] as! Int == 3 || storeInfo["type"] as! Int == 2 || storeInfo["type"] as! Int == 1 {
                    presentedVC.videoUrl = storeInfo["video_url"] as! String
                }
                else{
                    presentedVC.videoUrl = storeInfo["content_url"] as! String
                }
                
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case "Channel":

                if(storeInfo["allow_to_view"] as! Int == 1)
                {
                    let presentedVC = ChannelProfileViewController()
                    presentedVC.subjectId = storeInfo["channel_id"] as! Int
                    presentedVC.subjectType = "sitevideo_channel"//"core_main_sitevideochannel"
                    self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
                    
                }

                break
            case "":
                let presentedVC = StoresProfileViewController()
                presentedVC.storeId = storeInfo["store_id"] as! Int
                presentedVC.subjectType = "sitestore_store"
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
                break

            default:
                let presentedVC = StoresProfileViewController()
                presentedVC.storeId = storeInfo["store_id"] as! Int
                presentedVC.subjectType = "sitestore_store"
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
            }

        }
        else
        {
            self.parentViewController()!.view.makeToast( NSLocalizedString("You do not have permission to view this private page.",  comment: ""), duration: 5, position: "bottom")
        }
        
    }
    
    func browseProducts(contentItems: [AnyObject]){
        
        contentItemsCache = contentItems
        var i = 0
        var size:CGFloat = 0;
        var origin_x:CGFloat =  PADING
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            
            
            if contentItems.count > 2{
                size = ((UIScreen.main.bounds.width) - (4 * PADING))/2 - 5
                
            }
            else{
                
                size = ((UIScreen.main.bounds.width) - (2 * PADING))/2
            }
            
        }
        for contentItem in contentItems{
            
            contentView = createView(CGRect(x:origin_x, y:2, width:size, height:170-5), borderColor: UIColor.white, shadow: true)
            self.addSubview(contentView)
            
            contentImage = createImageView(CGRect(x:PADING, y:0, width:contentView.bounds.width - 2 * PADING, height:contentView.bounds.height - ( 2 * contentPADING) - (30)), border: false)
            if let photoId = contentItem["photo_id"] as? Int{
                
                if photoId != 0{
                    let url1 = NSURL(string: contentItem["image"] as! NSString as String)
                    contentImage.kf.indicatorType = .activity
                    (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    contentImage.contentMode =  UIViewContentMode.scaleAspectFit
                }
                else{
                    contentImage.image = nil
                    contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                    
                }
            }
            contentView.addSubview(contentImage)
            
            contentTitle = createLabel(CGRect(x:5, y:contentImage.frame.origin.y + contentImage.bounds.height + 5,  width:contentView.bounds.width - 10, height:30), text: "", alignment: .left, textColor: UIColor.black)
        var title = contentItem["title"] as! String
            if title.length > 30{
                title = (title as NSString).substring(to: 30-3)
                title  = title + "..."
            }
            contentTitle.text = title
            contentTitle.font = UIFont(name: fontBold, size: FONTSIZESmall)
            contentTitle.numberOfLines = 2
            contentView.addSubview(contentTitle)
            

            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showProduct), for: UIControlEvents.touchUpInside)
            contentSelection.tag = i
            self.addSubview(contentSelection)
            
            i += 1
            origin_x += size
            
        }
        
        self.contentSize = CGSize(width: origin_x + (2 * PADING), height: 170-5)
        
    }
    
    @objc func showProduct(sender: UIButton){
        
        var productInfo:NSDictionary!
        productInfo = contentItemsCache[sender.tag] as! NSDictionary

        let presentedVC = ProductProfilePage()
        let store_id =   productInfo["store_id"] as? Int
        let product_id =   productInfo["product_id"] as? Int
        presentedVC.product_id = product_id
        presentedVC.store_id = store_id
        self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)

    }
    
//    func showSellPage(sender: UIButton){
//
//
//
//        let presentedVC = ExternalWebViewController()
//        presentedVC.url = iscomingFrom
//        presentedVC.fromDashboard = false
//        self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
//
//
//
//    }
   

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
