# Solución: OAuth Client ya existe

El error indica que ya existe un OAuth 2.0 Client ID para Android con tu package name y SHA-1. Esto es **bueno** - significa que ya está configurado, solo necesitas verificar que esté correctamente vinculado.

## Pasos para verificar y usar el OAuth Client existente:

### 1. Verificar OAuth Clients existentes en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto **emmu-tfg**
3. Ve a **APIs & Services** > **Credentials**
4. Busca en la lista de **OAuth 2.0 Client IDs**
5. Busca uno que tenga:
   - **Type:** Android
   - **Package name:** `com.emmutfg.emmu_tfg`
   - **SHA-1 certificate fingerprint:** `10:9B:2E:7D:3F:60:2D:28:1B:ED:36:0E:FB:64:0F:D6:26:95:9F:7E`

### 2. Verificar en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto **emmu-tfg**
3. Ve a **⚙️ Configuración del proyecto** > **Tus aplicaciones**
4. Selecciona tu app Android
5. Verifica que las **Huellas digitales del certificado** incluyan:
   - SHA-1: `10:9B:2E:7D:3F:60:2D:28:1B:ED:36:0E:FB:64:0F:D6:26:95:9F:7E`
   - SHA-256: `F8:76:98:23:BD:31:B8:6D:32:DE:35:C9:F1:BE:A9:94:77:56:6B:4C:EF:B1:09:F7:44:A2:A9:52:FD:5E:AD:4F`
6. Si no están, **añádelas** (no crear un nuevo OAuth client, solo añadir las huellas)
7. Después de añadir las huellas, **descarga el nuevo `google-services.json`**
8. Reemplázalo en `android/app/google-services.json`

### 3. Verificar el nuevo google-services.json

Después de descargar el nuevo archivo, verifica que tenga contenido en `"oauth_client": [...]` similar a:

```json
"oauth_client": [
  {
    "client_id": "XXXXXXXXX-XXXXXXXXXX.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.emmutfg.emmu_tfg",
      "certificate_hash": "109B2E7D3F602D281BED360EFB640FD626959F7E"
    }
  },
  {
    "client_id": "650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

**Nota:** El `client_type: 1` es para Android, y `client_type: 3` es para Web.

### 4. Si el OAuth client existe pero no está vinculado correctamente

Si encuentras el OAuth client en Google Cloud Console pero `google-services.json` sigue teniendo `"oauth_client": []` vacío:

1. En Firebase Console, después de añadir las huellas SHA-1/SHA-256, espera unos minutos
2. Descarga de nuevo el `google-services.json`
3. Firebase debería actualizar automáticamente el archivo para incluir el OAuth client existente

### 5. Verificar Google Sign-In está habilitado

Asegúrate de que:
1. **Firebase Console** > **Authentication** > **Sign-in method** > **Google** está **habilitado**
2. **Google Cloud Console** > **APIs & Services** > **Library** > **Google Sign-In API** está **habilitada**

### Resumen

- ✅ **NO necesitas crear un nuevo OAuth client** - ya existe uno
- ✅ **Añade las huellas SHA-1/SHA-256 en Firebase Console** si no están
- ✅ **Descarga el nuevo `google-services.json`** después de añadir las huellas
- ✅ **Verifica que el nuevo archivo tenga contenido en `oauth_client`**

El código ya está configurado para usar el `serverClientId` del Web, así que debería funcionar incluso si el OAuth client de Android no aparece inmediatamente en `google-services.json`.

