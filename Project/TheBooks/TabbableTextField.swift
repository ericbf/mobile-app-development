//
//  TabbableTextField.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/30/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

private class TabbableTextFieldDelegate: NSObject, UITextFieldDelegate {
	var delegate: UITextFieldDelegate?
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		delegate?.textFieldDidBeginEditing?(textField)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		delegate?.textFieldDidBeginEditing?(textField)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		delegate?.textFieldDidEndEditing?(textField, reason: reason)
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return delegate?.textFieldShouldBeginEditing?(textField) ?? true
	}
	
	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return delegate?.textFieldShouldClear?(textField) ?? true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return delegate?.textFieldShouldEndEditing?(textField) ?? true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		goToNext(for: textField)
		
		return delegate?.textFieldShouldReturn?(textField) ?? true
	}
}

private func goToNext(for responder: UIResponder) {
	guard let responder = responder as? Tabbable else {
		return
	}
	
	if let next = responder.nextField {
		next.becomeFirstResponder()
	} else {
		responder.resignFirstResponder()
	}
}

protocol Tabbable {
	var nextField: UIResponder? { get set }
	
	@discardableResult
	func resignFirstResponder() -> Bool
}

class TabbableTextField: UITextField, Tabbable {
	@IBOutlet weak var nextField: UIResponder?
	
	// Add a strong reference here, so that it doesn't deinit the delegate
	private let myDelegate = TabbableTextFieldDelegate()
	
	override weak open var delegate: UITextFieldDelegate? {
		// This allows user to set a custom delegate too. It essentially maintains the two delegates, and the tabbale one passes off any functions to the user's, after doing its thing.
		didSet {
			if let tabber = oldValue as? TabbableTextFieldDelegate {
				tabber.delegate = delegate
				delegate = tabber
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		delegate = myDelegate
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		delegate = myDelegate
	}
}
