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

class Clients: UITableViewController, UISearchResultsUpdating {
	let context = (UIApplication.shared.delegate as! AppDelegate).context
	var sections: [Character: [Client]] = [:]
	var filteredSections: [Character: [Client]] = [:]
	
	let searchController = UISearchController(searchResultsController: nil)
	
	@IBOutlet weak var countLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sections = Client.all(for: context).reduce([:]) {trans, curr in
			var trans = trans
			
			if !trans.has(key: curr.key) {
				trans[curr.key] = []
			}
			
			trans[curr.key]!.append(curr)
			
			return trans
		}
		filteredSections = sections
		
		updateCount()
		
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
	}
	
	var onSelect: ((Client) -> ())?
	
	//MARK: Search controller methods
	
	public func updateSearchResults(for searchController: UISearchController) {
		filterContent(for: searchController.searchBar.text!)
	}
	
	func refreshFiltered(_ search: String? = nil, _ scope: String? = nil) {
		guard let search = search, search.characters.count > 0 else {
			filteredSections = sections
			
			return
		}
		
		filteredSections = [:]
		
		for (key, array) in sections {
			filteredSections[key] = array.filter {
				$0.displayString.lowercased().contains(search.lowercased())
			}
		}
	}
	
	func filterContent(for search: String, scope: String = "All") {
		refreshFiltered(search)
		
		tableView.reloadData()
	}
	
	//MARK: Footer view count
	
	func updateCount() {
		let count = sections.reduce(0) { $0 + $1.value.count }
		
		countLabel.text = "\(count) Client" + (count != 1 ? "s" : "")
	}
	
	
	//MARK: UITableViewControllerDelegate and DataSource methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let client = filteredSections[keys[indexPath.section]]?[indexPath.row] {
			onSelect?(client)
		}
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return !searchController.isActive ? keys.map { String($0) } : nil
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return keys.count + 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let notLast = section < numberOfSections(in: tableView) - 1
		
		return notLast ? filteredSections[keys[section]]?.count ?? 0 : 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let notLast = section < numberOfSections(in: tableView) - 1
		
		let rows = self.tableView(tableView, numberOfRowsInSection: section)
		
		return notLast && rows > 0 ? String(keys[section]) : nil
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let section = indexPath.section
		let row = indexPath.row
		let client = filteredSections[keys[section]]?[row]
		
		if let client = client, let label = cell.textLabel {
			label.text = client.displayString
		}
		
		return cell
	}
	
	//MARK: Cell handling helpers
	
	private func addClient(_ client: Client) {
		let key = client.key
		
		if !sections.has(key: key) {
			sections[key] = []
		}
		
		sections[key]!.append(client)
		
		sortSection(client)
	}
	
	private func delClient(_ client: Client) {
		delClient(client, from: client.key)
	}
	
	private func delClient(_ client: Client, from section: Character) {
		self.sections[section]!.remove(object: client)
	}
	
	private func moveClient(_ client: Client, from section: Character) {
		delClient(client, from: section)
		addClient(client)
	}
	
	private func sortSection(_ client: Client) {
		let key = client.key
		
		sections[key]!.sort { $0.sortString < $1.sortString }
	}
	
	private func reloadSection(_ key: Character) {
		let index = keys.index(of: key)!
		
		tableView.reloadSections([index], with: .automatic)
	}
	
	//MARK: Highlighting a cell, for the looks of it
	
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
		let row = filteredSections[key]!.index(of: client)!
		
		let indexPath = IndexPath(row: row, section: section)
		
		let scrollPosition: UITableViewScrollPosition
		let visible = tableView.indexPathsForVisibleRows!
		
		if visible.count == 0 || visible.contains(indexPath) {
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
	
	//MARK: Navigation
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if sender as? UITableViewCell != nil && onSelect != nil {
			return false
		}
		
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewClient = segue.destination as? ViewClient {
			if let cell = sender as? UITableViewCell {
				guard let indexPath = tableView.indexPath(for: cell) else {
					return
				}
				
				guard let client = filteredSections[keys[indexPath.section]]?[indexPath.row] else {
					return
				}
				
				// Passing a client in to view
				let initialKey = client.key
				
				viewClient.client = client
				viewClient.onDone = {client in
					let key = client.key
					let isDeleted = client.isDeleted || client.managedObjectContext == nil
					
					if isDeleted {
						self.delClient(client, from: initialKey)
					} else if key != initialKey {
						self.moveClient(client, from: initialKey)
					} else {
						self.sortSection(client)
					}
					
					self.refreshFiltered()
					
					self.tableView.beginUpdates()
					
					if key != initialKey || isDeleted {
						self.reloadSection(initialKey)
					}
					
					if !isDeleted {
						self.reloadSection(key)
					}
					
					self.tableView.endUpdates()
					
					self.needsFade = isDeleted ? nil : client
					
					viewClient.navigationItem.rightBarButtonItem?.isEnabled = false
					
					self.updateCount()
				}
			} else {
				// Sender is not a cell, so we're creating a new one
				viewClient.onDone = {client in
					self.addClient(client)
					
					self.refreshFiltered()
					
					self.tableView.beginUpdates()
					
					self.reloadSection(client.key)
					
					self.tableView.endUpdates()
					
					self.needsFade = client
					
					self.updateCount()
					
					viewClient.dismissSelf()
				}
			}
		}
	}
}
