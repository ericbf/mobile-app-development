//
//  Authentication.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/30/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Authentication: UIViewController {
	var onAuthenticated: (() -> ())?
	
	override func dismiss() {
		onAuthenticated?()
		
		super.dismiss()
	}
}
