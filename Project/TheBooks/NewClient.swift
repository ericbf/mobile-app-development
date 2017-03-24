//
//  NewClient.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class NewClient: UIViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	
	@IBOutlet weak var firstNameField: UITextField!
	@IBOutlet weak var lastNameField: UITextField!
	
	lazy var onDone: ((Client) -> ())? = {_ in self.dismissSelf()}
	
	@IBAction func revalidate() {
		if let fn = firstNameField.text,
			let ln = lastNameField.text,
			fn.characters.count > 0 &&
				ln.characters.count > 0 {
			navigationItem.rightBarButtonItem!.isEnabled = true
		} else {
			navigationItem.rightBarButtonItem!.isEnabled = false
		}
	}
	
	@IBAction func done() {
		//TODO: Create the client
		let client = Client.make(for: context)
		
		client.firstName = firstNameField.text!
		client.lastName = lastNameField.text!
		
		let letterRequest = Letter.myFetchRequest()
		let letterValue = mapToLetter(client.firstName)
		
		letterRequest.predicate = NSPredicate(format: "value == %@", letterValue)
		
		let maybeList = try? context.fetch(letterRequest)
		
		if let letter = maybeList?.first {
			client.letter = letter
		} else {
			let letter = Letter.make(for: context)
			
			letter.value = letterValue
			
			client.letter = letter
		}
		
		client.letter.sort()
		
		try? context.save()
		
		onDone?(client)
	}
	
	func mapToLetter(_ str: String) -> String {
		switch str {
		case ~/"[a-zA-Z]":
			return String(str.first).uppercased()
		default:
			return "#"
		}
	}
}
