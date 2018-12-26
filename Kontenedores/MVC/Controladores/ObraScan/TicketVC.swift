//
//  TicketVC.swift
//  Kontenedores
//
//  Created by Admin on 10/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class TicketVC: UIViewController {

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var diaLabel: UILabel!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var portadaObraImg: UIImageView!
    @IBOutlet weak var nroKontenedorLabel: UIButton!
    @IBOutlet weak var asistioLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityConfirmar: UIActivityIndicatorView!
    @IBOutlet weak var stackDataObra: UIStackView!
    @IBOutlet weak var stackCanCon: UIStackView!
    
    var ticket : Ticket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nombreLabel.text = ticket.obra.titulo
        self.diaLabel.text = self.obtenerDia(fechaStr: ticket.presentacion.dia)
        self.horarioLabel.text = ticket.presentacion.hora
        self.nroKontenedorLabel.setTitle(String(ticket.presentacion.kontenedor), for: .normal)
        
        
        self.activityIndicator.startAnimating()
        
        self.portadaObraImg.cargarImgDesdeURL(urlImg: self.ticket.obra.imagen) {
            self.activityIndicator.stopAnimating()
        }
        
        stackCanCon.isHidden = self.ticket.entrada.estatus == "asistio"
        asistioLabel.isHidden = self.ticket.entrada.estatus == "pendiente"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func obtenerDia(fechaStr:String) -> String
    {
        let formatoFecha = DateFormatter()
        formatoFecha.dateFormat = "dd/MM/yyyyy"
        let fecha = formatoFecha.date(from: fechaStr)
        
        formatoFecha.dateFormat = "EEEE"
        formatoFecha.locale = Locale(identifier: "es_PE")
        
        let dia = formatoFecha.string(from: fecha!).capitalized
        
        return dia
    }
    
    
    @IBAction func confirmarEntrada(_ sender: UIButton)
    {
        self.actualizarEntrada(sender: sender)
    }
    
    func actualizarEntrada(sender:UIButton)
    {
        sender.isUserInteractionEnabled = false
        self.activityConfirmar.startAnimating()
        
        self.comprobarInternet { (disponible, msj) in
            
            DispatchQueue.main.async {
                if !disponible
                {
                    sender.isUserInteractionEnabled = true
                    self.activityConfirmar.startAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.actualizarEntradaWS()
                }
            }
        }
    }
    
    func actualizarEntradaWS()
    {
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.actualizarEntrada(tokenUsuario: tokenUsuario!, idEntrada: self.ticket.entrada.id) { (respuesta) in
            
            let msj = respuesta as? String ?? "Entrada Confirmada."
            
            let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
                self.stackCanCon.isHidden = true
                self.asistioLabel.isHidden = false
                //self.performSegue(withIdentifier: "regresarSegue", sender: self)
            })
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
            
            self.activityConfirmar.stopAnimating()
        }
    }
    
    
    
    @IBAction func cancelarEntrada(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        self.dismiss(animated: true, completion: nil)
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
