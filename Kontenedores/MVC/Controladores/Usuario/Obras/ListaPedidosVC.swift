//
//  ListaPedidosVC.swift
//  Kontenedores
//
//  Created by Admin on 12/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class ListaPedidosVC: UIViewController {
    
    @IBOutlet weak var activityAceptar: UIActivityIndicatorView!
    @IBOutlet weak var activityCancelar: UIActivityIndicatorView!
    
    @IBOutlet weak var totalPedidoLabel: UILabel!
    @IBOutlet weak var btnCancelar: UIButton!
    @IBOutlet weak var btnAceptar: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let monto = AppDelegate.listaPedido.last as? Double
        {
            totalPedidoLabel.text = monto.valorNumerico2DecimalesStr()
        }else
        {
            totalPedidoLabel.text = "0.00"
        }
    }
    
    @IBAction func aceptarPedido(_ sender: UIButton)
    {
        self.activityAceptar.startAnimating()
        sender.isUserInteractionEnabled = false
        
        self.aceptarCompra()
    }
    
    func aceptarCompra()
    {
        self.comprobarInternet { (disponible, msj) in
            
            DispatchQueue.main.async {
                if !disponible
                {
                    self.btnAceptar.isUserInteractionEnabled = true
                    self.activityAceptar.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.definirEstadoPedido(estatus: true, activity: self.activityAceptar)
                }
            }
        }
    }
    
    @IBAction func cancelarPedido(_ sender: UIButton)
    {
        self.activityCancelar.startAnimating()
        sender.isUserInteractionEnabled = false
        
        self.cancelarCompra()
    }
    
    func cancelarCompra()
    {
        self.comprobarInternet { (disponible, msj) in
            
            DispatchQueue.main.async {
                if !disponible
                {
                    self.btnCancelar.isUserInteractionEnabled = true
                    self.activityCancelar.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.definirEstadoPedido(estatus: false, activity: self.activityCancelar)
                }
            }
        }
    }
    
    func definirEstadoPedido(estatus:Bool,activity:UIActivityIndicatorView)
    {
        guard let idCompra = AppDelegate.listaPedido.first as? Int else {return}
        
        AppDelegate.pushConfirmacionPedido = false
        
        guard let usuario = AppDelegate.instanciaCompartida.usuario else {
            return
        }
        
        KontenedoreServices.instancia.actualizarPedido(tokenUsuario: usuario.token, idCompra: idCompra, estatus: estatus) { (respuesta) in
            
            if let exito = respuesta as? Double
            {
                AppDelegate.instanciaCompartida.usuario?.saldo = exito.valorNumerico2Decimales()
                
                self.dismiss(animated: true, completion: nil)
            }else
            {
                //self.mostrarAlerta(msj: "Lo sentimos,ocurrió un error.Vuelva a intentarlo")
                self.dismiss(animated: true, completion: nil)
            }
            
            self.btnAceptar.isUserInteractionEnabled = true
            self.btnCancelar.isUserInteractionEnabled = true
            
            activity.stopAnimating()
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
