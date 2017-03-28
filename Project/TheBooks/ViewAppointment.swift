//
//  ViewAppointment.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

public let APPOINTMENT_UPDATED_NOTIFICATION = Notification.Name("appointment updated"),
	APPOINTMENT_CREATED_NOTIFICATION = Notification.Name("appointment created")

class ViewAppointment: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	let center = NotificationCenter.default
	
	var appointment: Appointment?
	var client: Client? {
		didSet {
			clientLabel?.text = client?.displayString
			
			revalidate()
		}
	}
	
	var isMakingNewAppointment: Bool {
		return appointment == nil
	}
	
	@IBOutlet weak var clientLabel: UILabel!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var datePickerCell: UITableViewCell!
	
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var durationPicker: DurationPicker!
	@IBOutlet weak var durationPickerCell: UITableViewCell!

	@IBOutlet weak var deleteCell: UITableViewCell!
	
	let toggler = ToggleHelper([
		IndexPath(row: 0, section: 1): IndexPath(row: 1, section: 1),
		IndexPath(row: 2, section: 1): IndexPath(row: 3, section: 1)
	])
	
	var initialKey: String?
	var initialClient: Client?
	var initialStart: Date!
	var initialDuration: Int!
	
	func setInitials() {
		initialKey = appointment?.key
		initialClient = client
		initialStart = datePicker.date
		initialDuration = durationPicker.selectedDuration
	}
	
	func revalidate() {
		navigationItem.rightBarButtonItem?.isEnabled =
			appointment == nil && client != nil ||
			initialClient != client ||
			initialStart != datePicker.date ||
			initialDuration != durationPicker.selectedDuration
	}
	
	@IBAction func updateDateLabel() {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "E  MMM d, h:mm a"
		
		dateLabel.text = formatter.string(from: datePicker.date)
		
		revalidate()
	}
	
	func updateDurationLabel() {
		updateDurationLabel(durationPicker.selectedRow, durationPicker.selectedTitle)
	}
	
	func updateDurationLabel(_ row: Int, _ title: String) {
		durationLabel.text = title
		
		revalidate()
	}
	
	override func viewDidLoad() {
		durationPicker.onSelect = updateDurationLabel
		
		toggler.onExpanded = {expanded in
			if expanded.row == 1 {
				// Date picker
				self.dateLabel.textColor = UIColor.red
			} else {
				// Duration picker
				self.durationLabel.textColor = UIColor.red
			}
		}
		
		toggler.onMinimized = {minimized in
			if minimized.row == 1 {
				// Date picker
				self.dateLabel.textColor = UIColor.black
			} else {
				// Duration picker
				self.durationLabel.textColor = UIColor.black
			}
		}
		
		if let appointment = appointment {
			client = appointment.client
			
			datePicker.date = appointment.start
			
			if let row = durationPicker.rows.index(of: Int(appointment.duration)) {
				durationPicker.selectedRow = row
			}
			
			navigationItem.title = "View Appointment"
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ViewAppointment.done))
			navigationItem.rightBarButtonItem?.isEnabled = false
		} else {
			datePicker.clamp()
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss as () -> ()))
		}
		
		setInitials()
		revalidate()
		
		if let client = client {
			clientLabel.text = client.displayString
		}
		
		updateDateLabel()
		updateDurationLabel()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isMakingNewAppointment ? 2 : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let original = super.tableView(tableView, numberOfRowsInSection: section)
		
		return toggler.numberOfRows(from: original, for: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let indexPath = toggler.mapFromTable(indexPath)
		
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let original = super.tableView(tableView, heightForRowAt: toggler.mapFromTable(indexPath))
		
		return toggler.height(from: original, for: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		toggler.didSelect(rowAt: indexPath, for: tableView)
		
		if tableView.cellForRow(at: indexPath) == deleteCell {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.presentSheet(
				("Cancel", .cancel, nil),
				("Delete Appointment", .destructive, {_ in
					self.context.delete(self.appointment!)
					
					try? self.context.save()
					
					// Post about the deletion to all listeners here
					self.center.post(name: APPOINTMENT_UPDATED_NOTIFICATION, object: self)
					
					_ = self.navigationController?.popViewController(animated: true)
				})
			)
		}
	}
	
	@IBAction func done() {
		let isUpdate = self.appointment != nil
		let appointment = self.appointment ?? Appointment.make(for: context)
		
		appointment.client = client!
		appointment.client.sort()
		appointment.start = datePicker.date
		appointment.duration = Int16(durationPicker.selectedDuration)
		
		try? context.save()
		
		self.appointment = appointment
		
		let name = isUpdate ? APPOINTMENT_UPDATED_NOTIFICATION : APPOINTMENT_CREATED_NOTIFICATION
		
		// Post about the change to all listeners here
		center.post(name: name, object: self)
		
		setInitials()
		revalidate()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let clients = segue.destination as? Clients {
			clients.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: clients, action: #selector(dismiss as () -> ()))
			
			clients.onSelect = {client in
				self.client = client
				
				clients.dismiss()
			}
		}
	}
}
