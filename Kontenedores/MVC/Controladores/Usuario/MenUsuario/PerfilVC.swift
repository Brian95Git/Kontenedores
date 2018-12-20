//
//  PerfilVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 9/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class PerfilVC: BaseViewController{

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var celularLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pintarSaldoUsuario()
    }
    
    func pintarSaldoUsuario()
    {
        if let usuario = AppDelegate.instanciaCompartida.usuario,usuario.saldo > 0
        {
            self.saldoLabel.text = "S/. " + usuario.saldo.valorNumerico2DecimalesStr()
        }else
        {
            self.saldoLabel.text = "S/ 0.00"
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
