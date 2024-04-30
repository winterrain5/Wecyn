//
//  CountryListController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/14.
//

import UIKit
import RxRelay
import IQKeyboardManagerSwift
class CountryListController: BaseTableController {

    enum DataType {
        case Country
        case City
    }
    var selectedCountry:BehaviorRelay<CountryModel?> = BehaviorRelay(value: nil)
    var selectedCity:BehaviorRelay<CityModel?> = BehaviorRelay(value: nil)

    var searchResult:[Any] = []
    var group:[String] = []

    var dataType: DataType = .Country
    var countryID:Int? = nil
    let searchView = NavbarSearchView(placeholder: "Search Name",isSearchable: true,isBecomeFirstResponder: false).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.6, height: 36))
    init(dataType:DataType,countryID:Int? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dataType = dataType
        self.countryID = countryID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    var keyword:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.searchView.startLoading()
            if self.dataType == .City {
                self.searchResult = (self.dataArray as! [CityModel]).filter({ $0.city_name.lowercased().contains(keyword.trimmed.lowercased())})
            } else {
                self.searchResult = (self.dataArray as! [CountryModel]).filter({ $0.country_name.lowercased().contains(keyword.trimmed.lowercased())})
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchView.stoploading()
            }
            
            self.reloadData()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            self.searchResult = []
            self.reloadData()
        }

        switch dataType {
        case .Country:
            getCountryList()
        case .City:
            getCityList()
        }
    
        
        addLeftBarButtonItem()
        leftButtonDidClick = { [weak self] in
            self?.dismiss(animated: true)
        }

        
        let doneButton = UIButton()
        doneButton.textColor(.black)
        doneButton.titleForNormal = "Cancel"
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        
        let isCountrySelected = selectedCountry.map({ $0 != nil })
        let isCitySelected = selectedCity.map({ $0 != nil })
        let isSelected = Observable.combineLatest(isCountrySelected,isCitySelected).map({ $0.0 || $0.1 })

        isSelected.subscribe(onNext:{
            if $0 {
                doneButton.titleForNormal = "Done"
            }else {
                doneButton.titleForNormal = "Cancel"
            }
        }).disposed(by: rx.disposeBag)
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    func getCountryList() {
        self.navigation.item.title = "Select Country"
        AuthService.getAllCountry().subscribe(onNext:{ countrys in
            self.dataArray = countrys.sorted(by: { ($0.country_name.first ?? Character("")) < ($1.country_name.first  ?? Character("")) })
            self.endRefresh(countrys.count)
        }).disposed(by: self.rx.disposeBag)
    }
    
    func getCityList() {
        self.navigation.item.title = "Select City"
        guard let countryID = countryID else { return }
        AuthService.getAllCity(by: countryID).subscribe(onNext:{ citys in
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
        return self.searchResult.count == 0 ? self.dataArray.count : self.searchResult.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        var datas:[Any] = []
        if self.searchResult.count > 0 {
            datas = self.searchResult
        } else {
            datas = self.dataArray
        }
        switch dataType {
        case .City:
            let model = datas[indexPath.row] as! CityModel
            cell.textLabel?.text = model.city_name
            cell.accessoryType = model.isSelected ? .checkmark : .none
        case .Country:
            let model = datas[indexPath.row] as! CountryModel
            cell.textLabel?.text = model.country_name
            cell.accessoryType = model.isSelected ? .checkmark : .none
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
