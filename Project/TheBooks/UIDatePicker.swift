//
//  UIDatePicker.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/26/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

extension UIDatePicker {
	public func clamp() {
		let interval = TimeInterval(minuteInterval * 60)
		let time = self.date.timeIntervalSinceReferenceDate
		let remaining = time.remainder(dividingBy: interval)
		let rounded = (remaining / interval).rounded()
		let floor = time - remaining
		let clampedTime = floor + rounded * interval
		
		date = Date(timeIntervalSinceReferenceDate: clampedTime)
	}
}
