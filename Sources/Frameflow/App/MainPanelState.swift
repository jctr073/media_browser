import SwiftUI

enum MainPanelTab: Hashable, Identifiable {
    case preview
    case videoComposer
    case multiView

    var id: Self { self }

    var title: String {
        switch self {
        case .preview:
            return "Quick Sort"
        case .videoComposer:
            return "Composer"
        case .multiView:
            return "Multi-View"
        }
    }

    var systemImage: String {
        switch self {
        case .preview:
            return "play.rectangle"
        case .videoComposer:
            return "timeline.selection"
        case .multiView:
            return "rectangle.split.2x2"
        }
    }
}

@MainActor
final class MainPanelState: ObservableObject {
    @Published private(set) var visibleTabs: Set<MainPanelTab> = [.preview, .videoComposer, .multiView]
    @Published var activeTab: MainPanelTab = .preview

    func isVisible(_ tab: MainPanelTab) -> Bool {
        visibleTabs.contains(tab)
    }

    func setVisible(_ tab: MainPanelTab, _ isVisible: Bool, activate: Bool = false) {
        if isVisible {
            visibleTabs.insert(tab)
            if activate {
                activeTab = tab
            }
        } else {
            guard visibleTabs.count > 1 else {
                return
            }
            visibleTabs.remove(tab)
        }

        if !visibleTabs.contains(activeTab) {
            activeTab = fallbackTab()
        }
    }

    func show(_ tab: MainPanelTab, activate: Bool = true) {
        visibleTabs.insert(tab)
        if activate {
            activeTab = tab
        }
    }

    func activate(_ tab: MainPanelTab) {
        guard visibleTabs.contains(tab) else { return }
        activeTab = tab
    }

    private func fallbackTab() -> MainPanelTab {
        if visibleTabs.contains(.preview) {
            return .preview
        }
        if visibleTabs.contains(.videoComposer) {
            return .videoComposer
        }
        if visibleTabs.contains(.multiView) {
            return .multiView
        }
        visibleTabs.insert(.preview)
        return .preview
    }
}
