import UIKit

final class MainVc: UIViewController {
  
    private lazy var tableView = makeTableView()
  
    private struct Row {
        let title: String
        let destination: () -> UIViewController
    }

    private let rows: [Row] = [
        Row(
            title: Constants.title2DCell,
            destination: {
            return Interactive2DViewController()
            }
        ),
        Row(
            title: Constants.title2DLayeredCell,
            destination: {
            return Interactive2DLayeredViewController()
            }
        ),
        Row(
            title: Constants.title3DCell,
            destination: {
            return Interactive3DViewController()
            }
        )
    ]
  
    private let identifier = Constants.identifier

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Private methods

private extension MainVc {
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = Constants.navigationTitle
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(
                name: Constants.navTitleFont,
                size: 20
            )!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont(
                name: Constants.navTitleFont,
                size: 30
            )!
        ]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
    }
}

// MARK: - Factory Methods

private extension MainVc {
    func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        return tableView
    }
}

// MARK: - TableView Delegate

extension MainVc: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return Constants.heightRow
    }
  
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        let vc = row.destination()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView DataSource

extension MainVc: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return rows.count
    }
  
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        )
        cell.textLabel?.text = rows[indexPath.row].title
        cell.textLabel?.font = UIFont(name: Constants.cellTextFont, size: 16)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .gray
        return cell
    }
}

// MARK: - Constants

private extension MainVc {
    enum Constants {
        static let heightRow: CGFloat = 50
        static let identifier: String = "MyCell"
        static let title2DCell = "Interactive 2D logo"
        static let title2DLayeredCell = "Interactive layered 2D logo"
        static let title3DCell = "Interactive 3D logo"
        static let navigationTitle = "INTERACTIVE LOGO"
        static let cellTextFont = "Montserrat-Regular"
        static let navTitleFont = "Montserrat-Bold"
    }
}

