//
//  Array.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//  Copyright © 2016 CDI. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
	/**
	Removes this object from the array and returns it.
	
	- returns: the object if it was found and successfully removed, or `nil`.
	
	- parameters:
		- object: the object to remove.
	*/
    @discardableResult public mutating func remove(object: Element) -> Element? {
		if let index = self.index(of: object) {
			return self.remove(at: index)
		}
		
		return nil
	}
}

public extension Array {
	/**
	A pseudorandom element from this array and its index.
	
	- returns: the element, or `nil` if the array is empty.
	*/
	public var random: (index: Int, element: Element)? {
		if self.count == 0 {
			return nil
		}
		
		let index = Int(arc4random_uniform(UInt32(self.count)))
		
		return (index, self[index])
	}
	
	/**
	The first pseudorandom element from this array that matches the given predicate and that element's index.
	
	- parameters:
		- predicate: the predicate to use.
	
	- returns: the element, or `nil` if the array is empty.
	*/
	public func random(where predicate: (Element) throws -> Bool) rethrows -> (index: Int, element: Element)? {
		var toTry = [Int](0..<self.count),
			index = Int(arc4random_uniform(UInt32(self.count))),
			passes = try predicate(self[index])
		
		while toTry.count > 0 && !passes {
			toTry.remove(at: index)
			index = Int(arc4random_uniform(UInt32(toTry.count)))
			passes = try predicate(self[toTry[index]])
		}
		
		if toTry.count == 0 {
			return nil
		}
		
		return (toTry[index], self[toTry[index]])
	}
	
	/// Returns true if any element in the array returns true for the passed predicate. Will stop execution as soon as any element returns true, or there are no more elements.
	///
	/// - Parameter predicate: the predicate to use to test
	/// - Returns: whether all elements returned true for the predicate
	/// - Throws: rethrows any errors from the predicate
	func some(where predicate: (Element) throws -> Bool) rethrows -> Bool {
		for element in self {
			let currentPassed = try predicate(element)
			
			if currentPassed {
				return true
			}
		}
		
		return false
	}
	
	/// Returns true if every element in the array returns true for the passed predicate. Will stop execution as soon as any element returns false, or there are no more elements.
	///
	/// - Parameter predicate: the predicate to use to test
	/// - Returns: whether all elements returned true for the predicate
	/// - Throws: rethrows any errors from the predicate
	func every(where predicate: (Element) throws -> Bool) rethrows -> Bool {
		let anyFailed = try self.some {element in
			let currentPassed = try predicate(element)
			
			return !currentPassed
		}
		
		return !anyFailed
	}
}

/**
Array subtraction.

- returns: the new `Array` object.

- parameters:
	- a: the left array in the operation.
	- b: the right array in the operation.

Returns an array containing the elements from the first array that are not in the second array.
*/
public func -<T: Equatable>(a: [T], b: [T]) -> [T] {
	return a.filter {fromA in b.contains(fromA)}
}
