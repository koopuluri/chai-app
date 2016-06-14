//
//  MainController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/2/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class MainController: UIPageViewController {
    
    var navbarButtons: [UIButton]!
    
    // page indices to keep track of transitions:
    var currentPageIndex = 1
    var previousPageIndex = -1
    
    var startIndex = 1
    
    let meetsController = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewControllerWithIdentifier("MeetsController")
    
    let settingsController = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewControllerWithIdentifier("SettingsController")
    
    let chatsController = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewControllerWithIdentifier("ChatsController")
    
    @IBAction func unwindMain(segue: UIStoryboardSegue) {}
    
    func createMeetSegue() {
        self.performSegueWithIdentifier("CreateMeetSegue", sender: nil)
    }
    
    func getBarButtonIcon(imagePath: String) -> UIBarButtonItem {
        let btnName = UIButton()
        btnName.setImage(UIImage(named: imagePath), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
        
        let barButton = UIBarButtonItem()
        barButton.customView = btnName
        
        return barButton

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        print("MainController.viewDidLoad().startIndex: \(startIndex)")
        
        var startController: UIViewController?
        if (startIndex == 0) {
            startController = settingsController
        } else if (startIndex == 1) {
            startController = meetsController
        } else {
            startController = chatsController
        }
        
        setViewControllers([startController!],
                           direction: .Forward,
                           animated: true,
                           completion: nil)
        
        // setting bg color of navigationBar to white:
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return startIndex
    }

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.settingsController,
            self.meetsController,
            self.chatsController
        ]
    }()
    
    func programmaticallyMoveToPage(index: Int, direction: UIPageViewControllerNavigationDirection) {
        
        print("programmaticallyMoveToPage \(index) -- direction: \(direction.rawValue)")
        
        let selectedViewController = self.orderedViewControllers[index]
        
        self.setViewControllers([selectedViewController],
                                direction: direction,
                                animated: false,
                                completion: nil)
        
        // making the color transition:
        print("button transition: \(self.currentPageIndex) --> \(index)")
        self.previousPageIndex = self.currentPageIndex
        self.currentPageIndex = index
    }
}

extension MainController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            willTransitionToViewControllers pendingViewControllers:[UIViewController]) {
    }
    
    // weird workaround to add tintColor... http://stackoverflow.com/a/26443287
    func setButtonTintColor(button: UIButton?, color: UIColor?) {
        button?.imageView!.image = button?.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        button?.imageView?.tintColor = color
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                                               previousViewControllers: [UIViewController],
                                               transitionCompleted completed: Bool) {
        if (finished && completed && previousViewControllers.count > 0) {
            // time to change the selected, corresponding icons:
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



























