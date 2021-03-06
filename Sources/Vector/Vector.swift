// Vector.swift
//
// This source file is part of the Swift Math open source project.
//
// Copyright (c) 2022 Logan Richards and the Swift Math project authors.
// Licensed under MIT
//
// See https://github.com/Logarithm-1/LinearAlgebra/blob/main/LICENSE for license information

import Scalar

//TODO: Vector Function?

/// A `Vector` is a mathematical way to discribe both a magnitude and a direction.
public struct Vector<S: Scalar> {
    
    /// The `components` are how much the vecotor point's in each direction according to ``CoordinateSystem``. For cartesian coordinate's `[x, y, z, w,...]`, polar (sherical) coordinate's: `[r, θ, 𝛗, w,...]`,  and polar (cylidrical) `[r, θ, z, w,...]`.
    public var components: [S]
    
    //TODO: Remove defualt
    internal var coordinateSystem: CoordinateSystem = .Cartesian
    
    public init(_ vector: [S], corrdinateSystem: CoordinateSystem = .Cartesian) {
        self.components = vector
        self.coordinateSystem = corrdinateSystem
    }
}

//MARK: - Additional Initializers
extension Vector {
    /// A Defult initializers the equates to 0
    public init() {
        let vector: [S] = Array(repeating: 0, count: 2)
        self.init(vector)
    }
    
    /// A Vector that equates to 0, with different dimension sizes.
    public init(dimensions: Int) {
        let vector: [S] = Array(repeating: 0, count: dimensions)
        self.init(vector)
    }
    
    public init(coordinateSystem: CoordinateSystem) {
        self.components = [0]
        self.coordinateSystem = coordinateSystem
    }
}

// MARK: - Basic properties
extension Vector {
    /// The number of dimensions (the number of elements) in the `Vector`.
    public var dimensions: Int {
        get {
            return components.count
        } set(newValue) {
            while(components.count < newValue) {
                components.append(0)
            }
            
            while(components.count > 0 && components.count > newValue) {
                components.removeLast()
            }
        }
    }
    
    /// The number of dimensions, where it discludes the trailing zeros.
    ///
    /// For Example:
    ///
    ///     <1, 2, 0, 0, 0>.compactDimensions   //= 2 (2D)
    ///     <0, 0, 3>.compactDimensions         //= 3 (3D)
    ///     <1, 2, 0, 0, 3>.compactDimensions   //= 5 (5D)
    public var compactDimensions: Int {
        var countTrailingZeros: Int = 0
        
        for component in components.reversed() {
            if(component == 0) {//Component is a Trailing Zero
                countTrailingZeros += 1
            } else { //Component is not a trailing zero
                break
            }
        }
        
        return dimensions - countTrailingZeros
    }
    
    /// The magnitude of the vector squared.
    ///
    ///     ⟨1, 2, 3⟩.magnitude        = √(1^2 + 2^2 + 3^2)
    ///     ⟨1, 2, 3⟩.magnitudeSquared = (1^2 + 2^2 + 3^2)
    ///
    public var magnitudeSquared: S {
        switch coordinateSystem {
        case .Cartesian:
            var sum: S = 0
            
            for dimension in 0..<dimensions {
                sum += (self[dimension]*self[dimension]) //component^2
            }
            
            return sum
        case .PolarCylindrical:
            var sum: S = 0
            
            for dimension in 0..<dimensions {
                //since the r component already factors in the first two dimensions, we can skip the 2nd dimension.
                if(dimension != 1) {
                    sum += (self[dimension]*self[dimension]) //component^2
                }
            }
            
            return sum
        case .PolarSpherical:
            return self[0]*self[0] //would return the radius of the sphere squared, which equates to the magnitude squared of the vector.
        }
    }
    
    /// `{get set}` The magnitude of the vector
    ///
    ///     ⟨1, 2, 3⟩.magnitudeSquared = (1^2 + 2^2 + 3^2)
    ///     ⟨1, 2, 3⟩.magnitude        = √(1^2 + 2^2 + 3^2)
    ///                                = ⟨1, 2, 3⟩.magnitudeSquared.squareRoot()
    public var magnitude: S {
        get {
            return magnitudeSquared.squareRoot()
        } set(newValue) {
            self = unitVector.scale(by: newValue)
        }
    }
    
    /// `{get set}`  The direction of the vector. Equivalant to the unit vector.
    public var direction: Vector<S> {
        get {
            return unitVector
        } set(newValue) {
            self = newValue.unitVector.scale(by: magnitude)
        }
    }
    
    /// A vecotor of same direction as `self` but with a magnitude of `1`.
    public var unitVector: Vector<S> {
        switch coordinateSystem {
        case .Cartesian:
            var unit: Vector = Vector<S>(coordinateSystem: .Cartesian)
            
            for i in 0..<dimensions {
                unit[i] = self[i] / magnitude
            }
            
            return unit
        case .PolarCylindrical:
            var unit: Vector = Vector<S>(coordinateSystem: .PolarCylindrical)
            
            for i in 0..<dimensions {
                if(i != 1) {
                    unit[i] = self[i] / magnitude
                } else {
                    unit[i] = self[i]
                }
            }
            
            return unit
        case .PolarSpherical:
            var unit: Vector = self
            unit[0] = 1
            return unit
        }
    }
    
    //MARK: Static
    /// Equates to a vector `<0, 0>`
    public static var zero: Vector<S> {
        return Vector(dimensions: 2)
    }
    
    //TODO: î = [1, 0, 0]
    //TODO: j^ = [0, 1, 0]
    //TODO: k^ = [0, 0, 1]
}

//MARK: - Getters and Setters
extension Vector {
    /// `{get set}` a component in the `Vector` where the first component starts at `index: 0`.
    public subscript(index: Int) -> S {
        get {
            return index < dimensions ? components[index] : 0
        } set(newValue) {
            //Add dimensions until index can fit in to components
            while(dimensions <= index) {
                dimensions += 1
            }
            
            components[index] = newValue
        }
    }
    
    /// `{get set}` a subset of components in the `Vector`.
    public subscript(indices: Range<Int>) -> Vector<S> {
        get {
            var results: [S] = [S]()
            
            for index in indices {
                results.append(self[index])
            }
            
            return Vector<S>(results)
        } set(newValue) {
            precondition(newValue.dimensions == indices.count, "The new value must have the same number of components (dimensions) as the given range.")
            
            for index in indices {
                self[index] = newValue[index - indices.lowerBound]
            }
        }
    }
    
    /// `{get set}` a subset of components in the `Vector`.
    public subscript(indices: ClosedRange<Int>) -> Vector<S> {
        get { return self[indices.lowerBound..<(indices.upperBound + 1)] } set(newValue) { self[indices.lowerBound..<(indices.upperBound + 1)] = newValue }
    }
    
    /// `{get set}` a subset of components in the `Vector`.
    public subscript(indices: PartialRangeThrough<Int>) -> Vector<S> {
        get { return self[0...indices.upperBound] } set(newValue) { self[0...indices.upperBound] = newValue }
    }
    
    /// `{get set}` a subset of components in the `Vector`.
    public subscript(indices: PartialRangeUpTo<Int>) -> Vector<S> {
        get { return self[0..<indices.upperBound] } set(newValue) { self[0..<indices.upperBound] = newValue }
    }
    
    /// `{get set}` a subset of components in the `Vector`.
    public subscript(indices: PartialRangeFrom<Int>) -> Vector<S> {
        get { return self[indices.lowerBound..<dimensions] } set(newValue) { self[indices.lowerBound..<dimensions] = newValue }
    }
}

extension Vector {
    //Remove Trailing zero's
    public mutating func nomalize() {
        for i in 0..<dimensions {
            let index = dimensions - i - 1
            if(self[index] == 0) {
                components.remove(at: i)
            } else {
                break
            }
        }
    }
}
