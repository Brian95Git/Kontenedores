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
        sender.isUserInteractionEnabled = false
        self.activityAceptar.startAnimating()
        
        guard let idCompra = AppDelegate.listaPedido.first as? Int else {return}
        
        AppDelegate.pushConfirmacionPedido = false
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
    
        KontenedoreServices.instancia.actualizarPedido(tokenUsuario: tokenUsuario!, idCompra: idCompra, estatus: true) { (respuesta) in
            
            if let exito = respuesta as? Double
            {
                self.activityAceptar.stopAnimating()
                
                AppDelegate.instanciaCompartida.usuario?.saldo = exito.valorNumerico2Decimales()
                
                self.dismiss(animated: true, completion: nil)
            }else
            {
                self.activityAceptar.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelarPedido(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        self.activityCancelar.startAnimating()
        
        guard let idCompra = AppDelegate.listaPedido.first as? Int else {return}
        
        AppDelegate.pushConfirmacionPedido = false
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token

        KontenedoreServices.instancia.actualizarPedido(tokenUsuario: tokenUsuario!, idCompra: idCompra, estatus: false) { (respuesta) in
            
            if let exito = respuesta as? Double
            {
                self.activityCancelar.stopAnimating()
                
                AppDelegate.instanciaCompartida.usuario?.saldo = exito.valorNumerico2Decimales()
                
                self.dismiss(animated: true, completion: nil)
            }else
            {
                self.activityCancelar.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
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
