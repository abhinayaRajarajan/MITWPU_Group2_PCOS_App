//
//  SymptomsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

// Symptom Item
struct SymptomItem: Encodable,Decodable {
    let name: String
    let icon: String
    var isSelected: Bool = false
    var date: Date?
    var category: String
    init(name: String, icon: String,category: String){
        self.name = name
        self.icon = icon
        self.category=category
    }
    
    //init(name: String, icon: String, isSelected: Bool, date: Date){
        init(name: String, icon: String, isSelected: Bool, date: Date,category:String){
        self.name = name
        self.icon = icon
        self.isSelected = isSelected
        self.date = date
       self.category=category
    }
}

//LOgged Symptoms: codable for userdefaults storage

//Symptom Category
//struct SymptomCategory {
//    let title: String
//    let items: [SymptomItem]
//}
