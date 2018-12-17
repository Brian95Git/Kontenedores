//
//  FuncionesTBCell.swift
//  PushNotificacionTest
//
//  Created by Admin on 7/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import AVFoundation

protocol ComprarEntrada
{
    func entradaComprada(horario:String,nroEntradaLabel:String)
}

class FuncionesTBCell: UITableViewCell {

    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var nroEntradaLabel: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    var nro = 1
    var delegadoEntrada : ComprarEntrada?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        imgCheck.image = (selected) ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "borderCheck")
    }
    
    
    @IBAction func SumRestEntrada(_ sender: UIButton)
    {
        nro += (sender.tag == 1) ? 1 : -1
        nro = Int(simd_clamp(Float(nro), 1, 5))
        nroEntradaLabel.text = String(nro)
    }
    
    @IBAction func comprarEntrada(_ sender: UIButton)
    {
       delegadoEntrada?.entradaComprada(horario: horarioLabel.text!, nroEntradaLabel: nroEntradaLabel.text!)
    }
}
