//
//  UIViewController.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import UIKit

public extension UIViewController {
	@IBAction func dismiss() {
		dismiss(animated: true, completion: nil)
	}
	
	func presentSheet(_ buttons: (title: String, style: UIAlertActionStyle, handler: ((UIAlertAction) -> ())?)...) {
		presentSheet(buttons)
	}
	
	func presentSheet(_ buttons: [(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction) -> ())?)]) {
		let alert = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		for button in buttons {
			alert.addAction(UIAlertAction(title: button.title, style: button.style, handler: button.handler))
		}
		
		present(alert, animated: true, completion:nil)
	}
	
	/**
	Go to the view controller with the passed id, or the initial view controller if no id was passed, from another storyboard.
	
	- parameters:
		- storyboard: the desired storyboard's name, as a string.
		- id: the id of the view controller in that storyboard
		- animated: whether to animate the transition, default is `true`.
		- pre: a callback that can make changes to the view controller before it is pushed.
		- post: a callback that can make changes to the view controller after it is pushed.
	*/
	public func push(to storyboard: String, id: String? = nil, animated: Bool = true, pre: ((UIViewController)->())? = nil, post: ((UIViewController)->())? = nil) {
		let sb = UIStoryboard(name: storyboard, bundle: nil)
		
		var next: UIViewController?
		
		if let id = id {
			next = sb.instantiateViewController(withIdentifier: id)
		} else {
			next = sb.instantiateInitialViewController()
		}
		
		while let navController = next as? UINavigationController {
			next = navController.viewControllers[0]
		}
		
		if let next = next {
			pre?(next)
			
			if let nav = self.navigationController {
				nav.pushViewController(next, animated: animated) {
					post?(next)
				}
			} else {
				self.present(next, animated: animated) {
					post?(next)
				}
			}
		}
	}
	
	/**
	Creates a prompt with multiple buttons.
	
	- parameters:
		- title: the title to display, default is `nil`.
		- message: the message to display, default is `nil`.
		- buttons: the buttons, default is `[("No", .cancel), ("Yes", .default)]`.
		- callback: the callback for when the user taps a button. It receives the title of the tapped button.
	*/
	public func prompt(title: String? = nil, message: String? = nil, buttons: [(title: String, style: UIAlertActionStyle)] = [("No", .cancel), ("Yes", .default)], callback: ((_ button: String) -> ())? = nil) {
		let promptController = UIAlertController(title: title, message: message, preferredStyle: .alert),
			handler: (UIAlertAction!) -> () = {action in
				if let title = action.title {
					callback?(title)
				}
				
				return
			}
		
		for button in buttons {
			promptController.addAction(UIAlertAction(title: button.title, style: button.style, handler: handler))
		}
		
		self.present(promptController, animated: true, completion: nil)
	}
	
	/**
	Creates a prompt with a single button.
	
	- parameters:
		- title: the title to display, default is `nil`.
		- message: the message to display, default is `nil`.
		- button: the button, default is `("OK", .default)`.
		- callback: the callback for when the user taps the button.
	*/
	public func alert(title: String? = nil, message: String? = nil, button: (title: String, style: UIAlertActionStyle) = ("OK", .default), callback: (()->())? = nil) {
		self.prompt(title: title, message: message, buttons: [button], callback: {_ in callback?()})
	}
}
