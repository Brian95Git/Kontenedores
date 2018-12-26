//
//  PagarVC.swift
//  Kontenedores
//
//  Created by Admin on 27/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class PagarVC: BaseViewController {

    @IBOutlet weak var imgViewQR: UIImageView!
    @IBOutlet weak var sueldoUsuarioLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSlideMenuButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(irListaPedidos), name: NSNotification.Name(rawValue: "ListaPedidos"), object: nil)
        
        print("Did Load Pagar VC")
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("Will Appear Pagar VC")
        
        self.imgViewQR.image = self.generarCodidoQR()
        
        self.pintarSaldoUsuario()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppDelegate.pushConfirmacionPedido
        {
            self.performSegue(withIdentifier: "goToConfirmacionPedido", sender: self)
        }
    }
    
    func pintarSaldoUsuario()
    {
        if let usuario = AppDelegate.instanciaCompartida.usuario,usuario.saldo > 0
        {
            self.sueldoUsuarioLabel.text = "S/ " + usuario.saldo.valorNumerico2DecimalesStr()
        }else
        {
            self.sueldoUsuarioLabel.text = "S/ 0.00"
        }
    }
    
    func generarCodidoQR() -> UIImage
    {
        let filterQR = CIFilter(name: "CIQRCodeGenerator")!
        
        let idUsuario = String((AppDelegate.instanciaCompartida.usuario?.id)!)
        
        print("Id Usuario : " + idUsuario)
        
        let dataEntrada = idUsuario.data(using: .ascii, allowLossyConversion: false)
        
        filterQR.setValue(dataEntrada, forKey: "inputMessage")
        let scalarImgQR = CGAffineTransform(scaleX: 15, y: 15)
        let imgQR = UIImage(ciImage: filterQR.outputImage!.transformed(by: scalarImgQR))
        
        return imgQR
    }
    
    @objc func irListaPedidos(notificacion:Notification)
    {
        print("Nos vamos a la Lista de Pedidos")
    
        let vc = self.navigationController?.visibleViewController
    
        if let vc = vc,!(vc is PagarVC)
        {
            print("No estamos en la pantalla PagarVC")
            AppDelegate.pushConfirmacionPedido = true
            
            let pagarVC : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "PagarVC")

            self.navigationController?.pushViewController(pagarVC, animated: true)
        }else
        {
            print("Si estamos en la pantalla PagarVC")
            self.performSegue(withIdentifier: "goToConfirmacionPedido", sender: self)
        }
    }
    
     //MARK: - Navigation
    
     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       //  Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToConfirmacionPedido"
        {
            //print(lista.first as? Int ?? 0)
            //print(lista.last as? Double ?? 0)
            
            //let confirmacionPedidoVC = segue.destination as! ListaPedidosVC
            //confirmacionPedidoVC.lista = sender as! [Any]
        }
    }
    

}
