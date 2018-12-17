//
//  ViewController.swift
//  PushNotificacionTest
//
//  Created by Admin on 10/30/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usuarioTxt: UITextField!
    @IBOutlet weak var contrasenaTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet weak var topConstraintStackUser: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usuarioTxt.delegate = self
        contrasenaTxt.delegate = self
        
        activarOcultamientoTeclado()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.consultarUsuarioLogueado()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func consultarUsuarioLogueado()
    {
        if let usuarioLogueado = UserManager.userLogged() as? Usuario
        {
            print("Tenemos a un usuario ya logueado")
            //self.btnIniciarSesion.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            
            self.view.isUserInteractionEnabled = false
            
//            self.usuarioTxt.isUserInteractionEnabled = false
//            self.contrasenaTxt.isUserInteractionEnabled = false
            AppDelegate.instanciaCompartida.usuario = usuarioLogueado
            
            print("Token Usuario ",usuarioLogueado.token)
            
            switch usuarioLogueado.tipo {
            case "cliente" :
                self.obtenerSaldoDisponible(token: usuarioLogueado.token)
            case "proveedor","vendedor":
                self.performSegue(withIdentifier: "goToProveedor", sender: self)
            case "escaner":
                self.performSegue(withIdentifier: "goToScanEntrada", sender: self)
            default:
                break
            }
            
        }else
        {
            usuarioTxt.becomeFirstResponder()
        }
    }
    
    @IBAction func ingresarAction(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        self.iniciarSesion()
    }
    
    //MARK: Iniciar Sesion
    
    func iniciarSesion()
    {
        guard let usuarioStr = usuarioTxt.text,!usuarioStr.isEmpty,let contra = contrasenaTxt.text,!contra.isEmpty else {
            
            let alertController = UIAlertController(title: "Kontenedores", message: "Ingresa tu usuario y contraseña por favor.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                 self.btnIniciarSesion.isUserInteractionEnabled = true
            }
           
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        //self.performSegue(withIdentifier: "goToProveedor", sender: self)
//        self.usuarioTxt.isUserInteractionEnabled = false
//        self.contrasenaTxt.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        print("El Token de FCM es" , AppDelegate.fcmToken)
        
        KontenedoreServices.instancia.iniciarSesion(email: usuarioStr, contrasena: contra, tokenFcm: AppDelegate.fcmToken) { (respuesta) in

            if let usuario = respuesta as? Usuario
            {
                AppDelegate.instanciaCompartida.usuario = usuario
                
                if usuario.tipo == "cliente"
                {
                    print("Soy Cliente y obtengo mi saldo")
                    self.obtenerSaldoDisponible(token: usuario.token)
                }else if usuario.tipo  == "proveedor" || usuario.tipo  == "vendedor"
                {
                    AppDelegate.instanciaCompartida.usuario?.saldo = 0.00
                    self.guardarUsuarioLocalmente()

                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    self.performSegue(withIdentifier: "goToProveedor", sender: self)

//                    self.usuarioTxt.isUserInteractionEnabled = true
//                    self.contrasenaTxt.isUserInteractionEnabled = true
            
                }else
                {
                    self.guardarUsuarioLocalmente()
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    self.performSegue(withIdentifier: "goToScanEntrada", sender: self)

//                    self.usuarioTxt.isUserInteractionEnabled = true
//                    self.contrasenaTxt.isUserInteractionEnabled = true
                 
                }

            }else
            {
                //let msj = respuesta as? String ?? "Usuario o contraseña inválidos"
                
                let alertController = UIAlertController(title: "Kontenedores", message: "Usuario o contraseña inválidos", preferredStyle: .alert)

                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.view.isUserInteractionEnabled = true
    
                })

                alertController.addAction(ok)

                self.present(alertController, animated: true, completion: nil)

//                self.usuarioTxt.isUserInteractionEnabled = true
//                self.contrasenaTxt.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }

    //MARK: Obtener Saldo Disponible
    
    func obtenerSaldoDisponible(token:String)
    {
        KontenedoreServices.instancia.obtenerSaldoDisponible(tokenUsuario: token) { (respuesta) in
            
            if let saldo = respuesta as? Double
            {
                AppDelegate.instanciaCompartida.usuario?.saldo = saldo.valorNumerico2Decimales()
                
                self.guardarUsuarioLocalmente()
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                
                self.performSegue(withIdentifier: "goToObras", sender: self)
                
//                self.usuarioTxt.isUserInteractionEnabled = true
//                self.contrasenaTxt.isUserInteractionEnabled = true
            }else
            {
                let msj = respuesta as? String ?? "Lo sentimos,tu token de usuario ha expirado.Inicia sesión de nuevo."
                
                let alertController = UIAlertController(title: "Kontenedores", message: msj , preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    //self.view.isUserInteractionEnabled = true
                })
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                
                alertController.addAction(ok)
                
                //self.present(alertController, animated: true, completion: nil)
              
//                self.usuarioTxt.isUserInteractionEnabled = true
//                self.contrasenaTxt.isUserInteractionEnabled = true
            }
        }
    }
    
    func guardarUsuarioLocalmente()
    {
        guard let usuarioGuardar = AppDelegate.instanciaCompartida.usuario else {return}
        
        if  UserManager.saveUserLogged(usuarioGuardar, nil)
        {
            print("Se pudo guardar al usuario")
        }else
        {
            print("Error al querer guardar al usuario")
        }
        
    }
    
    @IBAction func olvideMiContraseña(_ sender: UIButton) {
        
        let urlResetStr = "http://68.183.115.4/reset"
        let urlReset = URL(string: urlResetStr)
        
        guard let urlResetOpen = urlReset else {return}
        
        if UIApplication.shared.canOpenURL(urlResetOpen)
        {
            UIApplication.shared.open(urlResetOpen, options: [:], completionHandler: nil)
        }
        
    }
    
    
    @IBAction func volverLogin(segue:UIStoryboardSegue)
    {
        self.view.isUserInteractionEnabled = true
        //self.btnIniciarSesion.isUserInteractionEnabled = true
        
        self.usuarioTxt.text = ""
        self.usuarioTxt.becomeFirstResponder()
        
        self.contrasenaTxt.text = ""
        
//        self.usuarioTxt.isUserInteractionEnabled = true
//        self.contrasenaTxt.isUserInteractionEnabled = true
        
        self.activityIndicator.stopAnimating()
    }
}

extension LoginVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return (textField == usuarioTxt) ? contrasenaTxt.becomeFirstResponder() : textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == contrasenaTxt
        {
            self.topConstraintStackUser.constant = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == contrasenaTxt && contrasenaTxt.resignFirstResponder()
        {
            print("Termine de Editar")
            self.iniciarSesion()
        }
        
        self.topConstraintStackUser.constant = 40
    }
}

extension UIViewController
{
    func activarOcultamientoTeclado()
    {
        let tapKeyboard = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado(sender:)))
        self.view.addGestureRecognizer(tapKeyboard)
    }

    @objc func ocultarTeclado(sender:UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
}
