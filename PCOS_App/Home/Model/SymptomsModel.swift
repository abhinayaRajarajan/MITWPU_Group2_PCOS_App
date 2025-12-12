//
//  SymptomsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

// MARK: - Symptom Item
struct SymptomItem {
    let id: String
    let name: String
    let iconName: String // SF Symbol name
    let color: UIColor
    let category: SymptomCategory
    
    var isSelected: Bool = false
}

// MARK: - Symptom Category
enum SymptomCategory: String, CaseIterable {
    case spotting = "Spotting"
    case discharge = "Discharge"
    case pain = "Pain"
    case skinAndHair = "Skin and Hair"
    case lifestyle = "Lifestyle"
    case gutHealth = "Gut health"
    case breastSelfExam = "Breast self exam"
    
    var symptoms: [SymptomItem] {
        switch self {
        case .spotting:
            return [
                SymptomItem(id: "spotting_light", name: "Light", iconName: "drop.fill", color: .systemPink, category: .spotting),
                SymptomItem(id: "spotting_brown", name: "Brown", iconName: "drop.fill", color: .systemBrown, category: .spotting)
            ]
            
        case .discharge:
            return [
                SymptomItem(id: "discharge_dry", name: "Dry", iconName: "aqi.low", color: .systemOrange, category: .discharge),
                SymptomItem(id: "discharge_sticky", name: "Sticky", iconName: "drop.fill", color: .systemTeal, category: .discharge),
                SymptomItem(id: "discharge_creamy", name: "Creamy", iconName: "circle.fill", color: .systemPink, category: .discharge),
                SymptomItem(id: "discharge_watery", name: "Watery", iconName: "drop.fill", color: .systemBlue, category: .discharge),
                SymptomItem(id: "discharge_egg_white", name: "Egg white", iconName: "circle.fill", color: .systemYellow, category: .discharge),
                SymptomItem(id: "discharge_unusual", name: "Unusual", iconName: "exclamationmark.circle.fill", color: .systemPurple, category: .discharge),
                SymptomItem(id: "discharge_spotting", name: "Spotting", iconName: "drop.fill", color: .systemPink, category: .discharge),
                SymptomItem(id: "discharge_none", name: "None", iconName: "nosign", color: .systemPink, category: .discharge)
            ]
            
        case .pain:
            return [
                SymptomItem(id: "pain_abdominal", name: "Abdominal cramps", iconName: "bolt.fill", color: .systemPurple, category: .pain),
                SymptomItem(id: "pain_tender_breasts", name: "Tender Breasts", iconName: "heart.fill", color: .systemPurple, category: .pain),
                SymptomItem(id: "pain_low_back", name: "Low back pain", iconName: "figure.stand", color: .systemPink, category: .pain),
                SymptomItem(id: "pain_headache", name: "Headache", iconName: "brain.head.profile", color: .systemPurple, category: .pain),
                SymptomItem(id: "pain_vulvar", name: "Vulvar pain", iconName: "flame.fill", color: .systemPurple, category: .pain)
            ]
            
        case .skinAndHair:
            return [
                SymptomItem(id: "skin_acne", name: "Acne", iconName: "circle.hexagongrid.fill", color: .systemPurple, category: .skinAndHair),
                SymptomItem(id: "skin_hair_loss", name: "Hair loss", iconName: "leaf.fill", color: .systemPurple, category: .skinAndHair),
                SymptomItem(id: "skin_darkening", name: "Skin darkening", iconName: "moon.fill", color: .systemPurple, category: .skinAndHair),
                SymptomItem(id: "skin_hirsutism", name: "Hirsutism", iconName: "waveform", color: .systemPurple, category: .skinAndHair)
            ]
            
        case .lifestyle:
            return [
                SymptomItem(id: "lifestyle_fatigue", name: "Fatigue", iconName: "bed.double.fill", color: .systemPurple, category: .lifestyle),
                SymptomItem(id: "lifestyle_insomnia", name: "Insomnia", iconName: "moon.zzz.fill", color: .systemPurple, category: .lifestyle),
                SymptomItem(id: "lifestyle_depressed", name: "Depressed", iconName: "cloud.rain.fill", color: .systemPurple, category: .lifestyle),
                SymptomItem(id: "lifestyle_anxiety", name: "Anxiety", iconName: "tornado", color: .systemPurple, category: .lifestyle)
            ]
            
        case .gutHealth:
            return [
                SymptomItem(id: "gut_bloating", name: "Bloating", iconName: "circle.fill", color: .systemPink, category: .gutHealth),
                SymptomItem(id: "gut_constipation", name: "Constipation", iconName: "exclamationmark.triangle.fill", color: .systemPurple, category: .gutHealth),
                SymptomItem(id: "gut_diarrhea", name: "Diarrhea", iconName: "drop.fill", color: .systemBlue, category: .gutHealth),
                SymptomItem(id: "gut_gas", name: "Gas", iconName: "wind", color: .systemPurple, category: .gutHealth)
            ]
            
        case .breastSelfExam:
            return [
                SymptomItem(id: "breast_normal", name: "Everything normal", iconName: "checkmark.circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_enlargement", name: "Enlargement", iconName: "arrow.up.circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_lump", name: "Lump", iconName: "circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_skin_change", name: "Skin change", iconName: "waveform.path", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_soft_tissue", name: "Soft tissue", iconName: "heart.circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_cracked_nipple", name: "Cracked nipple", iconName: "exclamationmark.circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_pain", name: "Pain", iconName: "bolt.circle.fill", color: .systemPink, category: .breastSelfExam),
                SymptomItem(id: "breast_nipple_discharge", name: "Nipple discharge", iconName: "drop.circle.fill", color: .systemPink, category: .breastSelfExam)
            ]
        }
    }
}

// MARK: - Symptom Log Entry
struct SymptomLogEntry {
    let date: Date
    let selectedSymptoms: [SymptomItem]
    
    var displayText: String {
        if selectedSymptoms.isEmpty {
            return "No symptoms logged"
        }
        return selectedSymptoms.map { $0.name }.joined(separator: ", ")
    }
}
