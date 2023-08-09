
import RxSwift
import OUICore

class SearchGroupViewController: UIViewController {
    
    var didSelectedItem: ((_ groupID: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let resultC = SearchResultViewController(searchType: .group)
        let searchC: UISearchController = {
            let v = UISearchController(searchResultsController: resultC)
            v.searchResultsUpdater = resultC
            v.searchBar.placeholder = "通过群ID号搜索添加"
            v.obscuresBackgroundDuringPresentation = false
            return v
        }()
        navigationItem.searchController = searchC
        resultC.didSelectedItem = didSelectedItem
    }
}
