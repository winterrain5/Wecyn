import Foundation
import LinkPresentation

@available(iOS 13, *)
final class URLController {

    let url: URL

    var metadata: LPLinkMetadata?

    weak var delegate: ReloadDelegate?

    weak var view: URLView?

    private let provider = LPMetadataProvider()

    private let messageId: String

    private let bubbleController: BubbleController

    init(url: URL, messageId: String, bubbleController: BubbleController) {
        self.url = url
        self.messageId = messageId
        self.bubbleController = bubbleController
        startFetchingMetadata()
    }

    private func startFetchingMetadata() {
        if let metadata = try? metadataCache.getEntity(for: url) {
            self.metadata = metadata
            view?.reloadData()
        } else {
            provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                guard let self,
                      let metadata,
                      error == nil else {
                    return
                }

                try? metadataCache.store(entity: metadata, for: self.url)

                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    self.delegate?.reloadMessage(with: self.messageId)
                }
            }
        }

    }

}
