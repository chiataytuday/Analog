//
//  PredefinedRollsExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation

extension Roll {
    static let predefinedRolls: [String : Roll] = [
        "Kodak Tri-X 400 (135, 36exp.)" : Roll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Ektar 100 (135)" : Roll(filmName: "Kodak Ektar 100", format: 135, frameCount: 36, iso: 100),
        "Ilford HP5 Plus (135, 36exp.)" : Roll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 400 (135)" : Roll(filmName: "Kodak Portra 400", format: 135, frameCount: 36, iso: 400),
        "Ilford HP5 Plus (120)" : Roll(filmName: "Ilford HP5 Plus", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 800 (135)" : Roll(filmName: "Kodak Portra 800", format: 135, frameCount: 36, iso: 800),
        "Kodak T-Max 400 (135)" : Roll(filmName: "Kodak T-Max 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 160 (135)" : Roll(filmName: "Kodak Portra 160", format: 135, frameCount: 36, iso: 160),
        "Kodak Portra 400 (120)" : Roll(filmName: "Kodak Portra 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 3200 (135)" : Roll(filmName: "Ilford Delta 3200", format: 135, frameCount: 36, iso: 3200),
        "Kodak GC/UltraMax 400 (135, 36exp.)" : Roll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Provia 100F (135)" : Roll(filmName: "Fujichrome Provia 100F", format: 135, frameCount: 36, iso: 100),
        "Ilford Delta 3200 (120)" : Roll(filmName: "Ilford Delta 3200", format: 120, frameCount: 0, iso: 3200),
        "Ilford Delta 100 (120)" : Roll(filmName: "Ilford Delta 100", format: 120, frameCount: 0, iso: 100),
        "Fujicolor PRO 400H (135)" : Roll(filmName: "Fujicolor PRO 400H", format: 135, frameCount: 36, iso: 400),
        "Kodak GC/UltraMax 400 (135, 24exp.)" : Roll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 24, iso: 400),
        "Fujifilm Neopan 100 Acros (135)" : Roll(filmName: "Fujifilm Neopan 100 Acros", format: 135, frameCount: 36, iso: 100),
        "Kodak Ektar 100 (120)" : Roll(filmName: "Kodak Ektar 100", format: 120, frameCount: 0, iso: 100),
        "Kodak T-Max 100 (135)" : Roll(filmName: "Kodak T-Max 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (120)" : Roll(filmName: "Ilford FP4 Plus", format: 120, frameCount: 0, iso: 125),
        "Ilford Pan F Plus (120)" : Roll(filmName: "Ilford Pan F Plus", format: 120, frameCount: 0, iso: 50),
        "Cinestill 800Tungsten Xpro (135)" : Roll(filmName: "Cinestill 800Tungsten Xpro", format: 135, frameCount: 36, iso: 800),
        "Kodak Tri-X 400 (120)" : Roll(filmName: "Kodak Tri-X 400", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 160 (120)" : Roll(filmName: "Kodak Portra 160", format: 120, frameCount: 0, iso: 160),
        "Fujicolor Superia 1600 (135)" : Roll(filmName: "Fujicolor Superia 1600", format: 135, frameCount: 36, iso: 1600),
        "Ilford Delta 400 (120)" : Roll(filmName: "Ilford Delta 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 400 (135)" : Roll(filmName: "Ilford Delta 400", format: 135, frameCount: 36, iso: 400),
        "Ilford Pan F Plus (135)" : Roll(filmName: "Ilford Pan F Plus", format: 135, frameCount: 36, iso: 50),
        "Ilford Delta 100 (135)" : Roll(filmName: "Ilford Delta 100", format: 135, frameCount: 36, iso: 100),
        "Fujichrome Velvia 100 (135)" : Roll(filmName: "Fujichrome Velvia 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (135)" : Roll(filmName: "Ilford FP4 Plus (135)", format: 135, frameCount: 36, iso: 125),
        "AgfaPhoto Vista Plus 400 (135)" : Roll(filmName: "AgfaPhoto Vista Plus 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Tri-X 400 (135, 24exp.)" : Roll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 24, iso: 400),
        "Fujicolor Superia X-TRA 400 (135, 24exp.)" : Roll(filmName: "Fujicolor Superia X-TRA 400", format: 135, frameCount: 24, iso: 400),
        "Ilford XP2 Super (135)" : Roll(filmName: "Ilford XP2 Super", format: 135, frameCount: 36, iso: 400),
        "Kodak GOLD 200 (135)" : Roll(filmName: "Kodak GOLD 200", format: 135, frameCount: 36, iso: 200),
        "Kentmere 400 (135)" : Roll(filmName: "Kentmere 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Velvia 50 (135)" : Roll(filmName: "Fujichrome Velvia 50", format: 135, frameCount: 36, iso: 50),
        "Kodak Portra 800 (120)" : Roll(filmName: "Kodak Portra 800", format: 120, frameCount: 0, iso: 800),
        "CineStill 50Daylight Xpro (135)" : Roll(filmName: "CineStill 50Daylight Xpro", format: 135, frameCount: 36, iso: 50),
        "LomoChrome Purple XR 400 (135)" : Roll(filmName: "LomoChrome Purple XR 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor PRO 400H (120)" : Roll(filmName: "Fujicolor Pro 400H", format: 120, frameCount: 0, iso: 400),
        "Fujicolor 200 (135)" : Roll(filmName: "Fujicolor 200", format: 135, frameCount: 36, iso: 200),
        "Ilford HP5 Plus (135, 24exp.)" : Roll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 24, iso: 400),
        "Arista EDU Ultra 400 (135)" : Roll(filmName: "Aristra EDU Ultra 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor Supera X-Tra 400 (135)" : Roll(filmName: "Fujicolor Supera X-Tra 400", format: 135, frameCount: 36, iso: 400),
        "Aristra EDU Ultra 100 (120)" : Roll(filmName: "Aristra EDU Ultra 100", format: 120, frameCount: 0, iso: 100)
    ]
}
