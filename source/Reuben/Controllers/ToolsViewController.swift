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
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 3
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
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
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        headerContentLabel.frame = CGRectMake(0, 0, collectionView.frame.width - 16, CGFloat.max)
        headerContentLabel.attributedText = self.headerContentForSection(section)
        headerContentLabel.sizeToFit()
        
        return CGSize(width: collectionView.frame.width, height: headerContentLabel.frame.height + 56)
    }
    
    
    // MARK: - ToolsViewController
    func headerContentForSection(section: Int) -> NSAttributedString {
        
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
        
        return NSAttributedString(string: "Status unknown")
    }
}
