//
//  ClientsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class Clients: UITableViewController {
	var letters = Letter.all(for: (UIApplication.shared.delegate as! AppDelegate).context)
	var indexed: [String: Letter]!
	
	let keys = [
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
		"G",
		"H",
		"I",
		"J",
		"K",
		"L",
		"M",
		"N",
		"O",
		"P",
		"Q",
		"R",
		"S",
		"T",
		"U",
		"V",
		"W",
		"X",
		"Y",
		"Z",
		"#"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		indexed = letters.reduce([:]) {trans, current in
			var trans = trans!
			
			trans[current.value] = current
			
			return trans
		}
		
		onDone?()
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return keys
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return keys.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return indexed[keys[section]]?.clients.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let rows = self.tableView(tableView, numberOfRowsInSection: section)
		
		return rows > 0 ? keys[section] : nil
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let section = indexPath.section
		let row = indexPath.row
		let client = indexed[keys[section]]?.clients[row] as? Client
		
		if let client = client, let label = cell.textLabel {
			label.text = "\(client.firstName) \(client.lastName)"
		}
		
		return cell
	}
}
