//
//  GitCollectionViewController.swift
//  GitHub-Trends
//
//  Created by noasis on 10/1/17.
//  Copyright © 2017 iyedah. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifierDefault = "Default"
private let reuseIdentifierSquare = "Square"

protocol GitCollectionViewControllerDelegate: class {
    func gitCollectionViewControllerWillBeginDragging(controller: GitCollectionViewController)
}

class GitCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: GitCollectionViewControllerDelegate?
    
    var gitSearchResult:GitSearchResult?
    var gettingMoreResults:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(localResourceChange), name: LocalResourceManager.LOCALSTOREDIDCHANGE, object: nil)

        self.collectionView!.register(UINib(nibName: "GitDefaultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierDefault)
        
        self.collectionView!.register(UINib(nibName: "GitSquareCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierSquare)

    }
    

    // MARK: RELOADING RESULTS
    
    func reloadWithSearchResult(searchResult:GitSearchResult) {
        
        self.gitSearchResult = searchResult
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            
            if (self.gitSearchResult?.filteredArray.count)! > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            
        }
        
    }
    
    // MARK: GETTING MORE RESULTS
    
    func showMoreResults() {
        
        if self.gitSearchResult?.nextPageRequest != nil && self.gettingMoreResults != true {
            
            self.gettingMoreResults = true

            
            self.gitSearchResult?.getAndAppendNextPage(completion: {
                DispatchQueue.main.async {
                    self.gettingMoreResults = false
                    self.collectionView?.reloadData()
                    
                }
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = self.gitSearchResult?.filteredArray.count {
            return count
        }
        
        return 0
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //We have two different cell xibs depending on our layout because we want the look and feel to consider
        //screen size (ie iPad or Other)
        
        var cell:GitCollectionViewCell
        if UILayoutManager.useDefaultLayout() == true {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierDefault, for: indexPath) as! GitCollectionViewCell
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierSquare, for: indexPath) as! GitCollectionViewCell
        }
        
        cell.backgroundColor = self.collectionView?.backgroundColor
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = self.collectionView?.tintColor
        }

        
        let repoInfo:GitRepoInfo = (self.gitSearchResult?.filteredArray[indexPath.row])!
        
        //Setting up our cell
        
        cell.usernameLbl?.text = repoInfo.owner?.username
        cell.repoDescriptionLbl?.text = repoInfo.description_text
        cell.repoNameLbl?.text = repoInfo.name
        
        if repoInfo.stargazers_count > 0 {
            let count = repoInfo.stargazers_count
            cell.starGazersLbl?.text = "☆ \(count)"
        }
        else {
             cell.starGazersLbl?.text = ""
        }
        
        
        let placeholderImage = UIImage(named: "github_avatar")
        cell.avatarImageView?.alpha = 0.5
        if let imagePath = repoInfo.owner?.avatar_url {
            
            
            cell.avatarImageView?.sd_setImage(with: URL(string: imagePath), placeholderImage: placeholderImage, options: [], completed: { (image, error, cacheType, url) in
                cell.avatarImageView?.alpha = 1
            })
            
            
        }
        else {
            cell.avatarImageView?.image = placeholderImage
        }
        
        
        if repoInfo.isFavourite == true {
            cell.isFavouriteLbl?.isHidden = false
        }
        else {
            cell.isFavouriteLbl?.isHidden = true
        }

    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == ((self.gitSearchResult?.filteredArray.count)! - 1) {
            self.showMoreResults()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let repoInfo:GitRepoInfo = (self.gitSearchResult?.filteredArray[indexPath.row])!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVc:DetailViewController = storyboard.instantiateViewController(withIdentifier :"DetailViewController") as! DetailViewController
        signInVc.repoInfo = repoInfo
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = appDelegate.window?.rootViewController as? UINavigationController
        navigationController?.pushViewController(signInVc, animated: true)
        
    }
    
    
    
    // MARK : UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if UILayoutManager.useDefaultLayout() == true {
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: 138)
        }
        else {
            return CGSize(width: 200, height: 200)
        }
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    

    // MARK: SCROLL VIEW DELEGATE
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
  
        self.delegate?.gitCollectionViewControllerWillBeginDragging(controller: self)
        
    }

    
    
    // MARK: LOCAL RESOURCES CHANGE NOTIFICATION
    
    //If there was a change to the local data store we want to update the collection if it is show local stuff
    func localResourceChange() {
        
        if self.gitSearchResult?.resultsAreLocal == true {
            
            let gitSearchResult = LocalResourceManager.shared.getLocallyStoredObjects()
            gitSearchResult.resultsAreLocal = true
            self.reloadWithSearchResult(searchResult: gitSearchResult)
            
        }
        
    }

}
