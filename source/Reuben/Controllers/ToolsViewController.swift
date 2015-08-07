//
//  ToolsViewController.swift
//  Reuben
//
//  Created by Daniel Norton on 4/23/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class ToolsViewController: UICollectionViewController {

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 1000
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
    
    
    // MARK: - ToolsViewController
    @IBAction func didTapTestDownload(sender: UIBarButtonItem) {

//        let url = NSURL(string: "https://developer.apple.com/library/ios/samplecode/MetalVideoCapture/MetalVideoCapture.zip")!
        let url = NSURL(string: "https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.pdf")!
        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            if let fileName = task.originalRequest?.URL?.lastPathComponent {
                
                let newName = documentsPath.stringByAppendingPathComponent(fileName)
                let newUrl = NSURL(fileURLWithPath: newName)
                let mgr = NSFileManager()
                
                if mgr.fileExistsAtPath(newName) {
                    
                    do {
                        
                        try mgr.removeItemAtURL(newUrl)
                        
                    } catch { }
                }
                
                do {
                    
                    try mgr.moveItemAtURL(url, toURL: newUrl)
                    print("\(NSDate()) - finish \(url.absoluteString) - \(newUrl.absoluteString)")
                    
                } catch {
                    
                    print("\(NSDate()) - 😨😨😨 FAILED!! Moving \(url.absoluteString) to \(newUrl.absoluteString)")
                    
                }
            }
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        let task = session.downloadTaskWithRequest(request)
        
        print("\(NSDate()) - start \(url.host!)")
        task.resume()
    }
}
