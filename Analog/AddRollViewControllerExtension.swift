//
//  AddRollViewControllerExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 2018/7/12.
//  Copyright © 2018 Zizhou Wang. All rights reserved.
//

import Foundation

extension AddRollViewController {
    static let predefinedRolls: [String : PredefinedRoll] = [
        "Kodak Tri-X 400 (135, 36exp.)" : PredefinedRoll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Ektar 100 (135)" : PredefinedRoll(filmName: "Kodak Ektar 100", format: 135, frameCount: 36, iso: 100),
        "Ilford HP5 Plus (135, 36exp.)" : PredefinedRoll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 400 (135)" : PredefinedRoll(filmName: "Kodak Portra 400", format: 135, frameCount: 36, iso: 400),
        "Ilford HP5 Plus (120)" : PredefinedRoll(filmName: "Ilford HP5 Plus", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 800 (135)" : PredefinedRoll(filmName: "Kodak Portra 800", format: 135, frameCount: 36, iso: 800),
        "Kodak T-Max 400 (135)" : PredefinedRoll(filmName: "Kodak T-Max 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 160 (135)" : PredefinedRoll(filmName: "Kodak Portra 160", format: 135, frameCount: 36, iso: 160),
        "Kodak Portra 400 (120)" : PredefinedRoll(filmName: "Kodak Portra 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 3200 (135)" : PredefinedRoll(filmName: "Ilford Delta 3200", format: 135, frameCount: 36, iso: 3200),
        "Kodak GC/UltraMax 400 (135, 36exp.)" : PredefinedRoll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Provia 100F (135)" : PredefinedRoll(filmName: "Fujichrome Provia 100F", format: 135, frameCount: 36, iso: 100),
        "Ilford Delta 3200 (120)" : PredefinedRoll(filmName: "Ilford Delta 3200", format: 120, frameCount: 0, iso: 3200),
        "Ilford Delta 100 (120)" : PredefinedRoll(filmName: "Ilford Delta 100", format: 120, frameCount: 0, iso: 100),
        "Fujicolor PRO 400H (135)" : PredefinedRoll(filmName: "Fujicolor PRO 400H", format: 135, frameCount: 36, iso: 400),
        "Kodak GC/UltraMax 400 (135, 24exp.)" : PredefinedRoll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 24, iso: 400),
        "Fujifilm Neopan 100 Acros (135)" : PredefinedRoll(filmName: "Fujifilm Neopan 100 Acros", format: 135, frameCount: 36, iso: 100),
        "Kodak Ektar 100 (120)" : PredefinedRoll(filmName: "Kodak Ektar 100", format: 120, frameCount: 0, iso: 100),
        "Kodak T-Max 100 (135, 36exp.)" : PredefinedRoll(filmName: "Kodak T-Max 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (120)" : PredefinedRoll(filmName: "Ilford FP4 Plus", format: 120, frameCount: 0, iso: 125),
        "Ilford Pan F Plus (120)" : PredefinedRoll(filmName: "Ilford Pan F Plus", format: 120, frameCount: 0, iso: 50),
        "Cinestill 800Tungsten Xpro (135)" : PredefinedRoll(filmName: "Cinestill 800Tungsten Xpro", format: 135, frameCount: 36, iso: 800),
        "Kodak Tri-X 400 (120)" : PredefinedRoll(filmName: "Kodak Tri-X 400", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 160 (120)" : PredefinedRoll(filmName: "Kodak Portra 160", format: 120, frameCount: 0, iso: 160),
        "Fujicolor Superia 1600 (135)" : PredefinedRoll(filmName: "Fujicolor Superia 1600", format: 135, frameCount: 36, iso: 1600),
        "Ilford Delta 400 (120)" : PredefinedRoll(filmName: "Ilford Delta 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 400 (135)" : PredefinedRoll(filmName: "Ilford Delta 400", format: 135, frameCount: 36, iso: 400),
        "Ilford Pan F Plus (135)" : PredefinedRoll(filmName: "Ilford Pan F Plus", format: 135, frameCount: 36, iso: 50),
        "Ilford Delta 100 (135)" : PredefinedRoll(filmName: "Ilford Delta 100", format: 135, frameCount: 36, iso: 100),
        "Fujichrome Velvia 100 (135)" : PredefinedRoll(filmName: "Fujichrome Velvia 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (135)" : PredefinedRoll(filmName: "Ilford FP4 Plus (135)", format: 135, frameCount: 36, iso: 125),
        "AgfaPhoto Vista Plus 400 (135)" : PredefinedRoll(filmName: "AgfaPhoto Vista Plus 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Tri-X 400 (135, 24exp.)" : PredefinedRoll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 24, iso: 400),
        "Fujicolor Superia X-TRA 400 (135, 24exp.)" : PredefinedRoll(filmName: "Fujicolor Superia X-TRA 400", format: 135, frameCount: 24, iso: 400),
        "Ilford XP2 Super (135)" : PredefinedRoll(filmName: "Ilford XP2 Super", format: 135, frameCount: 36, iso: 400),
        "Kodak GOLD 200 (135)" : PredefinedRoll(filmName: "Kodak GOLD 200", format: 135, frameCount: 36, iso: 200),
        "Kentmere 400 (135)" : PredefinedRoll(filmName: "Kentmere 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Velvia 50 (135)" : PredefinedRoll(filmName: "Fujichrome Velvia 50", format: 135, frameCount: 36, iso: 50),
        "Kodak Portra 800 (120)" : PredefinedRoll(filmName: "Kodak Portra 800", format: 120, frameCount: 0, iso: 800),
        "CineStill 50Daylight Xpro (135)" : PredefinedRoll(filmName: "CineStill 50Daylight Xpro", format: 135, frameCount: 36, iso: 50),
        "LomoChrome Purple XR 400 (135)" : PredefinedRoll(filmName: "LomoChrome Purple XR 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor PRO 400H (120)" : PredefinedRoll(filmName: "Fujicolor Pro 400H", format: 120, frameCount: 0, iso: 400),
        "Fujicolor 200 (135, 36exp.)" : PredefinedRoll(filmName: "Fujicolor 200", format: 135, frameCount: 36, iso: 200),
        "Ilford HP5 Plus (135, 24exp.)" : PredefinedRoll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 24, iso: 400),
        "Arista EDU Ultra 400 (135)" : PredefinedRoll(filmName: "Aristra EDU Ultra 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor Supera X-Tra 400 (135)" : PredefinedRoll(filmName: "Fujicolor Supera X-Tra 400", format: 135, frameCount: 36, iso: 400),
        "Aristra EDU Ultra 100 (120)" : PredefinedRoll(filmName: "Aristra EDU Ultra 100", format: 120, frameCount: 0, iso: 100),
        "Kentmere 100 (135)" : PredefinedRoll(filmName: "Kentmere 100", format: 135, frameCount: 36, iso: 100),
        "Arista EDU Ultra 400 (120)" : PredefinedRoll(filmName: "Arista EDU Ultra 400", format: 120, frameCount: 0, iso: 400),
        "Fujicolor Superia X-TRA 800 (135, 24xep.)" : PredefinedRoll(filmName: "Fujicolor Superia X-TRA 800", format: 135, frameCount: 24, iso: 800),
        "Bergger Pancro 400 (135)" : PredefinedRoll(filmName: "Bergger Pancro 400", format: 135, frameCount: 36, iso: 400),
        "Rollei Digibase CR 200 PRO (135)" : PredefinedRoll(filmName: "Rollei Digibase CR 200 PRO", format: 135, frameCount: 36, iso: 200),
        "Kodak T-Max 100 (135, 24exp.)" : PredefinedRoll(filmName: "Kodak T-Max 100", format: 135, frameCount: 24, iso: 100),
        "Fujicolor 200 (135, 24exp.)" : PredefinedRoll(filmName: "Fujicolor 200", format: 135, frameCount: 24, iso: 200),
        "AgfaPhoto Vista plus 200 (135)" : PredefinedRoll(filmName: "AgfaPhoto Vista plus 200", format: 135, frameCount: 36, iso: 200),
        "Fujicolor Superia X-TRA 800 (135, 36exp.)" : PredefinedRoll(filmName: "Fujicolor Superia X-TRA 800", format: 135, frameCount: 36, iso: 800),
        "Rollei Infrared 400 (120)" : PredefinedRoll(filmName: "Rollei Infrared 400", format: 120, frameCount: 0, iso: 400),
        "Fujifilm Neopan 100 (120)" : PredefinedRoll(filmName: "Fujifilm Neopan 100", format: 120, frameCount: 0, iso: 100),
        "Rollei Infrared 400 (135)" : PredefinedRoll(filmName: "Rollei Infrared 400", format: 135, frameCount: 36, iso: 400)
    ]
}
