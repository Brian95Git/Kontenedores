//
//  SplashKontenedoresVC.swift
//  Kontenedores
//
//  Created by ADMIN on 20/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class SplashKontenedoresVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var id : String!
        
        if let _ = UserManager.userLogged() as? Usuario
        {
            id = "Login"
        }else
        {
            id = "Obras"
        }
        
        let storyBoard = UIStoryboard(name: id, bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()!
        self.navigationController!.pushViewController(vc, animated: true)
        //self.performSegue(withIdentifier: id, sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
