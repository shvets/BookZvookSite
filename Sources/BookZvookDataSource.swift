import WebAPI
import TVSetKit
import AudioPlayer
import RxSwift

class BookZvookDataSource: DataSource {
  let service = BookZvookService.shared

  override open func load(params: Parameters) throws -> Observable<[Any]> {
    var items: Observable<[Any]> = Observable.just([])

    let selectedItem = params["selectedItem"] as? Item

    let request = params["requestType"] as! String
    let currentPage = params["currentPage"] as? Int ?? 1
    let pageSize = params["pageSize"] as? Int ?? 10
    
    switch request {
    case "Bookmarks":
      if let bookmarksManager = params["bookmarksManager"] as? BookmarksManager,
         let bookmarks = bookmarksManager.bookmarks {
        let data = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)

        items = Observable.just(adjustItems(data))
      }

    case "History":
      if let historyManager = params["historyManager"] as? HistoryManager,
         let history = historyManager.history {
        let data = history.getHistoryItems(pageSize: pageSize, page: currentPage)

        items = Observable.just(adjustItems(data))
      }

    case "Popular Books":
      items = try service.getPopularBooks().map { result in
        return self.adjustItems(result)
      }
      
    case "Authors Letters":
      items = try service.getLetters().map { result in
        return self.adjustItems(result)
      }
      
    case "Authors":
      if let url = params["parentId"] as? String {
        items = Observable.just(adjustItems(try service.getAuthors(url)))
      }

    case "Author":
      if let url = params["parentId"] as? String,
         let selectedItem = selectedItem,
         let name = selectedItem.name {
        
        let result = try service.getAuthorBooks(url, name: name, page: currentPage, perPage: pageSize)
        
        let data = result["movies"] as? [Any]
        
        items = Observable.just(self.adjustItems(data!))
      }

    case "New Books":
      items = try service.getNewBooks(page: currentPage).map { result in
        let data = result["movies"] as? [Any]
        
        let newItems = self.adjustItems(data!)
        
        return newItems
      }

    case "Genres":
      let genres = try service.getGenres()

      items = Observable.just(adjustItems(genres))
      
    case "Genre Books":
      if let selectedItem = selectedItem, let url = selectedItem.id {
        items = try service.getGenreBooks(url, page: currentPage).map { result in
          let data = result["movies"] as? [Any]
          
          let newItems = self.adjustItems(data!)
          
          return newItems
        }
      }
      
    case "Tracks":
      if let url = params["url"] as? String, !url.isEmpty {
        let playlistUrls = try service.getPlaylistUrls(url)

        let version = params["version"] as? Int ?? 0

        if playlistUrls.count > version {
          let url = playlistUrls[version]

          items = Observable.just(adjustItems(try service.getAudioTracks(url)))
        }
      }

    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
          items = try service.search(query, page: currentPage).map { result in
            let data = result["movies"] as? [Any]
            
            let newItems = self.adjustItems(data!)
            
            return newItems
          }
        }
      }

    default:
      items = Observable.just([])
    }

    return items
  }

  func adjustItems(_ items: [Any]) -> [Item] {
    var newItems = [Item]()

    if let items = items as? [HistoryItem] {
      newItems = transform(items) { item in
        createHistoryItem(item as! HistoryItem)
      }
    }
    else if let items = items as? [BookmarkItem] {
      newItems = transform(items) { item in
        createBookmarkItem(item as! BookmarkItem)
      }
    }
    else if let items = items as? [BookZvookAPI.PersonName] {
      newItems = transform(items) { item in
        let item = item as! BookZvookAPI.PersonName

        return MediaItem(name: item.name, id: String(describing: item.id))
      }
    }
    else if let items = items as? [BookZvookAPI.BooTrack] {
      newItems = transform(items) { item in
        let track = item as! BookZvookAPI.BooTrack

        return MediaItem(name: track.title + ".mp3", id: String(describing: track.url))
      }
    }
    else if let items = items as? [BookZvookAPI.Book] {
      newItems = transform(items) { item in
        let item = item as! BookZvookAPI.Book
        
        return MediaItem(name: item.title, id: String(describing: item.id))
      }
    }
    else if let items = items as? [[String: Any]] {
      newItems = transform(items) { item in
        createMediaItem(item as! [String: Any])
      }
    }
    else if let items = items as? [Item] {
      newItems = items
    }

    return newItems
  }

  func createHistoryItem(_ item: HistoryItem) -> Item {
    let newItem = BookZvookMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createBookmarkItem(_ item: BookmarkItem) -> Item {
    let newItem = BookZvookMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createMediaItem(_ item: [String: Any]) -> Item {
    let newItem = BookZvookMediaItem(data: ["name": ""])

    if let dict = item as? [String: String] {
      newItem.name = dict["name"]
      newItem.id = dict["id"]
      newItem.description = dict["description"]
      newItem.thumb = dict["thumb"]
      newItem.type = dict["type"]
    } else {
      newItem.name = item["name"] as? String

      if let array = item["items"] as? [[String: String]] {
        var newArray = [BookZvookAPI.PersonName]()

        for elem in array {
          let newElem = BookZvookAPI.PersonName(name: elem["name"]!, id: elem["id"]!)

          newArray.append(newElem)
        }

        newItem.items = newArray
      }
    }

    return newItem
  }

  func getLetters(_ items: [NameClassifier.ItemsGroup]) -> [String] {
    var ruLetters = [String]()
    var enLetters = [String]()

    for item in items {
      let groupName = item.key

      let index = groupName.index(groupName.startIndex, offsetBy: 0)

      let letter = String(groupName[index])

      if (letter >= "a" && letter <= "z") || (letter >= "A" && letter <= "Z") {
        if !enLetters.contains(letter) {
          enLetters.append(letter)
        }
      }
      else if (letter >= "а" && letter <= "я") || (letter >= "А" && letter <= "Я") {
        if !ruLetters.contains(letter) {
          ruLetters.append(letter)
        }
      }
    }

    return ruLetters + enLetters
  }

}
