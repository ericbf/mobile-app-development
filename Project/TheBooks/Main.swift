//
//  Main.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/31/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Main: UITabBarController {
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			prompt(title: "Menu", buttons: [("Change Passcode", .default), ("Close", .cancel)]) {title in
				if title == "Change Passcode" {
					AppDelegate.changePass()
				}
			}
		}
	}
}
