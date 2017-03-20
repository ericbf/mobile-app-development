//
//  DismissController.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class DismissController: UIStoryboardSegue {
	override func perform() {
		self.source.presentingViewController?.dismiss(animated: true, completion: nil)
	}
}
