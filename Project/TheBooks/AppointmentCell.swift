//
//  AppointmentCell.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class AppointmentCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var startLabel: UILabel!
	@IBOutlet weak var endLabel: UILabel!
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		let resetter = getBackgroundColorResetter()
		
		super.setHighlighted(highlighted, animated: animated)
		
		resetter()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		let resetter = getBackgroundColorResetter()
		
		super.setSelected(selected, animated: animated)
		
		resetter()
	}
	
	private func getBackgroundColorResetter() -> () -> () {
		func makeResetter(_ view: UIView) -> () -> () {
			let color = view.backgroundColor
			let resetters = view.subviews.map { makeResetter($0) }
			
			return {
				view.backgroundColor = color
				resetters.forEach { $0() }
			}
		}
		
		return makeResetter(self)
	}
}
