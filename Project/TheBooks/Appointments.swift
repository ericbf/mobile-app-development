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
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 18))
		
		let label = UILabel(frame: CGRect(x: 16, y: 5.5, width: 150, height: 18))
		
		let key = sorted[section]
		
		label.font = UIFont.boldSystemFont(ofSize: 17)
		label.text = key.key
		
		if let appointment = key.value.first {
			if Calendar.current.isDateInToday(appointment.start) {
				label.textColor = UIColor.red
			}
		}
		
		view.backgroundColor = UIColor(white: 0xf7 / 0xff, alpha: 1)
		view.addSubview(label)
		
		return view
	}
	
	@IBAction func scrollToToday() {
		var section = 0
		
		for (index, sectionData) in sorted.enumerated() {
			if let date = sectionData.value.first?.start {
				section = index
				
				if Calendar.current.isDateInToday(date) || date > Date() {
					break
				}
			}
		}
		
		tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
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
