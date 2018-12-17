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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //portadaObra.layer.cornerRadius = 20
        
        sombraPortadaObra.layer.shadowOpacity = 0.6
        sombraPortadaObra.layer.shadowRadius = 5.5
        
        clipsToBounds = true
        self.establecerCintillo()
    }
    
    func establecerCintillo()
    {
        let posX = (bounds.width / 2) * 0.6
        let posY = (bounds.height / 2) * 0.2
        
        let dimensiones = CGRect(x: posX, y: posY, width: self.bounds.width, height: self.bounds.height * 0.1)
        
        let vistaCintillo = UIView(frame: dimensiones)
        vistaCintillo.backgroundColor = UIColor.yellow
        
        vistaCintillo.transform = CGAffineTransform(rotationAngle: CGFloat(45.0.degreesToRadians))
        
        let labelCintillo = UILabel(frame: CGRect(x: 0, y: 0, width: vistaCintillo.bounds.width, height: vistaCintillo.bounds.height))
        
        labelCintillo.font = UIFont(name: "System", size: 10)
        
        labelCintillo.textColor = UIColor.black
        labelCintillo.text = "Prime Time"
        labelCintillo.textAlignment = .center

        vistaCintillo.addSubview(labelCintillo)
        
        self.addSubview(vistaCintillo)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        portadaObra.image = nil
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
