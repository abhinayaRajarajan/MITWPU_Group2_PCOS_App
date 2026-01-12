//
//  SymptomCategory.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//
import Foundation

struct SymptomCategory {
    let title: String
    let items: [SymptomItem]
    
    // Store all categories here as static data
    static let allCategories: [SymptomCategory] = [
        SymptomCategory(title: "Spotting", items: [
            SymptomItem(name: "Red", icon: "RedSpottingIcon"),
            SymptomItem(name: "Brown", icon: "BrownSpottingIcon")
        ]),
        SymptomCategory(title: "Discharge", items: [
            SymptomItem(name: "Dry", icon: "DryIcon"),
            SymptomItem(name: "Sticky", icon: "StickyIcon"),
            SymptomItem(name: "Creamy", icon: "CreamyIcon"),
            SymptomItem(name: "Watery", icon: "WateryIcon"),
            SymptomItem(name: "Egg White", icon: "EggWhiteIcon"),
            SymptomItem(name: "Unusual", icon: "UnusualIcon"),
            SymptomItem(name: "Position Cervix", icon: "PositionCervixIcon"),
            SymptomItem(name: "Texture", icon: "TextureIcon")
        ]),
        SymptomCategory(title: "Pain", items: [
            SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon"),
            SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon"),
            SymptomItem(name: "Low Back Pain", icon: "BackPainIcon"),
            SymptomItem(name: "Headache", icon: "HeadacheIcon"),
            SymptomItem(name: "Vulvar Pain", icon: "VulvarPainIcon")
        ]),
        SymptomCategory(title: "Skin and Hair", items: [
            SymptomItem(name: "Acne", icon: "AcneIcon"),
            SymptomItem(name: "Hair Loss", icon: "HairLossIcon"),
            SymptomItem(name: "Skin Darkening", icon: "SkinDarkeningIcon"),
            SymptomItem(name: "Hirsutism", icon: "HirutismIcon")
        ]),
        SymptomCategory(title: "Lifestyle", items: [
            SymptomItem(name: "Fatigue", icon: "FatigueIcon"),
            SymptomItem(name: "Insomnia", icon: "InsomniaIcon"),
            SymptomItem(name: "Depressed", icon: "DepressedIcon"),
            SymptomItem(name: "Anxiety", icon: "AnxietyIcon")
        ]),
        SymptomCategory(title: "Gut Health", items: [
            SymptomItem(name: "Bloating", icon: "BloatingIcon"),
            SymptomItem(name: "Constipated", icon: "ConstipationIcon"),
            SymptomItem(name: "Diarrhea", icon: "DiarrheaIcon"),
            SymptomItem(name: "Gas", icon: "GasIcon")
        ]),

    ]
}

