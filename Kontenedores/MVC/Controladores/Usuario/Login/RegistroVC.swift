//
//  RegistroVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 2/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class RegistroVC: UIViewController {

    @IBOutlet weak var nombreTxt: UITextField!
    @IBOutlet weak var apellidoTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var celularTxt: UITextField!
    @IBOutlet weak var contrasenaTxt: UITextField!
    @IBOutlet weak var repetirContrasenaTxt: UITextField!
    
    @IBOutlet weak var centroYStackRegistro: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activarOcultamientoTeclado()
        
        nombreTxt.delegate = self
        apellidoTxt.delegate = self
        emailTxt.delegate = self
        celularTxt.delegate = self
        contrasenaTxt.delegate = self
        repetirContrasenaTxt.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    @IBAction func registrarseAction(_ sender: UIButton)
    {
        self.registarUsuario()
    }
    
    func registarUsuario()
    {
        guard let nombre = nombreTxt.text,!nombre.isEmpty,let apellido = apellidoTxt.text,!apellido.isEmpty,let email = emailTxt.text,!email.isEmpty,let celular = celularTxt.text,!celular.isEmpty,celularTxt.text?.count ?? 0 >= 9,let contrasena = contrasenaTxt.text,!contrasena.isEmpty,let repetirContrasena = repetirContrasenaTxt.text,!repetirContrasena.isEmpty , contrasena == repetirContrasena
            else {
                
                let alertController = UIAlertController(title: "Kontenedores", message: "Verifica que todos los campos sean válidos.Puede que no hayas ingresado todo tu número celular o que las contraseñas no sean iguales.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(ok)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
        }
        
        //AppDelegate.instanciaCompartida.soyUsuario = true
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        let usuario = Usuario(nombre: nombre, apellido: apellido, celular: celular, email: email, contrasena: contrasena, repetirContrasena: repetirContrasena)
        
        KontenedoreServices.instancia.registrarUsuario(usuario: usuario) { (respuesta) in
            
            if let respuesta = respuesta as? Bool,respuesta
            {
                print("Respuesta Exitosa")
                
                let alertController = UIAlertController(title: "Kontenedores", message: "Se te ha enviado un mensaje a tu email para activar tu cuenta.Por favor, actívalo para poder iniciar sesión.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                    self.performSegue(withIdentifier: "volverLogin", sender: self)
                    
                })
                alertController.addAction(ok)
                
                self.present(alertController, animated: true, completion: nil)
                
            }else
            {
                let msj = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer registrarte. Vuelve a intentarlo."
                
                let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler:{ (action) in
                   self.view.isUserInteractionEnabled = true
                })
                
                alertController.addAction(ok)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func volverRegistro(segue:UIStoryboardSegue)
    {
        
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

extension RegistroVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == celularTxt {
            
            if string == "" && textField.text?.count == 9
            {
                textField.text?.removeLast()
            }
            
            return (textField.text?.count)! < 9
        }else
        {
            if string == "" && textField.text?.count == 60
            {
                textField.text?.removeLast()
            }
            
            return (textField.text?.count)! < 60
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == nombreTxt {return apellidoTxt.becomeFirstResponder()}
        
        if textField == apellidoTxt {return celularTxt.becomeFirstResponder()}
        
        if textField == celularTxt {
            centroYStackRegistro.constant = -80
            return emailTxt.becomeFirstResponder()}
        
        if textField == emailTxt {
            centroYStackRegistro.constant = -100
            return contrasenaTxt.becomeFirstResponder()
        }
        
        if textField == contrasenaTxt{
            centroYStackRegistro.constant = -120
            return repetirContrasenaTxt.becomeFirstResponder()
        }
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == emailTxt
        {centroYStackRegistro.constant = -80}
        
        if textField == repetirContrasenaTxt || textField == contrasenaTxt
        {centroYStackRegistro.constant = -120}
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        centroYStackRegistro.constant = 0
        
        if textField == repetirContrasenaTxt
        {
            self.registarUsuario()
        }
    }
}
