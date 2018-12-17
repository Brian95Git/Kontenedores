//
//  Venta.swift
//  Kontenedores
//
//  Created by Admin on 17/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class DataVenta: Decodable {

    let data : [Venta]
}

struct Venta : Decodable
{
    var id : Int
    var cliente_id : Int
    var proveedor_id : Int
    var vendedor : Int
    var fecha : String
    var estatus : String
    var hora : String
    var monto: Double
    var cliente:Cliente
}

struct Cliente : Decodable
{
    var id : Int
    var name : String
}
