//
//  DetailViewController.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit
import ReachabilitySwift

class DetailViewController: UIViewController {
    
    var repoInfo:GitRepoInfo?
    
    @IBOutlet weak var usernameLbl:UILabel?
    @IBOutlet weak var repoNameLbl:UILabel?
    @IBOutlet weak var repoDescriptionLbl:UILabel?
    @IBOutlet weak var starGazersLbl:UILabel?
    @IBOutlet weak var forksLbl:UILabel?
    @IBOutlet weak var createdAtLbl:UILabel?
    @IBOutlet weak var languageLbl:UILabel?
    
    @IBOutlet weak var avatarImageView:UIImageView?
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let reachability:Reachability = Reachability()!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repository"
        
        let activityBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = activityBarButton
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        
        self.loadRepo()

        self.activityIndicator.startAnimating()
        self.repoInfo?.update(completion: { (success) in
            
            if success == true {
                DispatchQueue.main.async {
                    self.loadRepo()
                    self.activityIndicator.stopAnimating()
                }
            }
            
        })
        
        
        
    }
    
    // MARK: DISPLAYING THE REPO INFO
    
    func loadRepo() {
        
        if self.repoInfo != nil {
            
            self.usernameLbl?.text = self.repoInfo?.owner?.username
            self.repoDescriptionLbl?.text = self.repoInfo?.description_text
            self.repoNameLbl?.text = self.repoInfo?.name
            
            let starCount = self.repoInfo?.stargazers_count
            self.starGazersLbl?.text = "☆ \(starCount!)"
            
            let forkCount = self.repoInfo?.forks
            self.forksLbl?.text = "♆ \(forkCount!)"
            
            self.languageLbl?.text = self.repoInfo?.language
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            self.createdAtLbl?.text = "Created at " + formatter.string(from: (self.repoInfo?.created_at)!)
            
            
            
            let placeholderImage = UIImage(named: "github_avatar")
            if let imagePath = self.repoInfo?.owner?.avatar_url {
                self.avatarImageView?.sd_setImage(with: URL(string: imagePath), placeholderImage: placeholderImage)
            }
            else {
                self.avatarImageView?.image = placeholderImage
            }
            
        }
        
    }
    
    
    // MARK: OPTIONS
    
    @IBAction func showOptions(btn:UIButton) {
        
        
        
        let alertView = UIAlertController(title: self.repoInfo?.name, message: self.repoInfo?.html_url, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertView.popoverPresentationController?.sourceView = self.view
        alertView.popoverPresentationController?.sourceRect = btn.frame
        
        alertView.view.tintColor = UIColor.darkText
        
        
        if self.repoInfo?.isFavourite == false {
            
            alertView.addAction(UIAlertAction(title: "Save to favourites", style: .default, handler: { (action) in
                
                self.repoInfo?.saveToFavourites()
                
            }))
            
        }
        else {
            
            alertView.addAction(UIAlertAction(title: "Remove from favourites", style: .default, handler: { (action) in
                
                self.repoInfo?.removeFromFavourites()
                
            }))
            
        }
        
        if self.repoInfo?.html_url != nil {
            let url = URL(string: (self.repoInfo?.html_url)!)!
            if UIApplication.shared.canOpenURL(url) {
                alertView.addAction(UIAlertAction(title: "Open in GitHub", style: .default, handler: { (action) in
                    
                    let options = [UIApplicationOpenURLOptionUniversalLinksOnly : false]
                    UIApplication.shared.open(url, options: options, completionHandler: nil)
                    
                }))
            }
            
            
            alertView.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
                
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activity.popoverPresentationController?.sourceRect = btn.frame
                activity.popoverPresentationController?.sourceView = self.view
                self.present(activity, animated: true, completion: nil)
                
            }))
            

        }
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
        

        

        
        
        
        
    }
    

    
    // MARK: INTERNET CONNECTION
    
    
    
    func reachabilityChanged(note: Notification?) {
        
        DispatchQueue.main.async {
            if self.reachability.isReachable == false {
                
                let image = UIImage(named: "no_internet")
                let optionsBarButton: UIBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
                //optionsBarButton.tintColor = UIColor.red
                
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
