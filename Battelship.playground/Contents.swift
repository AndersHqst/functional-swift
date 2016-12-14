import Foundation

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

extension Position {
    func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    var length: Double {
        return sqrt(x * x + y * y)
    }
}

// Functional approach: functions are first-class values, no different than structs, integers, etc.
// A Region is defined by whether a point is in side it. From this definition of the type,
// all subsequent functions will follow. 
// A tradeoff here, is that it is hard to actually draw the Region. Could by done by
// systematically querrying it for all points in a coordinates system, and draw those for which
// the Region returns true
typealias Region = (Position) -> Bool

func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}

func circle2(radius: Distance, center: Position) -> Region {
    return { point in point.minus(center).length <= radius }
}

func shift(_ region: @escaping Region, offset: Position) -> Region {
    return { point in region(point.minus(offset)) }
}

func invert(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}

func intersection(_ region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}

// Points in first, but not the second region
func difference(region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region, invert(minus))
}

// S circle with radius of 10 centered at 5,5
let c = shift(circle(radius: 10), offset: Position(x: 5, y: 5))



struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

extension Ship {
    func canSafelyEngage(_ target: Ship, friendly: Ship) -> Bool {
        let firingRegion = circle(radius: firingRange)
        let unsafeRegion = circle(radius: unsafeRange)
        let safeRegion = difference(region: firingRegion, minus: unsafeRegion)
        let rangeRegion = shift(safeRegion, offset: position)
        let friendlyRegion = shift(unsafeRegion, offset: friendly.position)
        let resultRegion = difference(region: rangeRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}
