//
//  UINavigationController.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import UIKit

public extension UINavigationController {
	/**
	Pushes a view controller onto the receiver’s stack and updates the display, then calls a given completion handler.
	
	
	The object in the viewController parameter becomes the top view controller on the navigation stack. Pushing a view controller causes its view to be embedded in the navigation interface. If the animated parameter is `true`, the view is animated into position; otherwise, the view is simply displayed in its final location.
	
	
	In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly. For information on how the navigation bar is updated, see `Updating the Navigation Bar`.
	
	- parameters:
		- viewController: The view controller to push onto the stack. This object cannot be a tab bar controller. If the view controller is already on the navigation stack, this method throws an exception.
		- animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
		- completion: The completion handler to use. It will be called after the transition is done, which could be right away if animated was false.
	*/
	func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
		self.pushViewController(viewController, animated: animated)
		
		if let coordinator = self.transitionCoordinator, animated {
			coordinator.animate(alongsideTransition: nil) { _ in
				completion?()
			}
		} else {
			completion?()
		}
	}
}
