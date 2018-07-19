import UIKit
import TVSetKit
import PageLoader
import AudioPlayer

open class BookZvookTableViewController: UITableViewController {
  //static let SegueIdentifier = "Audio Boo"
  let CellIdentifier = "BookZvookTableCell"

  let localizer = Localizer(BookZvookService.BundleId, bundleClass: BookZvookSite.self)

  let service = BookZvookService()
  let pageLoader = PageLoader()
  private var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("BookZvook")

    pageLoader.loadData(onLoad: loadMainMenu) { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
  }

  func loadMainMenu() throws -> [Any] {
    return [
      MediaName(name: "Now Listening", imageName: "Now Listening"),
      MediaName(name: "Bookmarks", imageName: "Star"),
      MediaName(name: "History", imageName: "Bookmark"),
      MediaName(name: "Popular Books", imageName: "Briefcase"),
      MediaName(name: "New Books", imageName: "Book"),
      MediaName(name: "Authors", imageName: "Mark Twain"),
      MediaName(name: "Genres", imageName: "Comedy"),
      MediaName(name: "Settings", imageName: "Engineering"),
      MediaName(name: "Search", imageName: "Search")
    ]
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let view = tableView.cellForRow(at: indexPath),
       let indexPath = tableView.indexPath(for: view) {
      let mediaItem = items.getItem(for: indexPath)

      switch mediaItem.name! {
        case "Now Listening":
          performSegue(withIdentifier: "Now Listening", sender: view)

        case "New Books":
          performSegue(withIdentifier: "New Books", sender: view)
        
        case "Authors":
          performSegue(withIdentifier: "Authors Letters", sender: view)

        case "Genres":
          performSegue(withIdentifier: "Genres", sender: view)

        case "Settings":
          performSegue(withIdentifier: "Settings", sender: view)

        case "Search":
          performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

        default:
          performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
      }
    }
  }

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            destination.params["requestType"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.configuration = service.getConfiguration()
          }

        case "Now Listening":
          if let destination = segue.destination.getActionController() as? AudioItemsController {
            let configuration = service.getConfiguration()

            let playerSettings = service.audioPlayer.audioPlayerSettings

            if let dataSource = configuration["dataSource"] as? DataSource,
              let currentBookId = playerSettings?.items["currentBookId"],
               let currentBookName = playerSettings?.items["currentBookName"],
               let currentBookThumb = playerSettings?.items["currentBookThumb"] {

              destination.name = currentBookName
              destination.thumb = currentBookThumb
              destination.id = currentBookId
              destination.audioPlayer = service.audioPlayer

              destination.loadAudioItems = BookZvookMediaItemsController.loadAudioItems(currentBookId, dataSource: dataSource)
            }
          }

      case "New Books":
        if let destination = segue.destination.getActionController() as? MediaItemsController,
          let view = sender as? MediaNameTableCell,
          let indexPath = tableView.indexPath(for: view) {

          let mediaItem = items.getItem(for: indexPath)

          destination.params["requestType"] = mediaItem.name
          destination.params["parentName"] = localizer.localize(mediaItem.name!)

          destination.configuration = service.getConfiguration()
        }
        
//      case "Genres":
//        if let destination = segue.destination.getActionController() as? MediaItemsController,
//          let view = sender as? MediaNameTableCell,
//          let indexPath = tableView.indexPath(for: view) {
//
//          let mediaItem = items.getItem(for: indexPath)
//
//          destination.params["requestType"] = mediaItem.name
//          destination.params["parentName"] = localizer.localize(mediaItem.name!)
//
//          destination.configuration = service.getConfiguration()
//        }
        
        case SearchTableController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchTableController {
            destination.params["requestType"] = "Search"
            destination.params["parentName"] = localizer.localize("Search Results")

            destination.configuration = service.getConfiguration()
          }

        default: break
      }
    }
  }

}
