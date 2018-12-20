//
//  Recarga.swift
//  Kontenedores
//
//  Created by Admin on 8/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

struct DataRecarga : Decodable
{
    let data : [Recarga]
}

struct Recarga : Decodable
{
    var id :Int
    var cliente_id:Int
    var saldo:Double
    var fecha:String
    var card_brand:String
    var card_number:String
    var id_culqi:String
    var created_at:String
}
