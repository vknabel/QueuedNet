//
//  NetBuilder.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

/// A Net Builder is used for configuring multiple Nets.
public class NetBuilder<T: NetNodeRawType> {
    public typealias TransitionHandler = NetTransition<T>.TransitionHandler
    public typealias ErrorHandler = NetTransition<T>.ErrorHandler
    
    /// A closure to configure the Builder.
    public typealias BuildClosure = (NetBuilder<T>) -> ()
    
    internal var rawNodes: [T] = []
    internal var rawTransitions: [NetRawTransition<T>] = []
    internal var rawInitials: [T]
    
    /**
    Initializes a net builder.
    
    - Parameter initials The raw values for all initial states.
    - Parameter buildClosure The closure to configure the net builder.
    */
    public init(initials: [T], buildClosure: BuildClosure) {
        assert(initials.count > 0, "A net must always have at least one initial node.")
        self.rawInitials = initials
        buildClosure(self)
        let inits = generateNodes().values.filter { initials.contains($0.rawValue) }
        assert(inits.reduce(true, { (b: Bool, i: NetNode<T>) -> Bool in
            b && i.outgoingTransition != nil
        }), "All initial nodes must have outgoing transitions.")
    }
    
    /**
    Adds a transition and implicitly missing Nodes.
    
    - Parameter from The transition's input nodes' raw values. If all nodes' state is Triggered, the transition will be performed.
    - Parameter to The transition's output nodes' raw values. All nodes' states will be set to Running once the transition has finished.
    - Parameter perform The transition handler to perform the transition. Will be executed in the transition's own thread.
    - Parameter error The error handler to resolve input nodes errors. Will be executed in the transition's own thread.
    */
    public func addTransition(from: [T], to: [T], perform: TransitionHandler? = nil, error: ErrorHandler? = nil) {
        self.rawNodes.append(contentsOf: from)
        self.rawNodes.append(contentsOf: to)
        let transition = NetRawTransition<T>(inputNodes: from, outputNodes: to, transitionHandler: perform, errorHandler: error)
        rawTransitions.append(transition)
    }
    
    /**
    Generates new node objects.
    
    - Returns Instances for all raw nodes.
    */
    internal func generateNodes() -> [T: NetNode<T>] {
        let nodes = rawNodes.map { NetNode<T>(rawValue: $0)! }
        var nodeHash = [T: NetNode<T>]()
        for n in nodes {
            nodeHash[n.rawValue] = n
        }
        
        rawTransitions.forEach { (rt: NetRawTransition<T>) in
            rt.transtition(nodes: nodeHash)
        }
        return nodeHash
    }
    
}
