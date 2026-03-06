import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging

public enum FirebaseSetup {

    public static func configure() {
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }
}
