//
//  HistorialVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 9/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class HistorialVC: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var historialTV: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var misCompras : [Compra] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSlideMenuButton()
        //self.activityIndicator.startAnimating()
        
        let refreshControl = UIRefreshControl(frame: self.historialTV.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerProductos), for: .valueChanged)
        
        self.historialTV.refreshControl = refreshControl
      
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pintarSaldoUsuario()
        self.obtenerProductos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    @objc func obtenerProductos()
    {
        //if !self.comprobarInternet() {return}
        
        if let refrescando = self.historialTV.refreshControl,!refrescando.isRefreshing
        {
            misCompras.removeAll()
        }
       
        self.historialTV.refreshControl?.beginRefreshing()
        
        let tokenUsuario = (AppDelegate.instanciaCompartida.usuario?.token)!
        
        KontenedoreServices.instancia.obtenerProductos(tokenUsuario: tokenUsuario) { (respuesta) in
            if let compras = respuesta as? [Compra]
            {
                self.misCompras = compras
                
//                self.misCompras.sort(by: { (com1, com2) -> Bool in
//                    return com1.id > com2.id
//                })
                
                self.historialTV.refreshControl?.endRefreshing()
                self.historialTV.reloadData()
                self.activityIndicator.stopAnimating()
            }else
            {
                let msj = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer traer tu historial."
                
                let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                }
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        //
    }
    
    //MARK: TableView Historial
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return misCompras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "productoCell", for: indexPath)
        
        let nombreProveedorLabel = celda.contentView.viewWithTag(100) as! UILabel
        let fechaLabel = celda.contentView.viewWithTag(101) as! UILabel
        let precioLabel = celda.contentView.viewWithTag(102) as! UILabel
        
        nombreProveedorLabel.text = self.misCompras[indexPath.row].nombreproveedor
        
        fechaLabel.text = self.obtenerMes(fechaStr: self.misCompras[indexPath.row].fecha)
        
        
        switch self.misCompras[indexPath.row].estatus {
        case "cancelado":
            precioLabel.text = "rechazado"
        case "pagado":
            precioLabel.text = "- S/. " + self.misCompras[indexPath.row].monto.valorNumerico2DecimalesStr()
        default:
            precioLabel.text = "pendiente"
        }
    
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let compraSeleccionada = self.misCompras[indexPath.row]
        
        if compraSeleccionada.estatus == "pendiente"
        {
            AppDelegate.listaPedido.removeAll()
            
            let lista : [Any] = [compraSeleccionada.id,compraSeleccionada.monto]
            
            AppDelegate.listaPedido = lista

            self.performSegue(withIdentifier: "goToConfirmacionPedido", sender: self)
        }
    }
    
    
    func obtenerMes(fechaStr:String) -> String
    {
        let formatoFecha = DateFormatter()
        formatoFecha.locale = Locale(identifier: "es_PE")
        formatoFecha.dateFormat = "yyyy-MM-dd"
        let fecha = formatoFecha.date(from: fechaStr)
        
        formatoFecha.dateFormat = "MMMM d"
        var mes = formatoFecha.string(from: fecha!)
        mes.insert(Character(String(mes.removeFirst()).uppercased()), at: mes.startIndex)
        
        return mes
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToConfirmacionPedido"
        {
            //let confirmacionPedido = segue.destination as! ListaPedidosVC
        }
    }
 

}
