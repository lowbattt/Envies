//
//  Extensions.swift
//  Envies
//
//  Created by lowbatt on 7/11/2565 BE.
//

import Foundation


extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
