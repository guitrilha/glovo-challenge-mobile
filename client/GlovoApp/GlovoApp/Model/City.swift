//
//  CityInfo.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond

struct City {
    let code : Observable<String>
    let name : Observable<String>
    let countryCode : Observable<String>
    let currency: Observable<String>
    let enabled: Observable<Bool?>
    let timeZone: Observable<String>
    let busy: Observable<Bool?>
    let languageCode: Observable<String>
    let workingArea : ObservableArray<String>
    
    init(){
        self.code = Observable(String())
        self.name = Observable(String())
        self.countryCode = Observable(String())
        self.currency = Observable(String())
        self.enabled = Observable(nil)
        self.timeZone = Observable(String())
        self.busy = Observable(nil)
        self.languageCode = Observable(String())
        self.workingArea = ObservableArray([])
    }
    
    init(_ dictionary: [String: Any]) {
        let codeStr = dictionary["code"] as? String ?? ""
        self.code = Observable(codeStr)
        let nameStr = dictionary["name"] as? String ?? ""
        self.name = Observable(nameStr)
        
        let countryCodeStr = dictionary["country_code"] as? String ?? ""
        self.countryCode = Observable(countryCodeStr)
        
        let currencyStr = dictionary["currency"] as? String ?? ""
        self.currency = Observable(currencyStr)
        
        let enabledBool = dictionary["enabled"] as? Bool ?? nil
        self.enabled = Observable(enabledBool)
        
        let timeZoneStr = dictionary["time_zone"] as? String ?? ""
        self.timeZone = Observable(timeZoneStr)
        
        let busyBool = dictionary["busy"] as? Bool ?? nil
        self.busy = Observable(busyBool)
        
        let languageCodeStr = dictionary["language_code"] as? String ?? ""
        self.languageCode = Observable(languageCodeStr)
        
        let workingAreaStrArr = dictionary["working_area"] as? [String] ?? [String]()
        self.workingArea = ObservableArray(workingAreaStrArr)
    }
}
