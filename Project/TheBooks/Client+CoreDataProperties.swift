//
//  Client+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData

private let name = "Client"

extension Client {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: name);
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Client] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}
	
	@nonobjc public class func make(for context: NSManagedObjectContext) -> Client {
		return NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! Client
	}
	
	@nonobjc public func sort() {
		let sortDescriptors = [
			NSSortDescriptor(key: "start", ascending: true),
			NSSortDescriptor(key: "duration", ascending: true)
		]
		
		let sorted = appointments.sortedArray(using: sortDescriptors)
		
		appointments = NSOrderedSet(array: sorted)
	}

    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var appointments: NSOrderedSet
    @NSManaged public var letter: Letter
}

// MARK: Generated accessors for appointments
extension Client {
    @objc(insertObject:inAppointmentsAtIndex:)
    @NSManaged public func insertIntoAppointments(_ value: Appointment, at idx: Int)

    @objc(removeObjectFromAppointmentsAtIndex:)
    @NSManaged public func removeFromAppointments(at idx: Int)

    @objc(insertAppointments:atIndexes:)
    @NSManaged public func insertIntoAppointments(_ values: [Appointment], at indexes: NSIndexSet)

    @objc(removeAppointmentsAtIndexes:)
    @NSManaged public func removeFromAppointments(at indexes: NSIndexSet)

    @objc(replaceObjectInAppointmentsAtIndex:withObject:)
    @NSManaged public func replaceAppointments(at idx: Int, with value: Appointment)

    @objc(replaceAppointmentsAtIndexes:withAppointments:)
    @NSManaged public func replaceAppointments(at indexes: NSIndexSet, with values: [Appointment])

    @objc(addAppointmentsObject:)
    @NSManaged public func addToAppointments(_ value: Appointment)

    @objc(removeAppointmentsObject:)
    @NSManaged public func removeFromAppointments(_ value: Appointment)

    @objc(addAppointments:)
    @NSManaged public func addToAppointments(_ values: NSOrderedSet)

    @objc(removeAppointments:)
    @NSManaged public func removeFromAppointments(_ values: NSOrderedSet)
}
