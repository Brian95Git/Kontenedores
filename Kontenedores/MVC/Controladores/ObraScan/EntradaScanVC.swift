//
//  EntradaScanVC.swift
//  Kontenedores
//
//  Created by Admin on 10/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

class EntradaScanVC: BaseViewController,AVCaptureMetadataOutputObjectsDelegate
{
    @IBOutlet weak var vistaCamara: UIView!
    
    var video = AVCaptureVideoPreviewLayer()
    
    //var ticket: Ticket!
    
    var idEntrada :Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.addSlideMenuButton()
        
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
        //print("View Will Appear")
        self.idEntrada = nil
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
                    if self.idEntrada == nil
                    {
                        self.idEntrada = Int(object.stringValue!)
                        
                        let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token
                        
                        KontenedoreServices.instancia.obtenerEntrada(tokenUsuario: tokenUsuario!, idEntrada: idEntrada!) { (respuesta) in
                            
                            if let ticket = respuesta as? Ticket
                            {
                                print("Obtenemos el ticket del Usuario")
                                self.performSegue(withIdentifier: "goToTicket", sender: ticket)
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func regresarEntradaScan(_ segue: UIStoryboardSegue)
    {
        
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToTicket"
        {
            let ticketVC = segue.destination as! TicketVC
            ticketVC.ticket = sender as? Ticket
        }
        
    }

}
