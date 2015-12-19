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

        var answer = 2
        
        let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
        if !service.hasUser {
            
            answer++
        }
        
        return answer
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let icon = cell as? ToolsCellView {
            
            switch indexPath.row {
               
            case 0:
                
                icon.backgroundColor = UIColor.orangeColor()
                icon.iconTitleLabel.textColor = UIColor.blackColor()
                icon.iconTitleLabel.text = "Refresh Status"
                
            case 1:
                
                icon.backgroundColor = UIColor.redColor()
                icon.iconTitleLabel.textColor = UIColor.blackColor()
                icon.iconTitleLabel.text = "Clean Status"
                
            case 2:
                
                let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
                if service.hasUser {
                    
                    icon.backgroundColor = UIColor.blueColor()
                    icon.iconTitleLabel.textColor = UIColor.whiteColor()
                    icon.iconTitleLabel.text = "log Out"
                    
                } else {
                    
                    icon.backgroundColor = UIColor.purpleColor()
                    icon.iconTitleLabel.textColor = UIColor.whiteColor()
                    icon.iconTitleLabel.text = "Login"
                }
                
            default:
                
                cell.backgroundColor = UIColor.lightGrayColor()
                icon.iconTitleLabel.textColor = UIColor.blackColor()
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
        
        switch indexPath.row {
    
        case 0:
            
            GHStatusService.refresh(nil)
            
        case 1:

            do {
                
                try GHStatusService.clean()
                self.reloadSection()
                
            } catch {
                
            }

        case 2:

            let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
            if service.hasUser {
             
                service.logout()
                self.reloadSection()
                
            } else {

                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
            
        default:
            
            GHStatusService.refresh(nil)
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
        
        if let latest = GHStatusService.readLatest() {

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
}
