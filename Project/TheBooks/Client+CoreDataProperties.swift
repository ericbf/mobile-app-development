//
//  Client+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData


extension Client {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client");
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Client] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}

    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var appointments: Set<Appointment>
}

// MARK: Generated accessors for appointments
extension Client {
    @objc(addAppointmentsObject:)
    @NSManaged public func addToAppointments(_ value: Appointment)

    @objc(removeAppointmentsObject:)
    @NSManaged public func removeFromAppointments(_ value: Appointment)

    @objc(addAppointments:)
    @NSManaged public func addToAppointments(_ values: Set<Appointment>)

    @objc(removeAppointments:)
    @NSManaged public func removeFromAppointments(_ values: Set<Appointment>)
}
