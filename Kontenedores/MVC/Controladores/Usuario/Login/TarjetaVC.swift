//
//  TarjetaVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 2/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import Culqi

class TarjetaVC: UIViewController,UIPopoverPresentationControllerDelegate,UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var btnMM: UIButton!
    @IBOutlet weak var btnAAAA: UIButton!
    @IBOutlet weak var btnMonto: UIButton!
    @IBOutlet weak var nroTarjeta: UITextField!
    @IBOutlet weak var cvcTxt: UITextField!
    
    @IBOutlet weak var anclaPopOver: UIView!
    @IBOutlet weak var viewRecargar: UIView!
    
    @IBOutlet weak var btnVolverLogin: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tagBtn = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nroTarjeta.delegate = self
        cvcTxt.delegate = self
        
        Culqi.setApiKey("pk_test_kF15NbtNvIA0LZX3")
        
        activarOcultamientoTeclado()       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    @IBAction func escogerFecha(_ sender: UIButton) {
        
        tagBtn = sender.tag
        var  listaNumeros : [String] = []
        
        switch sender.tag {
        case 0:
            listaNumeros = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        case 1:
            let rangoAños = 2018...2038
            rangoAños.forEach { (año) in
                listaNumeros.append(String(año))
            }
        case 2:
            let rangoMontos = 50...500
            rangoMontos.forEach { (monto) in
                if monto % 50 == 0
                {
                    listaNumeros.append(String(monto))
                }
            }
        default:
            break
        }
        
        let originSender = sender.convert(sender.frame.origin, to: self.view)
        
        anclaPopOver.frame.origin.x = originSender.x + sender.bounds.width / 2 - anclaPopOver.bounds.width / 2

        anclaPopOver.frame.origin.y = (originSender.y - sender.frame.origin.y) + sender.bounds.height
        
        self.performSegue(withIdentifier: "goToMMAAMonto", sender: listaNumeros)
    }
    
    @IBAction func confirmarRegistro(_ sender: UIButton)
    {
        if btnMM.titleLabel?.text != "MM" && btnAAAA.titleLabel?.text != "AAAA" && cvcTxt.text?.count == 3 && nroTarjeta.text?.count == 19 && btnMonto.titleLabel?.text != "0.00 S/"
        {
            let usuario = AppDelegate.instanciaCompartida.usuario!
            
//            var numTarjeta = nroTarjeta.text!
//
//            numTarjeta.removeAll { (char) -> Bool in
//                return char == " "
//            }
            
            Culqi.sharedInstance().createToken(withCardNumber: nroTarjeta.text!, cvv: cvcTxt.text!, expirationMonth: btnMM.titleLabel!.text! , expirationYear: btnAAAA.titleLabel!.text!, email: usuario.email, metadata: nil, success: { (respuestaHeader, tokenCulqi) in
                
                print("Se creo exitosamente el identifier : ",tokenCulqi.identifier)
                
            }) { (respuestaErroe, clqError, error) in
                
                print("Error al generar token : ",clqError.merchantMessage , "-----",error.localizedDescription)
            }
            
//            self.performSegue(withIdentifier: "goToObras", sender: self)
        }else
        {
            
        }

    }
    
    @IBAction func volverRecargar(_ segue:UIStoryboardSegue)
    {
//        let regresarVC = segue.source
//        self.navigationController?.pushViewController(regresarVC, animated: true)
        self.navigationController?.popViewController(animated: true)
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        //print("Aparesco PopOver")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //print("Presentation Style")
        return .none
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return adaptivePresentationStyle(for:controller)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToMMAAMonto"
        {
            let popOver = segue.destination as! MesTBVC
            popOver.popoverPresentationController?.delegate = self
            
            popOver.listaNumeros = sender as! [String]
            popOver.tagBtn = self.tagBtn
        }
    }
 
}


extension TarjetaVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let conteo = textField.text?.count ?? 0
        
        if textField == nroTarjeta
        {
            if string == "" && conteo == 19
            {
                textField.text?.removeLast()
            }
            
            //print("replacementString",string)
            //print("Conteo de la las letras",conteo)
            
            let indicesNulos = [4,9,14]

            indicesNulos.forEach { (indice) in
                if conteo == indice && string != ""{
                    textField.text?.append(" ")
                }
            }
            
            return conteo < 19
        }else
        {
            if string == "" && conteo == 3
            {
                textField.text?.removeLast()
            }
            
            return conteo < 3
        }
    }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
