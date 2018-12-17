//
//  HistorialPedidosVC.swift
//  Kontenedores
//
//  Created by Admin on 23/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class HistorialPedidosVC: BaseViewController,UITableViewDataSource {

    @IBOutlet weak var ventasTV: UITableView!
    
    var ventas = [Venta]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ventasTV.dataSource = self
        self.addSlideMenuButton()
        
        let refreshControl = UIRefreshControl(frame: ventasTV.frame)
        refreshControl.addTarget(self, action: #selector(obtenerVentasDelDia), for: .valueChanged)
        
        refreshControl.tintColor = #colorLiteral(red: 0.5294117647, green: 0, blue: 0.7803921569, alpha: 1)
        
        ventasTV.refreshControl = refreshControl
        
        self.obtenerVentasDelDia()
    }
    
    @objc func obtenerVentasDelDia()
    {
        if let refresh = ventasTV.refreshControl,!refresh.isRefreshing
        {
            ventas.removeAll()
        }
        
        ventasTV.refreshControl?.beginRefreshing()
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.obtenerVentasPorDia(tokenUsuario: tokenUsuario!) { (respuesta) in
            
            if let ventas = respuesta as? [Venta]
            {
                self.ventas = ventas
                
                self.ventasTV.refreshControl?.endRefreshing()
                self.ventasTV.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ventas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let celda = tableView.dequeueReusableCell(withIdentifier: "ventaCell", for: indexPath)
        
        let nombreUsuario = celda.contentView.viewWithTag(100) as! UILabel
        let fechaLabel = celda.contentView.viewWithTag(101) as! UILabel
        let horaLabel = celda.contentView.viewWithTag(102) as! UILabel
        let montoLabel = celda.contentView.viewWithTag(106) as! UILabel
        
        nombreUsuario.text = ventas[indexPath.row].cliente.name
        fechaLabel.text = ventas[indexPath.row].fecha
        horaLabel.text = ventas[indexPath.row].hora
        montoLabel.text = "S/. " + ventas[indexPath.row].monto.valorNumerico2DecimalesStr()
        
        return celda
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
