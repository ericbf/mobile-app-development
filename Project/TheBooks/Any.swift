//
//  AssociatedObject.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/20/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

func associated<Type>(with: AnyObject, key: UnsafePointer<UInt8>, _ initial: () -> Type) -> Type {
	if let value = objc_getAssociatedObject(with, key) as? Type {
		return value
	}
	
	let initialValue = initial()
	
	associate(with: with, key: key, initialValue)
	
	return initialValue
}

func associate<Type>(with: AnyObject, key: UnsafePointer<UInt8>, _ value: Type) {
	objc_setAssociatedObject(with, key, value, .OBJC_ASSOCIATION_RETAIN)
}
