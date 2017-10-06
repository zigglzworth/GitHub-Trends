//
//  GitSearchResult.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit


 /*
 
 GitSearchResult manages the search results of a API request for clean and convinient use by our UI Controllers
 
 */

class GitSearchResult: NSObject {
    
    var resultsAreLocal:Bool = false
    var resultsArray: Array <GitRepoInfo> = []
    var nextPageRequest: APIEndpointRequest?
    
    var filterString: String?
    
    var filteredArray: Array <GitRepoInfo> {
        get {
            
            if filterString == nil || filterString?.isEmpty == true {
                return resultsArray
            }
            else {
                return resultsArray.filter( { $0.matchesSearch(text: filterString!) })
            }
            
        }
    }
    
    func getAndAppendNextPage(completion:@escaping() ->()) {
        
        GitConnect.shared.searchGit(request: self.nextPageRequest!) { (searchResult) in
            
            self.resultsArray.append(contentsOf: searchResult.resultsArray)
            self.nextPageRequest = searchResult.nextPageRequest
            completion()
            
        }
    }

}
