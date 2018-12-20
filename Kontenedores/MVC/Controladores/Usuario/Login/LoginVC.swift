//
//  ViewController.swift
//  PushNotificacionTest
//
//  Created by Admin on 10/30/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase
import Alamofire

class LoginVC: UIViewController {

    @IBOutlet weak var usuarioTxt: UITextField!
    @IBOutlet weak var contrasenaTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet weak var centerYConstraintStackUser: NSLayoutConstraint!
    
    
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
            //print("Token Usuario ",usuarioLogueado.token)
            self.activityIndicator.startAnimating()
            
            self.view.isUserInteractionEnabled = false
            
            self.usuarioTxt.text = usuarioLogueado.email
            self.contrasenaTxt.text = usuarioLogueado.contrasena
            
            AppDelegate.instanciaCompartida.usuario = usuarioLogueado
        
            self.iniciarSesion()
            
        }else
        {
            usuarioTxt.becomeFirstResponder()
        }
    }
    
    @IBAction func ingresarAction(_ sender: UIButton)
    {
        self.iniciarSesion()
    }
    
    //MARK: Iniciar Sesion
    
    func iniciarSesion()
    {
        self.comprobarInternet { (disponible,msj) in
            if !disponible
            {
                print("Internet no disponible : ", msj)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }
            }else
            {
                DispatchQueue.main.async(execute: self.iniciarSesionWS)
            }
        }
    }

    func iniciarSesionWS()
    {
        guard let usuarioStr = self.usuarioTxt.text,!usuarioStr.isEmpty,let contrasena = self.contrasenaTxt.text,!contrasena.isEmpty else {
            self.mostrarAlerta(msj: "Ingresa tu usuario y contraseña por favor.")
            return
        }
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
        var tokenFcm = Messaging.messaging().fcmToken ?? "No Token de FireBase"
        print("El Token de Messaging fcmToken es" , tokenFcm)
        
        InstanceID.instanceID().instanceID { (result, error) in
            
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                tokenFcm = result.token
            }
        }
        
        KontenedoreServices.instancia.iniciarSesion(email: usuarioStr, contrasena: contrasena, tokenFcm: tokenFcm) { (respuesta) in
            
            if let usuario = respuesta as? Usuario
            {
                AppDelegate.instanciaCompartida.usuario = usuario
                AppDelegate.instanciaCompartida.usuario?.contrasena = contrasena
                
                switch usuario.tipo {
                case "cliente" :
                    self.obtenerSaldoDisponible(token: usuario.token)
                case "proveedor","vendedor":
                    self.guardarUsuarioLocalmente()
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    self.performSegue(withIdentifier: "goToProveedor", sender: self)
                case "escaner":
                    self.guardarUsuarioLocalmente()
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    self.performSegue(withIdentifier: "goToScanEntrada", sender: self)
                default:
                    break
                }
            }else
            {
                self.view.isUserInteractionEnabled = true
                self.mostrarAlerta(msj: "Usuario o contraseña inválidos.")
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
        
        self.usuarioTxt.text = ""
        self.usuarioTxt.becomeFirstResponder()
        
        self.contrasenaTxt.text = ""
  
        self.activityIndicator.stopAnimating()
    }
}

extension LoginVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return (textField == usuarioTxt) ? contrasenaTxt.becomeFirstResponder() : textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == contrasenaTxt
//        {
//            self.centerYConstraintStackUser.constant = 0
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == contrasenaTxt
        {
            print("Termine de Editar")
            self.iniciarSesion()
        }
        
        //self.centerYConstraintStackUser.constant = 40
    }
}

extension UIViewController
{
    func comprobarConexionRed() -> Bool
    {
        return Reachability()!.isReachable
    }
    
    func comprobarInternet(completionHandler: @escaping (Bool,String) -> Void)
    {
        // 1. Check the WiFi Connection
        guard comprobarConexionRed() else {
            completionHandler(false,"No estás conectado a ninguna red.")
            return
        }
        
        // 2. Check the Internet Connection but possibly use www.apple.com or www.alibaba.com instead of google.com because it's not available in China
        let webAddress = "https://www.apple.com" // Default Web Site
        
        guard let url = URL(string: webAddress) else {
            //print("could not create url from: \(webAddress)")
            completionHandler(false, "null")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil || response == nil {
                completionHandler(false, "Revisa la intensidad de tu internet y vuelve a intentarlo.")
            }else
            {
                completionHandler(true, "")
            }
        })
        
        task.resume()
    }
    
    
    func mostrarAlerta(msj:String)
    {
        let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
        }
        
        alertController.addAction(ok)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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
