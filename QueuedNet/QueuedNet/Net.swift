//
//  Net.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

/**
A Net represents its own context to be runned. All Nodes and Transitions run in their own OperationQueues.
*/
public class Net<T: NetNodeRawType> {
    
    /// All Nodes inside the Net.
    public let nodes: [T:NetNode<T>]
    /// The raw values for the initial states.
    public let initials: [T]
    
    /// Initializes a new instance by using a builder.
    public init(builder: NetBuilder<T>) {
        self.nodes = builder.generateNodes()
        self.initials = builder.rawInitials
    }
    
    /// Sets the intials' node states to Running.
    public func run() {
        self.initials.map { self.nodes[$0]! }.each { n in
            n.run()
        }
    }
    
}

public extension Net {
    /// Allows initialization without explicitly creating a Net Builder.
    public convenience init(initials: [T], buildClosure: NetBuilder<T>.BuildClosure) {
        let builder = NetBuilder<T>(initials: initials, buildClosure: buildClosure)
        self.init(builder: builder)
    }
}
