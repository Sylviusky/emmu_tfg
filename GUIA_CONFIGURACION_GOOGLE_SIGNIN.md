# Guía de Configuración de Google Sign-In para Firebase

## Problemas Identificados

1. **El `google-services.json` tiene `"oauth_client": []` vacío**
   - Esto significa que no hay un OAuth client configurado para Android en Firebase Console
   - Esto es crítico para que Google Sign-In funcione correctamente

2. **Falta configuración en Firebase Console**
   - Google Sign-In debe estar habilitado
   - Debe haber un OAuth client configurado para Android con SHA-1/SHA-256

## Soluciones Paso a Paso

### 1. Verificar y Habilitar Google Sign-In en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `emmu-tfg`
3. Ve a **Authentication** > **Sign-in method**
4. Verifica que **Google** esté habilitado
   - Si no está habilitado, haz clic en **Google** y actívalo
   - Asegúrate de tener configurado el **Email de soporte del proyecto** y **Nombre del proyecto**
   - Guarda los cambios

### 2. Configurar OAuth Client para Android

**Opción A: Si tienes SHA-1/SHA-256 configurados:**

1. En Firebase Console, ve a **Configuración del proyecto** (⚙️) > **Tus aplicaciones**
2. Selecciona tu aplicación Android
3. Verifica que las **Huellas digitales del certificado** (SHA-1 y SHA-256) estén añadidas
4. Si están, Firebase debería generar automáticamente un OAuth client para Android
5. Descarga el nuevo `google-services.json` y reemplázalo en `android/app/google-services.json`
6. Verifica que el nuevo archivo tenga contenido en `"oauth_client": [...]` (no vacío)

**Opción B: Si no tienes SHA-1/SHA-256 configurados:**

1. Obtén tus huellas digitales ejecutando:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   O para Windows:
   ```powershell
   cd android
   .\gradlew signingReport
   ```

2. Copia los valores de **SHA1** y **SHA256** del reporte
3. En Firebase Console, ve a **Configuración del proyecto** > **Tus aplicaciones** > **Android app**
4. Haz clic en **Añadir huella digital**
5. Añade tanto SHA-1 como SHA-256 (para debug y release si usas diferentes keystores)
6. Descarga el nuevo `google-services.json` y reemplázalo
7. Verifica que el nuevo archivo tenga contenido en `"oauth_client": [...]`

### 3. Verificar Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto `emmu-tfg`
3. Ve a **APIs & Services** > **Credentials**
4. Verifica que exista un **OAuth 2.0 Client ID** para Android
   - Debería tener tu package name: `com.emmutfg.emmu_tfg`
   - Debería tener SHA-1 y SHA-256 configurados
5. Si no existe, crea uno:
   - Tipo: **Android**
   - Package name: `com.emmutfg.emmu_tfg`
   - SHA-1: (del paso anterior)
   - SHA-256: (del paso anterior)

### 4. Verificar API de Google Sign-In

1. En Google Cloud Console, ve a **APIs & Services** > **Library**
2. Busca **Google Sign-In API**
3. Verifica que esté **habilitada**
4. Si no está habilitada, haz clic en **Enable**

### 5. Actualizar google-services.json

Después de configurar todo en Firebase Console:

1. Descarga el nuevo `google-services.json` desde Firebase Console
2. Reemplázalo en `android/app/google-services.json`
3. Verifica que el archivo tenga contenido en `"oauth_client": [...]` similar a:
   ```json
   "oauth_client": [
     {
       "client_id": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
       "client_type": 1,
       "android_info": {
         "package_name": "com.emmutfg.emmu_tfg",
         "certificate_hash": "YOUR_SHA1"
       }
     },
     {
       "client_id": "650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com",
       "client_type": 3
     }
   ]
   ```

### 6. Reconstruir la Aplicación

Después de actualizar `google-services.json`:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Configuración Actual del Código

El código está configurado para usar:
- **serverClientId**: `650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com` (Web OAuth client)
- Esto funciona como solución temporal, pero lo ideal es tener un OAuth client específico para Android

## Verificación

Después de seguir estos pasos, prueba:
1. Iniciar sesión con una cuenta de Google existente
2. Iniciar sesión con una cuenta de Google nueva (debería registrarla automáticamente)
3. Verifica en Firebase Console > Authentication > Users que los usuarios se crean correctamente
4. Verifica en Firestore > Usuario que se crean los documentos con el UID correcto

## Errores Comunes

- **`sign_in_failed, ApiException: 10`**: SHA-1/SHA-256 no configurados o incorrectos
- **`sign_in_failed, ApiException: 12500`**: Google Sign-In API no habilitada en Google Cloud Console
- **`idToken is null`**: `serverClientId` incorrecto o no especificado
- **`oauth_client: []` vacío**: OAuth client para Android no configurado en Firebase Console

