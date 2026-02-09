import SwiftUI

/// Navigation의 ViewBuilder protocol 구현체
/// Navigation과 Features 사이의 어댑터 역할
final class AppViewFactory: ViewBuilder {
    func makeHomeView(navigate: @escaping (Destination) -> Void) -> AnyView {
        AnyView(HomeView(
            onItemTapped: { id in
                navigate(.push(.itemDetail(id: id, onOpenComments: { itemId in
                    navigate(.push(.comments(itemId: itemId, onReplyTapped: { commentId in
                        navigate(.push(.replyDetail(commentId: commentId, onPopToRoot: {
                            navigate(.popToRoot)
                        })))
                    })))
                })))
            },
            onOpenOnboarding: { navigate(.fullScreen(.onboarding)) },
            onOpenImageViewer: { url in navigate(.fullScreen(.imageViewer(url: url))) }
        ))
    }

    func makeProfileView(navigate: @escaping (Destination) -> Void) -> AnyView {
        AnyView(ProfileView(
            onEditProfile: { onSave in
                navigate(.sheet(.profileEdit(onSave: onSave)))
            }
        ))
    }

    func makeSettingsView(navigate: @escaping (Destination) -> Void) -> AnyView {
        AnyView(SettingsView(
            onShowDetail: {
                navigate(.sheet(.settingsDetail))
            }
        ))
    }

    func makeView(for destination: PushDestination, navigate: @escaping (Destination) -> Void) -> AnyView {
        switch destination {
        case let .itemDetail(id, onOpenComments):
            return AnyView(ItemDetailView(
                itemId: id,
                onOpenComments: onOpenComments,
                onSwitchToProfile: { navigate(.tab(.profile)) },
                onSwitchToSettings: { navigate(.tab(.settings)) }
            ))

        case let .comments(itemId, onReplyTapped):
            return AnyView(CommentsView(
                itemId: itemId,
                onReplyTapped: onReplyTapped
            ))

        case let .replyDetail(commentId, onPopToRoot):
            return AnyView(ReplyDetailView(
                commentId: commentId,
                onPopToRoot: onPopToRoot
            ))
        }
    }

    func makeView(for destination: SheetDestination, navigate: @escaping (Destination) -> Void) -> AnyView {
        switch destination {
        case let .profileEdit(onSave):
            return AnyView(ProfileEditSheet(onSave: onSave))

        case .settingsDetail:
            return AnyView(SettingsDetailSheet())
        }
    }

    func makeView(for destination: FullScreenDestination, navigate: @escaping (Destination) -> Void) -> AnyView {
        switch destination {
        case .onboarding:
            return AnyView(OnboardingView())

        case let .imageViewer(url):
            return AnyView(ImageViewerView(imageUrl: url))
        }
    }
}
