//
//  SymptomDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//

import Foundation


class SymptomDataStore {
    
    static let shared = SymptomDataStore()
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    private init() {}
    
    // MARK: - Load Symptoms
    static func loadSymptoms(for date: Date) -> [SymptomItem] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateKey = "symptoms_\(formatter.string(from: date))"
        
        // Check UserDefaults first
        if let savedData = UserDefaults.standard.data(forKey: dateKey),
           let decoded = try? JSONDecoder().decode([SymptomItemCodable].self, from: savedData) {
            return decoded.map { $0.toSymptomItem(date: date) }
        }
        
        // Fall back to mock data for demo purposes
        return getMockSymptoms(for: date)
    }
    
    // MARK: - Save Symptoms
    static func saveSymptoms(_ symptoms: [SymptomItem], for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = "symptoms_\(formatter.string(from: date))"
        
        let codableSymptoms = symptoms.map { SymptomItemCodable(from: $0) }
        
        if let encoded = try? JSONEncoder().encode(codableSymptoms) {
            UserDefaults.standard.set(encoded, forKey: dateKey)
        }
    }
    
    // MARK: - Mock Data
    private static func getMockSymptoms(for date: Date) -> [SymptomItem] {
        let calendar = Calendar.current
        let today = Date()
        let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: today)).day ?? 0
        
        switch daysDifference {
        case 0: // Today
            return [
                SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Bloating", icon: "BloatingIcon", isSelected: true, date: date,category: "Gut Health"),
                SymptomItem(name: "Fatigue", icon: "FatigueIcon", isSelected: true, date: date,category: "Lifestyle"),
                SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon", isSelected: true, date: date,category: "Pain")
            ]
            
        case 1: // Yesterday
            return [
                SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Low Back Pain", icon: "BackPainIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Headache", icon: "HeadacheIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Acne", icon: "AcneIcon", isSelected: true, date: date,category: "Skin and Hair"),
                SymptomItem(name: "Insomnia", icon: "InsomniaIcon", isSelected: true, date: date,category: "Lifestyle")
            ]
            
        case 2: // 2 days ago
            return [
                SymptomItem(name: "Red", icon: "RedSpottingIcon", isSelected: true, date: date,category: "Spotting"),
                SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Fatigue", icon: "FatigueIcon", isSelected: true, date: date,category: "Lifestyle"),
                SymptomItem(name: "Bloating", icon: "BloatingIcon", isSelected: true, date: date,category: "Gut Health"),
                SymptomItem(name: "Anxiety", icon: "AnxietyIcon", isSelected: true, date: date,category: "Lifestyle")
            ]
            
        case 3: // 3 days ago
            return [
                SymptomItem(name: "Red", icon: "RedSpottingIcon", isSelected: true, date: date,category: "Spotting"),
                SymptomItem(name: "Brown", icon: "BrownSpottingIcon", isSelected: true, date: date,category: "Spotting"),
                SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Low Back Pain", icon: "BackPainIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Depressed", icon: "DepressedIcon", isSelected: true, date: date,category: "Lifestyle"),
                SymptomItem(name: "Constipated", icon: "ConstipationIcon", isSelected: true, date: date,category: "Gut Health")
            ]
            
        case 4: // 4 days ago
            return [
                SymptomItem(name: "Red", icon: "RedSpottingIcon", isSelected: true, date: date,category: "Spotting"),
                SymptomItem(name: "Abdominal Cramp", icon: "AbdominalCrampsIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Headache", icon: "HeadacheIcon", isSelected: true, date: date,category: "Pain"),
                SymptomItem(name: "Acne", icon: "AcneIcon", isSelected: true, date: date,category: "Skin and Hair"),
                SymptomItem(name: "Fatigue", icon: "FatigueIcon", isSelected: true, date: date,category: "Lifestyle"),
                SymptomItem(name: "Bloating", icon: "BloatingIcon", isSelected: true, date: date,category: "Gut Health"),
                SymptomItem(name: "Gas", icon: "GasIcon", isSelected: true, date: date,category: "Gut Health")
            ]
            
        default:
            return []
        }
    }
}

// MARK: - Codable Wrapper
struct SymptomItemCodable: Codable {
    let name: String
    let icon: String
    let category: String
    let isSelected: Bool

    init(from symptom: SymptomItem) {
        self.name = symptom.name
        self.icon = symptom.icon
        self.category = symptom.category
        self.isSelected = symptom.isSelected
    }

    func toSymptomItem(date: Date) -> SymptomItem {
        SymptomItem(
            name: name,
            icon: icon,
            isSelected: isSelected,
            date: date,
            category: category
        )
    }
}


