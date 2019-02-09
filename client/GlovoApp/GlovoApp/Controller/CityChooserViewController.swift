//
//  CitySelectionViewController.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import UIKit
import ReactiveKit

class CityChooserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let disposeBag = DisposeBag()
    
    let cityChooserPresenter = CityChooserPresenter()
    var cityChooserView : CityChooserView!
    
    let loadCitiesEvent = PublishSubject<[City], NoError>()
    let loadCountriesEvent = PublishSubject<[Country], NoError>()
    
    var onCitySelectedEvent : PublishSubject<City, NoError>?
    var cities = [City]()
    
    override func viewDidLoad() {
        self.title = "Select a City"
        cityChooserView = CityChooserView(presenter: cityChooserPresenter, tableViewDataSource: self, tableViewDelegate: self )
        fetchCountries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(cityChooserView)
        cityChooserView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.cityChooserPresenter.countries[indexPath.section]
        onCitySelected(country.cities[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let country = self.cityChooserPresenter.countries[section]
        return country.name.value
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let country = self.cityChooserPresenter.countries[indexPath.section]
        cell.textLabel!.text =  country.cities[indexPath.row].name.value
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return self.cityChooserPresenter.countries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let country = self.cityChooserPresenter.countries[section]
        return country.cities.array.count
    }
    
    func onCitySelected(_ city: City){
        onCitySelectedEvent?.next(city)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func fetchCountries() {
        loadCountriesEvent.observeNext { countries in
            if countries.count == 0 {
                self.showError(error: "Can`t load Countries and Cities.")
            }
            if self.cityChooserPresenter.isCitiesLoaded(){
                self.cityChooserPresenter.updateCountriesWith(cities: self.cities)
                self.cityChooserView.reloadData()
            }else{
                self.fetchCities()
            }
        }.dispose(in: disposeBag)
        
        self.cityChooserPresenter.fetchCountries(eventToNotify: loadCountriesEvent)
    }
    
    private func fetchCities() {
        loadCitiesEvent.observeNext { cities in
            if cities.count == 0 {
              self.showError(error: "Can`t load cities.")
            }
            self.cityChooserPresenter.updateCountriesWith(cities: self.cities)
            self.cityChooserView.reloadData()
        }.dispose(in: disposeBag)
        
        self.cityChooserPresenter.fetchCities(eventToNotify: loadCitiesEvent)
    }
    
    private func showError(error: String){
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        let actionOk = UIAlertAction(title: "OK", style: .default,
                                     handler: { action in
                                        alertController.dismiss(animated: true, completion: nil)})
        
        alertController.addAction(actionOk)
    }
    
}
