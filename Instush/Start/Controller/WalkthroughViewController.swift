//
//  WalkthroughViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 03/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIPageViewController {

    // MARK: Outlets
    var pageContent = ["Instush is a simple way to capture and share the world’s moments.",
                       "Follow your friends and family to see what they’re up to, and discover accounts from all over the world that are sharing things you love.",
                       "Join the community of over 1 billion people and express yourself by sharing all the moments of your day — the highlights and everything in between, too."]
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        guard let pageContentVC = getViewController(at: 0) else { return }
        setViewControllers([pageContentVC], direction: .forward, animated: true, completion: nil)
    }
}

// MARK: Extension - UIPageViewControllerDataSource
extension WalkthroughViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var indexPage = (viewController as! WalkthroughContentViewController).index
        indexPage -= 1
        return getViewController(at: indexPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var indexPage = (viewController as! WalkthroughContentViewController).index
        indexPage += 1
        return getViewController(at: indexPage)
    }
    
    func getViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index == pageContent.count { return nil }
        let pageContnetVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController")
                                as! WalkthroughContentViewController
        pageContnetVC.index = index
        pageContnetVC.content = pageContent[index]
        return pageContnetVC
    }
}



