//
//  PresentModallyWithNavigationItem.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/20/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class PresentModallyWithNavigationItem : UIStoryboardSegue {
	override func perform() {
		let nav = UINavigationController(rootViewController: self.destination)
		
		self.source.present(nav, animated: true, completion: nil)
	}
}
