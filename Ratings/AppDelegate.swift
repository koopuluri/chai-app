//
//  AppDelegate.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 1/27/16.
//  Copyright (c) 2016 Poop. All rights reserved.


import UIKit
import FBSDKCoreKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func goToSignup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Then push that view controller onto the navigation stack
        let rootViewController = self.window!.rootViewController as! UINavigationController
        let signupController = storyboard.instantiateViewControllerWithIdentifier("SignupController")
        rootViewController.presentViewController(signupController, animated: true, completion: nil)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Google maps:
        GMSServices.provideAPIKey("AIzaSyDvzo4jnTfjRCQLI0Wgp5NzGW4wJzQ6DCI")
        
        API.APP = self
        
        // notifs:
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
    }
    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        //send this device token to server
        Util.DEVICE_TOKEN = Util.getDeviceTokenString(deviceToken)
        
        print("SET DEVICE TOKEN!! \(Util.DEVICE_TOKEN)")
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SocketIOManager.sharedInstance.establishConnection()
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

