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
    
    @IBOutlet weak var btnRegresar: UIButton!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet weak var centerYConstraintStackUser: NSLayoutConstraint!
    
    var ocultarBtn : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usuarioTxt.delegate = self
        contrasenaTxt.delegate = self
        
        activarOcultamientoTeclado()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btnRegresar.isHidden = ocultarBtn
        self.consultarUsuarioLogueado()
        //usuarioTxt.becomeFirstResponder()
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
            AppDelegate.instanciaCompartida.usuario = usuarioLogueado
            
            self.usuarioTxt.text = usuarioLogueado.email
            self.contrasenaTxt.text = usuarioLogueado.contrasena
        
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
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
        self.comprobarInternet { (disponible,msj) in
            
            DispatchQueue.main.async {
                if !disponible
                {
                    print("Internet no disponible : ", msj)
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.iniciarSesionWS()
                }
            }
        }
    }

    func iniciarSesionWS()
    {
        guard let usuarioStr = self.usuarioTxt.text,!usuarioStr.isEmpty,let contrasena = self.contrasenaTxt.text,!contrasena.isEmpty else {
            
            let alertController = UIAlertController(title: "Kontenedores", message: "Ingresa tu usuario y contraseña porfavor.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.usuarioTxt.becomeFirstResponder()
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
            
            return
        }
        
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
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.performSegue(withIdentifier: "goToProveedor", sender: self)
                case "escaner":
                    self.guardarUsuarioLocalmente()
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.performSegue(withIdentifier: "goToScanEntrada", sender: self)
                default:
                    break
                }
            }else
            {
                let alertController = UIAlertController(title: "Kontenedores", message: "Usuario o contraseña inválidos.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.contrasenaTxt.becomeFirstResponder()
                })
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
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
                
                if self.ocultarBtn == false
                {
                    self.navigationController?.popViewController(animated: true)
                }else
                {
                    self.performSegue(withIdentifier: "goToObras", sender: self)
                }
            }
            
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }

    //MARK: Guardar el usuario localmente
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
    
    @IBAction func volverAtras(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
        self.btnRegresar.isHidden = true
        
        self.usuarioTxt.text = ""
        self.usuarioTxt.becomeFirstResponder()
        
        self.contrasenaTxt.text = ""
  
        self.activityIndicator.stopAnimating()
    }
}

extension LoginVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == contrasenaTxt
        {
            print("Termine de Editar")
            self.iniciarSesion()
        }
        
        return (textField == usuarioTxt) ? contrasenaTxt.becomeFirstResponder() : textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == contrasenaTxt
        {
            let alturaPantalla = UIScreen.main.bounds.height
            self.centerYConstraintStackUser.constant = (alturaPantalla == 568) ? -60 : 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.centerYConstraintStackUser.constant = 0
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
