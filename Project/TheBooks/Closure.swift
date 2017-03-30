//
//  Closure.swift
//  Common
//
//  Created by Eric Ferreira on 2/24/17.
//	Copyright © 2016 CDI. All rights reserved.
//

import Foundation
import PromiseKit

//MARK: Concurrency

/// Delay the execution of a closure until a certain amount of time passes.
///
/// - Parameters:
///   - seconds: How long to delay the execution. Default is `0`.
///   - closure: The closure to execute.
///
/// Executes in foreground or background: whichever is used to call the delay function.
public func delay(_ seconds: TimeInterval = 0, _ closure: (()->())?) {
	if let closure = closure {
		var queue: DispatchQueue
		
		if Thread.isMainThread {
			queue = DispatchQueue.main
		} else {
			queue = DispatchQueue.global()
		}
		
		queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
}

/// Execute a closure in the background.
///
/// - Parameter closure: The closure to execute.
///
/// Processing can be done in the background, but UI tasks *must* be done in the foreground.
public func background(_ closure: (()->())?) {
	if let closure = closure {
		DispatchQueue.global().async(execute: closure)
	}
}

/**
Run a closure of code on the main thread.

- parameters:
- closure: the closure to run.

UI tasks should always be run on the main thread, but processing tasks can be run on background threads.
*/
/// Execute a closure in the foreground.
///
/// - Parameter closure: The closure to execute.
///
/// UI tasks *must* be run in the foreground, but processing can be done in the background.
public func foreground(_ closure: (()->())?) {
	if let closure = closure {
		DispatchQueue.main.async(execute: closure)
	}
}

//MARK: Benchmark

/// Time the execution of the passed closure.
///
/// - Parameter closure: The closure to be timed
/// - Returns: The time it took to execute, in seconds
public func benchmark(_ closure: () -> ()) -> TimeInterval {
	let start = Date()
	
	closure()
	
	return Date().timeIntervalSince(start)
}

/// Time the execution of the passed closure.
///
/// - Parameter closure: The closure to be timed
/// - Returns: A tuple with the result of the closure and the time it took to execute, in seconds
public func benchmark<R>(_ closure: () -> R) -> (R, TimeInterval) {
	let start = Date()
	
	return (closure(), Date().timeIntervalSince(start))
}

//MARK: Recurse

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<R>(_ closure: (@escaping (@escaping () -> R) -> (() -> R))) -> (() -> R) {
	var recurse: (() -> R)!
	var memo: (() -> R)!
	
	recurse = {memo()}
	memo = closure(recurse)
	
	return recurse
}

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<P, R>(_ closure: (@escaping (@escaping (P) -> R) -> ((P) -> R))) -> ((P) -> R) {
	var recurse: ((P) -> R)!
	var memo: ((P) -> R)!
	
	recurse = {memo($0)}
	memo = closure(recurse)
	
	return recurse
}

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<P0, P1, R>(_ closure: (@escaping (@escaping (P0, P1) -> R) -> ((P0, P1) -> R))) -> ((P0, P1) -> R) {
	var recurse: ((P0, P1) -> R)!
	var memo: ((P0, P1) -> R)!
	
	recurse = {memo($0, $1)}
	memo = closure(recurse)
	
	return recurse
}

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<P0, P1, P2, R>(_ closure: (@escaping (@escaping (P0, P1, P2) -> R) -> ((P0, P1, P2) -> R))) -> ((P0, P1, P2) -> R) {
	var recurse: ((P0, P1, P2) -> R)!
	var memo: ((P0, P1, P2) -> R)!
	
	recurse = {memo($0, $1, $2)}
	memo = closure(recurse)
	
	return recurse
}

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<P0, P1, P2, P3, R>(_ closure: (@escaping (@escaping (P0, P1, P2, P3) -> R) -> ((P0, P1, P2, P3) -> R))) -> ((P0, P1, P2, P3) -> R) {
	var recurse: ((P0, P1, P2, P3) -> R)!
	var memo: ((P0, P1, P2, P3) -> R)!
	
	recurse = {memo($0, $1, $2, $3)}
	memo = closure(recurse)
	
	return recurse
}

/// Get a new reference to the closure returned from the passed closure
///
/// - Parameter closure: This closure will be call with a reference to the closure it returns.
/// - Returns: The closure returned from the closure parameter.
///
/// This allows us to create inline recursive closures. Because a variable can't reference itself in its initializer, we can't normally do recursive closures, but with this we can, like:
///
/// ```
/// let factorial = recurse {factorial in {(n: Int) in
///		return n < 2 ? 1 : factorial(n - 1) * n
/// }}
/// ```
///
/// We can use this, in fact, to make anonymous recursive closures for passing as parameters or wherever else.
public func recurse<P0, P1, P2, P3, P4, R>(_ closure: (@escaping (@escaping (P0, P1, P2, P3, P4) -> R) -> ((P0, P1, P2, P3, P4) -> R))) -> ((P0, P1, P2, P3, P4) -> R) {
	var recurse: ((P0, P1, P2, P3, P4) -> R)!
	var memo: ((P0, P1, P2, P3, P4) -> R)!
	
	recurse = {memo($0, $1, $2, $3, $4)}
	memo = closure(recurse)
	
	return recurse
}

//MARK: Memoize

/// Memoize a closure that takes no parameters.
///
/// - Parameter closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure.
public func memoize<R>(_ closure: @escaping () -> R) -> () -> R {
	var cache: R!
	var set = false
	
	return {
		if !set {
			set = true
			cache = closure()
		}
		
		if let promise = cache as? Promise<Any> {
			promise.catch {_ in
				set = false
			}
		}
		
		return cache
	}
}

/// Memoize a closure that has equatable parameters.
///
/// - Parameters:
///   - ignoring: An array of indices: the indices of parameters to ignore while memoizing. The indexed parameters will not affect the memoization. Index parameters starting at 0. Default is `[]`.
///   - closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure
///
/// Memoization works fastest if the parameters are hashable. If they are not, it will still work, but in linear time (rather than log time) for the non-hashable parameters.
public func memoize<P: Equatable, R>(ignoring: [Int] = [], _ closure: @escaping (P) -> R) -> (P) -> R {
	var cache: [AnyHashable: R] = [:]
	var keys: [(P, AnyHashable)] = []
	var i = 0
	
	func getKey() -> String {
		return "$$m_id_\(i)"
	}
	
	return {param in
		let key: AnyHashable
		
		if ignoring.contains(0) {
			key = getKey()
		} else if let param = param as? AnyHashable {
			key = param
		} else {
			if let entry = keys.first(where: {$0.0 == param}) {
				key = entry.1
			} else {
				key = getKey()
				i += 1
				keys.append((param, key))
			}
		}
		
		let returns = cache[key] ?? closure(param)

		if !cache.has(key: key) {
			cache[key] = returns
			
			if let promise = returns as? Promise<Any> {
				promise.catch {_ in
					cache.removeValue(forKey: key)
				}
			}
		}
		
		return returns
	}
}

func decrement(_ ignoring: [Int] = [], by amount: Int = 1) -> [Int] {
	return ignoring
		.map {$0 - amount}
		.filter {$0 < 0}
}

/// Memoize a closure that has equatable parameters.
///
/// - Parameters:
///   - ignoring: An array of indices: the indices of parameters to ignore while memoizing. The indexed parameters will not affect the memoization. Index parameters starting at 0. Default is `[]`.
///   - closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure
///
/// Memoization works fastest if the parameters are hashable. If they are not, it will still work, but in linear time (rather than log time) for the non-hashable parameters.
public func memoize<P0: Equatable, P1: Equatable, R>(ignoring: [Int] = [], _ closure: @escaping (P0, P1) -> R) -> (P0, P1) -> R {
	
	let innerIgnoring = decrement(ignoring)
	
	let first = memoize(ignoring: ignoring) {p in
		return memoize(ignoring: innerIgnoring) { closure(p, $0) }
	}
	
	return {first($0)($1)}
}

/// Memoize a closure that has equatable parameters.
///
/// - Parameters:
///   - ignoring: An array of indices: the indices of parameters to ignore while memoizing. The indexed parameters will not affect the memoization. Index parameters starting at 0. Default is `[]`.
///   - closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure
///
/// Memoization works fastest if the parameters are hashable. If they are not, it will still work, but in linear time (rather than log time) for the non-hashable parameters.
public func memoize<P0: Equatable, P1: Equatable, P2: Equatable, R>(ignoring: [Int] = [], _ closure: @escaping (P0, P1, P2) -> R) -> (P0, P1, P2) -> R {
	
	let innerIgnoring = decrement(ignoring)
	
	let first = memoize(ignoring: ignoring) {p in
		return memoize(ignoring: innerIgnoring) { closure(p, $0, $1) }
	}
	
	return {first($0)($1, $2)}
}

/// Memoize a closure that has equatable parameters.
///
/// - Parameters:
///   - ignoring: An array of indices: the indices of parameters to ignore while memoizing. The indexed parameters will not affect the memoization. Index parameters starting at 0. Default is `[]`.
///   - closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure
///
/// Memoization works fastest if the parameters are hashable. If they are not, it will still work, but in linear time (rather than log time) for the non-hashable parameters.
public func memoize<P0: Equatable, P1: Equatable, P2: Equatable, P3: Equatable, R>(ignoring: [Int] = [], _ closure: @escaping (P0, P1, P2, P3) -> R) -> (P0, P1, P2, P3) -> R {
	
	let innerIgnoring = decrement(ignoring)
	
	let first = memoize(ignoring: ignoring) {p in
		return memoize(ignoring: innerIgnoring) { closure(p, $0, $1, $2) }
	}
	
	return {first($0)($1, $2, $3)}
}

/// Memoize a closure that has equatable parameters.
///
/// - Parameters:
///   - ignoring: An array of indices: the indices of parameters to ignore while memoizing. The indexed parameters will not affect the memoization. Index parameters starting at 0. Default is `[]`.
///   - closure: The closure to be memoized. If this closure returns a `Promise`, a catch is added to unsave the memoized value if an error occurs.
/// - Returns: The memoized closure
///
/// Memoization works fastest if the parameters are hashable. If they are not, it will still work, but in linear time (rather than log time) for the non-hashable parameters.
public func memoize<P0: Equatable, P1: Equatable, P2: Equatable, P3: Equatable, P4: Equatable, R>(ignoring: [Int] = [], _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P0, P1, P2, P3, P4) -> R {
	
	let innerIgnoring = decrement(ignoring)
	
	let first = memoize(ignoring: ignoring) {p in
		return memoize(ignoring: innerIgnoring) { closure(p, $0, $1, $2, $3) }
	}
	
	return {first($0)($1, $2, $3, $4)}
}

//MARK: Throttle

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping () -> R) -> () -> R {
	var cache: R!
	var lastCall = Date(timeIntervalSince1970: 0)
	var calledWhileWaiting = false
	
	return {
		if Date().timeIntervalSince(lastCall) < seconds {
			calledWhileWaiting = true
		} else {
			lastCall = Date()
			
			if triggerAfterDelay {
				delay(seconds) {
					if calledWhileWaiting {
						calledWhileWaiting = false
						
						cache = closure()
					}
				}
			}
			
			cache = closure()
		}
		
		
		return cache
	}
}

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<P, R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping (P) -> R) -> (P) -> R {
	var p: P!
	let throttled = throttle(seconds, triggerAfterDelay: triggerAfterDelay) { closure(p) }
	
	return {
		p = $0
		
		return throttled()
	}
}

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<P0, P1, R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping (P0, P1) -> R) -> (P0, P1) -> R {
	var p0: P0!
	var p1: P1!
	let throttled = throttle(seconds, triggerAfterDelay: triggerAfterDelay) { closure(p0, p1) }
	
	return {
		p0 = $0
		p1 = $1
		
		return throttled()
	}
}

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<P0, P1, P2, R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping (P0, P1, P2) -> R) -> (P0, P1, P2) -> R {
	var p0: P0!
	var p1: P1!
	var p2: P2!
	let throttled = throttle(seconds, triggerAfterDelay: triggerAfterDelay) { closure(p0, p1, p2) }
	
	return {
		p0 = $0
		p1 = $1
		p2 = $2
		
		return throttled()
	}
}

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<P0, P1, P2, P3, R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping (P0, P1, P2, P3) -> R) -> (P0, P1, P2, P3) -> R {
	var p0: P0!
	var p1: P1!
	var p2: P2!
	var p3: P3!
	let throttled = throttle(seconds, triggerAfterDelay: triggerAfterDelay) { closure(p0, p1, p2, p3) }
	
	return {
		p0 = $0
		p1 = $1
		p2 = $2
		p3 = $3
		
		return throttled()
	}
}

/// Allows prevention of duplicate calls to a closure within a `TimeInterval`
///
/// - Parameters:
///   - seconds: The amount of time to hold calls. Default is `0`.
///   - triggerAfterDelay: Whether to call after the delay if any calls are made while throttling. Default is `false`.
///   - closure: The closure to be throttled.
/// - Returns: The throttled closure.
public func throttle<P0, P1, P2, P3, P4, R>(_ seconds: TimeInterval = 0, triggerAfterDelay: Bool = false, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P0, P1, P2, P3, P4) -> R {
	var p0: P0!
	var p1: P1!
	var p2: P2!
	var p3: P3!
	var p4: P4!
	let throttled = throttle(seconds, triggerAfterDelay: triggerAfterDelay) { closure(p0, p1, p2, p3, p4) }
	
	return {
		p0 = $0
		p1 = $1
		p2 = $2
		p3 = $3
		p4 = $4
		
		return throttled()
	}
}

//MARK: Bind

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p: The value to bind for the parameter
///   - closure: The closure whose parameter is to be bound
/// - Returns: A closure whose parameter is already bound
public func bind<P, R>(_ p: P, _ closure: @escaping (P) -> R) -> () -> R {
	return { closure(p) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - closure: The closure whose parameter is to be bound
/// - Returns: A closure whose first parameter is already bound
public func bind<P0, P1, R>(_ p0: P0, _ closure: @escaping (P0, P1) -> R) -> (P1) -> R {
	return { closure(p0, $0) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose two parameters are already bound
public func bind<P0, P1, R>(_ p0: P0, _ p1: P1, _ closure: @escaping (P0, P1) -> R) -> () -> R {
	return { closure(p0, p1) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - closure: The closure whose parameter is to be bound
/// - Returns: A closure whose first parameter is already bound
public func bind<P0, P1, P2, R>(_ p0: P0, _ closure: @escaping (P0, P1, P2) -> R) -> (P1, P2) -> R {
	return { closure(p0, $0, $1) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first two parameters are already bound
public func bind<P0, P1, P2, R>(_ p0: P0, _ p1: P1, _ closure: @escaping (P0, P1, P2) -> R) -> (P2) -> R {
	return { closure(p0, p1, $0) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose three parameters are already bound
public func bind<P0, P1, P2, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ closure: @escaping (P0, P1, P2) -> R) -> () -> R {
	return { closure(p0, p1, p2) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - closure: The closure whose parameter is to be bound
/// - Returns: A closure whose first parameter is already bound
public func bind<P0, P1, P2, P3, R>(_ p0: P0, _ closure: @escaping (P0, P1, P2, P3) -> R) -> (P1, P2, P3) -> R {
	return { closure(p0, $0, $1, $2) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first two parameters are already bound
public func bind<P0, P1, P2, P3, R>(_ p0: P0, _ p1: P1, _ closure: @escaping (P0, P1, P2, P3) -> R) -> (P2, P3) -> R {
	return { closure(p0, p1, $0, $1) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first three parameters are already bound
public func bind<P0, P1, P2, P3, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ closure: @escaping (P0, P1, P2, P3) -> R) -> (P3) -> R {
	return { closure(p0, p1, p2, $0) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - p3: The value to bind for the fourth parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose four parameters are already bound
public func bind<P0, P1, P2, P3, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ closure: @escaping (P0, P1, P2, P3) -> R) -> () -> R {
	return { closure(p0, p1, p2, p3) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - closure: The closure whose parameter is to be bound
/// - Returns: A closure whose first parameter is already bound
public func bind<P0, P1, P2, P3, P4, R>(_ p0: P0, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P1, P2, P3, P4) -> R {
	return { closure(p0, $0, $1, $2, $3) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first two parameters are already bound
public func bind<P0, P1, P2, P3, P4, R>(_ p0: P0, _ p1: P1, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P2, P3, P4) -> R {
	return { closure(p0, p1, $0, $1, $2) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first three parameters are already bound
public func bind<P0, P1, P2, P3, P4, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P3, P4) -> R {
	return { closure(p0, p1, p2, $0, $1) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - p3: The value to bind for the fourth parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose first four parameters are already bound
public func bind<P0, P1, P2, P3, P4, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> (P4) -> R {
	return { closure(p0, p1, p2, p3, $0) }
}

/// Bind a closure's parameters to the passed values
///
/// - Parameters:
///   - p0: The value to bind for the first parameter
///   - p1: The value to bind for the second parameter
///   - p2: The value to bind for the third parameter
///   - p3: The value to bind for the fourth parameter
///   - p4: The value to bind for the fifth parameter
///   - closure: The closure whose parameters are to be bound
/// - Returns: A closure whose five parameters are already bound
public func bind<P0, P1, P2, P3, P4, R>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ closure: @escaping (P0, P1, P2, P3, P4) -> R) -> () -> R {
	return { closure(p0, p1, p2, p3, p4) }
}
