//
//  NetTransition.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

/// A transition between nodes. Will be performed when all input nodes are triggered.
public class NetTransition<T: NetNodeRawType> {
    /// The transition handler to be performed in its own queue.
    public typealias TransitionHandler = (NetTransition<T>) -> ()
    /// The error handler to be performed when a input node fails.
    public typealias ErrorHandler = (NetNode<T>) -> ()
    
    /// All input nodes to be required in triggered state.
    public let inputNodes: [NetNode<T>]
    /// All output nodes to be run after the transition.
    public let outputNodes: [NetNode<T>]
    private let transitionHandler: TransitionHandler?
    private let errorHandler: ErrorHandler?
    
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    private var isTransitioning = false
    
    /// Sets the transition
    internal init(inputNodes: [NetNode<T>], outputNodes: [NetNode<T>], transitionHandler: TransitionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        assert(inputNodes.count > 0, "Transitions must always have at least one input node.")
        self.inputNodes = inputNodes
        assert(outputNodes.count > 0, "Transitions must always have at least one ouptut node.")
        self.outputNodes = outputNodes
        self.transitionHandler = transitionHandler
        self.errorHandler = errorHandler
        
        self.inputNodes.each { (n) in
            assert(n.outgoingTransition == nil, "Nodes aren't allowed to have multiple transitions.")
            n._outgoingTransition = self
        }
        self.outputNodes.each { (n) in
            assert(n.incomingTransition == nil, "Nodes aren't allowed to have multiple transitions.")
            n._incomingTransition = self
        }
    }
    
    /// Runs if all input nodes are set to triggered.
    internal func run() {
        self.queue.addOperation({ () -> Void in
            let allTriggered = !self.isTransitioning && self.inputNodes.reduce(true) { (b: Bool, n: NetNode<T>) -> Bool in
                b && n.state == .triggered
            }

            if allTriggered {
                self.isTransitioning = true
                self.transitionHandler?(self)
                self.inputNodes.each { n in
                    n.reset()
                }
                self.outputNodes.each { n in
                    n.run()
                }
                self.isTransitioning = false
            }
        })
        self.queue.waitUntilAllOperationsAreFinished()
    }
    
    /// Runs the error handler with the failed node.
    internal func handleError(forNode node: NetNode<T>) {
        if node.state == .error {
            self.errorHandler?(node)
            assert(node.state == .error, "The failed node could not be restored.")
        }
        else {
            assertionFailure("Only failed nodes can be handled as error.")
        }
    }
    
}

