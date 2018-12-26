//
//  Obra.swift
//  Kontenedores
//
//  Created by Admin on 22/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class DataObras: Decodable
{
    let data : [Obra]
}

struct Obra : Decodable
{
    var id :Int
    var proveedor_id :Int
    var titulo :String
    var descripcion:String
    var imagen:String
    var created_at :String
    var updated_at :String
    var etiqueta:String
    var presentaciones : [Presentacion]?
    var desplegarse : Bool? = false
}

struct Presentacion : Decodable
{
    var id : Int
    var proveedor_id : Int
    var obra_id:Int
    var dia : String
    var hora : String
    var kontenedor : Int
    var precio : Double
    var ocupados: Int
    var disponibilidad : Bool
    var escaneados : Int
    var obra: Obra?
}
