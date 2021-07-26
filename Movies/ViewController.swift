//
//  ViewController.swift
//  Movies
//
//  Created by Muhammed YILDIRIM  on 12.07.2021.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var table: UITableView!
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.dataSource = self
        table.delegate = self
        searchText.delegate = self
        
    }
    
    
    // Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    
    func searchMovies() {
        
        searchText.resignFirstResponder()
        
        guard let searchtext = searchText.text, !searchtext.isEmpty else {
            return
            
        }
        
        let query = searchtext.replacingOccurrences(of: " ", with: "%20")
        
        movies.removeAll()
       
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=ad9040c9&s=\(query)&type=movie")!,
                                           completionHandler: { data, response, error in

                                            guard let data = data, error == nil else {
                                                return
                                            }

                                            // Convert
                                            var result: MovieResult?
                                            do {
                                                result = try JSONDecoder().decode(MovieResult.self, from: data)
                                            }
                                            catch {
                                                print("error")
                                            }

                                            guard let finalResult = result else {
                                                return
                                            }

                                            // Update our movies array
                                            let newMovies = finalResult.Search
                                            self.movies.append(contentsOf: newMovies)

                                            // Refresh our table
                                            DispatchQueue.main.async {
                                                self.table.reloadData()
                                            }

                }).resume()

    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        // details movie segue
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
        let vc = SFSafariViewController(url: URL(string: url)!)
        present(vc, animated: true, completion: nil)
        
    }


}



struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String

    private enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, _Type = "Type", Poster
    }
}

