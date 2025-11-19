# Verificar APIs necesarias para Google Sign-In

## APIs que necesitas verificar/habilitar en Google Cloud Console:

### 1. **Identity Toolkit API** (La más importante)

Esta es la API principal que Firebase usa para la autenticación:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto **emmu-tfg**
3. Ve a **APIs & Services** > **Library**
4. Busca: **"Identity Toolkit API"**
5. Si no está habilitada, haz clic en **Enable**
6. Si ya está habilitada, verás un botón que dice "Manage" (está habilitada)

### 2. **Google+ API** (Puede estar deprecada, pero verifica)

1. En la misma sección **Library**, busca: **"Google+ API"**
2. Si aparece, habilítala

### 3. **OAuth consent screen**

Aunque no es una API, es importante verificar:

1. Ve a **APIs & Services** > **OAuth consent screen**
2. Verifica que esté configurado (puede ser "Internal" o "External")
3. Asegúrate de que el email de soporte esté configurado

## Lo más importante:

**Para Google Sign-In con Firebase, la API crítica es "Identity Toolkit API".**

Si esta API está habilitada y Google Sign-In está habilitado en Firebase Console, debería funcionar incluso sin una API específica llamada "Google Sign-In API".

## Verificar todas las APIs habilitadas:

1. Ve a **APIs & Services** > **Enabled APIs**
2. Busca en la lista si tienes:
   - ✅ **Identity Toolkit API** (crítica)
   - ✅ **Google+ API** (si existe)
   - ✅ **Firebase Authentication API** (debería estar habilitada automáticamente)

## Verificación final:

1. ✅ **Identity Toolkit API** habilitada en Google Cloud Console
2. ✅ **Google Sign-In** habilitado en Firebase Console > Authentication > Sign-in method
3. ✅ **OAuth 2.0 Client ID** para Android existe (ya confirmado que existe)
4. ✅ **SHA-1/SHA-256** añadidas en Firebase Console
5. ✅ **google-services.json** actualizado con las huellas

