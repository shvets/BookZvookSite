import UIKit
import TVSetKit
import PageLoader

class GenresTableViewController: UITableViewController {
  static let SegueIdentifier = " Genres"
  let CellIdentifier = " GenreTableCell"

  let localizer = Localizer(BookZvookService.BundleId, bundleClass: BookZvookSite.self)

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

  let service = BookZvookService()

  let pageLoader = PageLoader()

  private var items = Items()

  var selectedItem: Item?
  var parentId: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Genres")

#if os(iOS)
    tableView?.backgroundView = activityIndicatorView
    pageLoader.spinner = PlainSpinner(activityIndicatorView)
#endif

    func load() throws -> [Any] {
      var params = Parameters()
      params["requestType"] = "Genres"
      params["selectedItem"] = self.selectedItem
      params["parentId"] = self.parentId

      return try self.service.dataSource.loadAndWait(params: params)
    }

    pageLoader.loadData(onLoad: load) { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
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
    if let view = tableView.cellForRow(at: indexPath){
      performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController,
           let view = sender as? MediaNameTableCell,
           let indexPath = tableView.indexPath(for: view) {

          destination.params["requestType"] = "Author"
          destination.params["selectedItem"] = items.getItem(for: indexPath)
          destination.params["parentId"] = parentId

          destination.configuration = service.getConfiguration()
        }

      default: break
      }
    }
  }

}
