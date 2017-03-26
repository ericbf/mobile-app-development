//
//  DurationPicker.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/25/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import UIKit

class DurationPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
	let rows = [
		30,
		60,
		90,
		120
	]
	
	var selectedRow: Int {
		return selectedRow(inComponent: 0)
	}
	
	var selectedTitle: String {
		return pickerView(self, titleForRow: selectedRow, forComponent: 0)!
	}
	
	var onSelect: ((Int, String) -> ())?
	
	//MARK: Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}
	
	private func setup() {
		delegate = self
		dataSource = self
		
		self.selectRow(1, inComponent: 0, animated: false)
	}
	
	//MARK: Picker data source
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 4
	}
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return "\(rows[row]) mins"
	}
	
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		onSelect?(selectedRow, selectedTitle)
	}
}
