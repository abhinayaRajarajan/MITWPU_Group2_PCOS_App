//
//  DataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

struct DataStore {
    
        static let sampleFoods: [Food] = [
            // TODAY - Morning
            Food(
                id: UUID(),
                name: "Greek Yogurt with Berries",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                quantity: 200,
                proteinContent: 17,
                carbsContent: 15,
                fatsContent: 4,
                fibreContent: 3,
                tags: [.highProtein, .lowGlycemic, .gutFriendly, .pcosFriendly]
            ),
            // TODAY - Lunch
            Food(
                id: UUID(),
                name: "Avocado Toast",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
                quantity: 150,
                proteinContent: 6,
                carbsContent: 25,
                fatsContent: 14,
                fibreContent: 7,
                tags: [.healthyFats, .lowGlycemic, .antiInflammatory, .wholeFood]
            ),
            // TODAY - Snack
            Food(
                id: UUID(),
                name: "Almonds",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
                quantity: 30,
                proteinContent: 6,
                carbsContent: 6,
                fatsContent: 14,
                fibreContent: 3,
                tags: [.healthyFats, .highProtein, .wholeFood]
            ),
            
            // YESTERDAY - Breakfast
            Food(
                id: UUID(),
                name: "Oatmeal with Chia Seeds",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                quantity: 250,
                proteinContent: 12,
                carbsContent: 45,
                fatsContent: 8,
                fibreContent: 10,
                tags: [.lowGlycemic, .wholeFood, .pcosFriendly]
            ),
            // YESTERDAY - Lunch
            Food(
                id: UUID(),
                name: "Grilled Chicken Salad",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                quantity: 350,
                proteinContent: 32,
                carbsContent: 12,
                fatsContent: 10,
                fibreContent: 5,
                tags: [.highProtein, .lowCarb, .antiInflammatory, .wholeFood]
            ),
            
            // 2 DAYS AGO
            Food(
                id: UUID(),
                name: "Salmon with Quinoa",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                quantity: 400,
                proteinContent: 35,
                carbsContent: 40,
                fatsContent: 18,
                fibreContent: 5,
                tags: [.highProtein, .healthyFats, .antiInflammatory, .wholeFood]
            ),
            Food(
                id: UUID(),
                name: "Chocolate Milkshake",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                quantity: 300,
                proteinContent: 8,
                carbsContent: 55,
                fatsContent: 12,
                fibreContent: 1,
                tags: [.sugary, .insulinSpiking, .processed, .chocolate, .dairySensitive]
            ),
            
            // 3 DAYS AGO
            Food(
                id: UUID(),
                name: "Spinach Smoothie",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                quantity: 350,
                proteinContent: 10,
                carbsContent: 28,
                fatsContent: 5,
                fibreContent: 6,
                tags: [.antiInflammatory, .lowGlycemic, .wholeFood]
            ),
            
            // 4 DAYS AGO
            Food(
                id: UUID(),
                name: "Lentil Soup",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                quantity: 300,
                proteinContent: 18,
                carbsContent: 40,
                fatsContent: 3,
                fibreContent: 16,
                tags: [.highProtein, .lowGlycemic, .wholeFood, .pcosFriendly]
            ),
            
            // 5 DAYS AGO
            Food(
                id: UUID(),
                name: "Egg White Omelette",
                image: nil,
                timeStamp: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                quantity: 200,
                proteinContent: 25,
                carbsContent: 5,
                fatsContent: 2,
                fibreContent: 2,
                tags: [.highProtein, .lowCarb, .wholeFood]
            )
        ]
    

    static let sampleSymptoms: [Symptoms] = [
        Symptoms(
            spotting: .red,
            discharge: .creamy,
            pain: [.abdominalCramp, .headache],
            skinAndHair: [.acne],
            lifestyle: [.fatigue, .anxiety],
            gutHealth: [.bloating],
            breastHealth: .pain,
            timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        ),
        Symptoms(
            spotting: .brown,
            discharge: .eggWhite,
            pain: [.lowerBackPain],
            skinAndHair: [.hairLoss],
            lifestyle: [.insomnia],
            gutHealth: [.constipation],
            breastHealth: .fine,
            timeStamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        )
    ]

    static let sampleUsers: [Users] = [
        Users(
            id: UUID(),
            name: "Aisha",
            password: "password123",
            dob: Calendar.current.date(from: DateComponents(year: 1996, month: 5, day: 17)) ?? Date(),
            height: 165,
            weight: 68,
            symptoms: sampleSymptoms,
            diet: sampleFoods,
            medicines: ["Metformin", "Vitamin D"]
        ),
        Users(
            id: UUID(),
            name: "Mira",
            password: "securePass!",
            dob: Calendar.current.date(from: DateComponents(year: 1992, month: 11, day: 2)) ?? Date(),
            height: 158,
            weight: 74,
            symptoms: [
                Symptoms(
                    spotting: .red,
                    discharge: .watery,
                    pain: [.abdominalCramp, .vulvarPain],
                    skinAndHair: [.hirsutism],
                    lifestyle: [.depressed],
                    gutHealth: [.gas],
                    breastHealth: .fine,
                    timeStamp: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
                )
            ],
            diet: [
                Food(
                    id: UUID(),
                    name: "Oatmeal with Nuts",
                    image: nil,
                    timeStamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                    quantity: 250,
                    proteinContent: 10,
                    carbsContent: 40,
                    fatsContent: 12,
                    fibreContent: 8,
                    tags: [.highFibre, .lowGlycemic, .healthyFats, .wholeFood]
                )
            ],
            medicines: ["Inositol"]
        )
    ]
}
