//
//  FoodListDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

class FoodListdataStore {
    
    static let shared = FoodListdataStore()
    
    private let userDefaults = UserDefaults.standard
    private let foodItemsKey = "savedFoodItems"
    
    private init() {}
    
    // MARK: - Save Food Items
    func saveFoodItems(_ items: [FoodItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: foodItemsKey)
        }
    }
    
    // MARK: - Load Food Items
    func loadFoodItems() -> [FoodItem] {
        guard let data = userDefaults.data(forKey: foodItemsKey),
              let items = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            return getDefaultFoodItems()
        }
        return items
    }
    
    // MARK: - Add Food Item
    func addFoodItem(_ item: FoodItem) {
        var items = loadFoodItems()
        items.append(item)
        saveFoodItems(items)
    }
    
    // MARK: - Delete Food Item
    func deleteFoodItem(withId id: String) {
        var items = loadFoodItems()
//        items.removeAll { $0.id == id }
        saveFoodItems(items)
    }
    
    // MARK: - Search Food Items
    func searchFoodItems(query: String) -> [FoodItem] {
        let items = loadFoodItems()
        if query.isEmpty {
            return items
        }
        return items.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    // MARK: - Default Food Items (for first time use)
    private func getDefaultFoodItems() -> [FoodItem] {
        return [
            FoodItem(name: "Chicken Breast", calories: 165, servingSize: "100g", protein: 31, carbs: 0, fat: 3.6, desc: "Lean protein source, skinless and boneless."),
            FoodItem(name: "Brown Rice", calories: 112, servingSize: "100g", protein: 2.6, carbs: 24, fat: 0.9, desc: "Whole grain rice rich in fiber and minerals."),
            FoodItem(name: "Broccoli", calories: 34, servingSize: "100g", protein: 2.8, carbs: 7, fat: 0.4, desc: "Cruciferous vegetable high in vitamins and fiber."),
            FoodItem(name: "Salmon", calories: 208, servingSize: "100g", protein: 20, carbs: 0, fat: 13, desc: "Fatty fish rich in omega-3 fatty acids."),
            FoodItem(name: "Sweet Potato", calories: 86, servingSize: "100g", protein: 1.6, carbs: 20, fat: 0.1, desc: "Starchy root vegetable with beta-carotene."),
            FoodItem(name: "Eggs", calories: 155, servingSize: "100g", protein: 13, carbs: 1.1, fat: 11, desc: "Whole eggs, a complete protein source."),
            FoodItem(name: "Avocado", calories: 160, servingSize: "100g", protein: 2, carbs: 9, fat: 15, desc: "Creamy fruit high in healthy fats and fiber."),
            FoodItem(name: "Almonds", calories: 579, servingSize: "100g", protein: 21, carbs: 22, fat: 50, desc: "Nutrient-dense nuts rich in healthy fats."),
            FoodItem(name: "Greek Yogurt", calories: 59, servingSize: "100g", protein: 10, carbs: 3.6, fat: 0.4, desc: "Strained yogurt, high in protein and calcium."),
            FoodItem(name: "Banana", calories: 89, servingSize: "100g", protein: 1.1, carbs: 23, fat: 0.3, desc: "Sweet fruit rich in potassium and carbs."),
            FoodItem(name: "Oatmeal", calories: 68, servingSize: "100g", protein: 2.4, carbs: 12, fat: 1.4, desc: "Whole grain oats, a good source of fiber."),
            FoodItem(name: "Apple", calories: 52, servingSize: "100g", protein: 0.3, carbs: 14, fat: 0.2, desc: "Crisp fruit with soluble fiber (pectin)."),
            FoodItem(name: "Dry Fruit & Fresh Fruit Smoothie", calories: 220, servingSize: "250ml", protein: 6, carbs: 32, fat: 8, desc: "Smoothie blended with mixed dry fruits and fresh fruits.")
        ]
    }
}
