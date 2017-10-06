# GitHub-Trends

An iOS App that shows trending GitHub repos and allows marking favourites and sharing repo links.
Designed for both iPad and iPhone (iOS 10+)



# General architecture of the application.

The is written in Swift 3.0 and follows an archeticture that revolves around User interface controllers, API connection managers, API request helper objects, Local storage manager, and native objects representing request results

On the UI side there are two main screens. A screen showing a searchable collection of repos as chosen by the user (trending last month, last week, today, and favourites), and another screen showing more details about a repo and allowing for actions such as saving to favourites, sharing, and opening in GitHub (safari).


# Reasoning behind main technical choices.

The app is designed with simplicity, speed, and smoothness in mind. Technical choices in the app adhere to this guideline
by being lightweight and intuitive

The following pods were used:

     SDWebImage - For loading and cahcing avatar images
     
     ReachabilitySwift - For detecting internet connectivity and displaying disconnection icon in the event of net loss

# Trade-offs

In storing favourites NSKeyedArchiver was used as it is simple and fast to implement, however with more time for development
a more versatile and remotely-sycable solution may be used (AWS Cognito, Firebase, etc)

Currently the search will search the currently displayed collection and then slowly reveal more repos that match
the search for that colleciton request. However it should simply perform one GitHub API request that combines 
the search string and the other paramters of the request (ie. time range). This was not implemented due to time constraints
on the project but is simple enough to add in the future

# Installation

Make sure to have cocoapods installed and perform pod install before building
