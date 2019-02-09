//
//  ViewController.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ReactiveKit

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()
     private let disposeBag = DisposeBag()
    
    var mainView: MainView!
    var mainViewPresenter: MainViewPresenter?
    
    let currentUserPositionEvent = PublishSubject<CLLocationCoordinate2D, NoError>()
    let centerMapPositionEvent = PublishSubject<CLLocationCoordinate2D, NoError>()
    let zoomMapEvent = PublishSubject<Float, NoError>()
    let markerTappedEvent = PublishSubject<GMSMarker, NoError>()
    let onCitySelectedEvent = PublishSubject<City, NoError>()
    let loadCityInfoEvent = PublishSubject<City, LoadingError>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Glovo Challenge"
        mainViewPresenter = MainViewPresenter()
        mainView = MainView(mapDelegate: self as GMSMapViewDelegate, presenter: self.mainViewPresenter, buttonTapHandler: self.onSelectCityButtonTapped)
        checkLocationPermission()
        configMapObservers()
        loadAllCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }

    private func checkLocationPermission(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func configMapObservers(){
        currentUserPositionEvent.observeNext { cordinate in
            self.mainView.animateCameraTo(cordinate: cordinate)
        }.dispose(in: disposeBag)
        
        centerMapPositionEvent.observeNext { cordinate in
            guard let city = self.mainViewPresenter?.isInCityBounds(cordinate: cordinate) else {
                self.mainViewPresenter?.updateIsInCityWorkingArea(false)
                return
            }
            self.fetchCityInfo(city: city)
        }.dispose(in: disposeBag)
        
        zoomMapEvent.observeNext { zoom in
            self.mainView.updateMapBy(zoom: zoom, citiesToShow: self.mainViewPresenter?.cities.array)
        }.dispose(in: disposeBag)
        
        markerTappedEvent.observeNext { marker in
            guard let city = self.mainViewPresenter?.getCityBy(code: marker.userData as? String) else {
                return
            }
            self.mainView.fitCityInMap(city: city)
        }.dispose(in: disposeBag)
        
        onCitySelectedEvent.observeNext { city in
            self.mainView.fitCityInMap(city: city)
        }.dispose(in: disposeBag)
    }
 
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            self.onLocationDenied()
        default:
            self.onLocationAuthorized()
        }
    }
    
    private func onLocationAuthorized(){
        updateCurrentLocation()
        isUserInWorkigArea()
    }
    
    private func onLocationDenied(){
        self.showAlertToSelectCityManually(title: "We can`t locate you", error: "Please, select your city manually.")
    }
    
    private func updateCurrentLocation(){
        if let currentLocation = self.locationManager.location {
            currentUserPositionEvent.next(currentLocation.coordinate)
        }
    }
    
    private func isUserInWorkigArea(){
        if let isLocationInWorkingArea = self.mainViewPresenter?.isUserLocatedInWorkingArea(location: self.locationManager.location) {
            if !isLocationInWorkingArea {
                self.showAlertToSelectCityManually(title: "Oops, we are not there yet", error: "Please, select a city where we are already working.")
                
            }
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.updateCurrentLocation()
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        markerTappedEvent.next(marker)
        return true;
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        zoomMapEvent.next(cameraPosition.zoom)
        centerMapPositionEvent.next(cameraPosition.target)
    }

    func onSelectCityButtonTapped(){
        moveToCityChooserViewController()
    }
    
    private func moveToCityChooserViewController(){
        let cityChooserViewController = CityChooserViewController()
        cityChooserViewController.cities = mainViewPresenter?.cities.array ?? [City]()
        cityChooserViewController.onCitySelectedEvent = onCitySelectedEvent
        self.navigationController?.pushViewController(cityChooserViewController, animated: true)
    }
    
    private func loadAllCities(){
        let loadAllCitiesEvent = PublishSubject<[City], NoError>()
        loadAllCitiesEvent.observeNext { cities in
            self.mainView.addCitiesToMap(cities: cities)
        }.dispose(in: disposeBag)
        self.mainViewPresenter?.fetchAllCities(eventToNotify: loadAllCitiesEvent)
    }

    private func fetchCityInfo(city: City) {
        loadCityInfoEvent.observeNext { city in
            self.mainViewPresenter?.updateCity(city: city)
            self.mainViewPresenter?.updateIsInCityWorkingArea(true)
        }.dispose(in: disposeBag)
        self.mainViewPresenter?.fetchCityInfo(city: city, eventToNotify: self.loadCityInfoEvent)
    }
    
    private func showAlertToSelectCityManually(title: String, error: String){
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        let actionOk = UIAlertAction(title: "OK", style: .default,
                                     handler: { action in
                                        alertController.dismiss(animated: true, completion: nil)
                                        self.onSelectCityButtonTapped()})
        
        alertController.addAction(actionOk)
    }
    
}

