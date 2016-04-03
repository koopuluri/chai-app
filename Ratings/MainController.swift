//
//  MainController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/2/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class MainController: UIPageViewController {
    
    let meetsController = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewControllerWithIdentifier("MeetsController")
    
    @IBAction func unwindMain(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setViewControllers([meetsController],
                           direction: .Forward,
                           animated: true,
                           completion: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "settings", style: UIBarButtonItemStyle.Plain, target: self, action: Selector())
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "chats", style: UIBarButtonItemStyle.Plain, target: self, action: Selector())
        self.navigationItem.title = "Meets"
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            
            UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("SettingsController"),
            
            self.meetsController,
            
            UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("ChatsController")
        ]
    }()
}




extension MainController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            willTransitionToViewControllers pendingViewControllers:[UIViewController]) {
        print("nibName: \(NSStringFromClass(pendingViewControllers[0].classForCoder))")
        if (NSStringFromClass(pendingViewControllers[0].classForCoder) == "Ratings.MeetThreadViewController") {
            //self.pageIndex = 1
        } else {
            //self.pageIndex = 0
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                                               previousViewControllers: [UIViewController],
                                               transitionCompleted completed: Bool) {
        if (finished && completed && previousViewControllers.count > 0) {
            
        }
    }
}

extension MainController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        
        return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}



























