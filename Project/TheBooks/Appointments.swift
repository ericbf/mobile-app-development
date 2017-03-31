//
//  AppointmentsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Appointments: UITableViewController {
	private let context = AppDelegate.instance.context
	private let center = NotificationCenter.default
	
	private var sections: [String: [Appointment]] = [:]
	private var sorted: [(key: String, value: [Appointment])] = []
	
	var client: Client?
	
	@IBOutlet weak private var countLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appointments: [Appointment]
		
		if let client = client {
			appointments = client.appointments.array.map { $0 as! Appointment }
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
		
		refreshSorted()
		updateCount()
		
		scrollToToday(false)
		
		center.addObserver(self, selector: #selector(appointmentCreated), name: APPOINTMENT_CREATED_NOTIFICATION, object: nil)
		center.addObserver(self, selector: #selector(appointmentUpdated), name: APPOINTMENT_UPDATED_NOTIFICATION, object: nil)
		center.addObserver(self, selector: #selector(clientUpdated), name: CLIENT_UPDATED_NOTIFICATION, object: nil)
	}
	
	//MARK: Managed sorted
	
	private func refreshSorted() {
		sorted = sections.sorted { $0.value.first!.start < $1.value.first!.start }
	}
	
	//MARK: Footer view count
	
	private func updateCount() {
		let count = sections.reduce(0) { $0 + $1.value.count }
		
		countLabel.text = "\(count) Appointment" + (count != 1 ? "s" : "")
	}
	
	//MARK: Table view delegate and data source
	
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
	
	//MARK: Scroll helpers
	
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
	
	//MARK: Cell handling helpers
	
	func addAppointment(_ appointment: Appointment) {
		let key = appointment.key
		
		if !sections.has(key: key) {
			sections[key] = [appointment]
			
			refreshSorted()
			
			let index = sorted.index { $0.key == key }!
			
			tableView.insertSections([index], with: .automatic)
		} else {
			sections[key]!.append(appointment)
			
			sortSection(key)
			
			let section = sorted.index { $0.key == key }!
			let row = sorted[section].value.index(of: appointment)!
			let indexPath = IndexPath(row: row, section: section)
			
			tableView.insertRows(at: [indexPath], with: .automatic)
		}
	}
	
	func removeAppointment(_ appointment: Appointment, from key: String) {
		guard sections.has(key: key) else {
			return
		}
		
		sections[key]!.remove(object: appointment)
		
		let section = sorted.index { $0.key == key }!
		
		if sections[key]!.count == 0 {
			sections.removeValue(forKey: key)
			
			refreshSorted()
			
			tableView.deleteSections([section], with: .automatic)
		} else {
			let row = sorted[section].value.index(of: appointment)!
			let indexPath = IndexPath(row: row, section: section)
			
			refreshSorted()
			
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	func moveAppointment(_ appointment: Appointment, from key: String) {
		removeAppointment(appointment, from: key)
		addAppointment(appointment)
	}
	
	func sortSection(_ key: String) {
		sections[key]?.sort { $0.start < $1.start }
		refreshSorted()
	}
	
	func reloadSection(_ key: String) {
		guard let index = sorted.index(where: { $0.key == key }) else {
			return
		}
		
		tableView.reloadSections([index], with: .automatic)
	}
	
	//MARK: Highlighting a cell
	
	var needsFade: Appointment?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let appointment = needsFade {
			needsFade = nil
			
			selectCell(for: appointment)
			
			if let indexPath = self.tableView.indexPathForSelectedRow {
				delay(0.1) {
					self.tableView.deselectRow(at: indexPath, animated: true)
				}
			}
		}
	}
	
	func indexPath(for appointment: Appointment) -> IndexPath? {
		guard let section = sorted.index(where: { $0.key == appointment.key }),
			let row = sorted[section].value.index(of: appointment) else {
				return nil
		}
		
		return IndexPath(row: row, section: section)
	}
	
	private func selectCell(for appointment: Appointment) {
		guard let indexPath = indexPath(for: appointment) else {
			return
		}
		
		let scrollPosition: UITableViewScrollPosition
		let visible = tableView.indexPathsForVisibleRows!
		
		if visible.count == 0 || visible.contains(indexPath) {
			scrollPosition = .none
		} else if visible.first!.section > indexPath.section ||
			visible.first!.section == indexPath.section &&
			visible.first!.row > indexPath.row {
			scrollPosition = .top
		} else {
			scrollPosition = .bottom
		}
		
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: scrollPosition)
	}
	
	//MARK: Navigation
	
	var presented: ViewAppointment?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewAppointment = segue.destination as? ViewAppointment {
			presented = viewAppointment
			
			func setup(with appointment: Appointment) {
				viewAppointment.appointment = appointment
			}
			
			if let cell = sender as? AppointmentCell {
				guard let indexPath = tableView.indexPath(for: cell) else {
					return
				}
				
				let appointment = sorted[indexPath.section].value[indexPath.row]
				
				setup(with: appointment)
			} else if let appointment = sender as? Appointment {
				setup(with: appointment)
			} else if let client = client {
				// If new appointment is openned from client's list, preselect that client.
				viewAppointment.client = client
			}
		}
	}
	
	func appointmentUpdated(_ notification: Notification) {
		guard let viewAppointment = notification.object as? ViewAppointment,
			  let initialKey = viewAppointment.initialKey,
			  let appointment = viewAppointment.appointment else {
			// Required variables weren't set. ABORT!
			return
		}
		
		let isDeleted = appointment.isDeleted || appointment.managedObjectContext == nil
		
		tableView.beginUpdates()
		
		if isDeleted {
			removeAppointment(appointment, from: initialKey)
		} else if appointment.key != initialKey {
			moveAppointment(appointment, from: initialKey)
		} else {
			sortSection(appointment.key)
			reloadSection(appointment.key)
		}
		
		tableView.endUpdates()
		
		if viewAppointment == presented {
			needsFade = isDeleted ? nil : appointment
		}
		
		updateCount()
	}
	
	func appointmentCreated(_ notification: Notification) {
		guard let viewAppointment = notification.object as? ViewAppointment,
			  let appointment = viewAppointment.appointment else {
				// Required variables weren't set. ABORT!
				return
		}
		
		addAppointment(appointment)
		updateCount()
		
		if viewAppointment == presented {
			// It was my child that was updated. Do navigation stuff!
			
			// After an appointment is created, switch to view right away. This
			//    posts the View Appointment view underneath the modal, silently
			performSegue(withIdentifier: "Show ViewAppointment", sender: appointment)
			
			// Dismiss the modal view to reveal the View Client view
			viewAppointment.modalTransitionStyle = .crossDissolve
			viewAppointment.dismiss(animated: true) {
				self.needsFade = appointment
			}
			
			needsFade = appointment
		}
	}
	
	func clientUpdated(_ notification: Notification) {
		guard let viewClient = notification.object as? ViewClient,
			let client = viewClient.client else {
				// Required variables weren't set. ABORT!
				return
		}
		
		let paths: [IndexPath] = sorted
			.enumerated()
			.reduce([]) {trans, current in
				return trans + current.element.value.enumerated()
					.map { ($0.element.client, $0.offset) }
					.filter { $0.0 == client }
					.map { IndexPath(row: $0.1, section: current.offset) }
			}
		
		tableView.reloadRows(at: paths, with: .automatic)
	}
}
