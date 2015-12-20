//
//  ToolsViewController.swift
//  Reuben
//
//  Created by Daniel Norton on 4/23/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit


class ToolsViewController: UICollectionViewController {

    let cellReuseIdentifier = "ToolsViewControllerCell"
    let headerReuseIdentifier = "ToolsViewControllerHeader"
    
    enum CellIndexes: Int {
        
        case refreshStatus
        case cleanStatus
        case login
        case unused
    }
    
    let headerContentLabel: UILabel = {
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = UIFont.systemFontOfSize(17.0)
        return label
    }()
    
    static let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .MediumStyle
        return formatter
    }()
    
    let userAuthService = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
    var avatar: UIImage?
    
    var ghStatusSaveObserver: NSObjectProtocol?
    var uaSaveObserver: NSObjectProtocol?

    // MARK: NSObject
    deinit {
        
        if let observer = ghStatusSaveObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            ghStatusSaveObserver = nil
        }
        
        if let observer = uaSaveObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            uaSaveObserver = nil
        }
    }
    
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        ghStatusSaveObserver = NSNotificationCenter
            .defaultCenter()
            .addObserverForName(GHStatusService.SaveNotification,
                object: nil,
                queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
            
                    NSLog("👒👒 Reloading ToolsViewController via: %@", GHStatusService.SaveNotification)
                    self.reloadSection()
        }
        
        uaSaveObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserAuthenticationServices.SaveNotification,
            object: nil,
            queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
                
                NSLog("🐿🐿 ToolsViewController received: %@", UserAuthenticationServices.SaveNotification)
                self.reloadSection()
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return CellIndexes.login.rawValue + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let icon = cell as? ToolsCellView {
            
            switch CellIndexes(rawValue: indexPath.row)! {
               
            case CellIndexes.refreshStatus:
                
                configureIcon(icon,
                    backgroundColor: UIColor.orangeColor(),
                    titleColor: UIColor.blackColor(),
                    text: "Refresh Status")
                
            case CellIndexes.cleanStatus:
                
                configureIcon(icon,
                    backgroundColor: UIColor.redColor(),
                    titleColor: UIColor.blackColor(),
                    text: "Clean Status")
                
            case CellIndexes.login:
                
                if userAuthService.hasUser {
                    
                    configureIcon(icon,
                        backgroundColor: UIColor.blueColor(),
                        titleColor: UIColor.whiteColor(),
                        text: "log Out",
                        image: avatar)
                    
                    if (avatar == nil) {
                        
                        beginDownloadAvatar()
                    }
                    
                } else {
                    
                    configureIcon(icon,
                        backgroundColor: UIColor.purpleColor(),
                        titleColor: UIColor.whiteColor(),
                        text: "Login")
                }
                
            default:

                configureIcon(icon,
                    backgroundColor: UIColor.lightGrayColor(),
                    titleColor: UIColor.blackColor())
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(
                kind,
                withReuseIdentifier: headerReuseIdentifier,
                forIndexPath: indexPath)

            if let tool = view as? ToolsHeaderView {
                
                tool.title.text = "github"
                tool.content.attributedText = self.headerContentForSection(indexPath.section)
            }
            
            return view
    }


    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let service = GHStatusService()
        
        switch CellIndexes(rawValue: indexPath.row)! {
    
        case CellIndexes.refreshStatus:

            service.refresh(nil)
            
        case CellIndexes.cleanStatus:

            do {
                
                try service.clean()
                self.reloadSection()
                
            } catch {
                
            }

        case CellIndexes.login:

            if userAuthService.hasUser {
             
                userAuthService.logout()
                self.reloadSection()
                
            } else {

                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
            
        default:
            
            service.refresh(nil)
        }
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        headerContentLabel.frame = CGRectMake(0, 0, collectionView.frame.width - 16, CGFloat.max)
        headerContentLabel.attributedText = self.headerContentForSection(section)
        headerContentLabel.sizeToFit()
        
        return CGSize(width: collectionView.frame.width, height: headerContentLabel.frame.height + 56)
    }
    
    
    // MARK: - ToolsViewController
    private func headerContentForSection(section: Int) -> NSAttributedString {
        
        let service = GHStatusService()
        
        if let latest = service.read() {

            let start = NSAttributedString(string: "status: ")
            let answer = NSMutableAttributedString(attributedString: start)

            let status = NSAttributedString(string: latest.status, attributes: {

                switch latest.status {
                    
                case "good":
                    
                    return [
                        NSForegroundColorAttributeName: UIColor(red: 0.0, green: 128.0/255.0, blue: 64.0/255.0, alpha: 1.0),
                        NSFontAttributeName: headerContentLabel.font]
                    
                default:
                    
                    return [
                        NSForegroundColorAttributeName: UIColor.redColor(),
                        NSFontAttributeName: UIFont.boldSystemFontOfSize(headerContentLabel.font.pointSize)]
                }
            }())
            answer.appendAttributedString(status)
            
            let dateString = ToolsViewController.dateFormatter.stringFromDate(latest.lastUpdated)
            let lastUpdated = NSAttributedString(string: "\nlast updated: \(dateString)", attributes: nil)
            answer.appendAttributedString(lastUpdated)
            
            return answer
        }
        
        return NSAttributedString(string: "Status unknown\n")
    }
    
    private func reloadSection() {
        
        self.collectionView!.reloadSections(NSIndexSet(index: 0))
    }
    
    private func beginDownloadAvatar() {
        
        let identifier = __FUNCTION__
        let (session, delegate) = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            if let data = NSData(contentsOfURL: url) {

                let image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.avatar = image
                    self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)])
                })
            }
        }
        
        let url = userAuthService.readUser()!.avatarURL
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        let task = session.downloadTaskWithRequest(request)
        
        print("\(NSDate()) - start \(identifier)")
        task.resume()
    }
    
    private func configureIcon(icon: ToolsCellView, backgroundColor: UIColor, titleColor: UIColor, text: String? = nil, image: UIImage? = nil) {
        
        icon.backgroundColor = backgroundColor
        icon.iconTitleLabel.textColor = titleColor
        icon.iconTitleLabel.text = text
        icon.iconImageView.image = image
    }
}
