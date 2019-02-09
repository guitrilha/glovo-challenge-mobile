//
//  GlovoApi.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import ReactiveKit
import ReactiveAlamofire
import Alamofire
import ReactiveAlamofire
import Bond
class GlovoApi : GlovoApiProtocol {
    
    private static let SERVER_IP = "localhost"
    private static let SERVER_PORT = "3000"
    private let BASE_URL = "http://\(SERVER_IP):\(SERVER_PORT)/api"
    private let GET_COUNTRIES_ENDPOINT = "/countries/"
    private let GET_CITIES_ENDPOINT = "/cities/"
    private let GET_CITY_INFO_ENDPOINT = "/cities/"
    
    
    func getCountries() -> SafeSignal<GetCountriesResponse>{
        let URL = BASE_URL+GET_COUNTRIES_ENDPOINT
        return Alamofire.request(URL)
            .toJSONSignal()
            .flatMapError { error in
                return SafeSignal.just(["error" : error.localizedDescription])
            }.map { [unowned self] json in
                return self.parseCountries(json: json)
        }
    }
    
    private func parseCountries(json: Any?) -> GetCountriesResponse {
        if let errorDescr = containsRequestError(json: json){
            return .Failure(LoadingError(errorMessage: errorDescr))
        }
        guard let jsonArray = json as? [[String: Any]] else {
            return .Failure(LoadingError(errorMessage: "Error"))
        }
        var countries = [Country]()
        countries = jsonArray.compactMap{ return Country($0)}
        return .Success(countries: countries)
    }
    
    
    func getCities() -> SafeSignal<GetCitiesResponse>{
        let URL = BASE_URL+GET_CITIES_ENDPOINT
        
        return Alamofire.request(URL)
            .toJSONSignal()
            .flatMapError { error in
                return SafeSignal.just(["error" : error.localizedDescription])
            }.map { [unowned self] json in
                return self.parseCities(json: json)
        }
    }
    
    private func parseCities(json: Any?) -> GetCitiesResponse {
        if let errorDescr = containsRequestError(json: json){
            return .Failure(LoadingError(errorMessage: errorDescr))
        }
        guard let jsonArray = json as? [[String: Any]] else {
            return .Failure(LoadingError(errorMessage: "Error"))
        }
        var cities = [City]()
        cities = jsonArray.compactMap{ return City($0)}
        return .Success(cities: cities)
    }
    
    func getCityInfo(cityCode: String) -> SafeSignal<GetCityInfoResponse>{
        let URL = BASE_URL+GET_CITY_INFO_ENDPOINT+"\(cityCode)"
        return Alamofire.request(URL)
            .toJSONSignal()
            .flatMapError { error in
                return SafeSignal.just(["error" : error.localizedDescription])
            }.map { [unowned self] json in
                return self.parseCityinfo(json: json)
        }
    
    }
    
    private func parseCityinfo(json: Any?) -> GetCityInfoResponse {
        if let errorDescr = containsRequestError(json: json){
            return .Failure(LoadingError(errorMessage: errorDescr))
        }
        guard let jsonObject = json as? [String: Any] else {
           return .Failure(LoadingError(errorMessage: "UnexpectedError"))
        }
        return .Success(city: City(jsonObject))
    }
    
    private func containsRequestError(json: Any?) -> String?{
        guard let jsonError = json as? [String: Any] else {
            return nil
        }
        if let error = jsonError["error"] as? String? ?? nil {
            return error
        }
        return nil
    }
}
