//
//  ViewController.swift
//  GitHub-Trends
//
//  Created by noasis on 9/28/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit
import ReachabilitySwift

class UILayoutManager : NSObject {
    
    /*
     
     We don't want UI layout based on device (iPad / iPhone). We want it to be 
     based on screen size and oreintation
 
    */
    
    static func useDefaultLayout() -> Bool {
        
        let orientation = UIDevice.current.orientation
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if (orientation == .landscapeLeft || orientation == .landscapeRight) && (appDelegate?.window?.bounds.size.height)! > CGFloat(600) {
            return false
        }
        else if (appDelegate?.window?.bounds.size.width)! > CGFloat(600)  {
            return false
        }
        
        
        return true
    }
    
}

class ViewController: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate, GitCollectionViewControllerDelegate {
    

    @IBOutlet weak var searchBar:UISearchBar?

    var currentGitRepoTimeRange:GitSearchTimeRange = .lastMonth
    var gitCollectionViewController:GitCollectionViewController?
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)

    let reachability:Reachability = Reachability()!
    // MARK: ON START
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GitCollectionViewControllerSegue" {
            gitCollectionViewController = segue.destination as? GitCollectionViewController
        }
        
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.gitCollectionViewController?.delegate = self
        self.title = "GitHub"
        
        self.searchBar?.placeholder = "Search repos trending in the last month"
        
        
        
        
        let activityBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = activityBarButton
        
        //Setup internet connection notificaion
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        //Get some repos so there is something to show
        self.getRepositories()
    }
    
    
    // MARK: FILTERS AND OPTIONS
    
    @IBAction func showOptions(btn: UIButton) {
        
        self.searchBar?.resignFirstResponder()
        
        let alertView = UIAlertController(title: "Filters", message: "Which repositories would you like to see?", preferredStyle: UIAlertControllerStyle.actionSheet)
        

        alertView.popoverPresentationController?.sourceView = self.view
        alertView.popoverPresentationController?.sourceRect = btn.frame
        
        alertView.view.tintColor = UIColor.darkText
        
        alertView.addAction(UIAlertAction(title: "Trending today", style: .default, handler: { (action) in
            
            self.currentGitRepoTimeRange = .lastDay
            self.getRepositories()
            self.searchBar?.placeholder = "Search repos trending today"
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Trending in the last week", style: .default, handler: { (action) in
            
            self.currentGitRepoTimeRange = .lastWeek
            self.getRepositories()
            self.searchBar?.placeholder = "Search repos trending in the last week"
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Trending in the last month", style: .default, handler: { (action) in
            
            self.currentGitRepoTimeRange = .lastMonth
            self.getRepositories()
            self.searchBar?.placeholder = "Search repos trending in the last month"
            
        }))
        
        alertView.addAction(UIAlertAction(title: "My favourites", style: .default, handler: { (action) in
            
            self.currentGitRepoTimeRange = .none
            self.getLocallySavedRepositories()
            self.searchBar?.placeholder = "Search my favourites"
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    
    // MARK: GETTING REPOSITORIES
    
    func getRepositories() {
        
        self.activityIndicator.startAnimating()
        self.gitCollectionViewController?.collectionView?.alpha = 0.7
        GitConnect.shared.searchGit(timeRange: self.currentGitRepoTimeRange) { (gitSearchResult) in
            
            self.gitCollectionViewController?.reloadWithSearchResult(searchResult: gitSearchResult)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.gitCollectionViewController?.collectionView?.alpha = 1
                self.gitCollectionViewController?.collectionView?.isHidden = false
            }
            
        }
        
    }
    
    
    func getLocallySavedRepositories() {
        

        
        let gitSearchResult = LocalResourceManager.shared.getLocallyStoredObjects()
        gitSearchResult.resultsAreLocal = true
        self.gitCollectionViewController?.reloadWithSearchResult(searchResult: gitSearchResult)
        
  
        
    }


    // MARK: SEARCHBAR
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
          self.gitCollectionViewController?.gitSearchResult?.filterString = searchText
        
        DispatchQueue.main.async {
            self.gitCollectionViewController?.collectionView?.reloadData()
        }
        
    }
    
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.searchBar?.resignFirstResponder()
    }
    
    // MARK: GIT COLLECTION DELEGATE
    
    func gitCollectionViewControllerWillBeginDragging(controller: GitCollectionViewController) {
        self.searchBar?.resignFirstResponder()
    }
    
    
    // MARK: ORIENTATION CHANGE
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.gitCollectionViewController?.collectionView?.reloadData()
        
    }

    
    
    // MARK: INTERNET CONNECTION
    

    
    func reachabilityChanged(note: Notification?) {
        
        DispatchQueue.main.async {
            if self.reachability.isReachable == false {
                
                let image = UIImage(named: "no_internet")
                let optionsBarButton: UIBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
                self.navigationItem.rightBarButtonItem = optionsBarButton
                
                
            }
            else {
                
                let activityBarButton: UIBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                self.navigationItem.rightBarButtonItem = activityBarButton
                
            }
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

