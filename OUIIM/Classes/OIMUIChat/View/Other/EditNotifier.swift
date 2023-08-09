import Foundation
import UIKit

final class EditNotifier {

    private(set) var isEditing = false

    private var delegates = NSHashTable<AnyObject>.weakObjects()

    func add(delegate: EditNotifierDelegate) {
        delegates.add(delegate)
    }

    func setIsEditing(_ isEditing: Bool, duration: ActionDuration) {
        self.isEditing = isEditing
        delegates.allObjects.compactMap { $0 as? EditNotifierDelegate }.forEach { $0.setIsEditing(isEditing, duration: duration) }
    }
    
    
}
