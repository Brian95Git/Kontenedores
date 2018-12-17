//
//  CategoriaProducto.swift
//  Kontenedores
//
//  Created by Admin on 22/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class DataCategoria:Decodable {

    let data : Categorias
}

struct Categorias : Decodable
{
    var categoria:[Categoria]
}

struct DataProductos : Decodable
{
    var data: ProductosCategoria
}

struct ProductosCategoria:Decodable
{
    var categoria:Categoria
}

struct Categoria : Decodable
{
    var id: Int
    var nombre : String
    var descripcion:String
    var created_at:String
    var user_id:Int
    var productos : [Producto]?
}

struct Producto :Decodable{
    var id:Int
    var categoria_id:Int
    var proveedor_id:Int
    var nombreCategoria : String?
    var nombre : String
    var precio : Double
    var created_at:String
}

struct Pedido
{
    var cantidad = 0
    var producto : Producto
}
