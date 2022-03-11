//
//  HomeController.swift
//  UberClone
//
//  Created by User on 2022/03/10.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationService(locationManager)
        //signOut()
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        } else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configureMapView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
}

//MARK: - AuthenticationDelegate
extension HomeController: AuthenticationDelegate {
    func authenticationDidComplete() {
        configureUI()
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - LocationServices

extension HomeController: CLLocationManagerDelegate {
    func enableLocationService(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            locationManager.delegate = self
            
            
            switch manager.authorizationStatus {
            case .notDetermined:
                print("DEBUG: Not determined...")
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                break
            case .authorizedAlways:
                print("DEBUG: Auth always...")
                manager.startUpdatingLocation()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            case .authorizedWhenInUse:
                print("DEBUG: Auth when in use...")
                manager.requestAlwaysAuthorization()
            @unknown default:
                print("DEBUG: There is an error with finding your location")
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("DEBUG: Not determined...")
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                break
            case .authorizedAlways:
                print("DEBUG: Auth always...")
                manager.startUpdatingLocation()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            case .authorizedWhenInUse:
                print("DEBUG: Auth when in use...")
                manager.requestAlwaysAuthorization()
            @unknown default:
                print("DEBUG: There is an error with finding your location")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}