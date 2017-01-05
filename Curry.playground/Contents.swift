func curry<A, B, C>(f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { x in { y in f(x, y) } }
}

func foo(x: Int, y: Int) -> Int {
    return x * y
}

curry(f: foo)(2)(3)
