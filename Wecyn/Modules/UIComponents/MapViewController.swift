//
//  MapViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/27.
//

import UIKit
import MapKit
class MapViewController: BaseViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var locationPlacemark:CLPlacemark?
    var location:String
    let geocoder = CLGeocoder()
    init(location:String) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "Location"
        
        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.frame = self.view.bounds
        mapView.mapType = .standard
        
       
        
        let button = UIButton()
        button.imageForNormal = R.image.path()
        button.size = CGSize(width: 30, height: 30)
        button.titleLabel?.font = UIFont.sk.pingFangSemibold(15)
        button.rx.tap.subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            let status = CLLocationManager.authorizationStatus()
            if status == .denied {
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
                return
            }
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        geocoder.geocodeAddressString(self.location) { [weak self] marks, e in
            guard let `self` = self else { return }
            if e == nil {
                guard let placemark = marks?.first,let coordinate = placemark.location?.coordinate else { return }
                self.locationPlacemark = placemark
                let annotation = Annotation(title: self.location, subtitle: nil, coordinate: coordinate)
                
                self.mapView.zoom(to: [coordinate], meter: 1000, edgePadding: .zero, animated: false)
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenter(coordinate, animated: false)
                let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let coordinateRegion = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
                self.mapView.setRegion(coordinateRegion, animated: false)
                self.mapView.selectedAnnotations = [annotation]
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        guard let userCoordinate = locations.last?.coordinate else {
            return
        }
        let startItem = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        
        let endAddress:[String: Any]? = self.locationPlacemark?.addressDictionary as? [String: Any]
        guard let endCoordinate = self.locationPlacemark?.location?.coordinate else  {
            return
        }
        let endplacemark = MKPlacemark(coordinate:endCoordinate,addressDictionary: endAddress)
        let endItem = MKMapItem(placemark: endplacemark)
        
        let option:[String : Any] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: true]
        MKMapItem.openMaps(with: [startItem,endItem],launchOptions: option)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            annotationView?.canShowCallout = true
            (
                annotationView as! MKPinAnnotationView
            ).animatesDrop = true
        }
        
        return annotationView
        
    }
}

@objc class Annotation:NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

@objc class AnnotationView: MKAnnotationView {
   
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
