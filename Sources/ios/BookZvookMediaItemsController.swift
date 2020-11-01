import TVSetKit
import AudioPlayer

open class BookZvookMediaItemsController: MediaItemsController {
  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
  }

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier,
      let selectedCell = sender as? MediaItemCell {

      if let indexPath = collectionView?.indexPath(for: selectedCell) {
        let mediaItem = items[indexPath.row] as! MediaItem

        switch identifier {
        case AudioItemsController.SegueIdentifier:
          if let destination = segue.destination as? AudioItemsController {
            let playerSettings = AudioPlayer.readSettings(BookZvookService.audioPlayerPropertiesFileName)

            destination.playerSettings = playerSettings

            destination.selectedBookId = mediaItem.id!
            destination.selectedBookName = mediaItem.name!
            
            if let thumb = mediaItem.thumb {
              destination.selectedBookThumb = thumb
            }

            destination.selectedItemId = -1

            if let url = mediaItem.id {
              destination.loadAudioItems = BookZvookMediaItemsController.loadAudioItems(url, dataSource: dataSource)
            }

            if let requestType = params["requestType"] as? String,
               requestType != "History" {
              historyManager?.addHistoryItem(mediaItem)
            }
          }

        default:
          super.prepare(for: segue, sender: sender)
        }
      }
    }
  }

  static func loadAudioItems(_ url: String, dataSource: DataSource?) -> (() throws -> [Any])? {
    return {
      var items: [AudioItem] = []

      var params = Parameters()

      params["requestType"] = "Tracks"
      params["url"] = url

      if let mediaItems = try dataSource?.load(params: params) as? [MediaItem] {
        for mediaItem in mediaItems {
          let item = mediaItem

          items.append(AudioItem(name: item.name!, id: item.id!))
        }
      }

      return items
    }
  }
}

