//
//  SaldoVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 9/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class SaldoVC: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var btnRecargar: UIButton!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var movimientosTV: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var misRecargas : [Recarga] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSlideMenuButton()
        //self.activityIndicator.startAnimating()
   
        let refreshControl = UIRefreshControl(frame: self.movimientosTV.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerRecargas), for: .valueChanged)
        
        self.movimientosTV.refreshControl = refreshControl
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnRecargar.isUserInteractionEnabled = true
        
        self.obtenerRecargas()
        
        self.pintarSaldoUsuario()
    }
    
    @objc func obtenerRecargas()
    {
        //if !self.comprobarInternet() {return}
        
        if let refrescando = self.movimientosTV.refreshControl,!refrescando.isRefreshing
        {
            misRecargas.removeAll()
        }
        
        self.movimientosTV.refreshControl?.beginRefreshing()
      
        let tokenUsuario = (AppDelegate.instanciaCompartida.usuario?.token)!
        
        KontenedoreServices.instancia.obtenerRecargas(tokenUsuario: tokenUsuario) { (respuesta) in
            
            if let recargas = respuesta as? [Recarga]
            {
                self.misRecargas = recargas
                
                /*self.misRecargas.sort(by: { (rec1, rec2) -> Bool in
                    return rec1.id > rec2.id
                })*/
                
                self.movimientosTV.refreshControl?.endRefreshing()
                self.movimientosTV.reloadData()
                self.activityIndicator.stopAnimating()
            }
            else
            {
                let msj = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer traer tus movimientos."
                
                let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                    
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func pintarSaldoUsuario()
    {
        if let usuario = AppDelegate.instanciaCompartida.usuario,usuario.saldo > 0
        {
            self.saldoLabel.text = usuario.saldo.valorNumerico2DecimalesStr()
        }else
        {
            self.saldoLabel.text = "0.00" 
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return misRecargas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let celda = tableView.dequeueReusableCell(withIdentifier: "saldoCell", for: indexPath)
        
        let tarjetaLabel = celda.contentView.viewWithTag(100) as! UILabel
        let fechaLabel = celda.contentView.viewWithTag(101) as! UILabel
        let recargaLabel = celda.contentView.viewWithTag(102) as! UILabel
        
        tarjetaLabel.text = "\(misRecargas[indexPath.row].card_brand) \(misRecargas[indexPath.row].card_number)"
        
        fechaLabel.text = self.obtenerMes(fechaStr: misRecargas[indexPath.row].fecha)
        recargaLabel.text = "S/. \(misRecargas[indexPath.row].saldo)"
    
        return celda
    }
    
    func obtenerMes(fechaStr:String) -> String
    {
        let formatoFecha = DateFormatter()
        formatoFecha.locale = Locale(identifier: "es_PE")
        formatoFecha.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd HH:mm:ss"
        let fecha = formatoFecha.date(from: fechaStr)
        
        formatoFecha.dateFormat = "MMMM d"
        var mes = formatoFecha.string(from: fecha!)
        mes.insert(Character(String(mes.removeFirst()).uppercased()), at: mes.startIndex)
        
        return mes
    }
    
    @IBAction func recargarSaldo(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "recargarSaldo", sender: self)
    }
    
    @IBAction func volverSaldo(_ segue:UIStoryboardSegue)
    {
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
