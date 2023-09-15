//
//  PostUserHeaderController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/13.
//

import UIKit

class PostUserHeaderController: BaseViewController {
    let infoView = PostUserHeaderInfoView()
    var updateUserInfoComplete:((FriendUserInfoModel)->())?
    private var userId:Int = 0
    required init(userId:Int) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
        
    }
    
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(infoView)
        infoView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 322)
      
    }
    
    
    func refreshData() {
        FriendService.friendUserInfo(userId).subscribe(onNext:{
            self.infoView.model = $0
            self.updateUserInfoComplete?($0)
        },onError: { e in
            self.infoView.hideSkeleton()
        }).disposed(by: rx.disposeBag)
    }

    

}
