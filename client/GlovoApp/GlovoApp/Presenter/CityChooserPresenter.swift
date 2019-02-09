//
//  CityChooserViewModel.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import ReactiveKit
import CoreLocation
import Bond

class CityChooserPresenter {
    
    private let disposeBag = DisposeBag()
    var glovoApi = GlovoApi()
    
    var isLoadingTableView = Observable(Bool(true))
    
    var countries = [Country]()
    
    var cities = [City]()
    
    init() {
        
    }
    
    func updateCountriesWith(cities: [City]){
        self.cities = cities
        
        var citiesAux = cities
        self.countries.forEach { country in
            var countryCities = [City]()
            for (i, city) in citiesAux.enumerated().reversed() {
                if country.code.value.elementsEqual(city.countryCode.value) {
                    countryCities.append(city)
                    citiesAux.remove(at: i)
                }
            }
            country.cities.removeAll()
            country.cities.insert(contentsOf: countryCities, at: 0)
        }
        isLoadingTableView.value = false
    }
    
    func fetchCountries(eventToNotify: PublishSubject<[Country], NoError>){
        glovoApi.getCountries().observeNext(with: { response in
            switch response {
            case .Failure(let error):
                print(error)
                eventToNotify.next([Country]())
            case .Success(let countries):
                self.countries.removeAll()
                self.countries.insert(contentsOf: countries, at: 0)
                eventToNotify.next(countries)
            }
        }).dispose(in: disposeBag)
    }
    
    func fetchCities(eventToNotify: PublishSubject<[City], NoError>) {
        glovoApi.getCities().observeNext(with: { response in
            switch response {
            case .Failure(let error):
                eventToNotify.next([City]())
            case .Success(let cities):
                eventToNotify.next(cities)
            }
        }).dispose(in: disposeBag)
    }
    
    func isCitiesLoaded() -> Bool{
        return cities.count>0
    }
}
