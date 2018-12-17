//
//  KontenedoreServices.swift
//  Kontenedores
//
//  Created by Admin on 28/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import Alamofire

class KontenedoreServices: NSObject
{
    static let instancia =  KontenedoreServices()
    
    let urlBase = "http://68.183.115.4/api"
    
    //MARK: REGISTRAR USUARIO
    
    func registrarUsuario(usuario:Usuario,bloqueCompletacion:@escaping(_ msj :Any?) -> Void)
    {
        let urlRegistro = urlBase + "/signup"
        
        let parametros : [String :String] = ["name":usuario.nombre + " " +  usuario.apellido,"phone":usuario.celular,"email":usuario.email,"password":usuario.contrasena,"password_confirmation":usuario.repetirContrasena]
    
        Alamofire.request(urlRegistro, method: .post, parameters: parametros, encoding: URLEncoding.default, headers: [:]).responseJSON { (respuesta) in
            
            print("Resultado",respuesta.result)
            print("Valor",respuesta.value)
            
//            if let data = respuesta.data {
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                print("Respuesta Registrar Usuario: \(json)")
//            }
            
            let valor = respuesta.value as? [String:Any]
            bloqueCompletacion(valor?["message"])
        }
    }
    
    //MARK: INICIAR SESION
    
    func iniciarSesion(email:String,contrasena:String,tokenFcm:String,bloqueCompletacion:@escaping(_ usuario :Any?) -> Void)
    {
        let urlLogin = urlBase + "/login"
        
        let parametros : Parameters = ["email":email,"password":contrasena,"devicetoken":tokenFcm]
        
        Alamofire.request(urlLogin, method: .post, parameters: parametros, encoding: URLEncoding.default, headers: [:]).responseJSON { (respuesta) in
            
            //print("Resultado",respuesta.result)
            //print("Data",respuesta.data)
            print("Valor",respuesta.value)
            let valor = respuesta.value
            
            if respuesta.result.isSuccess {
                if let valorDict = valor as? [String:Any]
                {
//                    print("Valor Dict",valorDict)
                    guard let data = valorDict["data"] as? [String:Any] else {
                        bloqueCompletacion(nil)
                        return
                    }
                    
                    let id = data["id"] as? Int ?? 0
                    let nombre = data["name"] as? String ?? "No Nombre"
                    let celular = data["phone"] as? String ?? "No Numero"
                    let tipo = data["type"] as? String ?? "No especificado"
                    let email = data["email"] as?  String ?? "No email"
                    let tokenUsuario = data["access_token"] as? String ?? "No hay token"
                    
                    let usuario = Usuario(id:id,nombre: nombre, email: email, celular: celular, tipo: tipo, token: tokenUsuario)
                    
                    bloqueCompletacion(usuario)
                }
            }else
            {
                 bloqueCompletacion(nil)
            }
        }
        
    }
    
    //MARK: OBTENER SALDO DE USUARIO
    
    func obtenerSaldoDisponible(tokenUsuario:String,bloqueCompletacion:@escaping(_ usuario :Any?) -> Void)
    {
        let urlSaldoDisponible = urlBase + "/saldos/disponible"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlSaldoDisponible, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
        
            print("Resultado",respuesta.result)
            print("Valor",respuesta.value)
            
//            if let data = respuesta.data {
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                print("Data Response de Obtener Saldo: \(json)")
//            }
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                if let valorDict = valor
                {
                    //print("Valor Dict",valorDict)
                    guard let saldo = valorDict["data"] as? Double else
                    {
                        let msj = valorDict["message"] as? String
                        bloqueCompletacion(msj)
                        return
                    }
                    
                    bloqueCompletacion(saldo)
                }
                
            }else
            {
                let msj = valor?["message"] as? String
                bloqueCompletacion(msj)
            }
        }
    }
    
    //MARK: RECARGAR SALDO
    
    func recargarSaldo(tokenUsuario:String,saldo:Double,idCulqi:String,bloqueCompletacion:@escaping(_ usuario :Any?) -> Void)
    {
        let urlSaldoDisponible = urlBase + "/saldos"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        let parametros : Parameters = ["saldo":saldo,"id_culqi":idCulqi]
        
        Alamofire.request(urlSaldoDisponible, method: .post, parameters: parametros, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
//            print("Resultado",respuesta.result)
//            print("Valor",respuesta.value)
            
            if respuesta.result.isSuccess
            {
                bloqueCompletacion(nil)
            }else
            {
                bloqueCompletacion(nil)
            }
        }
    }
    
    //MARK: LISTADO DE OBRAS
    
    func obtenerObras(todasLasObras:Bool,bloqueCompletacion:@escaping(_ obras:Any?) -> Void)
    {
        let todas =  (todasLasObras) ? "" : "/?date=thisWeek"
        
        let urlObra = urlBase + "/obras" + todas
        
        Alamofire.request(urlObra).responseJSON { (respuesta) in
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {return}
//                let dataStr = String(data: data, encoding: .utf8)
//                print(dataStr)
                do
                {
                    let dataObras = try JSONDecoder().decode(DataObras.self, from: data)
                    bloqueCompletacion(dataObras.data)
                }catch let jsonErr
                {
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                  bloqueCompletacion(nil)
            }
        }
    }
    
    //MARK: COMPRAR ENTRADA
    
    func comprarEntrada(tokenUsuario:String,presentacionId:Int,nroEntradas:Int,bloqueCompletacion:@escaping(_ obras:Any?) -> Void)
    {
        let urlComprar = urlBase + "/obras/compras"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        let parametros : Parameters = ["presentacion_id":presentacionId,"cantidad":nroEntradas]
        
        Alamofire.request(urlComprar, method: .post, parameters: parametros, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print("Resultado",respuesta.result)
            print("Valor",respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                if let valorDict = valor
                {
                    guard let data = valorDict["data"] as? [String:Any] else {
                    
                        let msj = valorDict["message"] as? String
                        
                        bloqueCompletacion(msj)
                        return
                    }
                    
                    let saldo = data["saldo_disponible"] as? Double
               
                    bloqueCompletacion(saldo)
                }
                
            }else
            {
                let msj = valor?["message"] as? String
                bloqueCompletacion(msj)
            }
        }
    }
    
    //MARK: OBTENER ENTRADAS
    
    func obtenerEntradas(tokenUsuario:String,bloqueCompletacion:@escaping(_ entradas:Any?) -> Void)
    {
        let urlEntradas = urlBase + "/compras/obras"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlEntradas, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print("Resultado",respuesta.result)
            print("Valor",respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataEntradas = try JSONDecoder().decode(FacturaEntrada.self, from: data)
                    bloqueCompletacion(dataEntradas.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    //MARK: OBTENER PRODUCTOS
    
    func obtenerProductos(tokenUsuario:String,bloqueCompletacion:@escaping(_ productos:Any?) -> Void)
    {
        let urlProductos = urlBase + "/compras/productos"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlProductos, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print("Resultado",respuesta.result)
            print("Valor",respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataProductos = try JSONDecoder().decode(FacturaProducto.self, from: data)
                    bloqueCompletacion(dataProductos.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    //MARK: OBTENER RECARGAS
    
    func obtenerRecargas(tokenUsuario:String,bloqueCompletacion:@escaping(_ recargas:Any?) -> Void)
    {
        let urlRecarga = urlBase + "/saldos"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlRecarga, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            //print("Resultado",respuesta.result)
            //print("Valor",respuesta.value)
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataRecargas = try JSONDecoder().decode(DataRecarga.self, from: data)
                    bloqueCompletacion(dataRecargas.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    //MARK: SERVICIOS DEL PROVEEDOR
    
    func obtenerProductosProveedor(tokenUsuario:String,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlProductosProveedor = urlBase + "/productos"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlProductosProveedor, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataCategorias = try JSONDecoder().decode(DataCategoria.self, from: data)
                    bloqueCompletacion(dataCategorias.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
            
        }
        
    }
    
    func obtenerCategorias(tokenUsuario:String,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlProductosProveedor = urlBase + "/productos/categorias"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlProductosProveedor, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print(respuesta.result)
            print(respuesta.value)
            
            if let data = respuesta.data {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print("Data Response de Actualizar Pedido: \(json)")
            }
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataCategorias = try JSONDecoder().decode(DataCategoria.self, from: data)
                    bloqueCompletacion(dataCategorias.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
            
        }
        
    }
    
    func obtenerProductosDeCategoria(tokenUsuario:String,idCategoria:Int,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlProductosProveedor = urlBase + "/productos/categorias/\(idCategoria)"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
    
        Alamofire.request(urlProductosProveedor, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print(respuesta.result)
            print(respuesta.value)
            
            if let data = respuesta.data {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print("Data Response de Actualizar Pedido: \(json)")
            }
        
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataProductos = try JSONDecoder().decode(DataProductos.self, from: data)
                    bloqueCompletacion(dataProductos.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                  bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    //MARK: OBTENER LAS VENTAS DEL DIA
    
    func obtenerVentasPorDia(tokenUsuario:String,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        ///?date=toDay
        let urlVentasDia = urlBase + "/productos/ventas"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlVentasDia, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print(respuesta.result)
            print(respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataVentas = try JSONDecoder().decode(DataVenta.self, from: data)
                    bloqueCompletacion(dataVentas.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
            
        }
        
    }
    
    
    //MARK: MANDAR PEDIDO
    
    func mandarPedido(tokenUsuario:String,idCliente:Int,monto:Double,pedidos:[[String:Any]],bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlPedido = urlBase + "/productos/compras"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        let parametros : Parameters = ["cliente_id":idCliente,"productos":pedidos]
    
        Alamofire.request(urlPedido, method: .post, parameters: parametros, encoding: JSONEncoding.default, headers: cabecera).responseJSON { (respuesta) in

//            if let data = respuesta.data {
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                print("Failure Response: \(json)")
//            }

            print(respuesta.result)
            print(respuesta.value)

            let valor = respuesta.value as? [String:Any]

            if respuesta.result.isSuccess
            {
                if let valorRespuesta = valor
                {
                    guard let data = valorRespuesta["data"] as? [String:Any] else {
                        bloqueCompletacion(nil)
                        return
                    }

                    let compra = data["compra"] as? [String:Any]
                    let idCompra = compra?["id"] as? Int

                    bloqueCompletacion(idCompra)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    //MARK: CONSULTAR ESTADO PEDIDO
    
    func estadoPedido(tokenUsuario:String,idCompra:Int,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlEstadoPedido = urlBase + "/productos/compras/\(idCompra)"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlEstadoPedido, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in

            print("//----------------------------------//")
            print("CONSULTAMOS EL ESTADO DEL PEDIDO")
            print("//----------------------------------//")
            
            print(respuesta.result)
            print(respuesta.value)
            
//            if let data = respuesta.data {
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                //print("Data Response de Estado Pedido: \(json)")
//            }
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                if let valorRespuesta = valor
                {
                    guard let data = valorRespuesta["data"] as? [String:Any] else {
                        bloqueCompletacion(nil)
                        return
                    }
                
                    let estatus = data["estatus"] as? String
                    bloqueCompletacion(estatus)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }        
    }

    //MARK: ACTUALIZAR ESTADO PEDIDO
    
    func actualizarPedido(tokenUsuario:String,idCompra:Int,estatus:Bool,bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlActualizarPedido = urlBase + "/productos/compras/\(idCompra)"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        let parametros : Parameters = ["estatus":estatus]
        
        Alamofire.request(urlActualizarPedido, method: .put, parameters: parametros, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print(respuesta.result)
            print(respuesta.value)
            
            if let data = respuesta.data {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print("Data Response de Actualizar Pedido: \(json)")
            }
            
            print("Exito? :", respuesta.result.isSuccess)
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let json = valor, let data = json["data"] as? [String:Any] else {return}
                
                let saldo = data["saldo_disponible"] as? Double
                bloqueCompletacion(saldo)
            }else
            {
                bloqueCompletacion(nil)
            }
            
        }
    }
    
    
    //MARK: LISTA PEDIDOS ENCODING
    
    struct PedidosEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
            return request
        }
    }
    
    //
    
    func consultarEstadoPedido(tokenUsuario:String,idCliente:Int,pedidos:[[String:Any]],bloqueCompletacion:@escaping(_ producto:Any?) -> Void)
    {
        let urlPedido = urlBase + "/productos/compras"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlPedido, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            print(respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                
            }else
            {
                let msj = valor?["message"] as? String
                bloqueCompletacion(msj)
            }
            
        }
    }
    
    
    
    //MARK: SERVICIOS DEL USUARIO SCAN ENTRADAS OBRAS
    
    func obtenerEntrada(tokenUsuario:String,idEntrada:Int,bloqueCompletacion:@escaping(_ obras:Any?) -> Void)
    {
        let urlEntrada = urlBase + "/entrada/\(idEntrada)"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlEntrada, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            //print("Resultado",respuesta.result)
            //print("Valor",respuesta.value)
            
            let valor = respuesta.value as? [String:Any]
            
            if respuesta.result.isSuccess
            {
                guard let data = respuesta.data else {
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                //let dataStr = String(data: data, encoding: .utf8)
                //print(dataStr)
                do
                {
                    let dataTicket = try JSONDecoder().decode(DataTicket.self, from: data)
                    bloqueCompletacion(dataTicket.data)
                }catch let jsonErr
                {
                    print("JsonErr",jsonErr.localizedDescription)
                    bloqueCompletacion(jsonErr.localizedDescription)
                }
            }else
            {
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    
    
     func actualizarEntrada(tokenUsuario:String,idEntrada:Int,bloqueCompletacion:@escaping(_ obras:Any?) -> Void)
     {
        let urlEntrada = urlBase + "/entrada/\(idEntrada)"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlEntrada, method: .put, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
            let valor = respuesta.value as? [String:Any]
        
//            print("Respuesta Data",respuesta.data)
//            print("Respuesta Value",valor)
            
            if respuesta.result.isSuccess
            {
                guard let _ = valor?["data"] else {
                    print("Respuesta Exitosa pero sin Data")
                    bloqueCompletacion(valor?["message"] as? String)
                    return
                }
                
                print("Entrada Actualizada")
                bloqueCompletacion(respuesta.result.isSuccess)
                
            }else
            {
                print("Hubo en Error ,Failure")
                bloqueCompletacion(valor?["message"] as? String)
            }
        }
    }
    
    
    //MARK: CERRAR SESION
    
    func cerrarSesion(tokenUsuario:String,bloqueCompletacion:@escaping(_ obras:Any?) -> Void)
    {
        let urlDeslogueo = urlBase + "/logout"
        
        let cabecera : HTTPHeaders = ["Authorization":"Bearer" + " " + tokenUsuario]
        
        Alamofire.request(urlDeslogueo, method: .get, parameters: nil, encoding: URLEncoding.default, headers: cabecera).responseJSON { (respuesta) in
            
//            print("Resultado",respuesta.result)
//            print("Valor",respuesta.value)
            
            bloqueCompletacion(respuesta.result.isSuccess)
        }
    }
}
