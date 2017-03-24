//
//  String.swift
//  Common
//
//  Created by Eric Ferreira on 3/30/16.
//

import Foundation

public extension String {
	/**
	The words of the string using CFStringTokenizer with the current locale.
	*/
	public var words: [String] {
		func substring(with range: CFRange) -> String {
			return (self as NSString).substring(with: NSMakeRange(range.location, range.length))
		}
		
		let inputRange = CFRangeMake(0, self.utf16.count),
			flag = UInt(kCFStringTokenizerUnitWord),
			locale = CFLocaleCopyCurrent(),
			tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self as CFString!, inputRange, flag, locale)
		
		var words: [String] = [],
			tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
		
		while tokenType != CFStringTokenizerTokenType() {
			words.append(substring(with: CFStringTokenizerGetCurrentTokenRange(tokenizer)))
			tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
		}
		
		return words
	}
	
	/**
	Retuns whether this string matches the given regular expression pattern.
	
	- parameters:
		- pattern: The regular expression pattern
		- options: the regular expression options
		- matchingOptions: the matching options to use
	*/
	public func matches(_ pattern: String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = []) -> Bool {
		return self.matches(try! NSRegularExpression(pattern: pattern, options: options))
	}
	
	/**
	Returns whether this string matches the given regular expression.
	
	- parameters:
		- regex: The regular expression
		- options: the matching options to use
	*/
	public func matches(_ regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = []) -> Bool {
		return regex.rangeOfFirstMatch(in: self, options: options, range: NSMakeRange(0, self.characters.count)).location != NSNotFound
	}
	
	/**
	Returns a new string containing the characters of the String from the one at a given index to the end.
	
	- parameters:
		- index: the index from which to start
	*/
	public func substring(from index: Int) -> String {
		return self.substring(from: self.index(self.startIndex, offsetBy: index))
	}
	
	/**
	Returns a new string containing the characters of the String up to, but not including, the one at a given index.
	
	- parameters:
		- index: the index at which to end.
	*/
	public func substring(to index: Int) -> String {
		return self.substring(to: self.index(self.startIndex, offsetBy: index))
	}
	
	/**
	Returns a string object containing the characters of the String that lie within a given range.
	
	- parameters:
		- range: the range to use.
	*/
	public func substring(with range: Range<Int>) -> String {
		let start = self.index(self.startIndex, offsetBy: range.lowerBound),
			end = self.index(self.startIndex, offsetBy: range.upperBound)
		
		return self.substring(with: start..<end)
	}
	
	/**
	The character at the given index.
	
	- parameters:
		- i: the index.
	*/
	public subscript(_ i: Int) -> Character {
		get {
			return self[self.index(self.startIndex, offsetBy: i)]
		}
	}
	
	/**
	The first character in this string.
	*/
	public var first: Character {
		return self[0]
	}
	
	/**
	The last character in this string.
	*/
	public var last: Character {
		return self[self.characters.count]
	}
}

func ~=(pattern: NSRegularExpression, str: String) -> Bool {
	return pattern.numberOfMatches(in: str, options: [], range: NSRange(location: 0,  length: str.characters.count)) > 0
}

prefix operator ~/

prefix func ~/(pattern: String) -> NSRegularExpression {
	return try! NSRegularExpression(pattern: pattern, options: [])
}
