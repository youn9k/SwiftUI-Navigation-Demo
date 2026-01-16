import Foundation

// MARK: - Models

struct Item: Identifiable, Hashable {
  let id: String
  let title: String
  let description: String
  let imageUrl: String?
}

struct Comment: Identifiable, Hashable {
  let id: String
  let text: String
  let author: String
}

struct Reply: Identifiable, Hashable {
  let id: String
  let text: String
  let author: String
}

// MARK: - Sample Data

enum SampleData {
  static let items = [
    Item(id: "1", title: "아이템 1", description: "첫 번째 아이템입니다", imageUrl: nil),
    Item(id: "2", title: "아이템 2", description: "두 번째 아이템입니다", imageUrl: nil),
    Item(id: "3", title: "아이템 3", description: "세 번째 아이템입니다", imageUrl: nil),
    Item(id: "4", title: "아이템 4", description: "네 번째 아이템입니다", imageUrl: nil),
    Item(id: "5", title: "아이템 5", description: "다섯 번째 아이템입니다", imageUrl: nil)
  ]

  static let comments = [
    Comment(id: "1", text: "정말 유용한 아이템이네요!", author: "사용자1"),
    Comment(id: "2", text: "좋은 정보 감사합니다", author: "사용자2"),
    Comment(id: "3", text: "더 자세한 설명이 필요합니다", author: "사용자3"),
    Comment(id: "4", text: "도움이 많이 되었습니다", author: "사용자4")
  ]

  static let replies = [
    Reply(id: "1", text: "저도 동의합니다!", author: "답글작성자1"),
    Reply(id: "2", text: "추가 정보: ...", author: "답글작성자2"),
    Reply(id: "3", text: "감사합니다", author: "답글작성자3")
  ]

  static func item(byId id: String) -> Item? {
    items.first { $0.id == id }
  }

  static func comment(byId id: String) -> Comment? {
    comments.first { $0.id == id }
  }

  static func reply(byId id: String) -> Reply? {
    replies.first { $0.id == id }
  }
}
