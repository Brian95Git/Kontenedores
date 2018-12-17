//
//  TransferirVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 9/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class MisEntradasVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var entradasTV: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var diaHoyLabel: UILabel!

    var entradas : [Entrada] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSlideMenuButton()
        
        entradasTV.dataSource = self
        entradasTV.delegate = self
        
        self.fijarDia()
        
        //self.activityIndicator.startAnimating()
        
        let refreshControl = UIRefreshControl(frame: self.entradasTV.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerEntradas), for: .valueChanged)
        
        self.entradasTV.refreshControl = refreshControl
        
        self.obtenerEntradas()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fijarDia()
    {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "es_PE")
        dateFormat.dateFormat = "EEEE"
        
        var dia = dateFormat.string(from: Date())
        dia.insert(Character(String(dia.removeFirst()).uppercased()), at: dia.startIndex)

        self.diaHoyLabel.text = dia
    }
    
    @objc func obtenerEntradas()
    {
        print("Llamo Obtener las Entradas")
        if let refrescando = self.entradasTV.refreshControl,refrescando.isRefreshing
        {
            self.entradas.removeAll()
        }
        
        self.entradasTV.refreshControl?.beginRefreshing()
        
        let token = AppDelegate.instanciaCompartida.usuario?.token
        KontenedoreServices.instancia.obtenerEntradas(tokenUsuario: token!) { (respuesta) in
            
            if let entradas = respuesta as? [EntradaFactura]
            {
                entradas.forEach({ (factura) in
                    self.entradas += factura.detalles
                })
                
                //print("Ya Obtuve las entradas")
                
                self.entradasTV.refreshControl?.endRefreshing()
                self.entradasTV.reloadData()
                self.activityIndicator.stopAnimating()
            }else
            {
                print("Paso algo al querer obtener las entradas")
                
                let msj = respuesta as? String ?? "Lo sentimos,ocurrió un error al querer traer tus entradas."
                
                let alertController = UIAlertController(title: "Kontenedores", message: msj, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                }
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
    //MARK: TableView Entradas
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entradas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "entradaCell", for: indexPath)
        
        let nombreObraLabel = celda.contentView.viewWithTag(100) as! UILabel
        let fechaLabel = celda.contentView.viewWithTag(101) as! UILabel
        let nroKontenedor = celda.contentView.viewWithTag(102) as! UILabel
        let horarioLabel = celda.contentView.viewWithTag(106) as! UILabel
    
        let imgIcon = celda.contentView.viewWithTag(107) as! UIImageView
        
        nombreObraLabel.text = self.entradas[indexPath.row].presentacion!.obra?.titulo
        
        fechaLabel.text = obtenerMes(fechaStr: self.entradas[indexPath.row].presentacion!.dia)
        
        nroKontenedor.text = "kontenedor: \(self.entradas[indexPath.row].presentacion!.kontenedor)"
        
        horarioLabel.text = self.entradas[indexPath.row].presentacion!.hora
        
        let asistido = self.entradas[indexPath.row].estatus == "asistio"
        
        imgIcon.image = (asistido) ? #imageLiteral(resourceName: "check_green") : #imageLiteral(resourceName: "qrIcon")
 
        let anchuraImgIcon = (celda.contentView.constraints.first { (constraint) -> Bool in
            return constraint.identifier == "anchuraImg"
        })!
        
        anchuraImgIcon.constant = (asistido) ? -15 : 0
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let entrada = self.entradas[indexPath.row]
        
        let asistido = self.entradas[indexPath.row].estatus == "asistio"
        
        if !asistido
        {
            self.mostrarQR(entrada: entrada)
        }
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
    
    
    func generarCodidoQR(entrada:Entrada) -> UIImage
    {
        let filterQR = CIFilter(name: "CIQRCodeGenerator")!
        
        let idEntrada = String(entrada.id)
        
        print(idEntrada)
        
        let dataEntrada = idEntrada.data(using: .ascii, allowLossyConversion: false)
        
        filterQR.setValue(dataEntrada, forKey: "inputMessage")
        let scalarImgQR = CGAffineTransform(scaleX: 7, y: 7)
        let imgQR = UIImage(ciImage: filterQR.outputImage!.transformed(by: scalarImgQR))
        
        return imgQR
    }
    
    func mostrarQR(entrada:Entrada)
    {
        let alertController = UIAlertController(title: "Kontenedores", message: "Este es el código QR de tu entrada.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Aceptar", style: .default) { (action) in
            
        }
        
        let altura:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.bounds.height * 0.5)
        
        let imgQR = UIImageView(image: generarCodidoQR(entrada: entrada))
        alertController.view.addSubview(imgQR)
        
        imgQR.translatesAutoresizingMaskIntoConstraints = false
        
        let centerXImg = imgQR.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor)
        let centerYImg = imgQR.centerYAnchor.constraint(equalToSystemSpacingBelow: alertController.view.centerYAnchor, multiplier: 1.25)
        
        alertController.addAction(okAction)
        alertController.view.addConstraints([altura,centerXImg,centerYImg])
        
        self.present(alertController, animated: true, completion: nil)
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
