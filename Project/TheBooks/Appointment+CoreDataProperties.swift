//
//  Appointment+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData


extension Appointment {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Appointment> {
        return NSFetchRequest<Appointment>(entityName: "Appointment");
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Appointment] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return maybeArray ?? []
	}

    @NSManaged public var start: Date
    @NSManaged public var duration: Int16
    @NSManaged public var client: Client
    @NSManaged public var day: Day
}
