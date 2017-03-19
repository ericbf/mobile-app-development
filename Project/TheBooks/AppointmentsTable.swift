//
//  AppointmentsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class AppointmentsTable: UITableViewController {
	var days = Day.all(for: (UIApplication.shared.delegate as! AppDelegate).context)
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return days.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days[section].appointments.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let formatter = DateFormatter()
		
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		
		return formatter.string(from: days[section].date)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AppointmentCell
		
		return cell
	}
}
