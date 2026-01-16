import SwiftUI

struct CommentsView: View {
  @Environment(Router.self) private var router
  let itemId: String

  var body: some View {
    List {
      ForEach(SampleData.comments) { comment in
        Button {
          router.push(.replyDetail(commentId: comment.id))
        } label: {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(comment.author)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

              Spacer()

              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Text(comment.text)
              .font(.body)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.leading)
          }
          .padding(.vertical, 4)
        }
      }
    }
    .navigationTitle("댓글")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CommentsView(itemId: "1")
      .environment(Router.previewRouter())
  }
}
