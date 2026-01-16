import SwiftUI

struct ImageViewerView: View {
  @Environment(\.dismiss) private var dismiss
  let imageUrl: String

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack {
        // Close 버튼
        HStack {
          Spacer()
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.title)
              .foregroundStyle(.white)
              .padding()
          }
        }

        Spacer()

        // 이미지 (SF Symbol로 대체)
        Image(systemName: "photo")
          .font(.system(size: 200))
          .foregroundStyle(.white)
          .scaleEffect(scale)
          .gesture(
            MagnificationGesture()
              .onChanged { value in
                scale = lastScale * value
              }
              .onEnded { _ in
                lastScale = scale
                // 최소/최대 배율 제한
                if scale < 1.0 {
                  withAnimation {
                    scale = 1.0
                    lastScale = 1.0
                  }
                } else if scale > 3.0 {
                  withAnimation {
                    scale = 3.0
                    lastScale = 3.0
                  }
                }
              }
          )
          .onTapGesture(count: 2) {
            withAnimation {
              if scale > 1.0 {
                scale = 1.0
                lastScale = 1.0
              } else {
                scale = 2.0
                lastScale = 2.0
              }
            }
          }

        Spacer()

        // 이미지 정보
        VStack(spacing: 8) {
          Text("Image Viewer")
            .font(.headline)
            .foregroundStyle(.white)

          Text("Double tap to zoom")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.bottom, 40)
      }
    }
  }
}

#Preview {
  ImageViewerView(imageUrl: "sample")
}
