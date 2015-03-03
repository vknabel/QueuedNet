//
//  NetBuilder.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

/// A Net Builder is used for configuring multiple Nets.
public struct NetBuilder<T: NetNodeRawType> {
    public typealias TransitionHandler = NetTransition<T>.TransitionHandler
    public typealias ErrorHandler = NetTransition<T>.ErrorHandler
    
    /// A closure to configure the Builder.
    public typealias BuildClosure = (NetBuilder<T>) -> ()
    
    internal var rawNodes: [T] = []
    internal var rawTransitions: [NetRawTransition<T>] = []
    internal var rawInitials: [T]
    
    /**
    Initializes a net builder.
    
    :param: initials The raw values for all initial states.
    :param: buildClosure The closure to configure the net builder.
    */
    public init(initials: [T], buildClosure: BuildClosure) {
        assert(initials.count > 0, "A net must always have at least one initial node.")
        self.rawInitials = initials
        buildClosure(self)
        let inits = generateNodes().values.filter { contains(initials, $0.rawValue) }
        assert(reduce(inits, true, { (b: Bool, i: NetNode<T>) -> Bool in
            b && i.outgoingTransition != nil
        }), "All initial nodes must have outgoing transitions.")
    }
    
    /**
    Adds a transition and implicitly missing Nodes.
    
    :param: from The transition's input nodes' raw values. If all nodes' state is Triggered, the transition will be performed.
    :param: to The transition's output nodes' raw values. All nodes' states will be set to Running once the transition has finished.
    :param: perform The transition handler to perform the transition. Will be executed in the transition's own thread.
    :param: error The error handler to resolve input nodes errors. Will be executed in the transition's own thread.
    */
    public mutating func addTransition(#from: [T], to: [T], perform: TransitionHandler? = nil, error: ErrorHandler? = nil) {
        self.rawNodes.extend(from)
        self.rawNodes.extend(to)
        let transition = NetRawTransition<T>(inputNodes: from, outputNodes: to, transitionHandler: perform, errorHandler: error)
        rawTransitions.append(transition)
    }
    
    /**
    Generates new node objects.
    
    :returns: Instances for all raw nodes.
    */
    internal func generateNodes() -> [T: NetNode<T>] {
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
