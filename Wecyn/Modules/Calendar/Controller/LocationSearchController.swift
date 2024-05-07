//
//  LocationSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/28.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
/// This struct contains the current location in terms of coordinates and place id
struct CoordinateAndPlaceID {
    private var coord = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    private var pid: String = "ChIJP3Sa8ziYEmsRUKgyFmh9AQM"
    
    /// Updates the coordinates and pid to a new location
    ///
    /// - Parameters:
    ///   - newCoord: The new coordinates.
    ///   - newPid: The PID associated with the new location.
    mutating func updateIdentifier(newCoord: CLLocationCoordinate2D, newPID: String) {
        coord = newCoord
        pid = newPID
    }
    
    /// Getter method for the coordinates
    func getCoord() -> CLLocationCoordinate2D {
        return coord
    }
    
    /// Getter method for the PID
    func getPID() -> String {
        return pid
    }
}

class LocationModel {
    var title:String
    var detail:String
    var lagitude:Double?
    var longitude: Double?
    var pid:String?
    init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }
}
class LocationSearchController: BaseViewController {
    
    var searchView:UIView!
    
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    
    var selectLocationComplete:((LocationModel)->())?
    var editLocation:LocationModel?
    
    private var camera: GMSCameraPosition!
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    private var marker: GMSMarker = GMSMarker()
    var preciseLocationZoomLevel: Float = 18.0
    var approximateLocationZoomLevel: Float = 10.0
    
    private var mapsIdentifier = CoordinateAndPlaceID()
    
    // The currently selected place.
    var selectedLocation: LocationModel?
    var locationManager: CLLocationManager!
    
    var confirmButton = UIButton()
    
    required init(editLocation:LocationModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.editLocation = editLocation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMapView()
        configSearchView()
        configBaritem()
        
    }
    
    func configMapView() {
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    
        switch locationManager.authorizationStatus { // check authorizationStatus instead of locationServicesEnabled()
        case .notDetermined, .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("ALERT: no location services access")
        case .authorizedAlways:
            break
        default:
            break
        }
        
        placesClient = GMSPlacesClient.shared()
        
        // A default location to use when location permission is not granted.
        let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
        
        // Create a map.
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        camera = GMSCameraPosition(latitude: defaultLocation.coordinate.latitude,
                                   longitude: defaultLocation.coordinate.longitude,
                                   zoom: zoomLevel)
        let options = GMSMapViewOptions()
        options.camera = camera
        options.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        mapView = GMSMapView.init(options: options)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        
        self.view.addSubview(mapView)
        
    }
    
    
    func configBaritem() {
        self.navigationItem.title = "位置".innerLocalized()
        let leftButton = UIButton()
        leftButton.imageForNormal = R.image.xmark()
        leftButton.frame = CGRect(x: 0, y: 0, width: 33, height: 40)
        leftButton.contentHorizontalAlignment = .left
        leftButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.dismiss(animated: true)
            }).disposed(by: rx.disposeBag)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        confirmButton.imageForNormal = R.image.checkmark()
        confirmButton.imageForDisabled = R.image.checkmark()?.tintImage(R.color.disableColor()!)
        confirmButton.size = CGSize(width: 33, height: 40)
        confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let selected = self?.selectedLocation else { return }
            
            self?.dismiss(animated: true,completion: {
                self?.selectLocationComplete?(selected)
            })
            
        }).disposed(by: rx.disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        confirmButton.isEnabled = false
    }
    
    func configSearchView() {
        
        searchView = UIView()
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(kNavBarHeight)
        }
        
        resultsViewController = GMSAutocompleteResultsViewController()
        
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        searchView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        
        // Changes the results view controller and search bar to be the right color
        resultsViewController?.tableCellSeparatorColor =  .white
        resultsViewController?.tableCellBackgroundColor =  .white
        resultsViewController?.primaryTextHighlightColor = .black
        resultsViewController?.primaryTextColor = .black
        resultsViewController?.secondaryTextColor =  .black
        searchController?.searchBar.barTintColor =  .white
        searchController?.searchBar.tintColor =  .black
        searchController?.searchBar.backgroundColor =  .white
        searchController?.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    func refreshMap()  {
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        
        
        camera = GMSCameraPosition.camera(
            withLatitude: mapsIdentifier.getCoord().latitude,
            longitude: mapsIdentifier.getCoord().longitude,
            zoom: zoomLevel
        )
        mapView.animate(to: camera)
        
        marker.position = mapsIdentifier.getCoord()
        marker.map = mapView
        resultsViewController?.dismiss(animated: true)
        searchController?.searchBar.text = ""
        
        definesPresentationContext = true
    }
    

}


extension LocationSearchController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView.animate(to: camera)
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
        
        // Handle authorization status
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension LocationSearchController:GMSAutocompleteResultsViewControllerDelegate {
    /// Changes currentLat and currentLong to reflect the chosen location
    ///
    /// - Parameter place: A GMSPlace identifier of the new location.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        mapsIdentifier.updateIdentifier(
            newCoord: CLLocationCoordinate2D(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            ),
            newPID: place.placeID ?? ""
        )
        
        selectedLocation = LocationModel(title: place.name ?? "", detail: place.formattedAddress ?? "")
        selectedLocation?.lagitude = place.coordinate.latitude
        selectedLocation?.longitude = place.coordinate.longitude
        selectedLocation?.pid  = place.placeID
        confirmButton.isEnabled = true
        refreshMap()
    }
    
    /// Default error message
    ///
    /// - Parameter error: The error that occured.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}

extension LocationSearchController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        confirmButton.isEnabled = false
        return true
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

