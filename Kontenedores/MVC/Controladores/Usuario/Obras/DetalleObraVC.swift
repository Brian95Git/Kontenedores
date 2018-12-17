//
//  DetalleObraVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 5/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

class DetalleObraVC: UIViewController,UITableViewDataSource,UITableViewDelegate,ComprarEntrada
{
    
    @IBOutlet weak var btnSaldo: UIBarButtonItem!
    @IBOutlet weak var nombreObraLabel: UILabel!
    @IBOutlet weak var funcionesTV: UITableView!
    @IBOutlet weak var obraImg: UIImageView!
    @IBOutlet weak var nroEntradaLabel: UILabel!
    @IBOutlet weak var precioObraLabel: UILabel!
    @IBOutlet weak var descripcionTxtView: UITextView!
    @IBOutlet weak var btnConfirmar: UIButton!
    @IBOutlet weak var scrollDetalleObra: UIScrollView!
    
    var obra : Obra!
    
    var miEntrada = EntradaPreeliminar(id:0,nombreObra: "_", dia: "_", horario: "_", nroEntradas: 0, precio: 0.0)
    //var celdaSeleccionada : UITableViewCell?
    
    var nombreObraSelect = ""
    var horarioObraSelect = ""
    var imgObraSelect = UIImage()
    var nroEntradas = 1
    
    var presentacion : Presentacion?
    
    var presentacionesObra : [Presentacion] = []
    
    var diaEscogido = "Viernes"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //horarioDia = horariosViernes
        funcionesTV.dataSource = self
        funcionesTV.delegate = self
        
        nombreObraLabel.text = obra.titulo 
        obraImg.image = imgObraSelect
        
        self.descripcionTxtView.text = obra.descripcion 
        self.descripcionTxtView.scrollsToTop = true
        
        presentacionesObra = (obra.presentaciones?.filter({ (presentacion) -> Bool in
            let dia = obtenerDia(fechaStr: presentacion.dia)
            return dia == "Friday"
        }))!
        
        self.precioPorFuncion(presentacion: presentacionesObra.first)
        funcionesTV.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btnConfirmar.isUserInteractionEnabled = true
    }
    
     //MARK: Escoger Dia
    
    @IBAction func escogerDia(_ sender: UISegmentedControl)
    {
        let indexSegment = sender.selectedSegmentIndex
        
        self.diaEscogido = sender.titleForSegment(at: indexSegment)!
        
        self.nroEntradas = 1
        self.nroEntradaLabel.text = String(self.nroEntradas)
        
        presentacionesObra = []

        switch indexSegment {
        case 0:
//            horarioDia = horariosViernes
            
            let viernes = obra.presentaciones?.filter({ (presentacion) -> Bool in
                let dia = obtenerDia(fechaStr: presentacion.dia)
                return dia == "Friday"
            })
            
            presentacionesObra = viernes!
            
            self.presentacion = presentacionesObra.first
            self.precioPorFuncion(presentacion: self.presentacion)
            
        case 1:
//            horarioDia = horariosSabado
            
            let sabado = obra.presentaciones?.filter({ (presentacion) -> Bool in
                let dia = obtenerDia(fechaStr: presentacion.dia)
                return dia == "Saturday"
            })
            
            presentacionesObra = sabado!
            
            self.presentacion = presentacionesObra.first
            self.precioPorFuncion(presentacion: presentacionesObra.first)
            
        case 2:
//            horarioDia = horariosDomingo
            
            let domingo = obra.presentaciones?.filter({ (presentacion) -> Bool in
                let dia = obtenerDia(fechaStr: presentacion.dia)
                return dia == "Sunday"
            })
            
            presentacionesObra = domingo!
            
            self.presentacion = presentacionesObra.first
            self.precioPorFuncion(presentacion: presentacionesObra.first)
            
        default:
            break
        }
        
        funcionesTV.reloadData()
        self.btnConfirmar.backgroundColor = UIColor.lightGray

    }
    
    //MARK: Obtener Dia
    
    func obtenerDia(fechaStr:String) -> String
    {
        let formatoFecha = DateFormatter()
        formatoFecha.dateFormat = "dd/MM/yyyyy"
        let fecha = formatoFecha.date(from: fechaStr)
        
        formatoFecha.dateFormat = "EEEE"
        let dia = formatoFecha.string(from: fecha!).capitalized
        
        return dia
    }
    
    //MARK: Precio por Funcion
    
    func precioPorFuncion(presentacion:Presentacion?)
    {
        if let presentacion = presentacion
        {
            let precioActual = presentacion.precio.valorNumerico2Decimales() * Double(nroEntradas)
            self.precioObraLabel.text = "S/ " + precioActual.valorNumerico2DecimalesStr()
        }else
        {
            self.precioObraLabel.text = "S/ 0.00"
        }
    }
    
    //MARK: Volver Detalles Obras
    
    @IBAction func volverDetalleObras(segue:UIStoryboardSegue)
    {
      
    }
    
    @IBAction func verHorarios(_ sender: UIButton)
    {
        let rect = CGRect(x: btnConfirmar.frame.origin.x, y: btnConfirmar.frame.origin.y + 40, width: btnConfirmar.bounds.width, height: btnConfirmar.bounds.height)
        
        self.scrollDetalleObra.scrollRectToVisible(rect, animated: true)
    }
    
    //MARK: Table View Funciones Obras
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentacionesObra.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "funcionCell", for: indexPath) as! FuncionesTBCell
        
        celda.horarioLabel.text = presentacionesObra[indexPath.row].hora
        celda.delegadoEntrada = self
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let celdaFuncion = tableView.cellForRow(at: indexPath) as! FuncionesTBCell
        
        miEntrada.id = presentacionesObra[indexPath.row].id
        miEntrada.horario = celdaFuncion.horarioLabel.text!
        miEntrada.precio = presentacionesObra[indexPath.row].precio
        
        self.presentacion = presentacionesObra[indexPath.row]
        
        self.precioPorFuncion(presentacion: self.presentacion)
        //miEntrada.precio = 65.50
        self.btnConfirmar.backgroundColor = #colorLiteral(red: 0, green: 0.8431372549, blue: 0.4862745098, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //celdaSeleccionada = nil
    }
    
    //MARK: Comprar Entradas
    
    func entradaComprada(horario: String, nroEntradaLabel: String) {
        
        let strs = [horario,nroEntradaLabel]
        self.performSegue(withIdentifier: "goToEntrada", sender: strs)
    }
    
    @IBAction func sumRestaEntradas(_ sender: UIButton)
    {
        guard let _ = funcionesTV.indexPathForSelectedRow else {return}
        
        nroEntradas += (sender.tag == 1) ? 1 : -1
        nroEntradas = Int(simd_clamp(Float(nroEntradas), 1, 5))
        nroEntradaLabel.text = String(nroEntradas)
        
        self.precioPorFuncion(presentacion: self.presentacion)
    }
    
    @IBAction func comprarEntradas(_ sender: UIButton)
    {
        guard let _ = funcionesTV.indexPathForSelectedRow
        else
        {
            print("Selecciona una celda antes de comprar.")
            let alertCtroller = UIAlertController(title: "Kontenedores", message: "Por favor, selecciona una función antes de comprar.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertCtroller.addAction(okAction)
            
            self.present(alertCtroller, animated: true, completion: nil)
            
            return
        }
        
//        print("Indice Celda es ",indiceCelda)
//        print("Horario Obra",horarioObraSelect)
        self.miEntrada.nombreObra = self.nombreObraLabel.text!
        self.miEntrada.dia = self.diaEscogido
        self.miEntrada.nroEntradas = Int(self.nroEntradaLabel.text!)!
        
        sender.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "goToEntrada", sender: miEntrada)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToEntrada"
        {
            let entradaVC = segue.destination as! EntradaVC
            entradaVC.miEntrada = sender as? EntradaPreeliminar
        }
    }
}
