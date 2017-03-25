//
//  NewClient.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class ViewClient: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	
	@IBOutlet weak var firstNameField: UITextField!
	@IBOutlet weak var lastNameField: UITextField!
	@IBOutlet weak var phoneField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	
	var client: Client? {
		didSet {
			guard let client = client, firstNameField != nil else {
				return
			}
			
			initialFirstName = client.firstName
			initialLastName = client.lastName
			initialPhone = client.phone
			initialEmail = client.email
			
			navigationItem.title = "View Client"
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ViewClient.done))
			navigationItem.rightBarButtonItem?.isEnabled = false
		}
	}
	
	var isMakingNewClient: Bool {
		return client == nil
	}
	
	private var firstName: String {
		get { return firstNameField.text! }
		set { firstNameField.text = newValue }
	}
	
	private var lastName: String {
		get { return lastNameField.text! }
		set { lastNameField.text = newValue }
	}
	
	private var phone: String {
		get { return phoneField.text! }
		set { phoneField.text = newValue }
	}
	
	private var email: String {
		get { return emailField.text! }
		set { emailField.text = newValue }
	}
	
	var initialFirstName = "" {
		didSet {
			firstName = initialFirstName
		}
	}
	var initialLastName = "" {
		didSet {
			lastName = initialLastName
		}
	}
	var initialPhone = "" {
		didSet {
			phone = initialPhone
		}
	}
	var initialEmail = "" {
		didSet {
			email = initialEmail
		}
	}
	
	override func viewDidLoad() {
		if let client = client {
			// Manually trigger the didSet
			self.client = client
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isMakingNewClient ? 2 : super.numberOfSections(in: tableView)
	}
	
	@IBOutlet weak var deleteClientCell: UITableViewCell!
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath) == deleteClientCell {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.presentSheet(
				("Cancel", .cancel, nil),
				("Delete Client", .destructive, {_ in
					self.context.delete(self.client!)
					
					try? self.context.save()
					
					self.onDone!(self.client!)
					
					_ = self.navigationController?.popViewController(animated: true)
				})
			)
		}
	}
	
	/// Must be provided in the presenting view
	var onDone: ((Client) -> ())?
	
	@IBAction func revalidate() {
		navigationItem.rightBarButtonItem!.isEnabled =
			firstName != initialFirstName ||
			lastName != initialLastName ||
			phone != initialPhone ||
			email != initialEmail
	}
	
	@IBAction func done() {
		let client: Client
		
		if self.client == nil {
			client = Client.make(for: context)
		} else {
			client = self.client!
		}
		
		client.firstName = firstName
		client.lastName = lastName
		client.phone = phone
		client.email = email
		
		try? context.save()
		
		onDone!(client)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let appointments = segue.destination as? Appointments {
			appointments.client = client
		}
	}
}
