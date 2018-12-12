//
//  BottomSheetForPostViewController.swift
//  seiosnativeapp
//
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

import UIKit
class BottomSheetForPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate
{
    var postFeedOptions = [Int:String]()
    var sequences = [Int]()
    var PostFeedListObj = UITableView()
    var fullView: CGFloat = 250//225
    var partialView: CGFloat {
        return  UIScreen.main.bounds.height - (50 + 25 + iphonXBottomsafeArea)
    }
    var postOptionsName =  [Int:String]()
    var arrayOfpostFeedOptions : NSMutableArray! = [ ]
    var arrayOfpostOptionsName : NSMutableArray! = [ ]
    var separateLine : UILabel!
    var tagPostOptions = [Int]()
    var postView =  UIView()
    var delegate:RedirectionMethod?
    var postText : UILabel!
    var postImage : UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        for(k,v) in postFeedOptions.sorted(by: { $0.0 < $1.0 }){
            //print(k)
            //print(v)
            arrayOfpostFeedOptions.add(v)
            tagPostOptions.append(k)
            //print("tagPostOptions")
            //print(tagPostOptions)
        }
        // let arraySort =  tagPostOptions.sorted(by: >)
        // tagPostOptions = arraySort
        for(_,v) in postOptionsName.sorted(by: { $0.0 < $1.0 }){
            arrayOfpostOptionsName.add(v)
        }
        
//        for(k,v) in postFeedOptions{
//            arrayOfpostFeedOptions.add(v)
//            tagPostOptions.append(k)
//        }
//
//        for(_,v) in postOptionsName{
//            arrayOfpostOptionsName.add(v)
//        }
        
        
        let frame = self.view.frame
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetForPostViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        
        separateLine = createLabel(CGRect(x: frame.width/2 - 15, y: 10, width: 30 , height: 5), text: "", alignment: .left, textColor: UIColor.lightGray)
        separateLine.font = UIFont(name: fontName, size: FONTSIZESmall)
        separateLine.layer.borderWidth = 0.5
        separateLine.layer.borderColor = backgroundLightColor.cgColor
        separateLine.layer.cornerRadius = 5.0
        separateLine.backgroundColor = backgroundLightColor
        view.addSubview(separateLine)
        
        // Initialize Post Feed Table
        PostFeedListObj = UITableView(frame: CGRect(x: 0, y: 20  , width: frame.width, height: 230 ))
        PostFeedListObj.register(BottomSheetCell.self, forCellReuseIdentifier: "cell")
        PostFeedListObj.dataSource = self
        PostFeedListObj.delegate = self
        PostFeedListObj.estimatedRowHeight = 50
        PostFeedListObj.rowHeight = UITableViewAutomaticDimension
        PostFeedListObj.backgroundColor = textColorLight
        PostFeedListObj.separatorColor =  backgroundLightColor
        view.addSubview(PostFeedListObj)
        
        // Intialise Post View
        postView = createView(CGRect(x: 0, y: 20 ,width: UIScreen.main.bounds.width ,height: 50), borderColor: textColorclear, shadow: false)
        postView.backgroundColor = textColorLight
        postView.isHidden = true
        
        
        postText = createLabel(CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 150  , height: 50), text: NSLocalizedString("Add to your Post", comment: ""), alignment: .left, textColor: textColorDark)
        postText.font = UIFont(name: fontName, size: FONTSIZELarge)
        postView.addSubview(postText)
        
        let titleString = NSMutableAttributedString(string: "")

        if arrayOfpostFeedOptions.count > 0 {
        for i in 0 ..< arrayOfpostFeedOptions.count - 1{
            if tagPostOptions[i] == 0{
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: NSLocalizedString("%@  ", comment:""),(arrayOfpostFeedOptions[i] as? String)!))
                attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: tagIconColor, range: NSMakeRange(0, attrString.length))
                titleString.append(attrString)
                
            }
            else if tagPostOptions[i] == 1{
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: NSLocalizedString("%@  ", comment:""),(arrayOfpostFeedOptions[i] as? String)!))
                attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: CheckInIconColor, range: NSMakeRange(0, attrString.length))
                titleString.append(attrString)
            }
            else if tagPostOptions[i] == 2{
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: NSLocalizedString("%@  ", comment:""),(arrayOfpostFeedOptions[i] as? String)!))
                attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: PhotoIconColor, range: NSMakeRange(0, attrString.length))
                titleString.append(attrString)
            }
            else if tagPostOptions[i] == 5{
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: NSLocalizedString("%@  ", comment:""),(arrayOfpostFeedOptions[i] as? String)!))
                attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: videoIconColor, range: NSMakeRange(0, attrString.length))
                titleString.append(attrString)

            }
        }
        }
        
        postImage = createLabel(CGRect(x: postText.frame.origin.x + postText.frame.size.width, y: 0, width: UIScreen.main.bounds.width - (postText.frame.origin.x + postText.frame.size.width)  , height: 50), text: "", alignment: .left, textColor: textColorMedium)
        postImage.attributedText = titleString
        postImage.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        postImage.sizeToFit()
        postView.addSubview(postImage)
        postImage.frame.origin.x = UIScreen.main.bounds.width - postImage.frame.size.width
        postImage.frame.size.height = 50
        let openTableViewGesture = UITapGestureRecognizer(target: self, action: #selector(BottomSheetForPostViewController.OpenTableView))
        postView.addGestureRecognizer(openTableViewGesture)
        view.addSubview(postView)
        
    }
    
    @objc func OpenTableView(){
        delegate?.resign()
        self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 250 - iphonXBottomsafeArea , width: self.view.frame.width, height: 250 - iphonXBottomsafeArea )
        self.PostFeedListObj.isHidden = false
        postView.isHidden = true
        
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        delegate?.resign()
        self.PostFeedListObj.isHidden = false
        postView.isHidden = true
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            //self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 250  , width: self.view.frame.width, height: 250 )
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 250  , width: self.view.frame.width, height: 250 )
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    self?.PostFeedListObj.isScrollEnabled = true
                    
                }
                else{
                    self?.PostFeedListObj.isHidden = true
                    self?.postView.isHidden = false
                }
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//        let direction = gesture.velocity(in: view).y
//        let indexPath = IndexPath(row: 0, section: 0)
//        PostFeedListObj.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
//        let y = view.frame.minY
//        if (y == fullView && PostFeedListObj.contentOffset.y == 0 && direction > 0) || (y == partialView) {
//            PostFeedListObj.isScrollEnabled = true // changed
//        } else {
//            PostFeedListObj.isScrollEnabled = true
//        }
        
        return false
    }
    
//    func OpenTableView(){
//        delegate?.resign()
//        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
//        self.PostFeedListObj.isHidden = false
//        postView.isHidden = true
//
//    }
//
//    func panGesture(_ recognizer: UIPanGestureRecognizer) {
//        delegate?.resign()
//        self.PostFeedListObj.isHidden = false
//        postView.isHidden = true
//        let translation = recognizer.translation(in: self.view)
//        let velocity = recognizer.velocity(in: self.view)
//
//        let y = self.view.frame.minY
//        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
//            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
//            recognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
//
//        if recognizer.state == .ended {
//            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
//
//            duration = duration > 3 ? 1 : duration
//
//            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
//                if  velocity.y >= 0 {
//                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
//                } else {
//                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
//                }
//
//            }, completion: { [weak self] _ in
//                if ( velocity.y < 0 ) {
//                    self?.PostFeedListObj.isScrollEnabled = true
//
//                }
//                else{
//                    self?.PostFeedListObj.isHidden = true
//                    self?.postView.isHidden = false
//                }
//            })
//        }
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//        let direction = gesture.velocity(in: view).y
//
//        let y = view.frame.minY
//        if (y == fullView && PostFeedListObj.contentOffset.y == 0 && direction > 0) || (y == partialView) {
//            PostFeedListObj.isScrollEnabled = false
//        } else {
//            PostFeedListObj.isScrollEnabled = true
//        }
//
//        return false
//    }
//
    
    func roundViews() {
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        roundViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.00001
        
    }
    // Set Sticker Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfpostFeedOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BottomSheetCell
        cell.backgroundColor = textColorLight
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.separatorInset.left = 10.0
        cell.separatorInset.right = 10.0
        
        
        switch(tagPostOptions[indexPath.row]){
        case 0:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: tagIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
            case 1:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: CheckInIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
        case 2:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: PhotoIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
            
        case 5:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: videoIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
            
        case 6:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: linkIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
        case 7:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: videoIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
//        case 8:
//            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
//            attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
//            attrString.addAttribute(NSForegroundColorAttributeName, value: PhotoIconColor, range: NSMakeRange(0, attrString.length))
//            cell.imageview.attributedText = attrString
            
        case 9:
            let attrString = NSMutableAttributedString(string: (arrayOfpostFeedOptions[indexPath.row] as? String)!)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: linkIconColor, range: NSMakeRange(0, attrString.length))
            cell.imageview.attributedText = attrString
            
        default:
            break
        }
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: NSLocalizedString("%@", comment:""),(arrayOfpostOptionsName[indexPath.row] as? String)!))
        descString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
        descString.addAttribute(NSAttributedStringKey.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
        
        cell.imagetitle.attributedText = descString
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
        PostFeedListObj.isHidden = true
        postView.isHidden = false
        delegate?.redirectionAfterSelect(sender: tagPostOptions[indexPath.row])
    }
    
}


