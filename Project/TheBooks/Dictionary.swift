//
//  Dictionary.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import Foundation

public extension Dictionary where Value: Equatable {
	/**
	This function checks whether this dictionary contains a certain value.
	
	- returns: whether the dictionary has the value.
	
	- parameters:
		- value: the value to find.
	*/
	public func has(value: Value) -> Bool {
		if self.keyFor(value) != nil {
			return true
		}
		
		return false
	}
	
	/**
	This function returns the first key found for a given value, or nil if the value was not found.
	
	- returns: the key or `nil`
	
	- parameters:
		- value: the value to find.
	*/
	public func keyFor(_ value: Value) -> Key? {
		for pair in self {
			if pair.value == value {
				return pair.key
			}
		}
		
		return nil
	}
}

public extension Dictionary {
	/**
	This function checks whether this dictionary contains the passed key.
	
	- returns: whether the key was found.
	
	- parameters:
		- key: the key to find.
	*/
	public func has(key: Key) -> Bool {
		return self[key] != nil
	}
}
