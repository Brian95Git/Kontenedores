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
    @IBOutlet weak var dniTxt: UITextField!
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
        //dniTxt.delegate = self
        emailTxt.delegate = self
        celularTxt.delegate = self
        contrasenaTxt.delegate = self
        repetirContrasenaTxt.delegate = self
        
        nombreTxt.becomeFirstResponder()
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
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        self.comprobarInternet { (disponible, msj) in
            
            DispatchQueue.main.async {
                if !disponible
                {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.registrarUsuarioWS()
                }
            }
        }
    }
    
    func registrarUsuarioWS()
    {
        guard let nombre = nombreTxt.text,!nombre.isEmpty,let apellido = apellidoTxt.text,!apellido.isEmpty,let email = emailTxt.text,!email.isEmpty,let celular = celularTxt.text,!celular.isEmpty,celular.count >= 9,let contrasena = contrasenaTxt.text,!contrasena.isEmpty,let repetirContrasena = repetirContrasenaTxt.text,!repetirContrasena.isEmpty , contrasena == repetirContrasena
            else {
                
                self.view.isUserInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                self.mostrarAlerta(msj: "Verifica que los campos sean válidos.Puede que no hayas ingresado todo tu número celular o que las contraseñas no sean iguales.")
                
                return
        }
        
        let usuario = Usuario(nombre: nombre, apellido: apellido, dni:  self.dniTxt.text!,celular: celular, email: email, contrasena: contrasena, repetirContrasena: repetirContrasena)
        
        KontenedoreServices.instancia.registrarUsuario(usuario: usuario) { (respuesta) in

            let mensaje = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer registrarte. Vuelve a intentarlo."

            if mensaje == "Se te ha enviado un mensaje a tu email para activar tu cuenta. Por favor, actívalo para poder iniciar sesión."
            {
                let alertController = UIAlertController(title: "Kontenedores", message: mensaje, preferredStyle: .alert)

                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in

                    self.performSegue(withIdentifier: "volverLogin", sender: self)

                })

                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)

            }else
            {
                self.mostrarAlerta(msj: mensaje)
            }
            
            self.view.isUserInteractionEnabled = true
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
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if textField == celularTxt {
//
//            if string == "" && textField.text?.count == 9
//            {
//                textField.text?.removeLast()
//            }
//            
//            return (textField.text?.count)! < 9
//        }else
//        {
//            if string == "" && textField.text?.count == 60
//            {
//                textField.text?.removeLast()
//            }
//
//            return (textField.text?.count)! < 60
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == nombreTxt {return apellidoTxt.becomeFirstResponder()}
        
        if textField == apellidoTxt {return dniTxt.becomeFirstResponder()}
        
        if textField == dniTxt {return celularTxt.becomeFirstResponder()}
        
        if textField == celularTxt {
            centroYStackRegistro.constant = -80
            return emailTxt.becomeFirstResponder()}
        
        if textField == emailTxt {
            centroYStackRegistro.constant = -100
            return contrasenaTxt.becomeFirstResponder()
        }
        
        if textField == contrasenaTxt{
            centroYStackRegistro.constant = -140
            return repetirContrasenaTxt.becomeFirstResponder()
        }
        
        if textField == repetirContrasenaTxt
        {
            print("Pulse Aceptar en Repetir Contraseña")
            self.registarUsuario()
        }
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == emailTxt
        {centroYStackRegistro.constant = -100}
        
        if textField == contrasenaTxt
        {centroYStackRegistro.constant = -140}
        
        if textField == repetirContrasenaTxt
        {centroYStackRegistro.constant = -180}
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        centroYStackRegistro.constant = 0
    }
}
