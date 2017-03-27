//
//  ViewAppointment.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class ViewAppointment: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	
	var client: Client? {
		didSet {
			clientLabel?.text = client?.displayString
			navigationItem.rightBarButtonItem?.isEnabled = true
		}
	}
	var appointment: Appointment?
	var onDone: ((Appointment) -> ())!
	
	@IBOutlet weak var clientLabel: UILabel!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var datePickerCell: UITableViewCell!
	
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var durationPicker: DurationPicker!
	@IBOutlet weak var durationPickerCell: UITableViewCell!

	let toggler = ToggleHelper([
		IndexPath(row: 0, section: 1): IndexPath(row: 1, section: 1),
		IndexPath(row: 2, section: 1): IndexPath(row: 3, section: 1)
	])
	
	@IBAction func updateDateLabel() {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "E  MMM d, h:mm a"
		
		dateLabel.text = formatter.string(from: datePicker.date)
	}
	
	func updateDurationLabel() {
		updateDurationLabel(durationPicker.selectedRow, durationPicker.selectedTitle)
	}
	
	func updateDurationLabel(_ row: Int, _ title: String) {
		durationLabel.text = title
	}
	
	override func viewDidLoad() {
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
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewAppointment.dismissSelf))
		}
		
		if let client = client {
			clientLabel.text = client.displayString
		}
		
		datePicker.clamp()
		
		updateDateLabel()
		updateDurationLabel()
		
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
	}
	
	@IBAction func done() {
		if appointment == nil {
			appointment = Appointment.make(for: context)
		}
		
		appointment!.client = client!
		appointment!.start = datePicker.date
		appointment!.duration = Int16(durationPicker.rows[durationPicker.selectedRow])
		
		try? context.save()
		
		onDone(appointment!)
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
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let clients = segue.destination as? Clients {
			clients.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: clients, action: #selector(Clients.dismissSelf))
			
			clients.onSelect = {client in
				self.client = client
				
				clients.dismissSelf()
			}
		}
	}
}
