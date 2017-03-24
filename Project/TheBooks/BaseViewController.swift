//
//  BaseViewController.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/20/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

private var key_onDone: UInt8 = 0
extension UIViewController {
//	var onDone: ((Any?) -> ())? {
//		get {
//			return associated(with: self, key: &key_onDone) { nil }
//		}
//		set {
//			associate(with: self, key: &key_onDone, newValue)
//		}
//	}
	
	@IBAction func dismissSelf() {
		dismiss(animated: true, completion: nil)
	}
}
