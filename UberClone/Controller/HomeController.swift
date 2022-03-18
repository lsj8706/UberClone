//
//  HomeController.swift
//  UberClone
//
//  Created by User on 2022/03/10.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    
    private var user: User? {
        didSet { locationInputView.user = user }
    }
        
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        checkIfUserIsLoggedIn()
        enableLocationService(locationManager)
        fetchUserData()
    }
    
    //MARK: - API
    
    func fetchUserData() {
        Service.shared.fetchUserData { user in
            self.user = user
        }
    }
    
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
        
        configureTableView()
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
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    // 테이블 뷰 설정
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        // 테이블 뷰에서 필요한 cell을 제외한 부분의 cell 테두리를 제거
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
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
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

    }
    
}

//MARK: - UITableViewDelegate/DataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    // 테이블 뷰를 두 부분으로 나누기
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 첫번째 섹션(부분)에는 두개의 cell만 생성
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
    
}
