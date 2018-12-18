//
//  ProductoTBCell.swift
//  KontenedoresTest
//
//  Created by Admin on 15/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

protocol CantidadProducto
{
    func definirCantidadProducto(producto:inout Producto,cantidad:Int,indiceCelda:Int,seccionCelda:Int)
}

class ProductoTBCell: UITableViewCell {

    @IBOutlet weak var nombreProducto: UILabel!
    @IBOutlet weak var precioProducto: UILabel!
    @IBOutlet weak var cantidadProducto: UILabel!
    
    var cantidad = 0
    var seccion = 0
    
    var producto : Producto?
    var delegado : CantidadProducto?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.producto = nil
    }
    
    func configurarCeldaProducto(producto:Producto)
    {
        if self.producto == nil
        {
            nombreProducto.text = producto.nombre            
            precioProducto.text = "S/ " + producto.precio.valorNumerico2DecimalesStr()
            
            self.producto = producto
        }
        
        if let pedido = CategoriasVC.pedidos.first(where: { (pedido) -> Bool in
            return pedido.producto.nombre == self.producto!.nombre
        })
        {
            cantidad = pedido.cantidad
        }else
        {
            cantidad = 0
        }
        
        cantidadProducto.text = String(cantidad)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func seleccionarCantidad(_ sender: UIButton)
    {
        let aumentar = (sender.tag == 1)
    
        producto!.precio *= (aumentar) ? 1  : -1
        
        if cantidad > 0 || aumentar
        {
            let cantidadProducto = (aumentar) ? cantidad + 1 : cantidad - 1
            delegado?.definirCantidadProducto(producto: &producto!, cantidad: cantidadProducto, indiceCelda: tag, seccionCelda: seccion)
        }
        
        cantidad += (aumentar) ? 1 : -1
        cantidad = Int(simd_clamp(Float(cantidad), 0, 10))
        
        cantidadProducto.text = String(cantidad)
    }
}
