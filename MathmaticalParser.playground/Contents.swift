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
    let operations = ["+" : 0,"-" :  0,"*" : 1,"/" : 1, "^" : 2]
    let opList = ["+","-","*","/","^"]
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
            }
            if isOperation(token){
                if opStack.isEmpty{
                    opStack.append(token)
                } else if (getOpPrecedence(token) < getOpPrecedence(opStack.last!)){
                    let op = opStack.last!
                    let right = numStack.last!
                    let left = numStack[numStack.count-2]
                    let new = "( \(left) ) \(op) ( \(right) )"
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
        let charList = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        return contains(charList,x)
    }
    func isOperation(op: String) -> Bool{
        
        return contains(opList,op)
    }
    func getOpPrecedence(op: String) -> Int {
        if let x = operations[op]{
            return x
        }else{
            return -1
        }
    }
    func height(Node: ExpressionNode) -> Int{
        if Node.leaf{
            return 1
        } else {
            return height(Node.left as! ExpressionNode ) + 1
        }
    }
    func makeTree(ops: [String], nums: [String]) -> ExpressionNode{
        var opArray = ops
        var numArray = nums
        if !opArray.isEmpty{
            let op = opArray[0]
            opArray.removeAtIndex(0)
            var right: AnyObject = numArray[0]
            numArray.removeAtIndex(0)
            var left: AnyObject
            if opArray.isEmpty {
                left = numArray[0]
                numArray.removeAtIndex(0)
                if ((count(left as! String) > 2 && ((left as! String).rangeOfString("+") != nil || (left as! String).rangeOfString("*") != nil || (left as! String).rangeOfString("/") != nil || (left as! String).rangeOfString("-") != nil || (left as! String).rangeOfString("^") != nil))) {
                
                    let sh = shuntingYard()
                    sh.shunt(left as! String)
                    left = sh.makeTree(sh.opStack, nums: sh.numStack)
                }
            } else {
                left = makeTree(opArray, nums: numArray)
            }
            if ((count(right as! String) > 2 && ((right as! String).rangeOfString("+") != nil || (right as! String).rangeOfString("*") != nil || (right as! String).rangeOfString("/") != nil || (right as! String).rangeOfString("-") != nil || (right as! String).rangeOfString("^") != nil))) {
                let sh = shuntingYard()
                sh.shunt(right as! String)
                right = sh.makeTree(sh.opStack, nums: sh.numStack)
            }
            let ex = ExpressionNode()
            ex.initWithContent(op, leftValue: left, rightValue: right)
            return ex
        } else {
            let newMathTree = MathmaticalTree()
            let ex = newMathTree.initWithFormula(numArray[0] as String)
            return ex
        }
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
        root = ShuntingYard.makeTree(ShuntingYard.opStack,nums: ShuntingYard.numStack)
        return root
    }
}


let mathTree = MathmaticalTree()
//let start = mathTree.initWithFormula("( ( 3 + 7 * ( 6 + 8 ) ) * ( 4 + 4 * ( 1 + 7 ) ) - ( 8 * x ) )")
let start = mathTree.initWithFormula("( 6 ^ ( 4 + 4 ) * 7 ^ ( 5 * x ) )")
start.printNodeAndChildren("", isTail: true)




