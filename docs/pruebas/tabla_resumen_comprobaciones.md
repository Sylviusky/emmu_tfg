# Tabla Resumen de Comprobaciones - TFG

## Tabla Principal de Resultados

| Nº | Ítem | Tipo | Herramienta | Comando | Resultado Esperado | Resultado Obtenido | Evidencia | Acción Tomada |
|----|-----|------|-------------|--------|-------------------|-------------------|----------|---------------|
| 1 | Lint Flutter | Auto | `flutter analyze` | `flutter analyze` | 0 errores | 0 errores, 20 warnings | `build/reports/flutter_analyze.txt` | Warnings justificados (print statements, tipos privados en API) |
| 2 | Tests Unitarios | Auto | `flutter test` | `flutter test` | Todos los tests pasan | 2 tests, 2 passed | `build/reports/flutter_test.json` | Tests de utilidades puras (parseDynamicToGeoPoint) |
| 3 | Integration Tests | Auto | `flutter test integration_test` | `flutter test integration_test/place_autocomplete_test.dart` | Todos los tests pasan | 1 test, 1 passed | `build/reports/integration_test.json` | Test de flujo de autocompletado con mocks |
| 4 | Android Lint | Auto | Android Lint | `.\android\gradlew.bat -p android lint` | 0 errores críticos | Pendiente ejecución | `build/app/reports/lint-results-debug.html` | Corregir local.properties si es necesario |
| 5 | Accesibilidad - Lint | Auto | Android Lint | `.\android\gradlew.bat -p android lint` | 0 problemas de accesibilidad | Pendiente | `lint-results-debug.html` | Revisar reglas ContentDescription, TouchTargetSize |
| 6 | Accesibilidad - TalkBack | Manual | TalkBack | N/A | Navegación fluida | Pendiente | `docs/pruebas/accesibilidad_talkback_[fecha].md` | Usar plantilla de accesibilidad |
| 7 | Performance - Inicio | Auto/Manual | Flutter DevTools | `flutter run --profile` | < 3s cold start | Pendiente | Capturas DevTools | Medir tiempos de inicio |
| 8 | Performance - Memoria | Auto/Manual | Android Profiler | Android Studio Profiler | < 250 MB por pantalla | Pendiente | Gráficas de memoria | Analizar uso de memoria |
| 9 | Performance - FPS | Auto/Manual | Flutter DevTools | `flutter run --profile` | > 55 FPS | Pendiente | Gráficas de performance | Medir FPS en scroll |
| 10 | Seguridad - Permisos | Manual | Revisión código | Revisar AndroidManifest.xml | Solo permisos necesarios | Pendiente | `docs/pruebas/seguridad_permisos.md` | Documentar cada permiso |
| 11 | Seguridad - Firebase Rules | Manual | Pruebas manuales | Firebase Console + pruebas | Acceso denegado sin auth | Pendiente | `docs/pruebas/seguridad_firebase.md` | Probar reglas de Firestore/Storage |
| 12 | Seguridad - Claves API | Manual | Revisión código | Buscar claves hardcoded | Claves en variables de entorno | Pendiente | `docs/pruebas/seguridad_claves.md` | Mover a .env o Remote Config |
| 13 | Usabilidad - Tarea 1 | Manual | Protocolo de usabilidad | N/A | Tasa éxito ≥ 80% | Pendiente | `docs/pruebas/usabilidad_participante_[#].md` | Ejecutar con 5-8 participantes |
| 14 | Usabilidad - Tarea 2 | Manual | Protocolo de usabilidad | N/A | Tasa éxito ≥ 80% | Pendiente | `docs/pruebas/usabilidad_participante_[#].md` | Ejecutar con 5-8 participantes |
| 15 | Usabilidad - Tarea 3 | Manual | Protocolo de usabilidad | N/A | Tasa éxito ≥ 80% | Pendiente | `docs/pruebas/usabilidad_participante_[#].md` | Ejecutar con 5-8 participantes |
| 16 | Usabilidad - Tarea 4 | Manual | Protocolo de usabilidad | N/A | Tasa éxito ≥ 80% | Pendiente | `docs/pruebas/usabilidad_participante_[#].md` | Ejecutar con 5-8 participantes |
| 17 | Usabilidad - Tarea 5 | Manual | Protocolo de usabilidad | N/A | Tasa éxito ≥ 80% | Pendiente | `docs/pruebas/usabilidad_participante_[#].md` | Ejecutar con 5-8 participantes |
| 18 | Pre-launch Report | Auto | Google Play Console | Subir AAB a internal track | 0 crashes | Pendiente | Capturas Pre-launch report | Revisar pestañas Stability, Accessibility |
| 19 | Firebase Test Lab | Auto | Firebase Test Lab | `gcloud firebase test android run` | 0 crashes | Pendiente | `results-[matrix-id].zip` | Ejecutar tests en dispositivos reales |

---

## Resumen por Categoría

### Comprobaciones Automáticas
- **Completadas**: 3/6 (50%)
- **Pendientes**: Android Lint, Pre-launch Report, Firebase Test Lab

### Comprobaciones Manuales
- **Completadas**: 0/13 (0%)
- **Pendientes**: Accesibilidad TalkBack, Performance, Seguridad, Usabilidad

---

## Criterios de Aceptación Globales

- [ ] **Lint**: 0 errores críticos, warnings justificados
- [ ] **Tests**: > 80% de tests pasando
- [ ] **Accesibilidad**: Todos los elementos tienen contentDescription, orden lógico de navegación
- [ ] **Performance**: Inicio < 3s, FPS > 55, memoria < 250 MB
- [ ] **Seguridad**: Reglas Firebase correctas, claves no expuestas, permisos justificados
- [ ] **Usabilidad**: Tasa de éxito ≥ 80% en tareas clave, valoración media ≥ 4/5

---

## Estado Actual vs Core App Quality

| Categoría | Estado | Notas |
|-----------|--------|-------|
| Estabilidad | ☐ Pendiente | Requiere Pre-launch report y Test Lab |
| Accesibilidad | ☐ Pendiente | Requiere pruebas con TalkBack |
| Performance | ☐ Pendiente | Requiere mediciones con DevTools |
| Compatibilidad | ☐ Pendiente | Requiere pruebas en múltiples dispositivos |
| Privacidad | ☐ Pendiente | Requiere revisión de permisos y datos |

---

## Próximos Pasos

1. ✅ Completar Android Lint y generar reporte HTML
2. ⏳ Ejecutar pruebas de accesibilidad con TalkBack (2 dispositivos)
3. ⏳ Medir performance con Flutter DevTools
4. ⏳ Revisar y documentar seguridad (permisos, Firebase rules, claves)
5. ⏳ Ejecutar pruebas de usabilidad (5-8 participantes)
6. ⏳ Subir AAB a Google Play y revisar Pre-launch report
7. ⏳ Configurar y ejecutar Firebase Test Lab

---

## Notas para la Memoria

- **Evidencias a adjuntar**: Todos los archivos de `build/reports/` y `docs/pruebas/`
- **Citas a incluir**: 
  - Android Developers - Core App Quality
  - Firebase Test Lab Documentation
  - Flutter Testing Guide
  - Android Accessibility Guidelines

