//
//  UIView.swift
//  Common
//
//  Created by Eric Ferreira on 1/25/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import UIKit

public extension UIView {
	/**
	Remove all the subviews of this view, if it has any.
	*/
	public func removeAllSubviews() {
		for subview in subviews as [UIView] {
			subview.removeFromSuperview()
		}
	}
	
	/**
	Replaces one of the subviews of this view with another view, copying over all of the constraints of the subview.
	
	
	This function assumes that the subview to replace *is* in fact a subview of this view, and that the view to use to replace the subview is *not* already a subview of this view.
	
	- parameters:
		- subview: the view to be replaced.
		- view: the view to use to replace the subview.
	*/
	public func replace(_ subview: UIView, with view: UIView) {
		// Duplicate the frame of the view being replaced
		
		view.frame = subview.frame
		
		// Add the new view
		
		self.addSubview(view)
		
		// Duplicate all of the constraints that include the view being replaced
		
		for constraint in constraints {
			if constraint.firstItem as? UIView == subview {
				self.addConstraint(NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
		}
		
		for constraint in constraints {
			if constraint.secondItem as? UIView == subview {
				self.addConstraint(NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: view, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
		}
		
		for constraint in subview.constraints {
			if constraint.firstItem as? UIView == subview && constraint.secondItem == nil {
				view.addConstraint(NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
			
			if constraint.firstItem as? UIView == subview && constraint.secondItem as? UIView == subview {
				view.addConstraint(NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: view, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
		}
		
		// Remove the view being replaced
		
		subview.removeFromSuperview()
	}
}
