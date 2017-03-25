//
//  Appointment+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData

private let name = "Appointment"

extension Appointment {
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Appointment> {
        return NSFetchRequest<Appointment>(entityName: name)
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Appointment] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return (maybeArray ?? []).sorted {
			$0.start < $1.start ||
			$0.start == $1.start &&
				$0.duration < $1.duration
		}
	}
	
	@nonobjc public class func make(for context: NSManagedObjectContext) -> Appointment {
		return NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! Appointment
	}
	
	public var key: String {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "EEE  MMM d"
		formatter.timeStyle = .none
		
		return formatter.string(from: start)
	}

    @NSManaged public var start: Date
    @NSManaged public var duration: Int16
    @NSManaged public var client: Client
}
