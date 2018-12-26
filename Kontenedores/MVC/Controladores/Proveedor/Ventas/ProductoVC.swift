//
//  ProductoVC.swift
//  KontenedoresTest
//
//  Created by Admin on 15/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

class ProductoVC: UIViewController,UITableViewDataSource,UITableViewDelegate,CantidadProducto {

    @IBOutlet weak var tablaProductos: UITableView!
    @IBOutlet weak var btnPrecioTotal: UIButton!
    @IBOutlet weak var precioTotalLabel: UILabel!
    
    var categoria : Categoria!
    var productos : [Producto] = []
    //var categoriasElegidas = [Categoria]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tablaProductos.dataSource = self
        tablaProductos.delegate = self
       
        
        let refreshControl = UIRefreshControl(frame: self.tablaProductos.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerProductos), for: .valueChanged)
        
        self.tablaProductos.refreshControl = refreshControl
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.obtenerProductos()
        
        let precioTotalStr = CategoriasVC.precioActual > 0 ? CategoriasVC.precioActual.valorNumerico2DecimalesStr() : "0.00"
        
        precioTotalLabel.text = "Total : S/ " + precioTotalStr
    }
    
    @objc func obtenerProductos()
    {
        self.tablaProductos.refreshControl?.beginRefreshing()
        
        self.comprobarInternet { (disponible, msj) in
            DispatchQueue.main.async {
                if !disponible
                {
                    self.tablaProductos.refreshControl?.endRefreshing()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.obtenerProductosWS()
                }
            }
        }
    }

    func obtenerProductosWS()
    {        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.obtenerProductosDeCategoria(tokenUsuario: tokenUsuario!,idCategoria:categoria.id) { (respuesta) in
            
            if let productosCategoria = respuesta as? ProductosCategoria
            {
                self.productos.removeAll()
                self.productos = productosCategoria.categoria.productos!
                
                self.tablaProductos.refreshControl?.endRefreshing()
                self.tablaProductos.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "productoCell", for: indexPath) as! ProductoTBCell
        
        celda.tag = indexPath.row
        
        celda.delegado = self
        celda.configurarCeldaProducto(producto: self.productos[indexPath.row])

        return celda
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(categoria.nombre)"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func definirCantidadProducto(producto:inout Producto,cantidad:Int, indiceCelda: Int,seccionCelda:Int) {
    
        guard cantidad <= 10 else {return}
        
        CategoriasVC.precioActual += producto.precio
        
        CategoriasVC.precioActual = (CategoriasVC.precioActual <= 0) ? 0 : CategoriasVC.precioActual
        
        self.precioTotalLabel.text = "Total : S/ " + CategoriasVC.precioActual.valorNumerico2DecimalesStr()
        
        if producto.precio < 0 {producto.precio.negate()}
        
        let pedido = Pedido.init(cantidad: cantidad, producto: producto)
        
        if let pedidoRepetido = CategoriasVC.pedidos.first(where: { (pedidoFirst) -> Bool in
            return pedidoFirst.producto.nombre == producto.nombre
        })
        {
            CategoriasVC.pedidos.removeAll { (pedidoRemover) -> Bool in
                return pedidoRemover.producto.nombre == pedidoRepetido.producto.nombre
            }
        }
        
        if cantidad > 0 {CategoriasVC.pedidos.append(pedido)}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    @IBAction func volverProductos(_ segue : UIStoryboardSegue)
    {
        
    }
    
    @IBAction func nuevaOrden(_ sender: Any)
    {
        CategoriasVC.pedidos.removeAll()
        CategoriasVC.precioActual = 0
        
        self.precioTotalLabel.text = "Total : S/ " + CategoriasVC.precioActual.valorNumerico2DecimalesStr()
        
        self.tablaProductos.reloadData()
    }
    
    
    // MARK: - Confirmar Venta
    
    @IBAction func confirmarVenta(_ sender: UIButton)
    {
        if !CategoriasVC.pedidos.isEmpty
        {
            self.performSegue(withIdentifier: "goToListaPedidos", sender: self)
        }
    }

     // MARK: - Precio Total en Cadena de Texto
//    func precioTotalStr() -> String
//    {
//        //Con esta clase podemos limitar los numeros de digitos de nuestro numero despues del separador decimal.
//
//        let precioFormato = NumberFormatter()
//        precioFormato.allowsFloats = true
//        precioFormato.maximumFractionDigits = 2
//        precioFormato.minimumFractionDigits = 2
//
//        let nsNumberPrecio = CategoriasVC.precioActual
//        let precioTotalStr = precioFormato.string(from: nsNumberPrecio as NSNumber)!
//
//        return precioTotalStr
//    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToListaPedidos"
        {
            let pedidosVC = segue.destination as! PedidosVC
            pedidosVC.totalPrecioTxt = precioTotalLabel.text!
            //pedidosVC.categoriasElegidas = sender as! [Categoria]
        }

    }
}
