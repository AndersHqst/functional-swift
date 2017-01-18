// Type constructors that (Optional or Array) that support 'map' are called Functors
//extension Optional {
//    func map<U>(transform: (Wrapped) -> U) -> Optional<U> {  }
//}

// Many types can be made Functors, e.g. the Result type from earlier
enum Result<T> {
    case success(T)
    case failure(Error)
}

extension Result {
    func map<U>(f: (T) -> U) -> Result<U> {
        switch self {
        case let .success(value):
            return .success(f(value))
        case let .failure(error):
            return .failure(error)
        }
    }
}

let OK = Result<String>.success("OK")
let statusCode = OK.map(f: {
    (v:String) -> Int in
    switch v {
    case "OK": return 200
    default: return 400
    }
})

switch statusCode {
case let .success(statusCode):
    print(statusCode)
default:
    print("Unknown status code")
}