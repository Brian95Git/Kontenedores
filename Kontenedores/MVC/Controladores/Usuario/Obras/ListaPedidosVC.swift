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
        //self.comprobarInternet()
        
        sender.isUserInteractionEnabled = false
        self.activityAceptar.startAnimating()
        
        self.definirEstadoPedido(estatus: true, activity: self.activityAceptar)
    }
    
    @IBAction func cancelarPedido(_ sender: UIButton)
    {
        //if !self.comprobarInternet() {return}
        
        sender.isUserInteractionEnabled = false
        self.activityCancelar.startAnimating()
        
        self.definirEstadoPedido(estatus: false, activity: self.activityCancelar)
    }
    
    func definirEstadoPedido(estatus:Bool,activity:UIActivityIndicatorView)
    {
        guard let idCompra = AppDelegate.listaPedido.first as? Int else {return}
        
        AppDelegate.pushConfirmacionPedido = false
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.actualizarPedido(tokenUsuario: tokenUsuario!, idCompra: idCompra, estatus: estatus) { (respuesta) in
            
            if let exito = respuesta as? Double
            {
                activity.stopAnimating()
            
                AppDelegate.instanciaCompartida.usuario?.saldo = exito.valorNumerico2Decimales()
                
                self.dismiss(animated: true, completion: nil)
            }else
            {
                activity.stopAnimating()
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
