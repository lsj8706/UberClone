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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
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
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
}

//MARK: - AuthenticationDelegate
extension HomeController: AuthenticationDelegate {
    func authenticationDidComplete() {
        configureUI()
        self.dismiss(animated: true, completion: nil)
    }
}
