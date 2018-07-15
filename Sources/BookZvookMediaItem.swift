import UIKit
import WebAPI
import TVSetKit

class BookZvookMediaItem: MediaItem {
  let service = BookZvookService.shared

  var items = [BookZvookAPI.PersonName]()

  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }

  func hasMultipleVersions() -> Bool {
    var playlistUrls: [Any] = []

    do {
      playlistUrls = try service.getPlaylistUrls(id!)
    }
    catch {
      print("Error getting urls playlist")
    }

    return playlistUrls.count > 1
  }

}
