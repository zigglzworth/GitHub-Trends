//
//  LocalResourceManager.swift
//  GitHub-Trends
//
//  Created by noasis on 10/3/17.
//  Copyright © 2017 iyedah. All rights reserved.
//



 /*
 
 LocalResourceManager manages local storage of GitRepoInfo objects using NSKeyedArchiver and a managed array
 
 */


import UIKit


class LocalResourceManager: NSObject {
    
    static let LOCALSTOREDIDCHANGE = Notification.Name("LOCALSTOREDIDCHANGE")
    
    static let shared: LocalResourceManager = LocalResourceManager()
    var storedObjects:Array<GitRepoInfo> = []
    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("store").path
    }

    
    private override init() {
        super.init()
        
        //We manage our favourites in an array for quick retrieval and we don't expect high memory usage for such an array
        
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: self.filePath) as? [GitRepoInfo] {
            self.storedObjects.append(contentsOf: array)
        }
    }
    
    //MARK: STORING A REPO TO DISK
    
    func saveRepoLocally(object: GitRepoInfo) {
        
        if self.storedObjects.contains(object) {
            let index = self.storedObjects.index(of: object)
            
            if index != nil && index! < self.storedObjects.count {
                self.storedObjects[index!] = object
            }
            
        }
        else {
          self.storedObjects.append(object)
        }
        
        NSKeyedArchiver.archiveRootObject(self.storedObjects, toFile: self.filePath)
        
        NotificationCenter.default.post(name: LocalResourceManager.LOCALSTOREDIDCHANGE, object: nil, userInfo: nil)
    }
    
    
    //MARK: DELETING A REPO FROM DISK
    
    func deleteRepoLocally(object: GitRepoInfo) {
        
        let index = self.storedObjects.index(of: object)
        if index != nil && index! < self.storedObjects.count {
            self.storedObjects.remove(at: index!)
            NSKeyedArchiver.archiveRootObject(self.storedObjects, toFile: self.filePath)
        }
        
        NotificationCenter.default.post(name: LocalResourceManager.LOCALSTOREDIDCHANGE, object: nil, userInfo: nil)
        
    }
    
    //MARK: CHECKING IF A REPO EXISTS IN OUR STORE
    
    func isSaved(object: GitRepoInfo) -> Bool {
        
        return self.storedObjects.contains(object)
        
    }
    
    
    //MARK: GET ALL LOCALLY STORED REPOS
    
    func getLocallyStoredObjects() -> GitSearchResult {
        
        let searchResult = GitSearchResult()
        searchResult.resultsArray.append(contentsOf: self.storedObjects)
        return searchResult
        
        
    }
    
    

}
