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
	
	let toggles = [
		IndexPath(row: 0, section: 1): IndexPath(row: 1, section: 1),
		IndexPath(row: 0, section: 2): IndexPath(row: 1, section: 2)
	]
	
	func toggles(for section: Int) -> [IndexPath] {
		return self.toggles
			.filter {
				$0.value.section == section &&
					self.expanded != $0.value &&
					!self.minimized.contains($0.value)
			}
			.map { $0.value }
	}
	
	var expanded: IndexPath?
	var minimized: [IndexPath] = []
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let offset = toggles(for: section).count
		
		return super.tableView(tableView, numberOfRowsInSection: section) - offset
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let offset = toggles(for: indexPath.section).filter { $0.row < indexPath.row }.count
		let newPath = IndexPath(row: indexPath.row + offset, section: indexPath.section)
		
		return super.tableView(tableView, cellForRowAt: newPath)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if minimized.contains(indexPath) {
			return 0
		}
		
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let picker = toggles[indexPath] {
			tableView.deselectRow(at: indexPath, animated: true)
			
			func runner(_ closure: @escaping () -> ()) -> () -> () {
				return {
					CATransaction.begin()
					tableView.beginUpdates()
					
					closure()
					
					tableView.endUpdates()
					CATransaction.commit()
				}
			}
			
			func add() {
				if picker != expanded {
					minimized.append(picker)
					
					tableView.insertRows(at: [picker], with: .none)
				}
				
				CATransaction.setCompletionBlock(runner(resize))
			}
			
			func resize() {
				if expanded != nil {
					minimized.append(expanded!)
				}
				
				if picker != expanded {
					minimized.remove(object: picker)
					expanded = picker
				} else {
					expanded = nil
				}
				
				CATransaction.setCompletionBlock(runner(remove))
			}
			
			func remove() {
				tableView.deleteRows(at: minimized, with: .none)
				minimized.removeAll()
			}
			
			runner(add)()
		}
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
