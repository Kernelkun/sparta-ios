//
//  WeakSet.swift
//  
//
//  Created by Yaroslav Babalich on 09.02.2021.
//

import Foundation

/// The WeakSet is weak: References to objects in the collection are held weakly.
/// If there is no other reference to an object stored in the WeakSet, they can be garbage collected.
public class WeakSet<T>: Sequence, ExpressibleByArrayLiteral, CustomStringConvertible, CustomDebugStringConvertible {

    private var objects = NSHashTable<AnyObject>.weakObjects()

    public init(_ objects: [T]) {
        for object in objects {
            insert(object)
        }
    }

    public required convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }

    public var allObjects: [T] {
        return objects.allObjects as? [T] ?? []
    }

    public var count: Int {
        return objects.count
    }

    public func contains(_ object: T) -> Bool {
        return objects.contains(object as AnyObject)
    }

    public func insert(_ object: T) {
        objects.add(object as AnyObject)
    }

    public func remove(_ object: T) {
        objects.remove(object as AnyObject)
    }

    public func removeAll() {
        objects.removeAllObjects()
    }

    public func makeIterator() -> AnyIterator<T> {
        let iterator = objects.objectEnumerator()
        return AnyIterator {
            return iterator.nextObject() as? T
        }
    }

    public var description: String {
        return objects.description
    }

    public var debugDescription: String {
        return objects.debugDescription
    }
}
