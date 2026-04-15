import Foundation
import CoreData

final class SessionStore {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = CoreDataStack()) {
        self.stack = stack
    }

    func saveEvent(
        startTime: Date,
        endTime: Date,
        mode: SessionMode,
        focusPosture: Posture?,
        breakActivity: BreakActivity?,
        duration: TimeInterval
    ) {
        let context = stack.viewContext
        context.perform {
            let event = SessionEvent(context: context)
            event.id = UUID()
            event.startTime = startTime
            event.endTime = endTime
            event.mode = mode.rawValue
            event.focusPosture = focusPosture?.rawValue
            event.breakActivity = breakActivity?.rawValue
            event.posture = focusPosture?.rawValue ?? breakActivity?.rawValue ?? ""
            event.duration = duration
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func fetchTodayCount() -> Int {
        let context = stack.viewContext
        let request = SessionEvent.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        request.predicate = NSPredicate(format: "startTime >= %@", startOfDay as NSDate)
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
}

final class CoreDataStack {
    let container: NSPersistentContainer

    init() {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "FocusBreak", managedObjectModel: model)
        let storeURL = Self.storeURL()
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data load error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private static func storeURL() -> URL {
        let fileManager = FileManager.default
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = directory.appendingPathComponent("FocusBreak", isDirectory: true)
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        return appDirectory.appendingPathComponent("FocusBreak.sqlite")
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "SessionEvent"
        entity.managedObjectClassName = NSStringFromClass(SessionEvent.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let startTimeAttribute = NSAttributeDescription()
        startTimeAttribute.name = "startTime"
        startTimeAttribute.attributeType = .dateAttributeType
        startTimeAttribute.isOptional = false

        let endTimeAttribute = NSAttributeDescription()
        endTimeAttribute.name = "endTime"
        endTimeAttribute.attributeType = .dateAttributeType
        endTimeAttribute.isOptional = false

        let modeAttribute = NSAttributeDescription()
        modeAttribute.name = "mode"
        modeAttribute.attributeType = .stringAttributeType
        modeAttribute.isOptional = false

        let postureAttribute = NSAttributeDescription()
        postureAttribute.name = "posture"
        postureAttribute.attributeType = .stringAttributeType
        postureAttribute.isOptional = false

        let focusPostureAttribute = NSAttributeDescription()
        focusPostureAttribute.name = "focusPosture"
        focusPostureAttribute.attributeType = .stringAttributeType
        focusPostureAttribute.isOptional = true

        let breakActivityAttribute = NSAttributeDescription()
        breakActivityAttribute.name = "breakActivity"
        breakActivityAttribute.attributeType = .stringAttributeType
        breakActivityAttribute.isOptional = true

        let durationAttribute = NSAttributeDescription()
        durationAttribute.name = "duration"
        durationAttribute.attributeType = .doubleAttributeType
        durationAttribute.isOptional = false

        entity.properties = [
            idAttribute,
            startTimeAttribute,
            endTimeAttribute,
            modeAttribute,
            postureAttribute,
            focusPostureAttribute,
            breakActivityAttribute,
            durationAttribute
        ]

        model.entities = [entity]
        return model
    }
}

@objc(SessionEvent)
final class SessionEvent: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date
    @NSManaged var mode: String
    @NSManaged var posture: String
    @NSManaged var focusPosture: String?
    @NSManaged var breakActivity: String?
    @NSManaged var duration: TimeInterval
}

extension SessionEvent {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SessionEvent> {
        NSFetchRequest<SessionEvent>(entityName: "SessionEvent")
    }
}
