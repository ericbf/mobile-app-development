//
//  NewClient.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

public let CLIENT_UPDATED_NOTIFICATION = Notification.Name("client updated"),
	CLIENT_CREATED_NOTIFICATION = Notification.Name("client created")

class ViewClient: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	let center = NotificationCenter.default
	
	@IBOutlet weak var firstNameField: UITextField!
	@IBOutlet weak var lastNameField: UITextField!
	@IBOutlet weak var phoneField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	
	var client: Client?
	
	var isMakingNewClient: Bool {
		return client == nil
	}
	
	private var firstName: String {
		get { return firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines) }
		set { firstNameField.text = newValue }
	}
	
	private var lastName: String {
		get { return lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines) }
		set { lastNameField.text = newValue }
	}
	
	private var phone: String {
		get { return phoneField.text!.trimmingCharacters(in: .whitespacesAndNewlines) }
		set { phoneField.text = newValue }
	}
	
	private var email: String {
		get { return emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines) }
		set { emailField.text = newValue }
	}
	
	var initialKey: Character?
	
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
		if client != nil {
			navigationItem.title = "View Client"
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ViewClient.done))
		} else {
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss as () -> ()))
		}
		
		setInitials()
		revalidate()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isMakingNewClient ? 2 : super.numberOfSections(in: tableView)
	}
	
	@IBOutlet weak var deleteClientCell: UITableViewCell!
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath)! == deleteClientCell {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.presentSheet(
				("Cancel", .cancel, nil),
				("Delete Client", .destructive, {_ in
					if self.client!.appointments.count > 0 {
						self.alert(title: "Cannot Delete Client", message: "You must either delete or move all of this client's appointments before this client can be deleted")
					} else {
						self.context.delete(self.client!)
						
						try? self.context.save()
						
						// Post about the deletion to all listeners here
						self.center.post(name: CLIENT_UPDATED_NOTIFICATION, object: self)
						
						_ = self.navigationController?.popViewController(animated: true)
					}
				})
			)
		}
	}
	
	func setInitials() {
		initialKey = client?.key
		initialFirstName = client?.firstName ?? ""
		initialLastName = client?.lastName ?? ""
		initialPhone = client?.phone ?? ""
		initialEmail = client?.email ?? ""
	}
	
	@IBAction func revalidate() {
		navigationItem.rightBarButtonItem!.isEnabled =
			firstName != initialFirstName ||
			lastName != initialLastName ||
			phone != initialPhone ||
			email != initialEmail
	}
	
	@IBAction func done() {
		view.endEditing(true)
		
		let isUpdate = self.client != nil
		let client = self.client ?? Client.make(for: context)
		
		client.firstName = firstName
		client.lastName = lastName
		client.phone = phone
		client.email = email
		
		try? context.save()
		
		self.client = client
		
		let name = isUpdate ? CLIENT_UPDATED_NOTIFICATION : CLIENT_CREATED_NOTIFICATION
		
		// Post about the change to all listeners here
		center.post(name: name, object: self)
		
		setInitials()
		revalidate()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let appointments = segue.destination as? Appointments {
			appointments.client = client
		}
	}
}
