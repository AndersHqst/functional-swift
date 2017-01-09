import Foundation
import UIKit

func plusIsCommutative(x: Int, y: Int) -> Bool {
    return x + y == y + x
}

plusIsCommutative(x: 3, y: 123)
// Quick check example
//check("Plus is cmmitatice", plusIsCommutative)

protocol Smaller {
    func smaller() -> Self?
}

protocol Arbitrary: Smaller {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
}

func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] {
    return (0..<times).map(transform)
}

extension Int {
    static func random(from: Int, to: Int) -> Int {
        return from + (Int(arc4random()) % (to - from))
    }
    
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

extension CGFloat: Arbitrary {
    static func arbitrary() -> CGFloat {
        let rand = CGFloat(arc4random()) / CGFloat(arc4random())
        let sign = arc4random() % 2 == 0 ? 1 : -1
        return rand * CGFloat(sign)
    }
    
    func smaller() -> CGFloat? {
        return self == 0 ? nil : self / 2
    }
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(Int.random(from: 65, to: 90))!)
    }
    
    func smaller() -> Character? {
        return nil
    }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(from: 0, to: 40)
        let randomCharacters = tabulate(times: randomLength) {_ in 
            Character.arbitrary()
        }
        return String(randomCharacters)
    }
    
    func smaller() -> String? {
        return isEmpty ? nil : String(characters.dropFirst())
    }
}

String.arbitrary()

let numberOfIterations = 100
func check1<A: Arbitrary>(_ message: String, _ property: (A) -> Bool) {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            print("\"\(message)\" doesn't hold:\(value)")
            return
        }
    }
      print("\"\(message)\" passed \(numberOfIterations) tests")
}

extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

extension CGSize: Arbitrary {
    internal func smaller() -> CGSize? {
        let w = width / 2
        let h = height / 2
        return CGSize(width: w, height: h)
    }

    static func arbitrary() -> CGSize {
        return CGSize(width: CGFloat.arbitrary(), height: CGFloat.arbitrary())
    }
}

// Usage
check1("Area should atleast be 0", { (size: CGSize) in size.area >= 0 })

func iterateWhile<A>(condition: (A) -> Bool, initial: A, next: (A) -> A?) -> A {
    if let x = next(initial), condition(x) {
        return iterateWhile(condition: condition, initial: x, next: next)
    }
    return initial
}

func check2<A: Arbitrary>(_ message: String, _ property: (A) -> Bool) {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: { !property($0) },
                                            initial: value,
                                            next: { $0.smaller() })
            print("\"\(message)\" doesn't hold:\(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests")
}

check2("String starts with hello", { (s: String) in s.hasPrefix("hello") })
check2("String is shorter than lenght 4", { (s: String) in s.characters.count < 4 })

func quicksort(_ array: [Int]) -> [Int] {
    var array:[Int] = array
    if array.isEmpty { return [] }
    let pivot = array.remove(at: 0)
    let lesser:[Int] = array.filter { $0 < pivot }
    let greater:[Int] = array.filter { $0 >= pivot }
    let b = [pivot]
    return quicksort(lesser) + b + quicksort(greater)
}

quicksort([1, 4, 2, 3, 1, 6, 7, 42, 123123124214, 19, -12, 2])

// We cannot make the Element of Array implement Arbitrary,
// So instead, create an auxiliary struct

struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<A>(_ arbitraryInstance: ArbitraryInstance<A>, _ property: @escaping (A) -> Bool, _ message: String) {
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: { !property($0) }, initial: value, next: arbitraryInstance.smaller)
            print("\"\(message)\" doesn't hold:\(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests")
}

func check3<X: Arbitrary>(_ message: String, property: @escaping (X) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: X.arbitrary, smaller: { $0.smaller() })
    checkHelper(instance, property, message)
}

extension Array where Element: Arbitrary {
    internal func smaller() -> Array<Element>? {
        if count == 0 { return nil }
        dropFirst()
        return self
    }

    static func arbitrary() -> Array<Element> {
        let length = Int.random(from: 0, to: 40)
        return tabulate(times: length) { _ in
            return Element.arbitrary()
        }
    }
}

// Now, overload to make array match the ArbitraryInstance
func check<X: Arbitrary>(_ message: String, property: @escaping ([X]) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: Array.arbitrary, smaller: { (x: [X]) in x.smaller() })
    checkHelper(instance, property, message)
}

check("Our qsort should work like sorted") {
    (x:[Int]) in
    let otherSequence = x.sorted()
    return quicksort(x).elementsEqual(otherSequence)
}
