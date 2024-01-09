//
//  AdminStaffExpsController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffExpsController: BaseTableController {

    
    required init(datas:[AdminStaffExps]) {
        super.init(nibName: nil, bundle: nil)
        self.dataArray = datas
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Experience"
        
        self.endRefresh(self.dataArray.count,emptyString: "No Experience")
       
    }

    
    override func createListView() {
        super.createListView()
        
        
        
        tableView?.register(nibWithCellClass: AdminStaffExpsCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 120
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AdminStaffExpsCell.self)
        
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? AdminStaffExps
        }
   
        return cell
        
    }

}
