//
//  BaseViewController.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/20/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

extension UIViewController {
	@IBAction func dismissSelf() {
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
}
