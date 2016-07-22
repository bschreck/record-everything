import UIKit

class MealBaseTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    
//    weak var tableView: MealBaseTableViewController? = nil
//    weak var mealBase: MealBase? = nil
//    
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
    
    var cookingMethodsDataSource = [String]() {
        didSet {
            var cookingMethodsLabelText = ""
            for (index,cm) in cookingMethodsDataSource.enumerate() {
                cookingMethodsLabelText += "\(cm)"
                if index < cookingMethodsDataSource.count-1 {
                    cookingMethodsLabelText += ", "
                }
            }
            cookingMethodsLabel.text = cookingMethodsLabelText
        }
    }
    
    @IBOutlet weak var cookingMethodsLabel: UILabel!

    @IBOutlet weak var ingredientsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    @IBAction func editMealBase(sender: AnyObject) {
//        let VC1 = self.tableView!.storyboard!.instantiateViewControllerWithIdentifier("CreateMealBase") as! CreateMealBaseViewController
//        VC1.mealBase = mealBase
//        
//        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
//        self.tableView!.presentViewController(navController, animated:true, completion: nil)
//    }
}
