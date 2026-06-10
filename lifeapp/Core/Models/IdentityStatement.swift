import Foundation
import SwiftData

@Model
final class IdentityStatement {
    var id: UUID
    var text: String
    var createdAt: Date
    var order: Int

    init(text: String, order: Int) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.order = order
    }

    var description: String {
        "IdentityStatement(order: \(order))"
    }
}
