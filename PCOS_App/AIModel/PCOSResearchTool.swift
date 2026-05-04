//
//  PCOSResearchTool.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//

import Foundation
import NaturalLanguage

struct ResearchChunk: Codable {
    let id: String
    let topic: String
    let source: String
    let content: String
    let action: String
    let triggers: [String]
    let phenotypes: [String]
    let phase: [String]
    let priority: Int
}

struct PCOSResearchTool {

    // ── Singleton data store ───────────────────────────────────────────────
    private static var chunks: [ResearchChunk] = []
    private static var isLoaded = false

    static func preload() {
        guard !isLoaded else { return }
        guard let url = Bundle.main.url(forResource: "PCOSResearch", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([ResearchChunk].self, from: data) else {
            print("⚠️ PCOSResearch.json not found or malformed")
            return
        }
        chunks = loaded
        isLoaded = true
        print("✅ Loaded \(chunks.count) research chunks")
    }

    /// Search the PCOS research database for evidence-based information.
    /// Returns the most relevant research findings with specific action recommendations.
    func search(query: String, activeSymptoms: String? = nil, phenotype: String? = nil) -> String {
        PCOSResearchTool.preload()

        let symptomsRaw = activeSymptoms ?? ""
        let symptoms    = symptomsRaw.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
        let phenotypeStr = phenotype ?? ""

        let triggerMatches = PCOSResearchTool.chunks.filter { chunk in
            symptoms.contains(where: { symptom in
                chunk.triggers.contains(where: { $0.lowercased().contains(symptom) })
            })
        }

        let phenotypeFiltered = PCOSResearchTool.chunks.filter { chunk in
            phenotypeStr.isEmpty || chunk.phenotypes.contains("any") || chunk.phenotypes.contains(phenotypeStr)
        }

        let queryWords = query.lowercased().components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        var scored: [(chunk: ResearchChunk, score: Double)] = phenotypeFiltered.map { chunk in
            let topicWords   = chunk.topic.lowercased().components(separatedBy: .whitespaces)
            let contentWords = chunk.content.lowercased().components(separatedBy: .whitespaces)
            var score = 0.0
            for word in queryWords {
                if topicWords.contains(word)   { score += 3.0 }
                if contentWords.contains(word) { score += 1.0 }
                if chunk.triggers.contains(where: { $0.lowercased().contains(word) }) { score += 2.0 }
            }
            score += Double(3 - chunk.priority) * 2.0
            if triggerMatches.contains(where: { $0.id == chunk.id }) { score += 5.0 }
            return (chunk, score)
        }

        if let embedding = NLEmbedding.wordEmbedding(for: .english) {
            scored = scored.map { item in
                let topicWords = item.chunk.topic.components(separatedBy: .whitespaces)
                var semanticBoost = 0.0
                for word in queryWords {
                    for topicWord in topicWords {
                        let distance = embedding.distance(between: word, and: topicWord)
                        semanticBoost += max(0, 1.0 - distance) * 0.5
                    }
                }
                return (item.chunk, item.score + semanticBoost)
            }
        }

        let topChunks = scored.sorted { $0.score > $1.score }.prefix(3).map { $0.chunk }

        guard !topChunks.isEmpty else {
            return "No specific research found for this query. Rely on general PCOS guidelines."
        }

        return topChunks.enumerated().map { i, chunk in
            """
            [\(i+1)] SOURCE: \(chunk.source) | PRIORITY: \(chunk.priority)
            FINDING: \(chunk.content)
            ACTION: \(chunk.action)
            """
        }.joined(separator: "\n\n")
    }
}
