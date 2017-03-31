//
//  Authentication.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/31/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit
import BKPasscodeView
import SwiftKeychainWrapper

private let PASSCODE_KEY = "the_PAssCoDe_k3y"

class Authentication: NSObject, BKPasscodeViewControllerDelegate {
	private override init() {}
	
	var fails: UInt = 0
	
	/**
	* Tells the delegate that passcode is created or authenticated successfully.
	*/
	func passcodeViewController(_ aViewController: BKPasscodeViewController!, didFinishWithPasscode aPasscode: String!) {
		fails = 0
		
		KeychainWrapper.standard.set(aPasscode, forKey: PASSCODE_KEY)
		
		aViewController.dismiss()
	}
	
	func passcodeViewControllerLock(untilDate aViewController: BKPasscodeViewController!) -> Date! {
		if fails == 5 {
			return Date(timeIntervalSinceNow: 10)
		} else if fails == 6 {
			return Date(timeIntervalSinceNow: 30)
		} else if fails >= 7 {
			return Date(timeIntervalSinceNow: 60)
		}
		
		return nil
	}
	
	func passcodeViewControllerNumber(ofFailedAttempts aViewController: BKPasscodeViewController!) -> UInt {
		return fails
	}
	
	func passcodeViewControllerDidFailAttempt(_ aViewController: BKPasscodeViewController!) {
		fails += 1
	}
	
	func passcodeViewControllerDidFailTouchIDKeychainOperation(_ aViewController: BKPasscodeViewController!) {
		print("fail touchID")
	}
	
	func passcodeViewController(_ aViewController: BKPasscodeViewController!, authenticatePasscode aPasscode: String!, resultHandler aResultHandler: ((Bool) -> Void)!) {
		let maybeSaved = KeychainWrapper.standard.string(forKey: PASSCODE_KEY)
		
		aResultHandler(maybeSaved != nil && aPasscode == maybeSaved!)
	}
	
	private static let delegate = Authentication()
	
	class func getInstance() -> BKPasscodeViewController {
		let controller = BKPasscodeViewController(nibName: nil, bundle: nil)
		
		controller.delegate = delegate
		
		if KeychainWrapper.standard.string(forKey: PASSCODE_KEY) == nil {
			controller.type = BKPasscodeViewControllerNewPasscodeType
		} else {
			controller.type = BKPasscodeViewControllerCheckPasscodeType
		}
		
		controller.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle
		
		controller.touchIDManager = BKTouchIDManager(keychainServiceName: KeychainWrapper.standard.serviceName)
		controller.touchIDManager.promptText = "Or tap cancel to use passcode."
		
		return controller
	}
}
