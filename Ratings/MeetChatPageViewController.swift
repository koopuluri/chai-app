//
//  MeetChatPageViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/2/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class MeetChatPageViewController: UIPageViewController {
    //let meetId = "56e1b6f5fa3f0c01f45568cd"
    
    var meetId: String?
    var from: String?
    var mode: String?
    
    var meetController: UIViewController?
    var chatController: UIViewController?
    
    let switchSegment = UISegmentedControl(items: ["info", "chat"])
    
    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // setting segmented view in the bar button item:
        switchSegment.selectedSegmentIndex = 0
        
        let startController = self.mode == "Meet" ? orderedViewControllers[0] : orderedViewControllers[1]
        
        self.setViewControllers([startController],
                                direction: .Forward,
                                animated: true,
                                completion: nil)
        
        let switchBarButton = UIBarButtonItem(customView: switchSegment)
        self.navigationItem.rightBarButtonItem = switchBarButton
        
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        self.meetController = self.newMeetController(self.meetId)
        self.chatController = self.newChatController(self.meetId)
        
        return [
            self.meetController!,
            self.chatController!
        ]
    }()
    
    private func newMeetController(meetId: String?) -> UIViewController {
        let meetController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("MeetController") as! MeetController;
        
        print("about to initialize the meetController from MeetChatPageViewController: \(self.meetId)")
        meetController.meetId = meetId;
        return meetController
    }
    
    private func newChatController(meetId: String?) -> UIViewController {
        let threadController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("ThreadViewController") as! MeetThreadViewController;
        return threadController;
    }
}


// MARK: UIPageViewControllerDataSource

extension MeetChatPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                                     willTransitionToViewControllers pendingViewControllers:[UIViewController]) {
        if (NSStringFromClass(pendingViewControllers[0].classForCoder) == "Ratings.MeetThreadViewController") {
            self.pageIndex = 1
        } else {
            self.pageIndex = 0
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                                    didFinishAnimating finished: Bool,
                                    previousViewControllers: [UIViewController],
                                    transitionCompleted completed: Bool) {
        if (finished && completed && previousViewControllers.count > 0) {
            switchSegment.selectedSegmentIndex = self.pageIndex
        }
    }
}

extension MeetChatPageViewController: UIPageViewControllerDataSource {
    
    
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