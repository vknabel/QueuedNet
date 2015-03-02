//
//  NetTransition.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

public class NetTransition<T: NetNodeRawType> {
    public typealias TransitionHandler = (NetTransition<T>) -> ()
    public typealias ErrorHandler = (NetNode<T>) -> ()
    
    public let inputNodes: [NetNode<T>] = []
    public let outputNodes: [NetNode<T>] = []
    private let transitionHandler: TransitionHandler?
    private let errorHandler: ErrorHandler?
    
    private let queue: NSOperationQueue = {
        let q = NSOperationQueue()
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
    
    public func run() {
        self.queue.addOperationWithBlock({ () -> Void in
            let allTriggered = !self.isTransitioning && self.inputNodes.reduce(true) { (b: Bool, n: NetNode<T>) -> Bool in
                b && n.state == .Triggered
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
    
    public func handleError(node: NetNode<T>) {
        if node.state == .Error {
            self.errorHandler?(node)
            assert(node.state == .Error, "The failed node could not be restored.")
        }
        else {
            assertionFailure("Only failed nodes can be handled as error.")
        }
    }
    
}

