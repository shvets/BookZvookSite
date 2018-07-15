import Foundation
import WebAPI
import TVSetKit
import AudioPlayer

public class BookZvookService {
  static let shared: BookZvookAPI = {
    return BookZvookAPI()
  }()

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/bookzvook-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/bookzvook-history.json"

  static let audioPlayerPropertiesFileName = "bookzvook-player-settings.json"

  static let StoryboardId = "BookZvook"
  static let BundleId = "com.rubikon.BookZvookSite"

  lazy var bookmarks = Bookmarks(BookZvookService.bookmarksFileName)
  lazy var history = History(BookZvookService.historyFileName)

  lazy var bookmarksManager = BookmarksManager(bookmarks)
  lazy var historyManager = HistoryManager(history)

  var audioPlayer: AudioPlayer {
    return AudioPlayer.getAudioPlayer(BookZvookService.audioPlayerPropertiesFileName)
  }

  var dataSource = BookZvookDataSource()

  public init() {}

  func getConfiguration() -> [String: Any] {
    return [
      "pageSize": 10,
      "rowSize": 1,
      "mobile": true,
      "bookmarksManager": bookmarksManager,
      "historyManager": historyManager,
      "dataSource": dataSource,
      "storyboardId": BookZvookService.StoryboardId,
      "bundleId": BookZvookService.BundleId
    ]
  }
}
