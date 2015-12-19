//
//  FileStoreService.swift
//  Reuben
//
//  Created by Daniel Norton on 12/18/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import Foundation

class FileStoreService {
    
    var cache: NSData?
    let storeName: String
    let validate: ((NSData) -> Bool)
    private let store: NSURL
    
    // MARK: NSObject
    init(storeName: String, validate: ((data: NSData) -> Bool)) {
        
        self.storeName = storeName
        self.validate = validate
        
        self.store = {
            
            let fm = NSFileManager.defaultManager()
            let urls = fm.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
            if let url = urls.first {
                
                let fullPath = url.URLByAppendingPathComponent(storeName)
                
                do {
                    
                    _ = try fm.createDirectoryAtURL(fullPath, withIntermediateDirectories: true, attributes: nil)
                    return fullPath
                    
                } catch {
                    
                }
            }
            
            return NSURL(fileURLWithPath: NSTemporaryDirectory())
        }()
    }
    
    // MARK: public static functions
    func cleanAndSave(tempFile: NSURL) throws -> Bool {
        
        if let data = NSData(contentsOfURL: tempFile) {
            
            if self.validate(data) {
                
                try self.clean()
                try self.save(tempFile)
                
                return true
                
            }
        }
        return false
    }
    
    func clean() throws {

        cache = nil
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(self.store, includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
            for file in files {
                
                try fm.removeItemAtURL(file)
            }
        }
    }
    
    func save(tempFile: NSURL) throws -> NSURL {
        
        let fm = NSFileManager.defaultManager()
        let name = NSUUID().UUIDString
        let newName = self.store.URLByAppendingPathComponent("\(name).json")

        if fm.fileExistsAtPath(newName.absoluteString) {
            
            try fm.removeItemAtPath(newName.absoluteString)
        }
        
        try fm.moveItemAtURL(tempFile, toURL: newName)
        
        cache = nil
        cache = read()
        
        return newName
    }
    
    func read() -> NSData? {
        
        if cache != nil {
            
            return cache
        }
        
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(self.store, includingPropertiesForKeys: [NSURLContentModificationDateKey], options: .SkipsSubdirectoryDescendants)
            
            let fileProps = files.sort({ (first, second) -> Bool in
                
                do {
                    
                    var firstResource: AnyObject?
                    try first.getResourceValue(&firstResource, forKey: NSURLContentModificationDateKey)
                    var secondResource: AnyObject?
                    try second.getResourceValue(&secondResource, forKey: NSURLContentModificationDateKey)
                    
                    if let firstDate = firstResource as? NSDate, let secondDate = secondResource as? NSDate {
                        
                        return firstDate.compare(secondDate) != NSComparisonResult.OrderedDescending
                    }
                    
                } catch {
                    
                }
                
                return false
            })
            
            if let file = fileProps.last,
            let data = NSData(contentsOfURL: file)
            where self.validate(data)
            {
                return data
            }
            
        } catch { }
        
        return nil
    }
}