//
//  Service.swift
//  UberClone
//
//  Created by User on 2022/03/16.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserData(completion: @escaping(String) -> Void) {
        print("DEBUG: Current uid is \(currentUid!)")
        
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let fullname = dictionary["fullname"] as? String else { return }
            completion(fullname)
        }
        
    }
    
}
