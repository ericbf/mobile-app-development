//
//  FirstViewController.swift
//  TheBooks
//
//  Created by Eric Ferreira on 2/25/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
		
		let table = UITableView(frame: view.frame)
		
        table.layer.borderColor = UIColor.green.cgColor
        table.layer.borderWidth = 10
        table.contentInset = UIEdgeInsets(
			top: 44 + statusBarHeight,
			left: 0,
			bottom: tabBarController?.tabBar.frame.height ?? 49,
			right: 0
		)
		table.dataSource = self
		table.delegate = self
        
        view.addSubview(table)
		
		let toolbar = UIToolbar()
		
		toolbar.frame = CGRect(
			x: 0,
			y: 0,
			width: view.frame.width,
			height: 44 + statusBarHeight
		)
		
		view.addSubview(toolbar)
    }
	
	let items = Array(repeating: 0, count: 30)
}

extension FirstViewController: UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}

extension FirstViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		cell.textLabel?.text = "Item: \(items[indexPath.row])"
		
        return cell
    }
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}
