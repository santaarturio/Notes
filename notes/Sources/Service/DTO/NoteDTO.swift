import Foundation

struct NoteDTO: Codable {
  let id: String
  let title: String
  let subtitle: String
  let date: String?
}

extension Note {
  init(dto: NoteDTO) {
    id = .init(string: dto.id)
    title = dto.title
    text = dto.subtitle
    date = ISO8601DateFormatter.cached.date(from: dto.date ?? "")
  }
}
