//
//  AppointmentsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Appointments: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	var appointments: [Appointment] = []
	var sections: [String: [Appointment]] = [:]
	var sorted: [(key: String, value: [Appointment])] = []
	
	var client: Client?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		appointments = Appointment.all(for: context)
		
		if let client = client {
			appointments = appointments.filter {$0.client == client}
		}
		
		sections = appointments.reduce([:]) {trans, curr in
			var trans = trans
			
			if !trans.has(key: curr.key) {
				trans[curr.key] = []
			}
			
			trans[curr.key]!.append(curr)
			
			return trans
		}
		sorted = self.sections.sorted {
			return $0.value.first!.start < $1.value.first!.start
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sorted.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sorted[section].value.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sorted[section].key
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AppointmentCell
		
		return cell
	}
	
	func addAppointment(_ appointment: Appointment) {
		let key = appointment.key
		
		if !sections.has(key: key) {
			sections[key] = []
		}
		
		sections[key]!.append(appointment)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewAppointment = segue.destination as? ViewAppointment {
			viewAppointment.onDone = {appointment in
				self.addAppointment(appointment)
				
				//TODO: All the stuff over here
				
				viewAppointment.dismissSelf()
			}
		}
	}
}
