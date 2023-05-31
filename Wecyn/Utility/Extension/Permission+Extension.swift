//
//  Permission+Extension.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/15.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import Permission
extension Reactive where Base: Permission {
    
    /// Reactive wrapper for `Permission` instance.
    public var request: Observable<PermissionStatus> {
        return Observable.create { (observer) in
            self.base.request { observer.onNext($0) }
            return Disposables.create { observer.onCompleted() }
        }
    }
}
