import UIKit

class ViewController: UIViewController {
    private let jokeLabel = UILabel()
    private let pickerView = UIPickerView()
    private let refreshButton = UIButton(type: .system)

    private var selectedCategory: JokeCategory = .any

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadJokes()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // joke label
        jokeLabel.textAlignment = .center
        jokeLabel.numberOfLines = 0
        jokeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(jokeLabel)
        
        // picker for categories
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        // refresh
        refreshButton.setTitle("Refresh Joke", for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshJoke), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            jokeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jokeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            jokeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            jokeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: jokeLabel.bottomAnchor, constant: 20),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            pickerView.heightAnchor.constraint(equalToConstant: 100),
            
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20)
        ])
    }
    
    private func loadJokes() {
        JokeAPIClient.fetchJokes(category: selectedCategory, amount: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let jokes):
                    if let joke = jokes.first {
                        self?.display(joke: joke)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    self?.jokeLabel.text = "Failed to fetch joke: \(error.localizedDescription)"
                }
            }
        }
    }

    private func display(joke: Joke) {
        if joke.type == "single" {
            jokeLabel.text = joke.joke
        } else if joke.type == "twopart" {
            jokeLabel.text = "\(joke.setup ?? "")\n\n\(joke.delivery ?? "")"
        }
    }
    
    @objc private func refreshJoke() {
        loadJokes()
    }
}

// MARK: - UIPickerViewDataSource and UIPickerViewDelegate
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return JokeCategory.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return JokeCategory.allCases[row].rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = JokeCategory.allCases[row]
    }
}

// MARK: - JokeCategory Extension
extension JokeCategory: CaseIterable {
    static var allCases: [JokeCategory] {
        return [.any, .programming, .misc, .dark, .pun, .spooky, .christmas]
    }
}

