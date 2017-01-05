

// The ?? infix operator, imagine it was define as follows 
//func ??<T>(optional: T?, defaultValue: T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue
//    }
//}
// Drawback is that we HAVE to compute the defaultValue to pass it in, which could expensive
var s:String? = "123"
var a = s ?? "som expensive computation of the string here"

// Instead the Swift standard uses a function, that is then only evaluated when needed
// where the @autoclosure keyword will automatically wrap the defaultValue in a closure, and
// only evaluate it when needed
//func ??<T>(optional: T?, @autoclosure defaultValue: () -> T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue
//    }
//}


let cities = ["Paris":2241, "Madrid":3165, "Amsterdam":827, "Berlin":3562]

// The subscript return an optional, so we can switch on it
switch cities["Madrid"] {
    case 0?: print("Madrid is empty")
    case (1..<1000)?: print("Less than one million")
    case .some(let x): print("\(x) thousands live in Madrid")
    case .none: print("We dont know")
}

// The map function on optionals
var i:Int? = 1
var res = i.map { $0 + 1}
print(res ?? "res was nil")


// flatMap is defined on multiple types, including optionals
extension Optional {
    func flatMap<U>(f: (Wrapped) -> U?) -> U? {
        guard let x = self else { return nil }
        return f(x)
    }
}

// Using flatMap
i.flatMap({x in
    print("i is \(x)")
})

var ints = [1, 2, nil]
ints.flatMap { x in
    print(x.flatMap({ x in x + 100}) ?? "nil value")
}

