//
//  CategoriasVC.swift
//  KontenedoresTest
//
//  Created by Admin on 15/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class CategoriasVC: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tablaCategorias: UITableView!
    
    static var precioActual : Double = 0
    static var pedidos : [Pedido] = []
    static var categorias : [Categoria] = []
    
    var celdaCategoria : UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.addSlideMenuButton()
        
        self.tablaCategorias.dataSource = self
        self.tablaCategorias.delegate = self
        
        //self.setearCategorias()
        let refreshControl = UIRefreshControl(frame: self.tablaCategorias.bounds)
        refreshControl.tintColor = #colorLiteral(red: 0.5754463174, green: 0.1947190858, blue: 0.7834362566, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(self.obtenerCategorias), for: .valueChanged)
        
        self.tablaCategorias.refreshControl = refreshControl
        
        self.obtenerCategorias()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    /*func setearCategorias()
    {
        var bebidas : [Producto] = []
        var bebida = Producto(nombreCategoria: "Bebidas", nombre: "Pilsen", precio: 2.50)
        bebidas.append(bebida)
        bebida = Producto(nombreCategoria: "Bebidas", nombre: "Cusqueña", precio: 4.00)
        bebidas.append(bebida)
        bebida = Producto(nombreCategoria: "Bebidas", nombre: "Inca Kola", precio: 6.50)
        bebidas.append(bebida)
        bebida = Producto(nombreCategoria: "Bebidas", nombre: "Coca Cola", precio: 3.00)
        bebidas.append(bebida)
        bebida = Producto(nombreCategoria: "Bebidas", nombre: "Fanta", precio: 5.20)
        bebidas.append(bebida)
        bebida = Producto(nombreCategoria: "Bebidas", nombre: "Sprite", precio: 7.80)
        bebidas.append(bebida)
        
        var categoria = Categoria(nombre: "Bebidas", productos: bebidas)
        categorias.append(categoria)
        
        var postres = [Producto]()
        var postre = Producto(nombreCategoria: "Postres", nombre: "Torte Helada", precio: 3.00)
        postres.append(postre)
        postre = Producto(nombreCategoria: "Postres", nombre: "Torte Chocolate", precio: 4.00)
        postres.append(postre)
        postre = Producto(nombreCategoria: "Postres", nombre: "Tres Leches", precio: 5.50)
        postres.append(postre)
        postre = Producto(nombreCategoria: "Postres", nombre: "Pie de Limon", precio: 2.50)
        postres.append(postre)
        postre = Producto(nombreCategoria: "Postres", nombre: "Cremolada", precio: 3.50)
        postres.append(postre)
        postre = Producto(nombreCategoria: "Postres", nombre: "Selva Negra", precio: 4.20)
        postres.append(postre)
        
        categoria = Categoria(nombre: "Postres", productos: postres)
        categorias.append(categoria)
        
        var entradas = [Producto]()
        var entrada = Producto(nombreCategoria: "Entradas", nombre: "Causa Rellena", precio: 4.00)
        entradas.append(entrada)
        entrada = Producto(nombreCategoria: "Entradas", nombre: "Tequeños", precio: 6.00)
        entradas.append(entrada)
        entrada = Producto(nombreCategoria: "Entradas", nombre: "Caldo de Gallina", precio: 5.00)
        entradas.append(entrada)
        entrada = Producto(nombreCategoria: "Entradas", nombre: "Salpicon de Pollo", precio: 4.50)
        entradas.append(entrada)
        entrada = Producto(nombreCategoria: "Entradas", nombre: "Yuquitas Rellenas", precio: 6.80)
        entradas.append(entrada)
        entrada = Producto(nombreCategoria: "Entradas", nombre: "Palta Rellena", precio: 3.40)
        entradas.append(entrada)
        
        categoria = Categoria(nombre: "Entradas", productos: entradas)
        categorias.append(categoria)
        
        var segundos = [Producto]()
        var segundo = Producto(nombreCategoria: "Segundos", nombre: "Asado con Pure", precio: 14.00)
        segundos.append(segundo)
        segundo = Producto(nombreCategoria: "Segundos", nombre: "Lomo Saltado", precio: 11.50)
        segundos.append(segundo)
        segundo = Producto(nombreCategoria: "Segundos", nombre: "Pescado Frito con Lentejas", precio: 10.00)
        segundos.append(segundo)
        segundo = Producto(nombreCategoria: "Segundos", nombre: "Aji de Gallina", precio: 12.00)
        segundos.append(segundo)
        segundo = Producto(nombreCategoria: "Segundos", nombre: "Tallarines Verdes con Bisteck", precio: 13.00)
        segundos.append(segundo)
        segundo = Producto(nombreCategoria: "Segundos", nombre: "Seco de Carne con Frejoles", precio: 11.00)
        segundos.append(segundo)
        
        categoria = Categoria(nombre: "Segundos", productos: segundos)
        categorias.append(categoria)
    }
    */
    
    @objc func obtenerCategorias()
    {
        //if !self.comprobarInternet() {return}
        
        if let refrescando = self.tablaCategorias.refreshControl,!refrescando.isRefreshing
        {
            CategoriasVC.categorias.removeAll()
        }
        
        self.tablaCategorias.refreshControl?.beginRefreshing()
        
        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
        
        KontenedoreServices.instancia.obtenerCategorias(tokenUsuario: tokenUsuario!) { (respuesta) in
            
            if let dataCategoria = respuesta as? Categorias
            {
                CategoriasVC.categorias = dataCategoria.categoria
                self.tablaCategorias.refreshControl?.endRefreshing()
                self.tablaCategorias.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tablaCategorias.isUserInteractionEnabled = true
    }
    
    @IBAction func volverCategorias(_ segue:UIStoryboardSegue)
    {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  CategoriasVC.categorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "categoriaCell", for: indexPath)
        
        celda.tag = indexPath.row
        
        //let imgCategoria = celda.contentView.subviews.first as! UIImageView
        let categoriaTxt = celda.contentView.subviews.last as! UILabel
        
        //imgCategoria.image = UIImage(named: categorias[indexPath.row].nombre)!
        categoriaTxt.text =  CategoriasVC.categorias[indexPath.row].nombre

        return celda
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categorías Productos"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "goToProductoVC", sender:  tableView.cellForRow(at: indexPath))
        
        tablaCategorias.isUserInteractionEnabled = false
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //print("El sender es",sender)
        celdaCategoria = sender as? UITableViewCell
        
        let productoVC = segue.destination as! ProductoVC
        productoVC.categoria = CategoriasVC.categorias[(celdaCategoria?.tag)!]
    }
    

}
