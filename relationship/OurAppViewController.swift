import UIKit
import SafariServices

struct AppItem {
    let iconName: String
    let name: String
    let subtitle: String
    let link: String
}

class OurAppViewController: UIViewController {
    
    private let apps: [AppItem] = [
        .init(iconName: "snibox", name: "Snibox - 多合一实用工具箱", subtitle: "100+ 效率工具，装机必备全能工具箱", link: "https://apps.apple.com/zh/app/id6572311811"),
        .init(iconName: "pdfinity", name: "秘影PDF - PDF文档编辑、转换工具", subtitle: "轻松合并、拆分、压缩、转换和编辑 PDF", link: "https://apps.apple.com/cn/app/%E7%A7%98%E5%BD%B1pdf-pdf%E6%96%87%E6%A1%A3%E7%BC%96%E8%BE%91-%E8%BD%AC%E6%8D%A2%E5%B7%A5%E5%85%B7/id6502285909"),
        .init(iconName: "picrecall", name: "Picrecall - 老照片修复、照片清晰度增强", subtitle: "老照片、划痕修复、画质增强，全能照片增强器", link: "https://apps.apple.com/cn/app/picrecall-%E8%80%81%E7%85%A7%E7%89%87%E4%BF%AE%E5%A4%8D-%E7%85%A7%E7%89%87%E6%B8%85%E6%99%B0%E5%BA%A6%E5%A2%9E%E5%BC%BA/id6482853307")
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AppItemCell.self, forCellReuseIdentifier: "AppItemCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "我们的应用"
        
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .stop, target: self, action: #selector(dismissAction))
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissAction() {
        dismiss(animated: true)
    }
    
    private func openAppStore(for app: AppItem) {
        guard let url = URL(string: app.link) else { return }
        UIApplication.shared.open(url)
    }
}

extension OurAppViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppItemCell", for: indexPath) as? AppItemCell else {
            return UITableViewCell()
        }
        let app = apps[indexPath.row]
        cell.configure(with: app)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let app = apps[indexPath.row]
        openAppStore(for: app)
    }
}

class AppItemCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    func configure(with app: AppItem) {
        iconImageView.image = UIImage(named: app.iconName)
        nameLabel.text = app.name
        subtitleLabel.text = app.subtitle
    }
}
