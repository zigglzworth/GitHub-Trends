//
//  APIEndpointRequest.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit


/*
 
 The APIEndpointRequest object is a wrapper for a URLSession request for cleanliness and convinience
 
 */


extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = map { key, value -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}



class APIEndpointRequest: NSObject, URLSessionDelegate {
    
    var params:[AnyHashable: Any] = [:]
    var endpointURLString:String?
    var url:URL?
    var httpMethod:String = "GET"
    
    var currentTask:URLSessionDataTask?
    
    
    func sendRequest(completion:@escaping(Data?, URLResponse?, Error?) -> ()) -> () {
        
        
        
        
        let request = NSMutableURLRequest()
        request.httpMethod = httpMethod
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            if (params.count > 0 && request.httpMethod != "GET") {
                let json = try JSONSerialization.data(withJSONObject: params as Any, options: [])
                request.httpBody = json
                if self.url == nil {
                    self.url = URL(string: endpointURLString!)!
                }
            }
            else if request.httpMethod == "GET" {
                
                if self.url == nil {
                    if params.count > 0 {
                        let parameterString = params.stringFromHttpParameters()
                        self.url = URL(string: endpointURLString! + "?" + parameterString)!
                    }
                    else {
                        self.url = URL(string: endpointURLString!)!
                    }
                    
                }

            }
            
            request.url = self.url
            
            
            let config = URLSessionConfiguration.default
            let session = URLSession.init(configuration: config)
            

            
            
            let task =  session.dataTask(with: request as URLRequest) { (data, response, err) in
                
                
                
                if (err != nil) {
                    print("sendRequest error \(String(describing: err))")
                }
                
                completion(data, response, err)
                
                
            }
            task.resume()
            
            
        } catch {
            
            let userInfo: [AnyHashable : Any] =
                [
                    NSLocalizedDescriptionKey :  NSLocalizedString("RequestError", value: "The URLSession request failed", comment: "") ,
                    NSLocalizedFailureReasonErrorKey : NSLocalizedString("RequestError", value: "Failed \(self.httpMethod) request to \(String(describing: self.endpointURLString))", comment: "")
            ]
            
            let err = NSError(domain: "APIEndpointRequest", code: 404, userInfo: userInfo)
            
            completion(nil, nil, err)
        }
        
        
    }
    
    
    func cancel() {
        
        if currentTask != nil {
            currentTask?.cancel()
        }
        
    }
    
    
    
}

