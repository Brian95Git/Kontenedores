//
//  Usuario.swift
//  Kontenedores
//
//  Created by Admin on 22/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class Usuario: NSObject,NSCoding {
    
    var id :Int = 0
    var token :String = ""
    var nombre: String = ""
    var apellido :String = ""
    var dni :String = ""
    var email : String = ""
    var celular : String = ""
    var contrasena : String = ""
    var repetirContrasena : String = ""
    var tipo : String = ""
    var saldo : Double = -1
   
    
    override init() {
        super.init()
    }
    init(nombre:String,apellido:String,dni:String,celular:String,email:String,contrasena:String,repetirContrasena:String) {
        
        self.nombre = nombre
        self.apellido = apellido
        self.dni = dni
        self.celular = celular
        self.email = email
        self.contrasena = contrasena
        self.repetirContrasena = repetirContrasena
    }
    
    init(id:Int,nombre:String,email:String,celular:String,tipo:String,token:String)
    {
        self.id = id
        self.nombre = nombre
        self.email = email
        self.celular = celular
        self.tipo = tipo
        self.token = token
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id,forKey:"id")
        aCoder.encode(self.nombre,forKey:"nombre")
        aCoder.encode(self.email,forKey:"email")
        aCoder.encode(self.celular,forKey:"celular")
        aCoder.encode(self.tipo,forKey:"tipo")
        aCoder.encode(self.token,forKey:"token")
        aCoder.encode(self.saldo, forKey: "miSaldo")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.nombre = (aDecoder.decodeObject(forKey: "nombre") as? String)!
        self.email = (aDecoder.decodeObject(forKey: "email") as? String)!
        self.celular = (aDecoder.decodeObject(forKey: "celular") as? String)!
        self.tipo = (aDecoder.decodeObject(forKey: "tipo") as? String)!
        self.token = (aDecoder.decodeObject(forKey: "token") as? String)!
        self.saldo = aDecoder.decodeDouble(forKey: "miSaldo")
    }
}

extension Double
{
    func valorNumerico2Decimales() -> Double
    {
        let saldoFormato = NumberFormatter()
        saldoFormato.maximumFractionDigits = 2
        saldoFormato.minimumFractionDigits = 2
        
        let nsNumberPrecio = self as NSNumber
        
        let saldoStr = saldoFormato.string(from: nsNumberPrecio as NSNumber)!
        
        let saldo = Double(saldoStr)!
    
        return saldo
    }
    
    func valorNumerico2DecimalesStr() -> String
    {
        let saldoFormato = NumberFormatter()
        saldoFormato.maximumFractionDigits = 2
        saldoFormato.minimumFractionDigits = 2
        
        let nsNumberPrecio = self as NSNumber
        let saldoStr = saldoFormato.string(from: nsNumberPrecio as NSNumber)!
        
        return saldoStr
    }
}
