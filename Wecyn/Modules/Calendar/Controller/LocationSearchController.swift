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

    var searchView = NavbarSearchView()
    var datas:[LocationModel] = []
    var selectLocationComplete:((String)->())?
    var selectLocation: BehaviorRelay = BehaviorRelay<LocationModel?>(value: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton()
        doneButton.textColor(.black)
        let doneItem = UIBarButtonItem(customView: doneButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 16)
        
        self.navigation.item.rightBarButtonItems = [doneItem,fixItem]
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.selectLocationComplete?(self.selectLocation.value?.title ?? "")
            self.returnBack()
        }).disposed(by: rx.disposeBag)
        
        selectLocation.map({ $0 != nil }).subscribe(onNext:{ $0 ? (doneButton.titleForNormal = "Done") : (doneButton.titleForNormal = "Cancel") }).disposed(by: rx.disposeBag)
        
        searchView = NavbarSearchView(placeholder: "Search Location",
                                      isSearchable: true,
                                      isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.datas.removeAll()

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = keyword
            request.resultTypes = .address
            let localSearch = MKLocalSearch(request: request)
            localSearch.start { response, e in
                if e == nil {
                    if !localSearch.isSearching {
                        self.datas = response?.mapItems.map({ mapItem in
                            /*
                             (lldb) po mapItem.placemark.thoroughfare
                             ▿ Optional<String>
                               - some : "银湖北路80号(天柱山路地铁站1号口步行340米)"

                             (lldb) po mapItem.placemark.locality
                             ▿ Optional<String>
                               - some : "芜湖市"

                             (lldb) po mapItem.placemark.subLocality
                             ▿ Optional<String>
                               - some : "镜湖区"

                             (lldb) po mapItem.placemark.administrativeArea
                             ▿ Optional<String>
                               - some : "安徽省"
                             */
                            let detail = (mapItem.placemark.administrativeArea ?? "") + (mapItem.placemark.locality ?? "") + (mapItem.placemark.subLocality ?? "") + (mapItem.placemark.thoroughfare ?? "")
                            let model = LocationModel(title: (mapItem.placemark.locality ?? "") + (mapItem.placemark.name ?? ""), detail: detail)
                            return model
                        }) ?? []
                        self.tableView?.reloadData()
                        self.searchView.endSearching()
                    }
                }
            }

        }
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
        tableView?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: kTabBarHeight, right: 0)
        
        tableView?.rowHeight = 62
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
        titleLabel.textColor = R.color.textColor162C46()
        
        
        detailLabel.font = UIFont.sk.pingFangRegular(12)
        detailLabel.textColor = R.color.textColor74()
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
