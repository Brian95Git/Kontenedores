//
//  PedidosVC.swift
//  KontenedoresTest
//
//  Created by Admin on 16/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

class PedidosVC: UIViewController,UITableViewDataSource,UITableViewDelegate,CantidadProducto {

    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tablaPedidos: UITableView!
    @IBOutlet weak var btnConfirmar: UIButton!
    
    //var precioActual : Double = 0
    var totalPrecioTxt = ""
    var idsCategorias : [Int] = []
    //var categoriasElegidas = [String]()
    
    var categoriasElegidas = [Categoria]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tablaPedidos.dataSource = self
        tablaPedidos.delegate = self
        totalLabel.text = totalPrecioTxt
        
        self.categoriasElegidas = CategoriasVC.categorias.filter({ (categoria) -> Bool in
            
            let idPedido = CategoriasVC.pedidos.contains(where: { (pedido) -> Bool in
                return pedido.producto.categoria_id == categoria.id
            })
            
            return idPedido
        })
        
//        CategoriasVC.pedidos.forEach { (pedido) in
//        
//            
//            
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tablaPedidos.reloadData()
        self.btnConfirmar.isUserInteractionEnabled = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categoriasElegidas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let pedidosPorCategoria = CategoriasVC.pedidos.filter({ (pedido) -> Bool in
            return categoriasElegidas[section].id == pedido.producto.categoria_id
        })
        
        return pedidosPorCategoria.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "pedidoCell", for: indexPath) as! ProductoTBCell

        celda.delegado = self
        celda.seccion = indexPath.section
        celda.tag = indexPath.row
        
        let pedidosPorCategoriaLista = CategoriasVC.pedidos.filter{ (pedido) -> Bool in
            return pedido.producto.categoria_id == categoriasElegidas[indexPath.section].id
        }
        
        celda.configurarCeldaProducto(producto: pedidosPorCategoriaLista[indexPath.row].producto)
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(categoriasElegidas[section].nombre)"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func definirCantidadProducto(producto:inout Producto,cantidad:Int, indiceCelda: Int,seccionCelda:Int) {
        
        guard cantidad <= 10 else {return}
        
        CategoriasVC.precioActual += producto.precio
        
        CategoriasVC.precioActual = (CategoriasVC.precioActual <= 0) ? 0 : CategoriasVC.precioActual
        
        totalLabel.text = "Total : S/ " + CategoriasVC.precioActual.valorNumerico2DecimalesStr()
        
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
        
        if cantidad > 0
        {
            CategoriasVC.pedidos.append(pedido)
        }else
        {
            let indexSet = IndexSet(integer:seccionCelda)
            let indexPath = IndexPath(row: indiceCelda, section: seccionCelda)
            
            self.tablaPedidos.deleteRows(at: [indexPath], with: .left)
            self.tablaPedidos.reloadSections(indexSet, with: .none)
            
//            let pedidosPorCategoriaLista = CategoriasVC.pedidos.filter{ (pedido) -> Bool in
//                return pedido.producto.nombreCategoria == nombresCategorias[seccionCelda]
//            }
//            
//            if pedidosPorCategoriaLista.isEmpty
//            {
//                //self.tablaPedidos.deleteSections(indexSet, with: .left)
//                self.tablaPedidos.reloadData()
//            }else
//            {
//            
//            }
        }
    }
    

    
    @IBAction func volverPedidos(_ segue : UIStoryboardSegue)
    {
        
    }
    
    @IBAction func confirmarVenta(_ sender: UIButton)
    {
        if CategoriasVC.pedidos.count > 0
        {
            sender.isUserInteractionEnabled = false
            
            self.performSegue(withIdentifier: "goToEscanerQR", sender: CategoriasVC.pedidos)
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
