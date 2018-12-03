//
//  SearchViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit
import CarbonKit

class SearchViewController: UIViewController {
 
    // MARK: Properties
    let navItems = ["People", "Hashtag"]        /* CarbonTabSwipeNavigation items title */
    var navVC = [SearchBarLinstener]()          /* CarbonTabSwipeNavigation ViewControllers */
    var searchBarListener: SearchBarLinstener?
    
    // MARK: Outlets
    @IBOutlet weak var viewContent: UIView!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCarbonTabSwipeNavigation()
    }
    
    
    // MARK: Methods
    private func configureSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 18))
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:searchBar)
    }
    
    private func configureCarbonTabSwipeNavigation() {
        let carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: navItems, delegate: self)
        let tabWidth = view.frame.width / CGFloat(navItems.count)
        carbonTabSwipeNavigation.setNormalColor(UIColor.lightGray)
        carbonTabSwipeNavigation.setSelectedColor(UIColor.darkText)
        carbonTabSwipeNavigation.setIndicatorColor(UIColor.darkText)
        carbonTabSwipeNavigation.setIndicatorHeight(1.0)
        carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(tabWidth, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(tabWidth, forSegmentAt: 1)
        carbonTabSwipeNavigation.carbonSegmentedControl?.backgroundColor = UIColor.white
        carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: viewContent)
        carbonTabSwipeNavigation.delegate = self
    }
}

// MARK: Extension - Search Bar Delegate
extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarListener?.onTextChanged(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarListener?.onSearchClicked()
    }
}

// MARK: Extension - Carbon Tab Swipe Navigation Delegate
extension SearchViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation,
                                  viewControllerAt index: UInt) -> UIViewController {
        switch index {
            case 1:
                let searchHashtagVC = storyboard?.instantiateViewController(withIdentifier: "HashtagSearchViewController")
                    as! HashtagSearchViewController
                navVC.insert(searchHashtagVC, at: Int(index))
                return searchHashtagVC
            default:
                let searchPeopleVC = storyboard?.instantiateViewController(withIdentifier: "SearchPeopleViewController")
                    as! SearchPeopleViewController
                navVC.insert(searchPeopleVC, at: Int(index))
                return searchPeopleVC
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, willMoveAt index: UInt) {
        self.searchBarListener = navVC[Int(index)]
    }
}

// MARK: Protocol - Search Bar Events
protocol SearchBarLinstener {
    func onTextChanged(searchText: String)
    func onSearchClicked()
}
