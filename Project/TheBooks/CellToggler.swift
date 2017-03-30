//
//  CellToggler.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/25/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class ToggleHelper {
	let toggles: [IndexPath: IndexPath]
	
	init(_ togglers: [IndexPath: IndexPath]) {
		self.toggles = togglers
	}
	
	/// Closure that takes the `IndexPath` of the cell being expanded.
	var onExpanded: ((IndexPath) -> ())?
	
	/// Closure that takes the `IndexPath` of the cell being minimized.
	var onMinimized: ((IndexPath) -> ())?
	
	var semaphore = 0
	var expanded: IndexPath?
	var minimized: [IndexPath] = []
	
	private func hiddenToggles(for section: Int) -> [IndexPath] {
		return self.toggles
			.filter {
				$0.value.section == section &&
					self.expanded != $0.value &&
					!self.minimized.contains($0.value)
			}
			.map { $0.value }
			.sorted()
	}
	
	func mapFromTable(_ path: IndexPath) -> IndexPath {
		var offset = 0
		
		for toggler in hiddenToggles(for: path.section) {
			if toggler.row - offset <= path.row {
				offset += 1
			} else {
				break
			}
		}
		
		return IndexPath(row: path.row + offset, section: path.section)
	}
	
	private func mapFromAbsolute(_ path: IndexPath) -> IndexPath {
		let offset = hiddenToggles(for: path.section)
			.filter { $0.row <= path.row }
			.count
		
		return IndexPath(row: path.row - offset, section: path.section)
	}
	
	func numberOfRows(from original: Int, for section: Int) -> Int {
		let offset = hiddenToggles(for: section).count
		
		return original - offset
	}
	
	func height(from original: CGFloat, for indexPath: IndexPath) -> CGFloat {
		let indexPath = mapFromTable(indexPath)
		
		if minimized.contains(indexPath) {
			return 0
		}
		
		return original
	}
	
	func didSelect(rowAt indexPath: IndexPath, for tableView: UITableView) {
		if let toggled = toggles[mapFromTable(indexPath)] {
			semaphore += 1
			tableView.deselectRow(at: indexPath, animated: true)
			
			if toggled != expanded {
				onExpanded?(toggled)
			}
			
			if expanded != nil {
				onMinimized?(expanded!)
			}
			
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
				if toggled != expanded && !minimized.contains(toggled) {
					minimized.append(toggled)
					
					tableView.insertRows(at: [mapFromAbsolute(toggled)], with: .none)
				}
				
				CATransaction.setCompletionBlock(runner(resize))
			}
			
			func resize() {
				if expanded != nil && !minimized.contains(expanded!) {
					minimized.append(expanded!)
				}
				
				if toggled != expanded {
					minimized.remove(object: toggled)
					expanded = toggled
				} else {
					expanded = nil
				}
				
				CATransaction.setCompletionBlock(runner(remove))
			}
			
			func remove() {
				semaphore -= 1
				
				if semaphore == 0 {
					tableView.deleteRows(at: minimized.map(mapFromAbsolute), with: .none)
					minimized.removeAll()
				}
			}
			
			runner(add)()
		}
	}
}
