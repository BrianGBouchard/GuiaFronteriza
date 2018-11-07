//
//  AppDelegate.swift
//  GuíaFronteriza
//
//  Created by Brian Bouchard on 9/6/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit
import CoreData
import FirebaseInstanceID
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var currentUserID: String?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "Menlo", size: 15.0)!], for: .normal)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Menlo", size: 15.0)!, NSAttributedString.Key.foregroundColor : UIColor.white]
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (isGranted, error) in
            if error != nil {
                print("ERROR")
            } else {
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (user, error) in
                if let error = error {
                    print("Failed to sign in anonymously with error \(error)")
                }
                if let user = user {
                    self.currentUserID = user.user.uid
                    print("USER ID IS \(String(describing: self.currentUserID))")
                }
            }
        } else {
            currentUserID = Auth.auth().currentUser?.uid
            print("USER ID IS \(String(describing: self.currentUserID))")
            if let currentID = currentUserID {

            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /*Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        print("Token is \(Messaging.messaging().apnsToken)")*/
    }

    func connectToFMC() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFMC()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //tokenID = fcmToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Gui_aFronteriza")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

