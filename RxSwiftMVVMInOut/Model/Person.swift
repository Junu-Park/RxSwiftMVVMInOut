//
//  Person.swift
//  RxSwiftMVVMInOut
//
//  Created by 박준우 on 2/19/25.
//

import Foundation

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let profileImage: String
}
