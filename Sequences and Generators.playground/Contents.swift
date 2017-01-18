import Foundation

protocol GeneratorType {
    associatedtype Element
    func next() -> Element?
}

// Seperate the generation of data from its usage with generators
class CountDownGenerator: GeneratorType {
    var element: Int
    
    init<T>(_ array: [T]) {
        element = array.count - 1
    }
    
    func next() -> Int? {
        defer {
            element -= 1
        }
        return element < 0 ? nil : element
    }
}

let xs = ["A", "B", "C"]
let generator = CountDownGenerator(xs)
while let i = generator.next() {
    print("Element: \(xs[i])")
}


struct ReverseSequence<Element>: Sequence, IteratorProtocol {
    var array: [Element]
    var index = 0
    
    init(_ array: [Element]) {
        self.array = array
        self.index = array.count - 1
    }
    
    mutating func next() -> Element? {
        defer { index -= 1 }
        if index < 0 {
            return nil
        }
        return array[index]
    }
}

let seq = ReverseSequence([1, 2, 3])
for e in seq {
    print("Sequence \(e)")
}