//
//  Producto.swift
//  Kontenedores
//
//  Created by Admin on 7/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class FacturaProducto: Decodable {
    let data : [Compra]
}

struct ProductoFactura : Decodable
{
    var id : Int
    var cliente_id:Int
    var proveedor_id:Int
    var fecha:String
    var hora:String
    //var detalles:[Compra]
}

struct Compra : Decodable
{
    var id :Int
    var cliente_id:Int
    var proveedor_id:Int
    var vendedor:Int
    var fecha:String
    var estatus:String
    var hora:String
    var created_at:String
    var nombreproveedor: String
    var monto:Double
}

struct ProductoUsuario : Decodable
{
    var id :Int
    var categoria_id:Int
    var proveedor_id:Int
    var nombre:String
    var precio:Double
    var categoria:CategoriaUsuario
}

struct CategoriaUsuario : Decodable
{
    var id :Int
    var nombre:String
    var descripcion:String
    var user_id:Int
}

