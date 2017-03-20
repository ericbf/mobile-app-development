//
//  BaseViewController.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/20/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

private var key: UInt8 = 0
extension UIViewController {
	var onDone: (() -> ())? {
		get {
			return associated(with: self, key: &key) { nil }
		}
		set {
			associate(with: self, key: &key, value: newValue)
		}
	}
}
