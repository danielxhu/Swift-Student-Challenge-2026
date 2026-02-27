import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    
    init() {
        let entity = NSEntityDescription()
        entity.name = "FamilyMember"
        entity.managedObjectClassName = "FamilyMember"
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"; idAttr.attributeType = .UUIDAttributeType
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "fullName"; nameAttr.attributeType = .stringAttributeType
        
        let relAttr = NSAttributeDescription()
        relAttr.name = "relationship"; relAttr.attributeType = .stringAttributeType
        
        let photoAttr = NSAttributeDescription()
        photoAttr.name = "photoData"; photoAttr.attributeType = .binaryDataAttributeType
        
        entity.properties = [idAttr, nameAttr, relAttr, photoAttr]
        
        let model = NSManagedObjectModel()
        model.entities = [entity]
        
        container = NSPersistentContainer(name: "SeniorTrainer", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data failed: \(error)") }
        }
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
}
