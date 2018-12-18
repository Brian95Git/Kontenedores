//
//  QRScanVC.swift
//  KontenedoresTest
//
//  Created by Admin on 17/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var vistaCamara: UIView!
    @IBOutlet weak var vistaConfirmacion: UIView!
    @IBOutlet weak var confirmacionLabel: UILabel!
    @IBOutlet weak var btnContinuar: UIButton!
    @IBOutlet weak var activityConfirmacion: UIActivityIndicatorView!
    
    @IBOutlet weak var imgConfirmacion: UIImageView!
    
    
    
    var video = AVCaptureVideoPreviewLayer()
    var idCliente : Int?
    var listaPedidos = [[String:Any]]()
    
    var estadoConfirmacion = "pendiente"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("El precio actual es ",CategoriasVC.precioActual.valorNumerico2Decimales())
        print("Tengo de pedidos : ",CategoriasVC.pedidos.count)
        
       self.imgConfirmacion.transform = CGAffineTransform(scaleX: 0, y: 0)
        
       self.vistaConfirmacion.transform = CGAffineTransform(scaleX: 0, y: 0)
        
       self.btnContinuar.isHidden = true
        //listaPedidos.removeAll()
        
        CategoriasVC.pedidos.forEach { (pedido) in
            
            let pedidoUsuario : [String:Any] = ["id":pedido.producto.id,"precio":pedido.producto.precio,"cantidad":pedido.cantidad]
        
            listaPedidos.append(pedidoUsuario)
        }
        
        //print(listaPedidos)
        
        let sesion = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("No Camara")
            return
        }
        
        print("Accedemos a la camara")
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            sesion.addInput(input)
        }
        catch
        {
            print("Error")
        }
        
        let output = AVCaptureMetadataOutput()
        sesion.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        self.vistaCamara.layoutIfNeeded()
        self.vistaCamara.layoutSubviews()
        
        video = AVCaptureVideoPreviewLayer(session: sesion)
        video.frame = vistaCamara.layer.bounds
        self.vistaCamara.layer.addSublayer(video)
        
        self.vistaCamara.layoutSublayers(of: self.video)
        
        sesion.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0
        {
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            {
                if object.type == .qr
                {
                    //print(object.stringValue ?? "Ninguna Cadena")
                    
                    if self.idCliente == nil
                    {
                        self.idCliente = Int(object.stringValue!)!
                        print("IdClient :", idCliente!)
                        
                        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
                        //print(tokenUsuario!)
                        
                        KontenedoreServices.instancia.mandarPedido(tokenUsuario: tokenUsuario!, idCliente: self.idCliente!, monto: CategoriasVC.precioActual.valorNumerico2Decimales(), pedidos: self.listaPedidos) { (respuesta) in
                        
                            if let idCompra = respuesta as? Int
                            {
                                print("Id de la Compra" , idCompra)
                                self.llamarVistaConfirmacion()
                                self.consultarEstadoPedido(tokenUsuario: tokenUsuario!, idCompra: idCompra,estado: "pendiente")
                            }else
                            {
                                self.estadoConfirmacion = "sinsaldo"
                                self.llamarVistaConfirmacion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func llamarVistaConfirmacion()
    {
        self.vistaConfirmacion.layer.shadowOpacity = 0.75
        self.vistaConfirmacion.layer.shadowRadius = 20
        
        self.activityConfirmacion.startAnimating()
        
        UIView.animate(withDuration: 0.275, delay: 0, usingSpringWithDamping: 0.475, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
            self.vistaConfirmacion.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (bool) in
            
            if self.estadoConfirmacion == "sinsaldo"
            {
                self.activityConfirmacion.stopAnimating()
                
                UIView.animate(withDuration: 0.25) {
                    self.vistaConfirmacion.backgroundColor = UIColor.orange
                }
                
                self.imgConfirmacion.image = #imageLiteral(resourceName: "billetera")
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.475, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.imgConfirmacion.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { (bool) in
                }
                
                self.confirmacionLabel.text = "Saldo insuficiente."
                
                self.btnContinuar.isHidden = false
            }
        }
    }
    
    @IBAction func continuar(_ sender: Any)
    {
        if self.estadoConfirmacion  == "pagado"
        {
            CategoriasVC.pedidos.removeAll()
            CategoriasVC.precioActual = 0
        }
        
        self.performSegue(withIdentifier: "volverPedidos", sender: nil)
    }
    
    func consultarEstadoPedido(tokenUsuario:String,idCompra :Int,estado:String)
    {
        print("El estado del Pedido es", estado)
        
        if estado != "pendiente" {
         
            let confirmacion = (estado == "pagado")
            
            self.activityConfirmacion.stopAnimating()
            
            UIView.animate(withDuration: 0.5) {
                 self.vistaConfirmacion.backgroundColor = (confirmacion) ? #colorLiteral(red: 0, green: 0.8431372549, blue: 0.4862745098, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
            
            self.imgConfirmacion.image = (confirmacion) ? #imageLiteral(resourceName: "check_confirmacion") : #imageLiteral(resourceName: "cancel")
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.475, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                self.imgConfirmacion.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (bool) in
            }
            
            
            self.confirmacionLabel.text = (confirmacion) ? "El comprador aceptó la venta." : "El comprador rechazó la venta."
            
            self.btnContinuar.isHidden = false
        
            self.estadoConfirmacion = estado
            
            return
        }
        
        KontenedoreServices.instancia.estadoPedido(tokenUsuario: tokenUsuario, idCompra: idCompra) { (respuesta) in
            
            if let estatusActual = respuesta as? String
            {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                    
                    self.consultarEstadoPedido(tokenUsuario: tokenUsuario, idCompra: idCompra, estado: estatusActual)
                })
                
            }
        }
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
