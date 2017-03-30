//
//  Client+CoreDataProperties.swift
//  TheBooks
//
//  Created by Eric Ferreira on 3/18/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation
import CoreData

private let NAME = "Client"

extension Client {
	@NSManaged public var firstName: String
	@NSManaged public var lastName: String
	@NSManaged public var phone: String
	@NSManaged public var email: String
	@NSManaged public var appointments: NSOrderedSet
	
    @nonobjc public class func myFetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: NAME);
	}
	
	@nonobjc public class func all(for context: NSManagedObjectContext) -> [Client] {
		let maybeArray = try? context.fetch(myFetchRequest())
		
		return (maybeArray ?? []).sorted { $0.sortString < $1.sortString }
	}
	
	@nonobjc public class func make(for context: NSManagedObjectContext) -> Client {
		return NSEntityDescription.insertNewObject(forEntityName: NAME, into: context) as! Client
	}
	
	@nonobjc public func sort() {
		let sortDescriptors = [
			NSSortDescriptor(key: "start", ascending: true),
			NSSortDescriptor(key: "duration", ascending: true)
		]
		
		let sorted = appointments.sortedArray(using: sortDescriptors)
		
		appointments = NSOrderedSet(array: sorted)
	}
	
	private func isValid(_ str: String?) -> Bool {
		return str != nil && str!.characters.count > 0
	}
	
	public var name: String? {
		if isValid(firstName) || isValid(lastName) {
			if isValid(firstName) && isValid(lastName) {
				return "\(firstName) \(lastName)"
			}
			
			if isValid(firstName) {
				return firstName
			}
			
			return lastName
		}
		
		return nil
	}
	
	public var displayString: String {
		if isValid(name) {
			return name!
		}
		
		if isValid(email) {
			return email
		}
		
		if isValid(phone) {
			return phone
		}
		
		return "<missing info>"
	}
	
	public var sortString: String {
		return displayString
	}
	
	public var key: Character {
		switch sortString.substring(to: 1) {
		case ~/"[a-zA-Z]":
			return sortString.uppercased().first
		default:
			return "#"
		}
	}
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
