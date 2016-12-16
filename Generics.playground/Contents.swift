func genericComputeArray1<T>(xs: [Int], transform: (Int) -> T) -> [T] {
    var result:[T] = []
    for x in xs {
        result.append(transform(x))
    }
    return result
}

let arr1 = genericComputeArray1(xs: [1,2,3], transform: { x in x + 3 })
print(arr1)

extension Array {
    // Already defined in the SequenceType protocol
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result:[T] = []
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}

// for in loops are really just a wrapper around
//var generator = myArray.generate()
//while let element = generator.next() {
//    // do something
//}

extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}

struct SortedCollection<T: Comparable> {
    private var contents: [T] = []
    
    init<S : Sequence>(_ sequence: S) where S.Iterator.Element == T {
        contents = sequence.sorted()
    }
    
    func index(of value: T) -> Int? {
        let index = contents.binarySearch { $0 < value }
        if index >= contents.count {
            return nil
        }
        return contents[index] == value ? index : nil
    }

    func insertionIndex(of value: T) -> Int? {
        return contents.binarySearch { $0 <= value }
    }
    
    func count() -> UInt {
        return UInt(contents.count)
    }
    
    func object(at index: UInt) -> T? {
        if index < count() {
            return contents[Int(index)]
        }
        return nil
    }
    
    var array:[T] {
        return contents
    }
    
    mutating func insert(value: T) {
        if let index = insertionIndex(of: value) {
            contents.insert(value, at: index)
        } else {
            fatalError()
        }
    }
    
    mutating func remove(value: T) -> T? {
        if let index = index(of: value) {
            return contents.remove(at: index)
        }
        return nil
    }
}

// Manually implementing the IteratorProtocol
struct SortedCollectionIterator<T: Comparable>: IteratorProtocol {
    typealias Collection = SortedCollection<T>
    
    let collection: Collection
    var index:UInt = 0
    
    init(_ collection: Collection) {
        self.collection = collection
    }
    
    mutating func next() -> T? {
        defer {
            index = index + 1
        }
        return collection.object(at: index)
    }
}

extension SortedCollection : Sequence {
    func makeIterator() -> SortedCollectionIterator<T> {
        return SortedCollectionIterator(self)
    }
}

// Reuse an existing IteratorProtocol implementation
// Commented as it dublicates the implementation above
//extension SortedCollection : Sequence {
//    func makeIterator() -> IndexingIterator<Array<T>> {
//        return IndexingIterator(_elements: self.array)
//    }
//}

// Test
let seq = [2, 1, 3]
var sortedSeq = SortedCollection(seq)
let test1 = sortedSeq.index(of: 1)
test1 == 0
let test2 = sortedSeq.index(of: 2)
test2 == 1
let test3 = sortedSeq.index(of: 666)
test3 == nil
let test4 = sortedSeq.insertionIndex(of: 666)
test4 == 3
sortedSeq.insert(value: 7)
print(sortedSeq)

for e in sortedSeq {
    print(e)
}