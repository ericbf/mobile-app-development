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

extension UITableViewController {
	func callout(_ indexPaths: IndexPath...) {
		callout(indexPaths)
	}
	
	func callout(_ indexPaths: [IndexPath]) {
		/*
		- (void)calloutCells:(NSArray*)indexPaths
		{
		[UIView animateWithDuration:0.0
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^void() {
		for (NSIndexPath* indexPath in indexPaths)
		{
		[[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
		}
		}
		completion:^(BOOL finished) {
		for (NSIndexPath* indexPath in indexPaths)
		{
		[[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
		}
		}];
		}
		*/
		UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
			for indexPath in indexPaths {
				self.tableView.cellForRow(at: indexPath)!.setHighlighted(true, animated: true)
			}
		}, completion: {_ in
			for indexPath in indexPaths {
				self.tableView.cellForRow(at: indexPath)!.setHighlighted(false, animated: true)
			}
		})
	}
}
