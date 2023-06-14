//
//  CountryListController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/14.
//

import UIKit
import RxRelay

class CountryListController: BaseTableController {

    enum DataType {
        case Country
        case City
    }
    var selectedCountry:BehaviorRelay<CountryModel?> = BehaviorRelay(value: nil)
    var selectedCity:BehaviorRelay<CityModel?> = BehaviorRelay(value: nil)
        
    var group:[String] = []

    var dataType: DataType = .Country
    var countryID:Int? = nil
    
    init(dataType:DataType,countryID:Int? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dataType = dataType
        self.countryID = countryID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch dataType {
        case .Country:
            getCountryList()
        case .City:
            getCityList()
        }
    
        
        let cancelButton = UIButton()
        cancelButton.textColor(.blue)
        cancelButton.titleForNormal = "Cancel"
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        cancelButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        let doneButton = UIButton()
        doneButton.textColor(.blue)
        doneButton.titleForNormal = "Done"
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        
        let isCountrySelected = selectedCountry.map({ $0 != nil })
        let isCitySelected = selectedCity.map({ $0 != nil })
        let isSelected = Observable.combineLatest(isCountrySelected,isCitySelected).map({ $0.0 || $0.1 })
        isSelected.asDriver(onErrorJustReturn: false).drive(doneButton.rx.isEnabled).disposed(by: rx.disposeBag)
        isSelected.subscribe(onNext:{
            if $0 {
                doneButton.textColor(.blue)
            }else {
                doneButton.textColor(R.color.textColor52()!)
            }
        }).disposed(by: rx.disposeBag)
         
    }
    
    func getCountryList() {
        self.navigation.item.title = "Select Country"
        RegistService.getAllCountry().subscribe(onNext:{ countrys in
            self.dataArray = countrys.sorted(by: { ($0.country_name.first ?? Character("")) < ($1.country_name.first  ?? Character("")) })
            self.endRefresh(countrys.count)
        }).disposed(by: self.rx.disposeBag)
    }
    
    func getCityList() {
        self.navigation.item.title = "Select City"
        guard let countryID = countryID else { return }
        RegistService.getAllCity(by: countryID).subscribe(onNext:{ citys in
            self.dataArray = citys.sorted(by: { ($0.city_name.first ?? Character("")) < ($1.city_name.first  ?? Character("")) })
            self.endRefresh(citys.count)
        }).disposed(by: self.rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.register(cellWithClass: UITableViewCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        if self.dataArray.count > 0 {
            switch dataType {
            case .City:
                let model = self.dataArray[indexPath.row] as! CityModel
                cell.textLabel?.text = model.city_name
                cell.accessoryType = model.isSelected ? .checkmark : .none
            case .Country:
                let model = self.dataArray[indexPath.row] as! CountryModel
                cell.textLabel?.text = model.country_name
                cell.accessoryType = model.isSelected ? .checkmark : .none
            }
           
            
        }
        return cell
    }

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard self.dataArray.count > 0 else { return }
        switch dataType {
        case .Country:
            updateCountrySelectStaus(indexPath: indexPath)
        case .City:
            updateCitySelectStaus(indexPath: indexPath)
        }
      
        self.tableView?.reloadData()
    }
    
    func updateCountrySelectStaus(indexPath: IndexPath) {
        if let lastSelectedModel = selectedCountry.value {
            lastSelectedModel.isSelected.toggle()
        }
        let model = self.dataArray[indexPath.row] as! CountryModel
        model.isSelected.toggle()
        if model.isSelected {
            selectedCountry.accept(model)
        }else {
            selectedCountry.accept(nil)
        }
    }
    
    func updateCitySelectStaus(indexPath: IndexPath) {
        if let lastSelectedModel = selectedCity.value {
            lastSelectedModel.isSelected.toggle()
        }
        let model = self.dataArray[indexPath.row] as! CityModel
        model.isSelected.toggle()
        if model.isSelected {
            selectedCity.accept(model)
        }else {
            selectedCity.accept(nil)
        }
    }

}
