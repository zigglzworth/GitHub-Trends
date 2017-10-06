//
//  GitRepoInfo.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit



/*
 
 GitRepoInfo and GitUser are native object representations of the GitHub API JSON returned repo and owner objects respectively
 A GitRepoInfo contains a GitUser object in it's owner property as is the case in the GitHub API JSON object of a repo
 
 GitRepoInfo supports NSCoding so it can be used with NSKeyedArchiver for storing objects locally
 
 */


// MARK: GitUser OBJECT

class GitUser: NSObject {
    
    var id = 0
    var username:String?
    var avatar_url:String?
    
    
    func updateValues(dict: [AnyHashable:Any]) {
        
        var dictionary = dict
        for key in dict.keys {
            if dict[key] is NSNull {
                dictionary.removeValue(forKey: key)
            }
        }
        
        if self.id == 0 {
            if let id = dictionary["id"] {
                self.id = (id as? Int)!
            }
        }
        
        if let login = dictionary["login"] {
            self.username = login as? String
        }
        else {
            self.username = "user"
        }
        
        if let avatar_url = dictionary["avatar_url"] {
            self.avatar_url = avatar_url as? String
        }
    }
    
    
    
    init(dictionary: [AnyHashable:Any]) {
        
        super.init()
        self.updateValues(dict: dictionary)
        

    }
    
    
    func getDictionary() -> [AnyHashable:Any] {
        
        var dictionary:[AnyHashable:Any] = [:]
        
        if self.username != nil {
            dictionary["login"] = self.username
        }
        
        dictionary["id"] = self.id
        
        if self.avatar_url != nil {
            dictionary["avatar_url"] = self.avatar_url
        }
        
        return dictionary
        
    }
    
    
    
    override func isEqual(_ object: Any?) -> Bool {
        
        let o:GitUser = object as! GitUser
        
        if o.id == self.id {
            return true
        }
        
        return false
    }
    
    
}


// MARK: GitRepoInfo OBJECT


class GitRepoInfo: NSObject, NSCoding {
    
    
    struct Keys {
        static let id = "id"
        static let stargazers_count = "stargazers_count"
        static let forks = "forks"
        static let name = "name"
        static let full_name = "full_name"
        static let description_text = "description_text"
        static let language = "language"
        static let created_at = "created_at"
        static let owner = "owner"
    }
    
    var id = 0
    var stargazers_count = 0
    var forks = 0
    
    var name: String?
    var full_name: String?
    var description_text:String?
    var language: String?
    

    var created_at: Date?
    
    var html_url: String?
    
    var owner: GitUser?
    
    var isFavourite: Bool {
        get {
            return LocalResourceManager.shared.isSaved(object: self)
        }
    }
    
    
    
    init(dictionary: [AnyHashable:Any]) {
        
        super.init()
        self.updateValues(dict: dictionary)
 
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        

        
        self.id = aDecoder.decodeInteger(forKey: Keys.id)
        self.stargazers_count = aDecoder.decodeInteger(forKey: Keys.stargazers_count)
        self.forks = aDecoder.decodeInteger(forKey: Keys.forks)
        
        self.name = aDecoder.decodeObject(forKey: Keys.name) as? String
        self.full_name = aDecoder.decodeObject(forKey: Keys.full_name) as? String
        self.description_text = aDecoder.decodeObject(forKey: Keys.description_text) as? String
        self.language = aDecoder.decodeObject(forKey: Keys.language) as? String
        
        self.created_at = aDecoder.decodeObject(forKey: Keys.created_at) as? Date
        
        if let owner_dictionary = aDecoder.decodeObject(forKey: Keys.owner) as? [AnyHashable: Any] {
            let o = GitUser(dictionary: owner_dictionary)
            self.owner = o
        }

        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: Keys.id)
        aCoder.encode(stargazers_count, forKey: Keys.stargazers_count)
        aCoder.encode(forks, forKey: Keys.forks)
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(full_name, forKey: Keys.full_name)
        aCoder.encode(description_text, forKey: Keys.description_text)
        aCoder.encode(language, forKey: Keys.language)
        aCoder.encode(created_at, forKey: Keys.created_at)
        //owner should be get dict
        let owner_dictionary = owner?.getDictionary()
        aCoder.encode(owner_dictionary, forKey: Keys.owner)
        
    }
    
    
    func updateValues(dict: [AnyHashable:Any]) {
        
        var dictionary = dict
        for key in dict.keys {
            if dict[key] is NSNull {
                dictionary.removeValue(forKey: key)
            }
        }
        
        if self.id == 0 {
            if let id = dictionary["id"] {
                self.id = (id as? Int)!
            }
        }
        
        
        
        if let name = dictionary["name"] {
            self.name = name as? String
        }
        else {
            self.name = "Untitled"
        }
        
        if let full_name = dictionary["full_name"] {
            self.full_name = full_name as? String
        }

        
        if let description_text = dictionary["description"] {
            self.description_text = description_text as? String
        }
        else {
            self.description_text = "No description"
        }
        
        if let language = dictionary["language"] {
            self.language = language as? String
        }
        else {
            self.language = "Language unknown"
        }
        
        if let stargazers_count = dictionary["stargazers_count"] {
            self.stargazers_count = (stargazers_count as? Int)!
        }
        else {
            self.stargazers_count = 0
        }
        
        
        if let forks = dictionary["forks"] {
            self.forks = (forks as? Int)!
        }
        else {
            self.forks = 0
        }
        
        
        if let created_at = dictionary["created_at"] {

            let formatter = ISO8601DateFormatter()
            let string = created_at as! String
            self.created_at = formatter.date(from: string)
            
        }
        
        
        if let html_url = dictionary["html_url"] {
            self.html_url = html_url as? String
        }
        
        if let owner = dictionary["owner"] as? [AnyHashable:Any] {
            self.owner = GitUser(dictionary: owner)
        }
        
        if self.isFavourite == true {
            self.saveToFavourites() //because we always want the local to be updated
        }

    }
    
    func update(completion:@escaping(Bool) ->()) {
        
        if self.full_name != nil {
            
            GitConnect.shared.getRepo(fullName: self.full_name!) { (dictionary) in
                
                if dictionary != nil {
                    self.updateValues(dict: dictionary!)
                    completion(true)
                }
                else {
                    completion(false)
                }
                
            }
            
        }
        else {
            completion(false)
        }
        
    }
    
    
    
    func saveToFavourites() {
        LocalResourceManager.shared.saveRepoLocally(object: self)
    }
    
    func removeFromFavourites() {
        LocalResourceManager.shared.deleteRepoLocally(object: self)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        let o:GitRepoInfo = object as! GitRepoInfo
        
        if o.id == self.id {
            return true
        }
        
        return false
    }
    
    
    func matchesSearch(text: String) -> Bool {
        
        if self.description_text?.lowercased().contains(text.lowercased()) == true || self.full_name?.lowercased().contains(text.lowercased()) == true {
            return true
        }
        
        return false
    }


}
