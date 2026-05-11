//
//  HomeworkItem.swift
//  Gradmo
//
//  Created by Codex on 11/05/26.
//

import UIKit

struct HomeworkItem {
    let title: String
    let content: String
    let dateText: String
    let image: UIImage?
    let attachmentURL: URL?

    static let samples: [HomeworkItem] = [
        HomeworkItem(
            title: "Algebra Practice",
            content: "Complete exercise 4.1 and 4.2 from the textbook before the next class.Read the chapter on light and prepare answers for the worksheet questions.",
            dateText: "Due 12 May 2026",
            image: UIImage(named: "institutePlaceholder"),
            attachmentURL: nil
        ),
        HomeworkItem(
            title: "Science Worksheet",
            content: "Read the chapter on light and prepare answers for the worksheet questions.Read the chapter on light and prepare answers for the worksheet questions.Read the chapter on light and prepare answers for the worksheet questions.Read the chapter on light and prepare answers for the worksheet questions.",
            dateText: "Due 14 May 2026",
            image: UIImage(named: "institutePlaceholder"),
            attachmentURL: nil
        )
    ]
}
