//
//  MainView.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import GoogleMaps
import ReactiveKit

class MainView: UIView {
    
    let mapUtils = MapUtils()
    var mainViewPresenter: MainViewPresenter?
    
    let containerViewBGColor = UIColor.white
    let zoomForMarkers : Float = 9
    var lastZoom : Float = 9
    
    var viewContainer: UIView!
    var viewMapContainer: UIView!
    var viewCityInfoContainer: UIView!
    var viewLabelsContainer: UIView!
    var viewOutOfWorkingAreaContainer: UIView!
    var loadingView: UIActivityIndicatorView!
    
    //CityInfoContainer
    var labelCityName: UILabel!
    var labelCitycode: UILabel!
    var labelCurrency: UILabel!
    var labelCountryCode: UILabel!
    var labelTimeZone: UILabel!
    var labelLanguageCode: UILabel!
    var labelEnabled: UILabel!
    var labelBusy: UILabel!
    
    //MapContainer
    var mapDelegate: GMSMapViewDelegate!
    var viewMap: GMSMapView!
    
     var buttonTapHandler: (() -> Void)!
    
    init(mapDelegate : GMSMapViewDelegate, presenter: MainViewPresenter?, buttonTapHandler: @escaping ()  -> Void) {
        super.init(frame: CGRect.zero)
        self.mapDelegate = mapDelegate
        self.mainViewPresenter = presenter
        self.buttonTapHandler = buttonTapHandler
        
        setupContainerView()
        setupMapContainer()
        setupInfoContainer()
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupContainerView() {
        viewContainer = UIView()
        viewContainer.backgroundColor = containerViewBGColor
        viewContainer.clipsToBounds = true
        self.addSubview(viewContainer)
        viewContainer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func setupMapContainer(){
        viewMapContainer = UIView()
        viewContainer.addSubview(viewMapContainer)
        viewMapContainer.snp.makeConstraints{ (make) in
            make.top.left.right.equalTo(viewContainer)
            make.height.equalTo(viewContainer).multipliedBy(0.7)
        }
        setupMapView()
    }
    
    func setupMapView(){
        let camera = GMSCameraPosition.camera(withLatitude: 0.00, longitude: 0.00, zoom: 1)
        viewMap = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        viewMapContainer.addSubview(viewMap)
        viewMap.snp.makeConstraints{ (make) in
            make.edges.equalTo(viewMapContainer)
        }
        viewMap.delegate = mapDelegate
    }
    
    
    func setupInfoContainer(){
        viewCityInfoContainer = UIView()
        viewContainer.addSubview(viewCityInfoContainer)
        viewCityInfoContainer.snp.makeConstraints{ (make) in
            make.left.equalTo(viewContainer).offset(40)
            make.right.equalTo(viewContainer).offset(-40)
            make.top.equalTo(viewMapContainer.snp.bottom).offset(8)
            make.bottom.equalTo(viewContainer.snp.bottom).offset(-8)
        }
        setupCityInfoLabelsContainer()
        setupOutOfWorkingAreaContainer()
    }
    
    
    func setupCityInfoLabelsContainer(){
        viewLabelsContainer = UIView()
        viewCityInfoContainer.addSubview(viewLabelsContainer)
        viewLabelsContainer.snp.makeConstraints{ (make) in
            make.edges.equalToSuperview()
        }
        
        let viewLabelsLeftContainer = UIStackView()
        viewLabelsLeftContainer.translatesAutoresizingMaskIntoConstraints = false
        viewLabelsLeftContainer.spacing = 2
        viewLabelsLeftContainer.axis = .vertical
        
        viewLabelsContainer.addSubview(viewLabelsLeftContainer)
        
        viewLabelsLeftContainer.snp.makeConstraints { (make) in
            make.top.left.equalTo(viewCityInfoContainer)
            make.width.equalToSuperview().multipliedBy(0.5)
            }
        
        labelCityName = UILabel()
        viewLabelsLeftContainer.addArrangedSubview(labelCityName)
        labelCityName.textColor = UIColor.black

        labelCitycode = UILabel()
        viewLabelsLeftContainer.addArrangedSubview(labelCitycode)
        labelCitycode.textColor = UIColor.black
        
        labelCountryCode = UILabel()
        viewLabelsLeftContainer.addArrangedSubview(labelCountryCode)
        labelCountryCode.textColor = UIColor.black
    
        labelCurrency = UILabel()
        viewLabelsLeftContainer.addArrangedSubview(labelCurrency)
        labelCurrency.textColor = UIColor.black
    
        let viewLabelsRightContainer = UIStackView()
        viewLabelsRightContainer.translatesAutoresizingMaskIntoConstraints = false
        viewLabelsRightContainer.spacing = 2
        viewLabelsRightContainer.axis = .vertical
        
        viewLabelsContainer.addSubview(viewLabelsRightContainer)
        
        viewLabelsRightContainer.snp.makeConstraints { (make) in
            make.top.right.equalTo(viewCityInfoContainer)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.left.equalTo(viewLabelsLeftContainer.snp.right)
        }

        labelEnabled = UILabel()
        viewLabelsRightContainer.addArrangedSubview(labelEnabled)
        labelEnabled.textColor = UIColor.black
       
        labelTimeZone = UILabel()
        viewLabelsRightContainer.addArrangedSubview(labelTimeZone)
        labelTimeZone.textColor = UIColor.black

        labelLanguageCode = UILabel()
        viewLabelsRightContainer.addArrangedSubview(labelLanguageCode)
        labelLanguageCode.textColor = UIColor.black

        labelBusy = UILabel()
        viewLabelsRightContainer.addArrangedSubview(labelBusy)
        labelBusy.textColor = UIColor.black
    }
    

    
    func setupOutOfWorkingAreaContainer(){
        viewOutOfWorkingAreaContainer = UIView()
        viewCityInfoContainer.addSubview(viewOutOfWorkingAreaContainer)

        viewOutOfWorkingAreaContainer.snp.makeConstraints{ (make) in
            make.edges.equalToSuperview()
        }
        
        let labelOutOfBounds = UILabel()
        labelOutOfBounds.textColor = UIColor.black
        labelOutOfBounds.text = "Located out of working area"
        viewOutOfWorkingAreaContainer.addSubview(labelOutOfBounds)
        labelOutOfBounds.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalTo(viewOutOfWorkingAreaContainer)
        }

        let outOfBoundsButton = UIButton()
        outOfBoundsButton.setTitle("Select City", for: .normal)
        outOfBoundsButton.backgroundColor = UIColor.gray
        outOfBoundsButton.setTitleColor(UIColor.black, for: .normal)
        outOfBoundsButton.reactive.tap.observe { with in
            self.buttonTapHandler()
        }
        
        viewOutOfWorkingAreaContainer.addSubview(outOfBoundsButton)
        outOfBoundsButton.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(60)
            make.top.equalTo(labelOutOfBounds.snp.bottom).offset(15)
            make.centerX.equalTo(viewOutOfWorkingAreaContainer)
        }
    }
    
    func bindViewModel() {
        mainViewPresenter?.currentCity.map{ $0.name.value}.bind(to: labelCityName)
        mainViewPresenter?.currentCity.map{ $0.code.value}.bind(to: labelCitycode)
        mainViewPresenter?.currentCity.map{ $0.countryCode.value}.bind(to: labelCountryCode)
        mainViewPresenter?.currentCity.map{ $0.currency.value}.bind(to: labelCurrency)
        mainViewPresenter?.currentCity.map{ let isEnabled = $0.enabled.value ?? false
                            return isEnabled ? "Enabled" : "Not Enabled"
                            }.bind(to: labelEnabled)
        mainViewPresenter?.currentCity.map{ $0.timeZone.value}.bind(to: labelTimeZone)
        mainViewPresenter?.currentCity.map{ $0.languageCode.value}.bind(to: labelLanguageCode)
        mainViewPresenter?.currentCity.map{ let isBusy = $0.busy.value ?? false
                            return isBusy ? "Busy" : "Not Busy"
                            }.bind(to: labelBusy)
        
        mainViewPresenter?.isInWorkingArea.bind(to: viewOutOfWorkingAreaContainer.reactive.isHidden)
        mainViewPresenter?.isInWorkingArea.map{!$0}.bind(to: viewLabelsContainer.reactive.isHidden)
        
    }
    
    func addCitiesToMap(cities: [City]){
        if lastZoom > zoomForMarkers {
            showAllCitiesWorkingAreaOnMap(cities: cities)
        } else {
            showAllCitiesMarkersOnMap(cities: cities)
        }
    }
    
    func showAllCitiesWorkingAreaOnMap(cities: [City]?) {
        viewMap.clear()
        cities?.forEach{ city in
            self.drawCityWorkingAreaInMap(workingArea: city.workingArea.array, cityCode: city.code.value)
        }
    }
    
    func showAllCitiesMarkersOnMap(cities: [City]?) {
        viewMap.clear()
        cities?.forEach{ city in
            self.showCityMarker(city: city)
        }
    }
    
    func drawCityWorkingAreaInMap(workingArea : [String], cityCode: String){
        let workingAreaPaths = mapUtils.getWorkingAreaPaths(workingArea: workingArea)
        workingAreaPaths.forEach{ workingAreaPath in
            mapUtils.drawPolygonBy(map: viewMap, path: workingAreaPath)
            }
    }
    
    func showCityMarker(city: City) {
        let workingAreaWithValidAreas = self.filterEmptyWorkingAreas(workingAreas: city.workingArea.array)
        guard let markerCoordinate = mapUtils.getCityMarkerPosition(workingArea: workingAreaWithValidAreas) else {
            return
        }
        mapUtils.drawMarker(map: viewMap, coordinate: markerCoordinate, title: city.name.value, userData: city.code.value)
    }
    
    func filterEmptyWorkingAreas(workingAreas: [String]) -> [String] {
        return workingAreas.filter { workingArea -> Bool in
            return !workingArea.isEmpty
        }
    }
    
    func updateMapBy(zoom: Float, citiesToShow : [City]?){
        if zoom == lastZoom {
            return
        }
        guard let cities = citiesToShow else {
            viewMap.clear()
            lastZoom = zoom
            return
        }
        if cities.isEmpty {
            viewMap.clear()
            lastZoom = zoom
            return
        }
        
        if self.isToShowWorkingAreas(zoom: zoom, actualZoom: lastZoom,zoomForMarkers: zoomForMarkers){
            showAllCitiesWorkingAreaOnMap(cities: cities)
        } else if isToShowMarkers(zoom: zoom, actualZoom: lastZoom, zoomForMarkers: zoomForMarkers) {
            showAllCitiesMarkersOnMap(cities: cities)
        }
        lastZoom = zoom
    }
    
    func isToShowWorkingAreas(zoom: Float, actualZoom: Float, zoomForMarkers: Float) -> Bool {
        return actualZoom <= zoomForMarkers && zoom > zoomForMarkers
    }
    
    func isToShowMarkers(zoom: Float, actualZoom: Float, zoomForMarkers: Float) -> Bool {
        return actualZoom >= zoomForMarkers && zoom < zoomForMarkers
    }
    
    func fitCityInMap(city: City){
        let cityWorkingPaths = mapUtils.getWorkingAreaPaths(workingArea: city.workingArea.array)
        self.fitAllPathsInMap(paths: cityWorkingPaths)
    }
    
    func fitAllPathsInMap(paths: [GMSPath]) {
        let bounds = mapUtils.getBoundsForPaths(paths: paths)
        viewMap.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func animateCameraTo(cordinate: CLLocationCoordinate2D, zoom: Float ){
        viewMap.animate(toLocation: cordinate)
        viewMap.animate(toZoom: zoom)
    }
}
