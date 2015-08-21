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
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
        if !service.hasUser {
            
            let vc = service.loginViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }


    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}
