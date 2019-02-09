//
//  MapUtils.swift
//  GlovoApp
//
//  Created by Gui on 07/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import GoogleMaps
class MapUtils{
    
    func isCoordinateLocatedInAnyCity(coordinate: CLLocationCoordinate2D, cities: [City]) -> City?{
        let citiesBounds = cities.map { city -> GMSCoordinateBounds in
            return getCityBounds(city: city)
        }
        if cities.count > 0{
            for index in 0..<citiesBounds.count {
                if citiesBounds[index].contains(coordinate){
                    return cities[index]
                }
            }
        }
        return nil
    }
    
    func getCityMarkerPosition(workingArea: [String]) -> CLLocationCoordinate2D? {
        guard let pathStart = self.getWorkingAreaPaths(workingArea: workingArea).first else {
            return nil
        }
        return pathStart.coordinate(at: 0)
    }
    
    func getCityBounds(city: City) -> GMSCoordinateBounds {
        let cityPaths = getWorkingAreaPaths(workingArea: city.workingArea.array)
        return getBoundsForPaths(paths: cityPaths)
    }
    
    func getBoundsForPaths(paths: [GMSPath]) -> GMSCoordinateBounds {
        var bounds = GMSCoordinateBounds()
        paths.forEach{ path in
            if path.count() > 0{
                for index in 0..<path.count() {
                    bounds = bounds.includingCoordinate(path.coordinate(at: index))
                }
            }
        }
        return bounds
    }
    
    func getCameraBounds(map: GMSMapView) -> GMSCoordinateBounds {
        let projection = map.projection.visibleRegion()
        var cameraBounds = GMSCoordinateBounds()
        cameraBounds = cameraBounds.includingCoordinate(projection.farLeft)
        cameraBounds = cameraBounds.includingCoordinate(projection.farRight)
        cameraBounds = cameraBounds.includingCoordinate(projection.nearLeft)
        cameraBounds = cameraBounds.includingCoordinate(projection.nearRight)
        return cameraBounds
    }
    
    func getWorkingAreaPaths(workingArea: [String]) -> [GMSPath]{
        return workingArea.compactMap{ workingAreaPath in
            guard let path =  self.createPathBy(encodedPath: workingAreaPath) else {
                return nil
            }
            return path
        }
    }
    
    func createPathBy(encodedPath: String) -> GMSPath? {
        let encodedAux = encodedPath.replacingOccurrences(of: "\\", with: "\"")
        guard let path = GMSPath(fromEncodedPath: encodedAux) else {
            return nil
        }
        return path
    }
    
    func drawPolygonBy(map: GMSMapView, path: GMSPath){
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 0.4);
        polygon.map = map
    }
    
    func drawMarker(map: GMSMapView, coordinate: CLLocationCoordinate2D, title: String, userData: String){
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = title
        marker.userData = userData
        marker.isTappable = true
        marker.map = map
    }
}
