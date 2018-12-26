//
//  ObraCVCell.swift
//  Kontenedores
//
//  Created by Admin on 11/12/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class ObraCVCell: UICollectionViewCell
{
    @IBOutlet weak var portadaObra: UIImageView!
    @IBOutlet weak var tituloObra: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sombraPortadaObra: UIView!
    
    //var obra :Obra?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //portadaObra.layer.cornerRadius = 20
        
        sombraPortadaObra.layer.shadowOpacity = 0.6
        sombraPortadaObra.layer.shadowRadius = 5.5
        
        clipsToBounds = true
        //self.establecerCintillo()
    }
    
    func establecerCintillo(obra:Obra)
    {
        let esPrimeTime = (obra.etiqueta == "primetime")
        
        let dimensiones = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 0.1)
        
        let vistaCintillo = UIView(frame: dimensiones)
        self.addSubview(vistaCintillo)
        
        vistaCintillo.backgroundColor = (esPrimeTime) ? UIColor.yellow : #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        vistaCintillo.transform = CGAffineTransform(rotationAngle: CGFloat(45.0.degreesToRadians))
        
        vistaCintillo.translatesAutoresizingMaskIntoConstraints = false
        
        let anchura = vistaCintillo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0)
        
        let altura = vistaCintillo.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1)
        
        let centerXVista = NSLayoutConstraint(item: vistaCintillo, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.6, constant: 0)
        
        let topVista = NSLayoutConstraint(item: vistaCintillo, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.275, constant: 0)
        
        NSLayoutConstraint.activate([centerXVista,topVista,anchura,altura])
        
        let labelCintillo = UILabel(frame: CGRect(x: 0, y: 0, width: vistaCintillo.bounds.width, height: vistaCintillo.bounds.height))
        vistaCintillo.addSubview(labelCintillo)
        
        labelCintillo.font = UIFont(name: "System", size: 10)
        
        labelCintillo.textColor = UIColor.black
        labelCintillo.text = (esPrimeTime) ? "Prime Time" : "Late Night"
        labelCintillo.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        portadaObra.image = nil
        //self.obra = nil
    }
    
    func pintarPortada(obra:Obra)
    {
        self.activityIndicator.startAnimating()
        
        //guard let urlImg = URL(string: obra.imagen) else {return}
        
        self.portadaObra.cargarImgDesdeURL(urlImg: obra.imagen) {
            self.activityIndicator.stopAnimating()
        }
        
//        DispatchQueue.global(qos: .background).async {
//            let data = try? Data(contentsOf: urlImg)
//            let img = UIImage(data: data!)!
//            DispatchQueue.main.async {
//                 self.portadaObra.image = img
//                 self.activityIndicator.stopAnimating()
//            }
//        }
    }
}

let imgCache  = NSCache<NSString,UIImage>()

extension UIImageView
{
    func cargarImgDesdeURL(urlImg:String,bloqueCompletacion:@escaping() -> Void)
    {
        guard let url = URL(string: urlImg) else {
            return
        }
        
        image = nil
        
        if let imgFromCache = imgCache.object(forKey: urlImg as NSString)
        {
            self.image = imgFromCache
            bloqueCompletacion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, respuesta, error) in
            
            if error != nil
            {
                print(error ?? "Nada")
                return
            }
            
            DispatchQueue.main.async {
                
                let imgToCache = UIImage(data:data!)!
                
                imgCache.setObject(imgToCache, forKey: urlImg as NSString)
                
                self.image = imgToCache
                
                bloqueCompletacion()
            }
            
        }.resume()
    }
}

extension FloatingPoint
{
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
