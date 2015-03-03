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
    
    internal var rawNodes: [T] = []
    internal var rawTransitions: [NetRawTransition<T>] = []
    internal var rawInitials: [T]
    
    public init(initials: [T], buildClosure: BuildClosure) {
        assert(initials.count > 0, "A net must always have at least one initial node.")
        self.rawInitials = initials
        buildClosure(self)
        let inits = generateNodes().values.filter { contains(initials, $0.rawValue) }
        assert(reduce(inits, true, { (b: Bool, i: NetNode<T>) -> Bool in
            b && i.outgoingTransition != nil
        }), "All initial nodes must have outgoing transitions.")
    }
    
    public func addTransition(#from: [T], to: [T], perform: TransitionHandler? = nil, error: ErrorHandler? = nil) {
        self.rawNodes.extend(from)
        self.rawNodes.extend(to)
        let transition = NetRawTransition<T>(inputNodes: from, outputNodes: to, transitionHandler: perform, errorHandler: error)
        rawTransitions.append(transition)
    }
    
    func generateNodes() -> [T: NetNode<T>] {
        let nodes = rawNodes.map { NetNode<T>(rawValue: $0)! }
        var nodeHash = [T: NetNode<T>]()
        for n in nodes {
            nodeHash[n.rawValue] = n
        }
        
        rawTransitions.map { (rt: NetRawTransition<T>) in
            rt.transtition(nodeHash)
        }
        return nodeHash
    }
    
}
