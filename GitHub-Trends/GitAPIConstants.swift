//
//  GitAPIConstants.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit

class GitAPIConstants: NSObject {
    
    
    //MARK: URL ENDPOINT
    static let GITSEARCHBASEURLPATH = "https://api.github.com/search/repositories"
    static let GITREPOBASEURLPATH = "https://api.github.com/repos/"

    
    //MARK: GIT QUERY PARAMETER KEYS
    static let kGITSearchQueryKey = "q"
    static let kGITSearchQuerySortKey = "sort"
    static let kGITSearchQueryOrderKey = "order"
    

}
