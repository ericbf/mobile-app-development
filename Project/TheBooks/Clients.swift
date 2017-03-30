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
	let center = NotificationCenter.default
	
	var sections: [Character: [Client]] = [:]
	var filtered: [Character: [Client]] = [:]
	
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
		
		refreshFiltered()
		updateCount()
		
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		
		// Register to be updated about changes to clients
		center.addObserver(self, selector: #selector(clientCreated), name: CLIENT_CREATED_NOTIFICATION, object: nil)
		center.addObserver(self, selector: #selector(clientUpdated), name: CLIENT_UPDATED_NOTIFICATION, object: nil)
	}
	
	var onSelect: ((Client) -> ())?
	
	//MARK: Search controller methods
	
	public func updateSearchResults(for searchController: UISearchController) {
		filterContent(for: searchController.searchBar.text!)
	}
	
	//MARK: Manage filtered
	
	func refreshFiltered(_ search: String? = nil, _ scope: String? = nil) {
		guard let search = search, search.characters.count > 0 else {
			filtered = sections
			
			return
		}
		
		filtered = [:]
		
		for (key, array) in sections {
			filtered[key] = array.filter {
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
	
	
	//MARK: Table view delegate and data source
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let client = filtered[keys[indexPath.section]]?[indexPath.row] {
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
		
		return notLast ? filtered[keys[section]]?.count ?? 0 : 0
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
		let client = filtered[keys[section]]?[row]
		
		if let client = client, let label = cell.textLabel {
			label.text = client.displayString
		}
		
		return cell
	}
	
	//MARK: Cell handling helpers
	
	private func addClient(_ client: Client) {
		let key = client.key
		
		if !sections.has(key: key) {
			sections[key] = [client]
			
			refreshFiltered()
		} else {
			sections[key]!.append(client)
			
			sortSection(key)
		}
		
		let section = keys.index(of: key)!
		
		if let row = filtered[key]?.index(of: client) {
			let indexPath = IndexPath(row: row, section: section)
			
			tableView.insertRows(at: [indexPath], with: .automatic)
		}
	}
	
	private func removeClient(_ client: Client, from key: Character) {
		guard sections.has(key: key) else {
			return
		}
		
		sections[key]!.remove(object: client)
		
		let section = keys.index(of: key)!
		let row = filtered[key]?.index(of: client)
		
		refreshFiltered()
		
		if let row = row {
			let indexPath = IndexPath(row: row, section: section)
			
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	private func moveClient(_ client: Client, from key: Character) {
		removeClient(client, from: key)
		addClient(client)
	}
	
	private func sortSection(_ key: Character) {
		sections[key]?.sort { $0.sortString < $1.sortString }
		refreshFiltered()
	}
	
	private func reloadSection(_ key: Character) {
		guard let index = keys.index(of: key) else {
			return
		}
		
		tableView.reloadSections([index], with: .automatic)
	}
	
	//MARK: Highlighting a cell
	
	var needsFade: Client?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let client = needsFade {
			needsFade = nil
			
			selectCell(for: client)
			
			if let indexPath = self.tableView.indexPathForSelectedRow {
				delay(0.1) {
					self.tableView.deselectRow(at: indexPath, animated: true)
				}
			}
		}
	}
	
	private func selectCell(for client: Client) {
		guard let section = keys.index(of: client.key),
			  let row = filtered[client.key]!.index(of: client) else {
			return
		}
		
		let indexPath = IndexPath(row: row, section: section)
		let scrollPosition: UITableViewScrollPosition
		let visible = tableView.indexPathsForVisibleRows!
		
		if visible.count == 0 || visible.contains(indexPath) {
			scrollPosition = .none
		} else if visible.first!.section > section ||
			visible.first!.section == section &&
			visible.first!.row > row {
			scrollPosition = .top
		} else {
			scrollPosition = .bottom
		}
		
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: scrollPosition)
	}
	
	//MARK: Navigation
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if sender as? UITableViewCell != nil && onSelect != nil {
			// If there is an onSelect clause, don't automatically go to the view client view
			return false
		}
		
		return true
	}
	
	var presented: ViewClient?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewClient = segue.destination as? ViewClient {
			presented = viewClient
			
			func setup(with client: Client) {
				viewClient.client = client
			}
			
			if let cell = sender as? UITableViewCell {
				// Segue was triggered from tapping a cell. User is viewing an
				//     existing client. Pass that along please!
				guard let indexPath = tableView.indexPath(for: cell),
					  let client = filtered[keys[indexPath.section]]?[indexPath.row]else {
					return
				}
				
				setup(with: client)
			} else if let client = sender as? Client {
				// If segue was triggered with a client as sender, view that
				//     client. It was probably after creating it!
				setup(with: client)
			}
		}
	}
	
	func clientUpdated(_ notification: Notification) {
		guard let viewClient = notification.object as? ViewClient,
			  let initialKey = viewClient.initialKey,
			  let client = viewClient.client else {
			// Required variables weren't set. ABORT!
			return
		}
		
		let isDeleted = client.isDeleted || client.managedObjectContext == nil
		
		tableView.beginUpdates()
		
		if isDeleted {
			removeClient(client, from: initialKey)
		} else if client.key != initialKey {
			moveClient(client, from: initialKey)
		} else {
			sortSection(client.key)
			reloadSection(client.key)
		}
		
		tableView.endUpdates()
		
		if viewClient == presented {
			needsFade = isDeleted ? nil : client
		}
		
		updateCount()
	}
	
	func clientCreated(_ notification: Notification) {
		guard let viewClient = notification.object as? ViewClient,
			  let client = viewClient.client else {
			// Required variables weren't set. ABORT!
			return
		}
		
		addClient(client)
		refreshFiltered()
		reloadSection(client.key)
		updateCount()
		
		if viewClient == presented {
			// It was my child that was updated. Do navigation stuff!
			
			// After a client is created, switch to view right away. This posts
			//    the View Client view underneath the modal, silently
			performSegue(withIdentifier: "Show ViewClient", sender: client)
			
			// Dismiss the modal view to reveal the View Client view
			viewClient.modalTransitionStyle = .crossDissolve
			viewClient.dismiss(animated: true) {
				self.needsFade = client
			}
		} else {
			needsFade = client
		}
	}
}
