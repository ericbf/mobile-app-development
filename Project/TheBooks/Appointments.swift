//
//  AppointmentsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Appointments: UITableViewController {
	private let context = (UIApplication.shared.delegate as! AppDelegate).context
	private var sections: [String: [Appointment]] = [:]
	private var sorted: [(key: String, value: [Appointment])] = []
	
	var client: Client?
	
	@IBOutlet weak private var countLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appointments: [Appointment]
		
		if let client = client {
			appointments = Appointment.all(for: context).filter {$0.client == client}
		} else {
			appointments = Appointment.all(for: context)
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
		
		updateCount()
		
		scrollToToday(false)
	}
	
	private func updateCount() {
		let count = sections.reduce(0) { $0 + $1.value.count }
		
		countLabel.text = "\(count) Appointment" + (count != 1 ? "s" : "")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sorted.count + 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let notLast = section < numberOfSections(in: tableView) - 1
		
		return notLast ? sorted[section].value.count : 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let notLast = section < numberOfSections(in: tableView) - 1
		
		return notLast ? sorted[section].key : nil
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 18))
		
		let label = UILabel(frame: CGRect(x: 16, y: 5.5, width: 150, height: 18))
		
		let sectionData = sorted[section]
		
		label.font = UIFont.boldSystemFont(ofSize: 17)
		label.text = sectionData.key
		
		if let appointment = sectionData.value.first {
			if Calendar.current.isDateInToday(appointment.start) {
				label.textColor = UIColor.red
			}
		}
		
		view.backgroundColor = UIColor(white: 0xf7 / 0xff, alpha: 1)
		view.addSubview(label)
		
		return view
	}
	
	func scrollToToday(_ animated: Bool) {
		var section: Int?
		
		for (index, sectionData) in sorted.enumerated() {
			if let date = sectionData.value.first?.start {
				section = index
				
				if Calendar.current.isDateInToday(date) || date > Date() {
					break
				}
			}
		}
		
		if let section = section {
			tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
		}
	}
	
	@IBAction func scrollToToday() {
		scrollToToday(true)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AppointmentCell
		let appointment = sorted[indexPath.section].value[indexPath.row]
		let formatter = DateFormatter()
		
		formatter.dateFormat = "h:mm a"
		
		cell.startLabel.text = formatter.string(from: appointment.start)
		cell.endLabel.text = "\(appointment.duration) mins"
		cell.titleLabel.text = appointment.client.displayString
		cell.subtitleLabel.text = appointment.client.phone
		
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
			if let cell = sender as? AppointmentCell {
				guard let indexPath = tableView.indexPath(for: cell) else {
					return
				}
				
				let appointment = sorted[indexPath.section].value[indexPath.row]
				
				viewAppointment.appointment = appointment
				viewAppointment.onDone = {appointment in
					viewAppointment.navigationItem.rightBarButtonItem?.isEnabled = false
					
					//TODO: sort and stuff
					
					self.updateCount()
				}
			} else {
				if let client = client {
					// If new appointment is openned from client's list, preselect that client.
					viewAppointment.client = client
				}
				
				viewAppointment.onDone = {appointment in
					self.addAppointment(appointment)
					
					//TODO: add to table, etc
					
					self.updateCount()
					
					viewAppointment.dismissSelf()
				}
			}
		}
	}
}
