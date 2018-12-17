//
//  EntradaVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 6/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class EntradaVC: UIViewController {

    @IBOutlet weak var btnSaldo: UIBarButtonItem!
    @IBOutlet weak var nombreObraLabel: UILabel!
    @IBOutlet weak var diaLabel: UILabel!
    @IBOutlet weak var horaLabel: UILabel!
    @IBOutlet weak var nroEntradasLabel: UILabel!
    @IBOutlet weak var activityComprar: UIActivityIndicatorView!
    @IBOutlet weak var precioTotalLabel: UILabel!
    @IBOutlet weak var saldoActualLabel: UILabel!
    
    var miEntrada : EntradaPreeliminar!
    var nombreObraSelect = ""
    var diaSelect = ""
    var horaSelect = ""
    var nroEntradaSelect = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datosEntrada()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.saldoActualLabel.text = AppDelegate.instanciaCompartida.usuario?.saldo.valorNumerico2DecimalesStr()
        self.precioTotalLabel.text = self.precioTotalObra().valorNumerico2DecimalesStr()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func precioTotalObra() -> Double
    {
        let precioTotalEntrada = miEntrada.precio * Double(miEntrada.nroEntradas)
        return precioTotalEntrada
    }
    
    func datosEntrada()
    {
        nombreObraLabel.text = miEntrada.nombreObra
        diaLabel.text = miEntrada.dia
        horaLabel.text = miEntrada.horario
        nroEntradasLabel.text = String(miEntrada.nroEntradas)
    }
    
    @IBAction func comprarEntrada(_ sender: UIButton)
    {
        sender.titleEdgeInsets.right = 20
        self.activityComprar.startAnimating()
        
        sender.isUserInteractionEnabled = false
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.comprarEntrada(tokenUsuario: tokenUsuario!, presentacionId: miEntrada.id, nroEntradas: miEntrada.nroEntradas) { (respuesta) in
            
            if let saldo = respuesta as? Double
            {
                print(saldo)
                AppDelegate.instanciaCompartida.usuario?.saldo = saldo
                self.performSegue(withIdentifier: "goToCompraEntrada", sender: self.miEntrada)
            }else
            {
                let msj = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer comprar tu entrada."
                let alertController = UIAlertController(title: "Kontenedores", message:msj , preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                    sender.titleEdgeInsets.right = 0
                    sender.isUserInteractionEnabled = true
                })
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.activityComprar.stopAnimating()
        }
    }
    
    
//     MARK: - Navigation
//
//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        if segue.identifier == "goToCompraEntrada"
        {
            let compraEntradaVC = segue.destination as! CompraEntradaVC
            compraEntradaVC.miEntrada = miEntrada
        }
    }
}

