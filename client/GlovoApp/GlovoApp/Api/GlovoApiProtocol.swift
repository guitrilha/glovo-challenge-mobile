//
//  GlovoApiProtocol.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//
import ReactiveKit

protocol GlovoApiProtocol {
    func getCountries() -> SafeSignal<GetCountriesResponse>
    func getCities() -> SafeSignal<GetCitiesResponse>
    func getCityInfo(cityCode: String) -> SafeSignal<GetCityInfoResponse>
}
