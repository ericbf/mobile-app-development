//
//  ClientsTable.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

private let keys: [Character] = [
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

class Clients: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	var clients: [Client] = []
	var sections: [Character: [Client]] = [:]
	
	lazy var onSelect: ((Client) -> ())? = {
		self.performSegue(withIdentifier: "OpenViewClient", sender: $0)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clients = Client.all(for: context)
		sections = clients.reduce([:]) {trans, curr in
			var trans = trans
			
			if !trans.has(key: curr.key) {
				trans[curr.key] = []
			}
			
			trans[curr.key]!.append(curr)
			
			return trans
		}
	}
	
	
	// Handle segue to show
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let client = sections[keys[indexPath.section]]?[indexPath.row] {
			onSelect?(client)
		}
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return keys.map { String($0) }
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return keys.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[keys[section]]?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let rows = self.tableView(tableView, numberOfRowsInSection: section)
		
		return rows > 0 ? String(keys[section]) : nil
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let section = indexPath.section
		let row = indexPath.row
		let client = sections[keys[section]]?[row]
		
		if let client = client, let label = cell.textLabel {
			label.text = client.displayString
		}
		
		return cell
	}
	
	
	
	private func addClient(_ client: Client) {
		let key = client.key
		
		if !sections.has(key: key) {
			sections[key] = []
		}
		
		sections[key]!.append(client)
		
		sortSection(client)
	}
	
	private func sortSection(_ client: Client) {
		let key = client.key
		
		sections[key]!.sort { $0.sortString < $1.sortString }
	}
	
	private func reloadSection(_ key: Character) {
		let index = keys.index(of: key)!
		
		tableView.reloadSections([index], with: .automatic)
	}
	
	var needsFade: Client?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let client = needsFade {
			needsFade = nil
			
			fadeCell(for: client)
		}
	}
	
	private func fadeCell(for client: Client) {
		let key = client.key
		
		let section = keys.index(of: key)!
		let row = self.sections[key]!.index(of: client)!
		
		let indexPath = IndexPath(row: row, section: section)
		
		let scrollPosition: UITableViewScrollPosition
		let visible = tableView.indexPathsForVisibleRows!
		
		if visible.contains(indexPath) {
			scrollPosition = .none
		} else if visible.first!.section < section ||
			visible.first!.section == section &&
			visible.first!.row < row {
			scrollPosition = .top
		} else {
			scrollPosition = .bottom
		}
		
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: scrollPosition)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewClient = segue.destination as? ViewClient {
			if let client = sender as? Client {
				// Passing a client in to view
				let initialKey = client.key
				
				viewClient.client = client
				viewClient.onDone = {client in
					let key = client.key
					let isDeleted = client.isDeleted || client.managedObjectContext == nil
					
					if key != initialKey {
						self.sections[initialKey]!.remove(object: client)
						
						if !isDeleted {
							self.addClient(client)
						}
					} else if !isDeleted {
						self.sortSection(client)
					}
					
					self.tableView.beginUpdates()
					
					if key != initialKey || isDeleted {
						self.reloadSection(initialKey)
					}
					
					if !isDeleted {
						self.reloadSection(key)
					}
					
					self.tableView.endUpdates()
					
					if !isDeleted {
						self.needsFade = client
					} else {
						self.needsFade = nil
					}
					
					viewClient.client = client
				}
			} else {
				// No client, no creating a new one
				viewClient.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: viewClient, action: #selector(ViewClient.dismissSelf))
				viewClient.onDone = {client in
					self.addClient(client)
					
					self.tableView.beginUpdates()
					
					self.reloadSection(client.key)
					
					self.tableView.endUpdates()
					
					self.needsFade = client
					
					viewClient.dismissSelf()
				}
			}
		}
	}
}
