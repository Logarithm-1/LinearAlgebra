// Vector+ExpressibleBy.swift
//
// This source file is part of the Swift Math open source project.
//
// Copyright (c) 2022 Logan Richards and the Swift Math project authors.
// Licensed under MIT
//
// See https://github.com/Logarithm-1/LinearAlgebra/blob/main/LICENSE for license information

extension Vector: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = S
    
    public init(arrayLiteral elements: S...) {
        self.init(elements)
    }
}
