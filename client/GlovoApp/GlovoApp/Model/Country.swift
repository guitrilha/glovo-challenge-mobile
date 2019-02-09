//
//  File.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import Foundation
import ReactiveKit
import Bond

struct Country {
    let name : Observable<String>
    let code : Observable<String>
    var cities = MutableObservableArray<City>()
    
    
    init(_ dictionary: [String: Any]) {
        let nameStr = dictionary["name"] as? String ?? ""
        self.name = Observable(nameStr)
        let codeStr = dictionary["code"] as? String ?? ""
        self.code = Observable(codeStr)
    }
}
