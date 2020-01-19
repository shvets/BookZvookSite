import UIKit
import MediaApis
import TVSetKit

class BookZvookMediaItem: MediaItem {
  let service = BookZvookService.shared

  var items = [BookZvookAPI.PersonName]()

  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }

  override func retrieveExtraInfo() throws {
    print("retrieveExtraInfo")
    
//    if type == "movie" {
//      let mediaData = try service.getMediaData(pathOrUrl: id!)
//
//      var text = ""
//
//      if let intro = mediaData["Продолжительность:"] as? String {
//        text += "\(intro)\n\n"
//      }
//
//      if let genre = mediaData["Жанр:"] as? String {
//        text += "\(genre)\n\n"
//      }
//
//      if let artists = (mediaData["В ролях:"] as? String)?.description {
//        text += "\(artists)\n\n"
//      }
//
//      if let description = mediaData["description"] as? String {
//        text += "\(description)\n\n"
//      }
//
//      description = text
//    }
  }
}
