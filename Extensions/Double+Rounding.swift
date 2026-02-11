//
//  Double+Rounding.swift
//  MathGraph Lab
//
//  Helpers for snapping to grid
//  Part of Extensions layer
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Rounds to the nearest multiple of a given value (snap)
    func rounded(toNearest multiple: Double) -> Double {
        return (self / multiple).rounded() * multiple
    }
}
