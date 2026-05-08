//
//  RAGSearchEngine.swift
//  PCOS_App
//
//  Retrieval-Augmented Generation (RAG) engine.
//  Searches PCOSResearch.json and csvjson.json to inject verified context
//  into prompts — replacing Foundation Models' Tool calling mechanism.
//

import Foundation

final class RAGSearchEngine {

    static let shared = RAGSearchEngine()
    private init() {
        // Preload research data on init
        PCOSResearchTool.preload()
    }

    private let researchTool = PCOSResearchTool()
    private let foodTool = IndianFoodTool()

    // MARK: - Build RAG Context for Chat

    /// Builds a combined context block from PCOS research and food databases.
    /// This replaces the Tool calling mechanism — instead of letting the model
    /// decide whether to call a tool, we always inject the most relevant data.
    func buildRAGContext(
        query: String,
        activeSymptoms: [String] = [],
        phenotype: String? = nil
    ) -> String {
        var contextBlocks: [String] = []

        // 1. Search PCOS research database
        let symptomsStr = activeSymptoms.joined(separator: " ")
        let researchResults = researchTool.search(
            query: query,
            activeSymptoms: symptomsStr.isEmpty ? nil : symptomsStr,
            phenotype: phenotype
        )

        if !researchResults.contains("No specific research found") {
            contextBlocks.append("""
            [PCOS Research — use these findings to support your answer]
            \(researchResults)
            [END RESEARCH]
            """)
        }

        // 2. Search food database for food-related queries
        let foodKeywords = ["eat", "food", "meal", "diet", "protein", "carb",
                           "snack", "breakfast", "lunch", "dinner", "recipe",
                           "cook", "nutrient", "fibre", "fiber", "calorie",
                           "sugar", "insulin", "gi ", "glycemic", "veg", 
                           "vegetable", "options", "alternatives", "substitute", "cheat", "junk", "fast", "hair", "hairloss", "skin", "acne"]
        let queryLower = query.lowercased()
        let isFoodRelated = foodKeywords.contains(where: { queryLower.contains($0) })

        if isFoodRelated {
            let foodResults = foodTool.search(query: query, focus: phenotype)
            contextBlocks.append("""
            [Indian Food Suggestions — reference these when recommending foods]
            \(foodResults)
            [END FOOD]
            """)
        }

        return contextBlocks.joined(separator: "\n\n")
    }

    // MARK: - Build RAG Context for Meal Recommendations

    /// Searches the food database for foods that match the user's nutritional gaps.
    /// Returns food entries from csvjson.json as context for meal recommendation prompts.
    func buildMealRAGContext(
        proteinGap: Double,
        phenotype: String?,
        alreadyEaten: [String]
    ) -> String {
        let foods = FoodListdataStore.shared.loadFoodItems()
        guard !foods.isEmpty else { return "" }

        let alreadyEatenLower = Set(alreadyEaten.map { $0.lowercased() })

        // Find high-protein foods not already eaten, and shuffle them for variety
        let candidates = foods
            .filter { !alreadyEatenLower.contains($0.name.lowercased()) && $0.protein > 8.0 }
            .shuffled()
            .prefix(10)

        guard !candidates.isEmpty else { return "" }

        var lines: [String] = ["[Verified Food Database — use ONLY these values for nutrition]"]
        for food in candidates {
            lines.append("- \(food.name): \(Int(food.protein))g protein, \(food.calories)kcal per \(Int(food.servingSize))g")
        }
        lines.append("[END FOOD DATABASE]")

        return lines.joined(separator: "\n")
    }
}
