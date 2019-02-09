//
//  MainViewModel.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import ReactiveKit
import CoreLocation
import Bond

class MainViewPresenter {
    
    private let disposeBag = DisposeBag()
    let mapUtils = MapUtils()
    var glovoAPI : GlovoApiProtocol
    
    var currentCity : Observable<City> = Observable(City())
    var cities = MutableObservableArray<City>()
    var isInWorkingArea = Observable(Bool(false))
    
    init() {
        self.glovoAPI = GlovoApi()
    }
    
    func updateCity(city: City){
            self.currentCity.value = city
    }
    
    func updateIsInCityWorkingArea(_ bool: Bool){
        self.isInWorkingArea.value = bool
    }
    
    func isUserLocatedInWorkingArea(location: CLLocation?) -> Bool {
        if let currentLocation = location {
            return self.isInCityBounds(cordinate: currentLocation.coordinate) != nil
        }
        return false
    }
    
    func isInCityBounds(cordinate : CLLocationCoordinate2D) -> City?{
        let cityOp = mapUtils.isCoordinateLocatedInAnyCity(coordinate: cordinate, cities: cities.array)
        guard let city = cityOp else {
            return nil
        }
        return city
    }
    
    func fetchAllCities(eventToNotify: PublishSubject<[City], NoError>){
        glovoAPI.getCities().observeNext(with: { [weak self] response in
            switch response {
            case .Failure(let error):
                print(error.message)
            case .Success(let cities):
                self?.cities.removeAll()
                self?.cities.insert(contentsOf: cities, at: 0)
                eventToNotify.next(cities)
            }
        }).dispose(in: disposeBag)
    }
    
    func fetchCityInfo(city: City, eventToNotify: PublishSubject<City, LoadingError>) {
        glovoAPI.getCityInfo(cityCode: city.code.value).observeNext(with: { [weak self] response in
            switch response {
            case .Failure(let error):
                print(error.message)
                eventToNotify.next(city)
            case .Success(let city):
                eventToNotify.next(city)
            }
        }).dispose(in: disposeBag)
    }
    
    
    func getCityBy(code: String?) -> City? {
        guard let cityCode = code else {
            return nil
        }
        for index in 0..<cities.array.count {
            if cities[index].code.value.elementsEqual(cityCode) {
                return cities.array[index]
            }
        }
        return nil
    }
}
