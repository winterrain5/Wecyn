
import Foundation
import LinkPresentation
import UIKit

extension URL: PersistentlyCacheable {

    var persistentIdentifier: String {
        guard let percentEncoding = absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            fatalError()
        }
        return percentEncoding
    }
}

@available(iOS 13, *)
final class MetaDataCache<Cache: AsyncKeyValueCaching>: AsyncKeyValueCaching where Cache.CachingKey == URL, Cache.Entity == Data {

    private var cache: Cache

    init(cache: Cache) {
        self.cache = cache
    }

    func isEntityCached(for url: URL) -> Bool {
        cache.isEntityCached(for: url)
    }

    func getEntity(for url: URL) throws -> LPLinkMetadata {
        let data = try cache.getEntity(for: url)
        // swiftlint:disable force_try force_cast
        let entity = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! LPLinkMetadata
        // swiftlint:enable force_try force_cast
        return entity
    }

    func getEntity(for key: URL, completion: @escaping (Result<LPLinkMetadata, Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                let entity = try self.getEntity(for: key)
                DispatchQueue.main.async {
                    completion(.success(entity))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func store(entity: LPLinkMetadata, for key: URL) throws {
        // swiftlint:disable force_try
        let codedData = try! NSKeyedArchiver.archivedData(withRootObject: entity, requiringSecureCoding: true)
        // swiftlint:enable force_try
        try cache.store(entity: codedData, for: key)
    }

}
