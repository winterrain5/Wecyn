//
//  LocationSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/28.
//

import UIKit
import MapKit

class LocationModel {
    var title:String
    var detail:String
    var isSelect: Bool = false
    init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }
}
class LocationSearchController: BaseTableController {

    var searchView:NavbarSearchView!
    var datas:[LocationModel] = []
    var selectLocationComplete:((LocationModel)->())?
    var selectLocation: BehaviorRelay = BehaviorRelay<LocationModel?>(value: nil)
    var editLocation:LocationModel?
    required init(editLocation:LocationModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.editLocation = editLocation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton()
        doneButton.imageForNormal = R.image.checkmark()
        let doneItem = UIBarButtonItem(customView: doneButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 16)
        
        self.navigation.item.rightBarButtonItems = [doneItem,fixItem]
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            if let loc = self.selectLocation.value {
                self.selectLocationComplete?(loc)
            }
        
            self.returnBack()
        }).disposed(by: rx.disposeBag)
        
        selectLocation.map({ $0 != nil }).subscribe(onNext:{ doneButton.isEnabled = $0 }).disposed(by: rx.disposeBag)
        
        searchView = NavbarSearchView(placeholder: "Search Location",
                                      isSearchable: true,
                                      isBecomeFirstResponder: true)
        searchView.frame = CGRect(x: 16, y: kNavBarHeight, width: kScreenWidth - 32, height: 36)
        view.addSubview(searchView)
        searchView.searchText = editLocation?.title
        searchView.searchTextChanged = {  [weak self] in
            guard let `self` = self else { return }
            if $0.isEmpty {
                self.datas.removeAll()
                self.tableView?.reloadData()
                return
            }
            let first = LocationModel(title: $0, detail: "")
            if self.datas.count  > 0 {
                self.datas[0] = first
            } else {
                self.datas.append(first)
            }
            self.tableView?.reloadData()
        }
        
        searchView.beginSearch = { [weak self] in
            self?.datas.removeAll()
            self?.tableView?.reloadData()
        }
        
        
        func requstLocation(text:String) {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.resultTypes = .address
            let mls = MKLocalSearch(request: request)
          
            mls.start { response, e in
                if e != nil {
                    Toast.showError(e?.localizedDescription ?? "")
                    return
                }
                
                if !mls.isSearching {
                    self.datas.append(contentsOf: response?.mapItems.map({ mapItem in
                        let detail = (mapItem.placemark.administrativeArea ?? "") + (mapItem.placemark.locality ?? "") + (mapItem.placemark.subLocality ?? "") + (mapItem.placemark.thoroughfare ?? "")
                        let title =  (mapItem.placemark.locality ?? "") + (mapItem.placemark.name ?? "")
                        let model = LocationModel(title: title, detail: detail)
                        return model
                    }) ?? [])
                    self.tableView?.reloadData()
                    self.searchView.endSearching()
                }
            }
        }
        
        searchView.searching = {  [weak self] text in
            guard let `self` = self else { return }
            self.datas.removeAll()

            requstLocation(text:text)
            
        }
        
    
        self.navigation.item.title = "Location"
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
            
        }
    }
    
    
    
 
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.searchView.endSearching()
    }
    override func createListView() {
        super.createListView()
        
        tableView?.backgroundColor = .white
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        
        tableView?.register(cellWithClass: LocationItemCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kTabBarHeight, right: 0)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.datas.count > 0 {
            if self.datas[indexPath.row].detail.isEmpty {
                return 44
            } else {
                return 62
            }
        }
        return 0
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight + 36, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 36)
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: LocationItemCell.self)
        cell.titleLabel.text = datas[indexPath.row].title
        cell.detailLabel.text = datas[indexPath.row].detail
        cell.accessoryType = datas[indexPath.row].isSelect ? .checkmark : .none
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Haptico.selection()
        let model = datas[indexPath.row]
        if model.isSelect {
            model.isSelect = false
        } else {
            datas.forEach({ $0.isSelect = false })
            model.isSelect.toggle()
        }
        
        self.reloadData()
        
        self.selectLocation.accept(datas.filter({ $0.isSelect }).first)
    }
  
}



class LocationItemCell: UITableViewCell {
    let imgView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
        imgView.contentMode = .scaleAspectFit
        imgView.image = R.image.mappinAndEllipse()
        
        
        titleLabel.font = UIFont.sk.pingFangRegular(15)
        titleLabel.textColor = R.color.textColor22()
        
        
        detailLabel.font = UIFont.sk.pingFangRegular(12)
        detailLabel.textColor = R.color.textColor77()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.left.equalTo(imgView.snp.right).offset(8)
            make.top.equalToSuperview().offset(9)
            make.height.equalTo(18)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.greaterThanOrEqualToSuperview().offset(-8)
        }
    }
}
