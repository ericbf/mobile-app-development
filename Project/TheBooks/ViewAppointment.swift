//
//  ViewAppointment.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class ViewAppointment: UITableViewController {
	var onDone: ((Appointment) -> ())!
	
	@IBOutlet weak var clientLabel: UILabel!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var datePickerCell: UITableViewCell!
	
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var durationPicker: UIPickerView!
	@IBOutlet weak var durationPickerCell: UITableViewCell!
	
	
	
	@IBAction func done() {
		//TODO: Create the appointment
		
		// onDone()
		
		dismissSelf()
	}
	
	let toggler = ToggleHelper([
		IndexPath(row: 0, section: 1): IndexPath(row: 1, section: 1),
		IndexPath(row: 2, section: 1): IndexPath(row: 3, section: 1)
	])
	
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
				self.clientLabel.text = client.displayString
				
				clients.dismissSelf()
			}
		}
	}
}
