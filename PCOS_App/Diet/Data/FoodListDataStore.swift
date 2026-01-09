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
    func saveFoodItems(_ items: [InsulinFoodItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: foodItemsKey)
        }
    }
    
    // MARK: - Load Food Items
    func loadFoodItems() -> [InsulinFoodItem] {
        guard let data = userDefaults.data(forKey: foodItemsKey),
              let items = try? JSONDecoder().decode([InsulinFoodItem].self, from: data) else {
            return getDefaultFoodItems()
        }
        return items
    }
    
    // MARK: - Add Food Item
    func addFoodItem(_ item: InsulinFoodItem) {
        var items = loadFoodItems()
        items.append(item)
        saveFoodItems(items)
    }
    
    // MARK: - Delete Food Item
    func deleteFoodItem(withId id: String) {
        var items = loadFoodItems()
        items.removeAll { $0.id == id }
        saveFoodItems(items)
    }
    
    // MARK: - Search Food Items
    func searchFoodItems(query: String) -> [InsulinFoodItem] {
        let items = loadFoodItems()
        if query.isEmpty {
            return items
        }
        return items.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    // MARK: - Default Food Items (for first time use)
    private func getDefaultFoodItems() -> [InsulinFoodItem] {
        return [
            InsulinFoodItem(name: "Chicken Breast", calories: 165, servingSize: "100g", protein: 31, carbs: 0, fat: 3.6),
            InsulinFoodItem(name: "Brown Rice", calories: 112, servingSize: "100g", protein: 2.6, carbs: 24, fat: 0.9),
            InsulinFoodItem(name: "Broccoli", calories: 34, servingSize: "100g", protein: 2.8, carbs: 7, fat: 0.4),
            InsulinFoodItem(name: "Salmon", calories: 208, servingSize: "100g", protein: 20, carbs: 0, fat: 13),
            InsulinFoodItem(name: "Sweet Potato", calories: 86, servingSize: "100g", protein: 1.6, carbs: 20, fat: 0.1),
            InsulinFoodItem(name: "Eggs", calories: 155, servingSize: "100g", protein: 13, carbs: 1.1, fat: 11),
            InsulinFoodItem(name: "Avocado", calories: 160, servingSize: "100g", protein: 2, carbs: 9, fat: 15),
            InsulinFoodItem(name: "Almonds", calories: 579, servingSize: "100g", protein: 21, carbs: 22, fat: 50),
            InsulinFoodItem(name: "Greek Yogurt", calories: 59, servingSize: "100g", protein: 10, carbs: 3.6, fat: 0.4),
            InsulinFoodItem(name: "Banana", calories: 89, servingSize: "100g", protein: 1.1, carbs: 23, fat: 0.3),
            InsulinFoodItem(name: "Oatmeal", calories: 68, servingSize: "100g", protein: 2.4, carbs: 12, fat: 1.4),
            InsulinFoodItem(name: "Apple", calories: 52, servingSize: "100g", protein: 0.3, carbs: 14, fat: 0.2)
        ]
    }
}
