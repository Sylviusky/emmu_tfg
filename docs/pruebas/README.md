# Documentación de Comprobaciones - TFG

Esta carpeta contiene todas las plantillas y documentación necesaria para realizar y documentar las comprobaciones del TFG.

## Estructura de Archivos

```
docs/pruebas/
├── README.md (este archivo)
├── tabla_resumen_comprobaciones.md (tabla principal para la memoria)
├── plantilla_accesibilidad.md (pruebas con TalkBack)
├── plantilla_usabilidad.md (protocolo de usabilidad)
├── plantilla_performance.md (métricas de rendimiento)
└── plantilla_seguridad.md (comprobaciones de seguridad)
```

## Cómo Usar las Plantillas

### 1. Accesibilidad (TalkBack)

**Archivo**: `plantilla_accesibilidad.md`

**Pasos**:
1. Copia la plantilla y renómbrala: `accesibilidad_talkback_[fecha].md`
2. Activa TalkBack en un dispositivo Android (Configuración → Accesibilidad → TalkBack)
3. Recorre cada tarea usando gestos de TalkBack
4. Completa la tabla para cada elemento interactuado
5. Documenta problemas encontrados y recomendaciones

**Dispositivos recomendados**: 2-3 dispositivos diferentes (móvil + tablet si es posible)

---

### 2. Usabilidad

**Archivo**: `plantilla_usabilidad.md`

**Pasos**:
1. Recluta 5-8 participantes del perfil objetivo
2. Para cada participante:
   - Copia la plantilla: `usabilidad_participante_[#].md`
   - Ejecuta las 5 tareas en orden
   - Mide tiempo, errores y dificultad percibida
   - Completa el cuestionario SUS al final
3. Consolida resultados en una tabla resumen

**Duración estimada**: 30-45 minutos por participante

---

### 3. Performance

**Archivo**: `plantilla_performance.md`

**Pasos**:
1. Abre Flutter DevTools: `flutter run --profile`
2. Navega por cada pantalla y mide:
   - Tiempo de carga
   - FPS (frames por segundo)
   - Uso de memoria
3. Realiza scroll en listas y mide FPS
4. Captura gráficas de Android Profiler o DevTools
5. Completa la plantilla con todas las métricas

**Herramientas necesarias**:
- Flutter DevTools
- Android Studio Profiler (opcional)
- Firebase Performance Monitoring (opcional)

---

### 4. Seguridad

**Archivo**: `plantilla_seguridad.md`

**Pasos**:
1. Revisa `AndroidManifest.xml` y documenta todos los permisos
2. Revisa `firestore.rules` y `storage.rules`
3. Prueba acceso no autorizado (sin autenticación)
4. Busca claves API hardcoded en el código
5. Verifica que las comunicaciones usen HTTPS
6. Completa cada sección de la plantilla

**Herramientas útiles**:
- `grep` para buscar claves
- Firebase Console para probar reglas
- Charles Proxy o Burp Suite para analizar tráfico (opcional)

---

## Tabla Resumen

**Archivo**: `tabla_resumen_comprobaciones.md`

Este archivo contiene la tabla principal que debes incluir en la sección "Resultados" de tu memoria.

**Cómo usarlo**:
1. Completa cada fila con los resultados reales
2. Actualiza el estado de cada comprobación (Pendiente → Completada)
3. Adjunta las evidencias correspondientes
4. Copia la tabla final a tu memoria

---

## Evidencias a Generar

### Automáticas
- `build/reports/flutter_analyze.txt` - Análisis estático
- `build/reports/flutter_test.json` - Tests unitarios
- `build/reports/integration_test.json` - Integration tests
- `build/app/reports/lint-results-debug.html` - Android Lint

### Manuales
- `docs/pruebas/accesibilidad_talkback_[fecha].md` - Pruebas TalkBack
- `docs/pruebas/usabilidad_participante_[#].md` - Cada participante
- `docs/pruebas/performance_[fecha].md` - Métricas de rendimiento
- `docs/pruebas/seguridad_[fecha].md` - Comprobaciones de seguridad
- Capturas de pantalla de DevTools, Pre-launch report, etc.

---

## Comandos Útiles

### Generar Reportes Automáticos
```bash
# Flutter analyze
flutter analyze > build/reports/flutter_analyze.txt

# Tests unitarios
flutter test --machine > build/reports/flutter_test.json

# Integration tests
flutter test integration_test/place_autocomplete_test.dart --machine > build/reports/integration_test.json

# Android Lint
.\android\gradlew.bat -p android lint
# Reporte en: build/app/reports/lint-results-debug.html
```

### Performance
```bash
# Ejecutar en modo profile
flutter run --profile

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Build para Pre-launch Report
```bash
# Generar AAB
flutter build appbundle --release

# Subir a Google Play Console → Internal Testing
```

---

## Checklist Final

Antes de entregar la memoria, verifica:

- [ ] Todas las comprobaciones automáticas ejecutadas y documentadas
- [ ] Al menos 2 pruebas de accesibilidad con TalkBack completadas
- [ ] Pruebas de usabilidad con 5-8 participantes
- [ ] Métricas de performance documentadas
- [ ] Comprobaciones de seguridad completadas
- [ ] Pre-launch report revisado (si aplica)
- [ ] Todas las evidencias adjuntadas en la memoria
- [ ] Tabla resumen completa en la sección "Resultados"
- [ ] Referencias citadas correctamente

---

## Contacto y Dudas

Si tienes dudas sobre cómo realizar alguna comprobación, consulta:
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Android Core App Quality](https://developer.android.com/docs/quality-guidelines/core-app-quality)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)

---

**Última actualización**: Noviembre 2025

