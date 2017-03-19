//
//  Day+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Day {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day");
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Day] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}

    @NSManaged public var date: Date
    @NSManaged public var appointments: Set<Appointment>
}

// MARK: Generated accessors for appointments
extension Day {

    @objc(addAppointmentsObject:)
    @NSManaged public func addToAppointments(_ value: Appointment)

    @objc(removeAppointmentsObject:)
    @NSManaged public func removeFromAppointments(_ value: Appointment)

    @objc(addAppointments:)
    @NSManaged public func addToAppointments(_ values: Set<Appointment>)

    @objc(removeAppointments:)
    @NSManaged public func removeFromAppointments(_ values: Set<Appointment>)

}
