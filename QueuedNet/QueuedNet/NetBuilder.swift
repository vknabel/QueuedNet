//
//  NetBuilder.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

public class NetBuilder<T: NetNodeRawType> {
    public typealias TransitionHandler = NetTransition<T>.TransitionHandler
    public typealias ErrorHandler = NetTransition<T>.ErrorHandler
    
    public typealias BuildClosure = (NetBuilder<T>) -> ()
    
    public var nodes: [T:NetNode<T>] = [:]
    public var initials: [T]
    
    public init(initials: [T], buildClosure: BuildClosure) {
        assert(initials.count > 0, "A net must always have at least one initial node.")
        self.initials = initials
        buildClosure(self)
        assert(nodes(initials).reduce(true, combine: { (b: Bool, i: NetNode<T>) -> Bool in
            b && i.outgoingTransition != nil
        }), "All initial nodes must have outgoing transitions.")
    }
    
    public func addTransition(#from: [T], to: [T], perform: TransitionHandler? = nil, error: ErrorHandler? = nil) {
        let transition = NetTransition<T>(inputNodes: nodes(from), outputNodes: nodes(to), transitionHandler: perform, errorHandler: error)
    }
    
    public func nodes(raw: [T]) -> [NetNode<T>] {
        return raw.map { r in
            if let n = self.nodes[r] {
                return n
            }
            else {
                self.nodes[r] = NetNode(rawValue: r)!
                return self.nodes[r]!
            }
        }
    }
    
}
