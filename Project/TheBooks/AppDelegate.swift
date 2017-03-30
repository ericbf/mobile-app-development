//
//  AppDelegate.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	private func presentAuth(withAnimation animated: Bool = false) {
		struct auth {
			static let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
			static var presenting = false
		}
		
		if auth.presenting {
			// No need to present it if already presenting it!
			return
		}
		
		guard let window = window,
			  let root = window.rootViewController else {
			// If we are unable to push the auth, stop the app right here.
			fatalError()
		}
		
		let authentication = auth.storyboard.instantiateInitialViewController() as! Authentication
		
		authentication.onAuthenticated = {
			auth.presenting = false
		}
		
		root.present(authentication, animated: animated, completion: nil)
		auth.presenting = true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// This will present when the app first loads. We put it in a delay
		//    because we want to give the app time to initialize the root views
		//    (we avoid warnings this way. Warnings are BAD).
		delay {
			self.presentAuth()
		}
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// This will present the auth each time the app loses focus.
		presentAuth(withAnimation: true)
	}
	

	func applicationWillTerminate(_ application: UIApplication) {
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return [.portrait, .portraitUpsideDown]
	}

	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "TheBooks")

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
	
	var context: NSManagedObjectContext {
		return self.persistentContainer.viewContext
	}

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

