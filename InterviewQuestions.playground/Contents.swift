import UIKit


// Question 1

var thing = "sunny"

let closure = {
    print("Today was \(thing)")
}

thing = "cloudy"

//closure()

// Answer: Today was cloudy

50 / 50

// Question 2

var animals = ["fish", "cat", "chicken", "dog"]
animals.sort { (one: String, two: String) -> Bool in
    return one < two
}

// Answer: animals.sort(by: <)

No

// Question 3

struct Pizza {
    let ingredients: [String]
}

protocol Pizzeria {
    func makePizza(_ ingredients: [String]) -> Pizza
    func makeMargherita() -> Pizza
}

extension Pizzeria {
    func makeMargherita() -> Pizza {
        return makePizza(["tomato", "mozzarella"])
    }
}

struct Lombardis: Pizzeria {
    func makePizza(_ ingredients: [String]) -> Pizza {
        return Pizza(ingredients: ingredients)
    }

    func makeMargherita() -> Pizza {
        return makePizza(["tomato", "basil", "mozzarella"])
    }
}

let lombardis1: Pizzeria = Lombardis()
let lombardis2: Lombardis = Lombardis()

lombardis1.makeMargherita()
lombardis2.makeMargherita()

// Answer: Will be same results ["tomato", "basil", "mozzarella"]

// Question 4

struct Kitten {
}

func showKitten(kitten: Kitten?) {
    guard let k = kitten else {
        print("There is no kitten")
    }
    print(k)
}

// Why compiler shows erro for this case

// Answer: The else block of a guard requires an exit path


// Question 5

// Recurcive

enum List<T> {
    case node(T, List<T>)
}

// Answer: Need add before enum keyword indirect


// Question 6

public struct Thermometer {
    public var temperature: Double
    public init(temperature: Double) {
        self.temperature = temperature
    }
}

extension Thermometer: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self.init(temperature: value)
  }
}

var t: Thermometer = Thermometer(temperature:56.8)
var thermometer: Thermometer = 56.8

// Question 7

public class ThermometerClass {
  private(set) var temperature: Double = 0.0
  public func registerTemperature(_ temperature: Double) {
    self.temperature = temperature
  }
}

let thermometerClass = ThermometerClass()
thermometerClass.registerTemperature(56.0)

public struct ThermometerStruct {
  private(set) var temperature: Double = 0.0
  public mutating func registerTemperature(_ temperature: Double) {
    self.temperature = temperature
  }
}

let thermometerStruct = ThermometerStruct()
thermometerStruct.registerTemperature(56.0)

// Answer: Replace thermometerStruct to var

// Question 8

func countUniques<T: Comparable>(_ array: Array<T>) -> Int {
    let sorted = array.sorted()
    let initial: (T?, Int) = (.none, 0)
    let reduced = sorted.reduce(initial) {
        ($1, $0.0 == $1 ? $0.1 : $0.1 + 1)
    }
    return reduced.1
}


countUniques([1, 2, 3, 3])

// need to make call like this -> [1, 2, 3, 3].countUniques()

// Answer:

extension Array where Element: Comparable {
    func countUniques() -> Int {
        let sortedValues = sorted()
        let initial: (Element?, Int) = (.none, 0)
        let reduced = sortedValues.reduce(initial) {
            ($1, $0.0 == $1 ? $0.1 : $0.1 + 1)
        }
        return reduced.1
    }
}

// Question 9

nil == .none

// Answer: true
