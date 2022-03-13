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
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        checkIfUserIsLoggedIn()
        enableLocationService(locationManager)
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
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
    }
    
    // 네비게이션바 설정
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    // 지도 설정
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            print("DEBUG: Present table view...")
        }
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
// 위치 정보 수집 허용 여부 체크
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


//MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}


//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

    }
    
}
