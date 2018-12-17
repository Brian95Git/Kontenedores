//
//  Entrada.swift
//  Kontenedores
//
//  Created by Admin on 7/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class FacturaEntrada: Decodable {
    let data : [EntradaFactura]
}

struct EntradaFactura : Decodable
{
    var id : Int
    var cliente_id:Int
    var proveedor_id:Int
    var fecha:String
    var hora:String
    var detalles:[Entrada]
}

//-----------------------------------------------//

struct DataTicket :Decodable
{
    let data : Ticket
}

struct Ticket : Decodable
{
    let entrada : Entrada
    let presentacion : Presentacion
    let obra : Obra
}

struct Entrada : Decodable
{
    var id :Int
    var compra_id:Int
    var producto_id:Int
    var precio_final:Double
    var cantidad:Int
    var tipo:String
    var estatus:String
    var created_at:String
    var presentacion: Presentacion?
}

struct EntradaPreeliminar
{
    var id: Int
    var nombreObra : String
    var dia : String
    var horario : String
    var nroEntradas : Int
    var precio : Double
}
