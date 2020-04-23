//
//  ViewController.swift
//  MapExample
//
//  Created by IrvingHuang on 2020/4/16.
//  Copyright © 2020 Irving Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    // MARK:- Settings
    /// 地圖的預設位置(Taipei 101)
    let defaultLocation = CLLocationCoordinate2D( latitude: 25.033167, longitude: 121.564389)
    /// 使用者位置
    var currentLocation: CLLocationCoordinate2D?
    /// 若是無座標擇取預設位置
    var targetLocation: CLLocationCoordinate2D { return currentLocation ?? defaultLocation }
    
    // 初始化地圖
    /// 地圖
    private lazy var mapView: MKMapView = { [unowned self] in
        var map = MKMapView()
        map.delegate = self
        map.translatesAutoresizingMaskIntoConstraints = false
        map.isRotateEnabled = false
        map.showsPointsOfInterest = false
        map.showsBuildings = false
        map.showsTraffic = false
        map.showsCompass = false
        map.showsScale = false
        map.showsUserLocation = true
        // 初始位置
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: defaultLocation, span: span)
        map.region = region
        
        view.addSubview(map)
        return map
    }()
    
    private lazy var locationManager: CLLocationManager = { [unowned self] in
        var loc = CLLocationManager()
        loc.delegate = self
        loc.desiredAccuracy = kCLLocationAccuracyHundredMeters
        loc.activityType = .automotiveNavigation
        return loc
    }()

    // MARK:- Init & Setup
    override func loadView() {
        super.loadView()
        setup()
        requestLocation()
    }
    
    /// 是否已到達viewDidApear
    var isViewDidAppear = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewDidAppear {
            isViewDidAppear = true
            setUserRegion()
        }
    }

    // AutoLayout
    private func setup() {
        let views = [ "map": mapView]
        var constraints = [NSLayoutConstraint]()
        // 水平
        constraints += NSLayoutConstraint.constraints(withVisualFormat:"H:|-(0)-[map]-(0)-|",options: [], metrics: nil, views: views)
        // 垂直
        constraints += NSLayoutConstraint.constraints(withVisualFormat:"V:|-(0)-[map]-(0)-|",options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK:- Map Action
    private func setUserRegion() {
        _ = moveToCoordinate(with: targetLocation)
    }
    
    /// 取得使用者位置&Auth
    private func requestLocation() {
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func moveToCoordinate(with coordinate: CLLocationCoordinate2D) -> Bool {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        return moveToCoordinateBySpan(with: coordinate, span: span)
    }
    
    private func moveToCoordinateBySpan(with coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) -> Bool  {
        if coordinate.longitude != 0 && coordinate.latitude != 0  && coordinate.canSetRegion() {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            moveToRegion(with: region)
            return true
        }
        return false
    }
    
    private func moveToRegion(with region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: false)
    }
    
    // MARK:- API Event
    /// Debug API Times
    var count = 0
    
    /// 取得資料
    private func getDataFromAPI() {
        count += 1
        print("API called \(count) times.")
        
//        let screenRegion = getCoordinateList()
    }
    
    /// 取得地圖左上右下的經緯度座標
    private func getCoordinateList() -> [[String: Any]] {
        
        var screenCoordList: [[String: Any]] = []
        let startCoordinate = mapView.convert(CGPoint(x:0,y:0), toCoordinateFrom: mapView)
        let endCoordinate = mapView.convert(CGPoint(x: mapView.frame.width, y: mapView.frame.height), toCoordinateFrom: mapView)
        
        screenCoordList = [
            ["Lat":"\(startCoordinate.latitude)", "Lng":"\(startCoordinate.longitude)"],
            ["Lat":"\(endCoordinate.latitude)", "Lng":"\(endCoordinate.longitude)"]
        ]
        return screenCoordList
    }
    
}

// MARK:- Extension
// MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isViewDidAppear {
            getDataFromAPI()
        }
    }

}


// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // 取得定位授權權限狀況
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            print("didChangeAuthorization --> authorizedAlways or authorizedWhenInUse")
        case .denied:
            print("didChangeAuthorization --> denied")
        case .notDetermined:
            print("didChangeAuthorization --> notDetermined")
        default:
            print("didChangeAuthorization  --> restricted")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 當位置資訊有更新時
        if let location = locations.last {
            
            let temp = currentLocation
            currentLocation = location.coordinate
            // 如果是第一次取得使用者位置，就將位置移至使用者位置
            if (temp?.latitude ?? 0) == 0 && (temp?.longitude ?? 0) == 0 {
                setUserRegion()
            }
        }
    }
}


// MARK: CLLocationCoordinate2D
extension CLLocationCoordinate2D {
        
    func canSetRegion() -> Bool {
        if ((self.latitude >= -90) && (self.latitude <= 90) && (self.longitude >= -180) && (self.longitude <= 180) ) {
            return true
        }

        return false
    }
}
