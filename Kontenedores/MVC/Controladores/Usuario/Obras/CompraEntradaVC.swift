//
//  CompraEntradaVC.swift
//  Kontenedores
//
//  Created by Admin on 26/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class CompraEntradaVC: UIViewController {

    @IBOutlet weak var imgQR: UIImageView!
    
    var miEntrada : EntradaPreeliminar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imgQR.image = self.generarCodidoQR()
    }

    func generarCodidoQR() -> UIImage
    {
        let filterQR = CIFilter(name: "CIQRCodeGenerator")!
    
        let infoEntrada = "\(miEntrada.nombreObra) - \(miEntrada.dia) - \(miEntrada.horario) - \(miEntrada.nroEntradas)"
        
        let dataEntrada = infoEntrada.data(using: .ascii, allowLossyConversion: false)
        
        filterQR.setValue(dataEntrada, forKey: "inputMessage")
        let scalarImgQR = CGAffineTransform(scaleX: 15, y: 15)
        let imgQR = UIImage(ciImage: filterQR.outputImage!.transformed(by: scalarImgQR))
        
        return imgQR
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
