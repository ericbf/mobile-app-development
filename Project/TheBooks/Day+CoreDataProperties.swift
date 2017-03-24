//
//  Day+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData

private let name = "Day"

extension Day {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: name);
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Day] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}
	
	@nonobjc public class func make(for context: NSManagedObjectContext) -> Day {
		return NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! Day
	}

    @NSManaged public var date: Date
    @NSManaged public var appointments: NSOrderedSet
}

// MARK: Generated accessors for appointments
extension Day {
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
