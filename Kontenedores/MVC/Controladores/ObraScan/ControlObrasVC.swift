//
//  ControlObrasVC.swift
//  Kontenedores
//
//  Created by Admin on 15/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class ControlObrasVC: BaseViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var controlObrasTV: UITableView!
    @IBOutlet weak var activityObras: UIActivityIndicatorView!
    
    var obras : [Obra] = [Obra]()
    var presentaciones = [Presentacion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.activityObras.startAnimating()
        self.addSlideMenuButton()
        
        self.controlObrasTV.dataSource = self
        self.controlObrasTV.delegate = self
    
        let refreshControl = UIRefreshControl(frame: self.controlObrasTV.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerTodasLasObras), for: .valueChanged)
        
        self.controlObrasTV.refreshControl = refreshControl
        
        self.obtenerTodasLasObras()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    @objc func obtenerTodasLasObras()
    {
        if let refrescando = self.controlObrasTV.refreshControl,refrescando.isRefreshing
        {
            self.obras.removeAll()
            self.presentaciones.removeAll()
        }
        
        self.controlObrasTV.refreshControl?.beginRefreshing()
        
        KontenedoreServices.instancia.obtenerObras(todasLasObras: false) { (respuesta) in
            
            if let obras = respuesta as? [Obra]
            {
                self.obras = obras
                
                self.controlObrasTV.refreshControl?.endRefreshing()
                self.controlObrasTV.reloadData()
                self.activityObras.stopAnimating()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.obras.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard !self.obras.isEmpty else {return "Sin Titulo"}
        
        return self.obras[section].titulo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let obra = self.obras[section]
        
        guard let presentaciones = obra.presentaciones else {return 0}
        
        self.presentaciones = presentaciones
        
        return self.presentaciones.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "controlObraCell", for: indexPath)
    
        let fechaLabel = celda.contentView.viewWithTag(100) as! UILabel
        let funcionLabel = celda.contentView.viewWithTag(101) as! UILabel
        let escaneadasLabel = celda.contentView.viewWithTag(102) as! UILabel
        let compradasLabel = celda.contentView.viewWithTag(103) as! UILabel
        
        //let presentacion = obra
        guard !self.presentaciones.isEmpty else {return celda}
        
        fechaLabel.text = self.obtenerMes(fechaStr: presentaciones[indexPath.row].dia)
        funcionLabel.text = presentaciones[indexPath.row].hora
        escaneadasLabel.text = "\(presentaciones[indexPath.row].escaneados)  /"
        compradasLabel.text = "\(presentaciones[indexPath.row].ocupados)"
        
        return celda
    }
    
    func obtenerMes(fechaStr:String) -> String
    {
        let formatoFecha = DateFormatter()
        formatoFecha.locale = Locale(identifier: "es_PE")
        formatoFecha.dateFormat = "dd/MM/yyyyy"
        let fecha = formatoFecha.date(from: fechaStr)
        
        formatoFecha.dateFormat = "MMMM d"
        var mes = formatoFecha.string(from: fecha!)
        mes.insert(Character(String(mes.removeFirst()).uppercased()), at: mes.startIndex)
        
        return mes
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
