//
//  NSDate.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import Foundation

public extension Date {
	/**
	Allows you to create a date by ajusting only specific components of a date.
	
	- returns: the adjusted `NSDate` object.
	
	- parameters:
		- componentFlags: the components to edit, default is `[.year, .month, .day, .hour, .minute, .second]`.
		- adjuster: the callback that does the adjustments to the date.
	
	This function force unwraps the result for you, so it will crash if you make incompatible adjustments.
	*/
	public func dateByAdjusting(components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second], adjuster: (DateComponents) -> ()) -> Date {
		let cal = Calendar.current,
			comps = (cal as NSCalendar).components(components, from: self)
		
		adjuster(comps)
		
		return cal.date(from: comps)!
	}
}
