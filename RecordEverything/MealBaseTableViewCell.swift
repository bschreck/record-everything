import UIKit

class MealBaseTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    var ingredientsDataSource = [String]() {
        didSet {
            var ingredientsLabelText = ""
            for (index,ingredient) in ingredientsDataSource.enumerate() {
                ingredientsLabelText += "\(ingredient)"
                if index < ingredientsDataSource.count-1 {
                    ingredientsLabelText += ", "
                }
            }
            ingredientsLabel.text = ingredientsLabelText
        }
    }
    
    @IBOutlet weak var cookingMethodLabel: UILabel!

    @IBOutlet weak var ingredientsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
