//
//  TimeZoneController.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/10.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
class TimeZoneController: BaseTableController {

    var searchView:NavbarSearchView!
    var datas:[TimeZoneItemModel] = []
    var selectedTimezoneComplete:((TimeZoneItemModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView = NavbarSearchView(placeholder: "Search By Name",isSearchable: true,isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        
        searchView.searchTextChanged = { [weak self] keyword in
            guard let `self` = self else { return }
            if keyword.isEmpty {
                self.datas.removeAll()
                self.refreshData()
                return
            }
            self.datas = self.datas.filter({ $0.text.lowercased().contains(keyword.lowercased()) })
            self.reloadData()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            self.datas.removeAll()
            self.refreshData()
        }
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        refreshData()
    }
    
    override func refreshData() {
        
        
        let knownTimeZoneIdentifiers = TimeZone.knownTimeZoneIdentifiers
        for tz in TimeZone.knownTimeZoneIdentifiers {
            let timeZone = TimeZone(identifier: tz)
            if let abbreviation = timeZone?.abbreviation(), let seconds = timeZone?.secondsFromGMT() {
                print ("timeZone: \(tz) \nabbreviation: \(abbreviation)\nsecondsFromGMT: \(seconds)\n")
                let item = TimeZoneItemModel()
                let offset = seconds / 3600
                if offset >= 0 {
                    item.text = "(UTC+\(offset):00)" +  " " + tz
                } else {
                    item.text = "(UTC\(offset):00)" +  " " + tz
                }
                item.identifier = tz
                item.offset = offset
                datas.append(item)
            }
        }
        datas = datas.sorted(by: \.offset)
        self.reloadData()
        
     
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight-kNavBarHeight)
    }
    
    override func createListView() {

        super.createListView()
        
        addSingleSeparator()
        tableView?.register(cellWithClass: UITableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        if datas.count > 0 {
            cell.textLabel?.text = datas[indexPath.row].text
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datas.count > 0 {
            
            self.dismiss(animated: true) { [weak self] in
                guard let `self` = self else { return }
                self.selectedTimezoneComplete?(self.datas[indexPath.row])
            }
            
        }
    }
    
}




class TimeZoneItemModel: BaseModel  {
    var text: String = ""
    var identifier: String = ""
    var offset: Int = 0
}
