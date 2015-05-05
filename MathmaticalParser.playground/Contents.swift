//  Created by Alexander Russell on 4/15/15.
//  Copyright (c) 2015 Alexander Russell. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

/*
This is a basic mathmatical parser that takes a string and parses it into a tree
The tree is comprised of the class ExpressionNode
The use of this parser is verry simple
Just create a new instance of MathmaticalTree
call MathmaticalTree.initWithFormula(formula: String) // This will return the root node

The ExpressionNode Class has a printNodeAndChildren(prefix: String, isTail: Bool)
//NOTE: there is an example at the bottom of the program
This parser does work with variables as well as parenthesis
*/

import UIKit

class Queue{
    var queue: [AnyObject] = []
    func add(objToAdd: AnyObject){
        queue.append(objToAdd)
    }
    func deQueue() -> AnyObject{
        let remove: AnyObject = queue[0]
        queue.removeAtIndex(0)
        return remove
    }
    func empty() -> Bool{
        return queue.isEmpty
    }
}

class ExpressionNode{
    var left: AnyObject?
    var right: AnyObject?
    var op: AnyObject?
    var leaf: Bool = false
    func initWithContent(opValue: AnyObject, leftValue: AnyObject, rightValue: AnyObject){
        left = leftValue
        right = rightValue
        op = opValue
    }
    
    func printNodeAndChildren(prefix: String, isTail: Bool){
        var append = "|_ "
        var recursiveAppend = "   "
        if !isTail{
            append = "|-- "
            recursiveAppend = "|   "
        }
        println("\(prefix)\(append)\(op!)")
        if let node = right as? ExpressionNode{
            node.printNodeAndChildren("\(prefix)\(recursiveAppend)", isTail: false)
        }else{
            println("\(prefix)\(recursiveAppend)\(right!)")
        }
        if let node = left as? ExpressionNode{
             node.printNodeAndChildren("\(prefix)\(recursiveAppend)", isTail: false)
        } else {
            println("\(prefix)\(recursiveAppend)\(left!)")
        }
        
    }
    
}

class shuntingYard{
    var opStack: [String] = []
    var numStack: [String] = []
    let operations = ["+" : 0,"-" :  0,"*" : 1,"/" : 1]
    var finalList: [AnyObject] = []
    var parenString: [String] = []
    func shunt(formula: String){
        let form = String(reverse(formula))
        let tokens = split(form){$0 == " "}
        var parens = 0
        for token in tokens{
            if token == "(" || token == ")"{
                if token == "("{
                    parens--
                    if parens == 0 {
                        parenString.removeAtIndex(0)
                        var subPar = " ".join(reverse(parenString))
                        numStack.append(subPar)
                        parenString.removeAll(keepCapacity: false)
                        continue
                    }
                }
                if token == ")"{
                    parens++
                }
            }
            if parens > 0 {
                parenString .append(token)
                continue
            }
            
            if isNumeric(token) || isVariable(token){
                numStack.append(token)
            } else {
                if opStack.isEmpty{
                    opStack.append(token)
                } else if (getOpPrecedence(token) < getOpPrecedence(opStack.last!)){
                    let op = opStack.last!
                    let right = numStack.last!
                    let left = numStack[numStack.count-2]
                    let new = "\(left) \(op) \(right)"
                    opStack.removeLast()
                    numStack.removeLast()
                    numStack.removeLast()
                    numStack.append(new)
                    opStack.append(token)
                } else {
                    opStack.append(token)
                }
            }
        }
    }
    func isNumeric(num: String) -> Bool{
        let temp = num.toInt()
        if temp == nil{
            return false
        } else {
            return true
        }
    }
    func isVariable(x: String) -> Bool{
        let charset = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz")
        return x.rangeOfCharacterFromSet(charset, options: nil, range: nil) != nil
    }
    func isOperation(op: String) -> Bool{
        let opList = ["+","-","*","/"]
        return contains(opList,op)
    }
    func getOpPrecedence(op: String) -> Int {
        if let x = operations[op]{
            return x
        }else{
            return -1
        }
    }
    func finalize(){
        while(!numStack.isEmpty){
            if finalList.isEmpty{
                let right = numStack.last!
                let left = numStack[numStack.count-2]
                let op = opStack.last!
                finalList = [op,left,right]
                numStack.removeLast()
                numStack.removeLast()
                opStack.removeLast()
            }else{
                let right = numStack.last!
                let op = opStack.last!
                finalList = [op,finalList,right]
                numStack.removeLast()
                opStack.removeLast()
            }
        }
    }
    func height(Node: ExpressionNode) -> Int{
        if Node.leaf{
            return 1
        } else {
            return height(Node.left as! ExpressionNode ) + 1
        }
    }
    
    func makeTree(opArray: AnyObject) -> ExpressionNode{
        var right: AnyObject! = opArray[2] as! String
        var left: AnyObject = opArray[1]
        if let l = left as? [String]{
            left = "\(l[2]) \(l[0]) \(l[1])"
        }
        if let r = right as? [String]{
            right = "\(r[2]) \(r[0]) \(r[1])"
        }
        let charset = NSCharacterSet(charactersInString: "+*/-")
        if (count(right as! String) > 2 && (right as! String).rangeOfCharacterFromSet(charset, options: nil, range: nil) != nil) {
            let rightMathTree = MathmaticalTree()
            let rightRoot = rightMathTree.initWithFormula(right as! String)
            right = rightRoot
            
        }
        if (count(left as! String) > 2 && (left as! String).rangeOfCharacterFromSet(charset, options: nil, range: nil) != nil) {
            let leftMathTree = MathmaticalTree()
            let leftRoot = leftMathTree.initWithFormula(left as! String)
            left = leftRoot
        }
        var ex = ExpressionNode()
        ex.initWithContent(opArray[0], leftValue: left, rightValue: right)
        return ex
    }
}

class TreePrint{
    func printFromStartNode(node: ExpressionNode){
        let Q = Queue()
        Q.add(node)
        while(!Q.empty()){
            var current = Q.deQueue() as! ExpressionNode
            println(current.op!)
            
            if let left = current.left as? ExpressionNode{
                Q.add(left)
                print("\(left.op!)   ")
            } else {
                print("\(current.left!)    ")
            }
            if let right = current.right as? ExpressionNode{
                Q.add(right)
                print("\(right.op!)   ")
            } else {
                print("\(current.right!)   ")
            }
            println()
            println("********")        }
    }
    func height(Node: ExpressionNode) -> Int{
        if Node.leaf{
            return 1
        } else {
            return height(Node.left as! ExpressionNode ) + 1
        }
    }
}

class MathmaticalTree{
    var ShuntingYard = shuntingYard()
    var root = ExpressionNode()
    func initWithFormula(formula: String) -> ExpressionNode{
        ShuntingYard.shunt(formula)
        ShuntingYard.finalize()
        root = ShuntingYard.makeTree(ShuntingYard.finalList)
        return root
    }
}


let mathTree = MathmaticalTree()
let start = mathTree.initWithFormula("( 6 * ( a + b ) ) - 5")
start.printNodeAndChildren("", isTail: true)




