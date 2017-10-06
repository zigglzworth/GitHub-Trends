//
//  GitConnect.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//


/*
 
 GitConnect manages communication with the GitHub API from the app
 
 */

import UIKit
import ReachabilitySwift


enum GitSearchTimeRange: Int {
    case lastDay, lastWeek, lastMonth, none
}

class GitConnect: NSObject {
    
    
    static let shared: GitConnect = GitConnect()
    
    let reachability = Reachability()!
    var currentSearchRequest:APIEndpointRequest?
    
    private override init() {
        super.init()
    }
    
    
    // MARK: SEARCHING GIT WITH SEARCH TEXT - Currently unused but ready for future use
    
    func searchGit(searchText: String, completion:@escaping(GitSearchResult) ->()) {
        
        let endpointRequest:APIEndpointRequest = APIEndpointRequest.init()
        endpointRequest.endpointURLString = GitAPIConstants.GITSEARCHBASEURLPATH
        endpointRequest.params[GitAPIConstants.kGITSearchQuerySortKey] = "stars"
        endpointRequest.params[GitAPIConstants.kGITSearchQueryOrderKey] = "desc"
        endpointRequest.params[GitAPIConstants.kGITSearchQueryKey] = searchText
        
        
        
        self.searchGit(request: endpointRequest) { (gitSearchResult) in
            
            completion(gitSearchResult)
            
        }
        
    }
    
    
    // MARK: SEARCHING GIT WITH FOR TRENDING REPOS IN TIME RANGE
    
    func searchGit(timeRange: GitSearchTimeRange, completion:@escaping(GitSearchResult) ->()) {
        
        let endpointRequest:APIEndpointRequest = APIEndpointRequest.init()
        endpointRequest.endpointURLString = GitAPIConstants.GITSEARCHBASEURLPATH
        endpointRequest.params[GitAPIConstants.kGITSearchQuerySortKey] = "stars"
        endpointRequest.params[GitAPIConstants.kGITSearchQueryOrderKey] = "desc"
        
        let formatter = ISO8601DateFormatter()
        var date:Date?
        
        switch timeRange {
        case .lastDay:
            date = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            break
            
        case .lastWeek:
            date =  Calendar.current.date(byAdding: .day, value: -7, to: Date())
            break
            
        case .lastMonth:
            date =  Calendar.current.date(byAdding: .month, value: -1, to: Date())
            break
            
        default:
            date =  Calendar.current.date(byAdding: .month, value: -1, to: Date())
            break
            

        }
        
        let dateString = formatter.string(from: date!)
        endpointRequest.params[GitAPIConstants.kGITSearchQueryKey] = "created:>" + dateString
        
        self.searchGit(request: endpointRequest) { (gitSearchResult) in
            
            completion(gitSearchResult)
            
        }
        
    }
    
    
    // MARK: CORE SEARCHING GIT OPERATION SUING AN APIEndpointRequest
    
    
    func searchGit(request: APIEndpointRequest, completion:@escaping(GitSearchResult) ->()) {
        
        if self.currentSearchRequest != nil {
            self.currentSearchRequest?.cancel()
        }
        self.currentSearchRequest = request
        
        
        let gitSearchResult = GitSearchResult.init()
        
        if reachability.isReachable == true  {
            
            
            request.sendRequest { (data, response, error) in
                
                
                if error == nil {
                    
                    if let dict = self.DataToDictionary(data: data!) as? [AnyHashable : Any]  {
                        
                        if let array = dict["items"]  {
                            
                            let items = array as! Array <[AnyHashable : Any]>
                            
                            for dictionary in items {
                                let repo:GitRepoInfo = GitRepoInfo(dictionary: dictionary)
                                gitSearchResult.resultsArray.append(repo)
                            }
                            
                            
                        }
                        else {
                            
                        }
                        
                    }
                    
                    if response != nil {
                        gitSearchResult.nextPageRequest = self.extractNextPagerequest(response: response!)
                    }
                    
                    
                }
                
                completion(gitSearchResult)
                
            }
            
            
            
            
        }
        else {
 
            
            completion(gitSearchResult)
        }
        
    }
    
    // MARK: GETTING A SINGLE REPO - For updating stored favouites etc
    
    
    func getRepo(fullName: String, completion:@escaping([AnyHashable:Any]?) ->()) {
        
        
        
        let endpointRequest:APIEndpointRequest = APIEndpointRequest.init()
        endpointRequest.endpointURLString = GitAPIConstants.GITREPOBASEURLPATH + fullName
        
        endpointRequest.sendRequest { (data, response, error) in
            
            
            if error == nil {
                
                if let dict = self.DataToDictionary(data: data!) as? [AnyHashable : Any]  {
                    
                    completion(dict)
                    
                }
                else {
                    completion(nil)
                }
                
            }
            else {
                completion(nil)
            }
            
            
            
        }
        
        
    }
    
    // MARK: CONVERTING DATA TO DICTIONARY
    
    func DataToDictionary(data: Data) -> Any? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    
     // MARK: CREATING A GET NEXT PAGE REQUEST 
    
    
    func extractNextPagerequest(response:URLResponse) -> APIEndpointRequest? {
        
        let httpResponse = response as? HTTPURLResponse
        
        if let linkField = httpResponse?.allHeaderFields["Link"] as? String {
            
            let parts = linkField.components(separatedBy: ",")
            
            for part in parts {
                if part.contains("rel=\"next\"") == true {
                    
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: part, options: [], range: NSRange(location: 0, length: part.utf16.count))

                    for match in matches {
                        if let url = match.url {
                            let endpointRequest:APIEndpointRequest = APIEndpointRequest.init()
                            endpointRequest.url = url
                            return endpointRequest
                        }
                    }
                    
                }
            }
            
            
            
        }
        
        
        return nil
        
    }
    
    

}
