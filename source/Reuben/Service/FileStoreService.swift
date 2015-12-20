//
//  FileStoreService.swift
//  Reuben
//
//  Created by Daniel Norton on 12/18/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import Foundation

class FileStoreService {
    
    var useCache: Bool = false
    var fileExtension: String = "data"
    private(set) var cache: NSData?
    private let storeName: String
    private let validate: ((NSData) -> Bool)
    private let store: NSURL
    
    
    // MARK: - init
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
    
    convenience init(storeName: String) {
        
        self.init(storeName: storeName) {_ in
            
            return true
        }
    }
    
    // MARK: Public Functions
    func flushCache() -> NSData? {
        
        cache = nil
        return nil
    }
    
    func cleanAndSave(tempFile: NSURL) throws -> Bool {
        
        if let data = NSData(contentsOfURL: tempFile) where validate(data) {
                
            try clean()
            try save(tempFile)
            
            return true
        }
        
        return false
    }
    
    func clean() throws {

        flushCache()
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(store, includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
            for file in files {
                
                try fm.removeItemAtURL(file)
            }
        }
    }
    
    func save(tempFile: NSURL) throws -> NSURL {
        
        return try save(tempFile, validated: false)
    }
    
    private func save(tempFile: NSURL, validated: Bool) throws -> NSURL {
        
        if !validated, let data = NSData(contentsOfURL: tempFile) where !validate(data) {
            
            return tempFile
        }
        
        let fm = NSFileManager.defaultManager()
        let name = NSDate().timeIntervalSince1970// NSUUID().UUIDString
        let newName = store.URLByAppendingPathComponent("\(name).\(fileExtension)")

        if fm.fileExistsAtPath(newName.absoluteString) {
            
            try fm.removeItemAtPath(newName.absoluteString)
        }
        
        try fm.moveItemAtURL(tempFile, toURL: newName)
        
        cache = useCache
        ? read()
        : flushCache()
        
        return newName
    }
    
    func read() -> NSData? {
        
        if cache != nil {
            
            return cache
        }
        
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(store, includingPropertiesForKeys: [NSURLContentModificationDateKey], options: .SkipsSubdirectoryDescendants)
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
            let data = NSData(contentsOfURL: file) where validate(data) {

                cache = useCache
                ? data
                : flushCache()
                
                return data
            }
            
        } catch { }
        
        return nil
    }
}