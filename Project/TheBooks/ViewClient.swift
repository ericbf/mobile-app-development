//
//  NewClient.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

public let CLIENT_UPDATED_NOTIFICATION = Notification.Name("client updated"),
	CLIENT_CREATED_NOTIFICATION = Notification.Name("client created")

class ViewClient: UITableViewController, CNContactPickerDelegate, CNContactViewControllerDelegate {
	let context = AppDelegate.instance.context
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
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done as () -> ()))
		} else {
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss as () -> ()))
		}
		
		setInitials()
		revalidate()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isMakingNewClient ? 3 : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 2 {
			return 1
		}
		
		return super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		if indexPath.section == 2 {
			let actualRow: Int
			
			if client?.contactID != nil {
				actualRow = 2
			} else if client != nil {
				actualRow = 1
			} else {
				actualRow = 0
			}
			
			let newPath = IndexPath(row: actualRow, section: 2)
			
			cell = super.tableView(tableView, cellForRowAt: newPath)
		} else {
			cell = super.tableView(tableView, cellForRowAt: indexPath)
		}
		
		return cell
	}
	
	@IBOutlet weak var importFromContacts: UITableViewCell!
	@IBOutlet weak var linkToContact: UITableViewCell!
	@IBOutlet weak var viewContactCard: UITableViewCell!
	@IBOutlet weak var deleteClient: UITableViewCell!
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		
		if cell == importFromContacts || cell == linkToContact {
			// Pull up contact picker
			let picker = CNContactPickerViewController()
			
			picker.delegate = self
			
			present(picker, animated: true, completion: nil)
		} else if cell == viewContactCard {
			// Present the contact card
			do {
				let contact = try CNContactStore().unifiedContact(withIdentifier: client!.contactID!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
				let viewer = CNContactViewController(for: contact)
				
				viewer.delegate = self
				
				self.navigationController?.pushViewController(viewer, animated: true)
			} catch {
				alert(title: "Contact Missing!", message: "The linked contact for this client was not found. Please link it again!")
				
				client!.contactID = nil
				tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
			}
		} else if cell == deleteClient {
			// Deleting the client
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
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		
		if cell == viewContactCard {
			prompt(title: "Options", buttons: [("Unlink Contact", .default), ("Reset to Contact", .destructive), ("Cancel", .cancel)]) {title in
				if title == "Unlink Contact" {
					self.client!.contactID = nil
					self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
				} else if title == "Reset to Contact" {
					do {
						let contact = try CNContactStore().unifiedContact(withIdentifier: self.client!.contactID!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
						
						self.resetToContact(for: contact)
					} catch {
						self.alert(title: "Contact Missing!", message: "The linked contact for this client was not found. Please link it again!")
						
						self.client!.contactID = nil
						tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
					}
				}
			}
		}
	}
	
	//MARK: Contact picker/viewer delegate
	
	func resetToContact(for contact: CNContact) {
		firstName = contact.givenName
		lastName = contact.familyName
		phone = contact.phoneNumbers.first?.value.stringValue ?? ""
		email = (contact.emailAddresses.first?.value ?? "") as String
		
		let clientWasNil = client == nil
		let contactIDWasNil = client?.contactID == nil
		
		delay {
			self.done {
				self.client!.contactID = contact.identifier
			}
			
			if !clientWasNil &&
				(self.client?.contactID == nil) != contactIDWasNil {
				self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
			}
		}
	}
	
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
		resetToContact(for: contact)
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
	
	func done(withPresave: (() -> ())) {
		view.endEditing(true)
		
		let isUpdate = self.client != nil
		let client = self.client ?? Client.make(for: context)
		
		client.firstName = firstName
		client.lastName = lastName
		client.phone = phone
		client.email = email
		
		self.client = client
		
		withPresave()
		
		try? context.save()
		
		let name = isUpdate ? CLIENT_UPDATED_NOTIFICATION : CLIENT_CREATED_NOTIFICATION
		
		// Post about the change to all listeners here
		center.post(name: name, object: self)
		
		setInitials()
		revalidate()
	}
	
	@IBAction func done() {
		done() {}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let appointments = segue.destination as? Appointments {
			appointments.client = client
		}
	}
}
