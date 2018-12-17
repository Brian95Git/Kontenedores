//
//  PerfilProveedorVC.swift
//  Kontenedores
//
//  Created by Admin on 23/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class PerfilProveedorVC: BaseViewController {

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var celularLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addSlideMenuButton()
        
        if let usuario = AppDelegate.instanciaCompartida.usuario
        {
            nombreLabel.text = usuario.nombre
            emailLabel.text = usuario.email
            celularLabel.text = usuario.celular
        }
        
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
