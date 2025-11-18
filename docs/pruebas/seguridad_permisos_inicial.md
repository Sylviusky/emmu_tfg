# Revisión de Permisos Android - Análisis Inicial

**Fecha**: $(date)
**Revisado por**: [Tu nombre]

---

## Permisos Encontrados en AndroidManifest

### Permisos Explícitos

| Permiso | Ubicación | ¿Necesario? | Justificación | Riesgo |
|---------|-----------|-------------|---------------|--------|
| `INTERNET` | `android/app/src/debug/AndroidManifest.xml`<br>`android/app/src/profile/AndroidManifest.xml` | ✅ **Sí** | Necesario para comunicación con Firebase, APIs, y hot reload en desarrollo | 🟢 Bajo |

---

## Permisos Declarados por Plugins

Los siguientes plugins pueden declarar permisos automáticamente:

### Plugins Identificados

1. **`image_picker: ^1.0.7`**
   - **Permisos que puede solicitar**:
     - `CAMERA` - Para tomar fotos
     - `READ_EXTERNAL_STORAGE` - Para leer imágenes de la galería (Android < 13)
     - `READ_MEDIA_IMAGES` - Para leer imágenes (Android 13+)
   - **¿Se usa en la app?**: ☐ Sí ☐ No
   - **Justificación**: [Completar si se usa: "Los usuarios pueden subir fotos de sus instrumentos/eventos"]

2. **Google Maps / Location Picker**
   - **Permisos que puede solicitar**:
     - `ACCESS_FINE_LOCATION` - Ubicación precisa
     - `ACCESS_COARSE_LOCATION` - Ubicación aproximada
   - **¿Se usa en la app?**: ☐ Sí ☐ No (probablemente SÍ, por `location_picker.dart`)
   - **Justificación**: [Completar: "La app permite buscar anuncios por ubicación cercana"]

---

## Cómo Verificar Permisos Reales

### Método 1: Ver en Google Play Console (si ya subiste la app)
1. Ve a Google Play Console
2. App → Política → Permisos de la app
3. Verás todos los permisos que solicita

### Método 2: Ver en el APK compilado
```bash
# Compilar APK
flutter build apk --release

# Usar aapt2 para ver permisos (si tienes Android SDK)
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

### Método 3: Ver en tiempo de ejecución
1. Instala la app en un dispositivo
2. Ve a: Configuración → Apps → Emmu → Permisos
3. Verás todos los permisos que la app puede solicitar

---

## Checklist de Verificación

- [ ] Verificar permisos en dispositivo Android
- [ ] Documentar cada permiso encontrado
- [ ] Justificar por qué es necesario
- [ ] Evaluar nivel de riesgo
- [ ] Verificar que no hay permisos innecesarios

---

## Próximos Pasos

1. **Instala la app en un dispositivo Android**
2. **Ve a Configuración → Apps → Emmu → Permisos**
3. **Anota todos los permisos que aparecen**
4. **Completa la tabla de arriba con cada permiso**

---

## Ejemplo de Justificación Completa

```
Permiso: ACCESS_FINE_LOCATION
¿Necesario?: Sí
Justificación: La funcionalidad principal de la app es conectar músicos 
y estudiantes por ubicación. Los usuarios pueden buscar clases particulares 
o eventos cercanos a su ubicación. Sin este permiso, la funcionalidad de 
búsqueda geográfica no funcionaría.
Riesgo: Medio (datos sensibles de ubicación, pero esencial para la app)
Alternativas consideradas: ACCESS_COARSE_LOCATION (rechazada porque necesitamos 
precisión para calcular distancias correctamente)
```

---

## Notas

- Los permisos de plugins se declaran automáticamente en el `AndroidManifest.xml` generado
- Puedes ver el manifest final en: `build/app/intermediates/merged_manifests/`
- Si encuentras permisos innecesarios, puedes usar `tools:node="remove"` en el manifest

---

**Estado**: ⏳ Pendiente de verificación en dispositivo

