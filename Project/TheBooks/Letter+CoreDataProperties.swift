//
//  Letter+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData


extension Letter {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Letter> {
        return NSFetchRequest<Letter>(entityName: "Letter");
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Letter] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}

    @NSManaged public var value: String
    @NSManaged public var clients: NSOrderedSet

}

// MARK: Generated accessors for clients
extension Letter {
    @objc(insertObject:inClientsAtIndex:)
    @NSManaged public func insertIntoClients(_ value: Client, at idx: Int)

    @objc(removeObjectFromClientsAtIndex:)
    @NSManaged public func removeFromClients(at idx: Int)

    @objc(insertClients:atIndexes:)
    @NSManaged public func insertIntoClients(_ values: [Client], at indexes: NSIndexSet)

    @objc(removeClientsAtIndexes:)
    @NSManaged public func removeFromClients(at indexes: NSIndexSet)

    @objc(replaceObjectInClientsAtIndex:withObject:)
    @NSManaged public func replaceClients(at idx: Int, with value: Client)

    @objc(replaceClientsAtIndexes:withClients:)
    @NSManaged public func replaceClients(at indexes: NSIndexSet, with values: [Client])

    @objc(addClientsObject:)
    @NSManaged public func addToClients(_ value: Client)

    @objc(removeClientsObject:)
    @NSManaged public func removeFromClients(_ value: Client)

    @objc(addClients:)
    @NSManaged public func addToClients(_ values: NSOrderedSet)

    @objc(removeClients:)
    @NSManaged public func removeFromClients(_ values: NSOrderedSet)
}
