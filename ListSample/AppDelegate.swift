//
//  AppDelegate.swift
//  ListSample
//
//  Created by 平塚 俊輔 on 2016/02/19.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    class func sharedAppDelegate() -> AppDelegate {
        let sharedAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return sharedAppDelegate
    }
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /**
     共通のプログレス
     */
    func showCloseCommonProgress(isForceClose:Bool = false) {
        if isForceClose == false {
            if !SVProgressHUD.isVisible(){
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
        } else {
            if SVProgressHUD.isVisible(){
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    
}

extension NSObject{
    func notnullCheck(str: String?) ->Bool{
        var notnullflag = false
        if let str_constant = str{
            if str_constant != ""{
                notnullflag = true
            }
        }
        return notnullflag
    }
}

extension UIView{

    //タップにより色を変えるメソッドを呼び出す
    func changeColorByTap(int_color:Int){
        
        self.backgroundColor = UIColor(netHex: int_color)
    }
    
    
    
}

