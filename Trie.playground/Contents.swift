struct Trie<Element: Hashable> {
    let isElement: Bool
    var children: [Element: Trie<Element>]
}

extension Trie {
    init() {
        isElement = false
        children = [:]
    }
}

extension Trie {
    var elements: [[Element]] {
        // Check whether the root is an element - if not, we return an empty array that causes the parents to return an empty result (i.e. map iterates 0 children)
        var result: [[Element]] = isElement ? [[]] : []
        // Append all children
        for (key, value) in children {
            result += value.elements.map { [key] + $0 }
        }
        print("result \(result) in \(self) ")
        return result
    }
}

extension Array {
    func decompose() -> (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}

let a = Trie<Int>(isElement: false, children: [1: Trie<Int>(isElement: false, children: [4: Trie<Int>(isElement: true, children: [:]), 2: Trie<Int>(isElement: false, children: [3: Trie<Int>(isElement: true, children: [:])])])])
//let a = Trie<Int>(isElement: false, children: [1: Trie<Int>(isElement: false, children: [:])])
a.elements

var arr = [1, 2, 3]
func sum(_ xs: [Int]) -> Int {
    guard let (head, tail) = xs.decompose() else {
        return 0
    }
    return head + sum(tail)
}
print("sum using decompose: \(sum(arr))")

extension Trie {
    func lookup(key: [Element]) -> Bool {
        guard let (head, tail) = key.decompose() else { return isElement }
        guard let subtrie = children[head] else { return false }
        return subtrie.lookup(key: tail)
    }
}

extension Trie {
    func withPrefix(prefix: [Element]) -> Trie<Element>? {
        guard let (head, tail) = prefix.decompose() else { return self }
        guard let subtrie = children[head] else { return nil }
        return subtrie.withPrefix(prefix: tail)
    }
}

extension Trie {
    func autoComplete(key: [Element]) -> [[Element]] {
        return withPrefix(prefix: key)?.elements ?? []
    }
 }


a.lookup(key: [1,2,3])
a.withPrefix(prefix: [1,2])?.children
for suggestion in a.autoComplete(key: [1]) {
    print(suggestion)
}

extension Trie {
    init(_ key: [Element]) {
        if let (head, tail) = key.decompose() {
            let children = [head: Trie(tail)]
            self = Trie(isElement: false, children: children)
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }
}

extension Trie {
    mutating func insert(_ key: [Element]) -> Trie<Element> {
        guard let (head, tail) = key.decompose() else {
            return Trie(isElement: true, children: children)
        }
        if children[head] != nil {
            children[head] = children[head]!.insert(tail)
        } else {
            children[head] = Trie(tail)
        }
        return Trie(isElement: isElement, children: children)
    }
}

var b = Trie(["f", "o", "o"])
print(b.autoComplete(key: ["f"]))
b.insert(["f", "o", "g"])
print(b.autoComplete(key: ["f"]))


func buildStringTrie(_ words: [String]) -> Trie<Character> {
    let initalTrie = Trie<Character>()
    return words.reduce(initalTrie) {
        trie, word in
        var t = trie
        return t.insert(Array(word.characters))
    }
}

var stringTrie = buildStringTrie(["anders", "andrik"])
for suggestion in stringTrie.autoComplete(key: Array("and".characters)) {
    print(suggestion)
}


func autoCompleteString(trie: Trie<Character>, word: String) -> [String] {
    let chars = Array(word.characters)
    let completed = trie.autoComplete(key: chars)
    return completed.map {
        chars in
        word + String(chars)
    }
}

let contents = ["cat", "car", "cars", "dog"]
let trieOfWords = buildStringTrie(contents)
autoCompleteString(trie: trieOfWords, word: "c")


