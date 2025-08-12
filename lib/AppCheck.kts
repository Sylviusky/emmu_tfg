Firebase.initialize(context)
Firebase.appCheck.installAppCheckProviderFactory(
    //YourCustomAppCheckProviderFactory(),
    DebugAppCheckProviderFactory.getInstance()
)

class YourCustomAppCheckToken(
    private val token: String,
    private val expiration: Long,
) : AppCheckToken() {
    override fun getToken(): String = token
    override fun getExpireTimeMillis(): Long = expiration
}

class YourCustomAppCheckProvider(firebaseApp: FirebaseApp) : AppCheckProvider {
    override fun getToken(): Task<AppCheckToken> {
        // Logic to exchange proof of authenticity for an App Check token and
        //   expiration time.
        // ...

        // Refresh the token early to handle clock skew.
        val expMillis = expirationFromServer * 1000L - 60000L

        // Create AppCheckToken object.
        val appCheckToken: AppCheckToken = YourCustomAppCheckToken(tokenFromServer, expMillis)
        return Tasks.forResult(appCheckToken)
    }
}


class YourCustomAppCheckProviderFactory : AppCheckProviderFactory {
    override fun create(firebaseApp: FirebaseApp): AppCheckProvider {
        // Create and return an AppCheckProvider object.
        return YourCustomAppCheckProvider(firebaseApp)
    }
}