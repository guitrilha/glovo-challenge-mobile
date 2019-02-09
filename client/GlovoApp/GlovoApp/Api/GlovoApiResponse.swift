//
//  GlovoApiResponse.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

enum GetCountriesResponse {
    case Success(countries: [Country])
    case Failure(LoadingError)
}

enum GetCitiesResponse {
    case Success(cities: [City])
    case Failure(LoadingError)
}

enum GetCityInfoResponse {
    case Success(city: City)
    case Failure(LoadingError)
}

class LoadingError: Error{
    var message = ""
    
    init(errorMessage: String) {
        self.message = errorMessage
    }
}
