import SwiftUI

struct ReplyDetailView: View {
  @Environment(Router.self) private var router
  let commentId: String

  private var comment: Comment? {
    SampleData.comment(byId: commentId)
  }

  var body: some View {
    List {
      Section {
        if let comment = comment {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundStyle(.blue)

              VStack(alignment: .leading) {
                Text(comment.author)
                  .font(.headline)
                Text("원본 댓글")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }

            Text(comment.text)
              .font(.body)
              .padding(.top, 4)
          }
          .padding(.vertical)
        } else {
          Text("댓글을 찾을 수 없습니다")
            .foregroundStyle(.secondary)
        }
      } header: {
        Text("댓글 정보")
      }

      Section {
        ForEach(SampleData.replies) { reply in
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "person.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

              Text(reply.author)
                .font(.subheadline)
                .fontWeight(.semibold)
            }

            Text(reply.text)
              .font(.body)
              .foregroundStyle(.secondary)
          }
          .padding(.vertical, 4)
        }
      } header: {
        Text("답글 (\(SampleData.replies.count))")
      }

      Section {
        Button {
          router.popToRoot()
        } label: {
          Label("Home으로 돌아가기", systemImage: "house.fill")
        }
      }
    }
    .navigationTitle("답글 상세")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ReplyDetailView(commentId: "1")
      .environment(Router.previewRouter())
  }
}
