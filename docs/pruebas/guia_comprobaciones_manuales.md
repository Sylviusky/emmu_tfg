# Guía Paso a Paso: Comprobaciones Manuales

## Orden Recomendado de Ejecución

1. **Seguridad** (más rápido, no requiere dispositivos)
2. **Performance** (requiere DevTools, pero es rápido)
3. **Accesibilidad** (requiere dispositivos físicos)
4. **Usabilidad** (requiere más tiempo y participantes)

---

## 1. COMPROBACIONES DE SEGURIDAD

### Tiempo estimado: 1-2 horas

### Paso 1.1: Revisar Permisos Android

**Archivo a revisar**: `android/app/src/main/AndroidManifest.xml`

**Qué hacer**:
1. Abre el archivo `AndroidManifest.xml`
2. Busca todas las líneas `<uses-permission ...>`
3. Para cada permiso, completa la tabla en `plantilla_seguridad.md`:
   - ¿Es necesario? (Sí/No)
   - Justificación (por qué lo necesitas)
   - Nivel de riesgo (Bajo/Medio/Alto)

**Permisos comunes a revisar**:
- `INTERNET` - ✅ Normal (necesario para Firebase)
- `ACCESS_FINE_LOCATION` - ⚠️ Revisar (¿realmente necesario?)
- `ACCESS_COARSE_LOCATION` - ⚠️ Revisar
- `CAMERA` - ⚠️ Revisar (¿para subir fotos?)
- `READ_EXTERNAL_STORAGE` - ⚠️ Revisar
- `WRITE_EXTERNAL_STORAGE` - ⚠️ Revisar

**Ejemplo de justificación**:
```
Permiso: ACCESS_FINE_LOCATION
¿Necesario?: Sí
Justificación: La app permite buscar anuncios por ubicación cercana. 
Necesitamos la ubicación precisa para calcular distancias.
Riesgo: Medio (datos sensibles, pero justificado por funcionalidad)
```

---

### Paso 1.2: Buscar Claves API Hardcoded

**Archivos a revisar**:
- `lib/google_maps_api_key.dart`
- `android/local.properties`
- Cualquier archivo `.dart` que contenga claves

**Qué hacer**:
1. Busca en el código cualquier string que parezca una clave API:
   ```bash
   # En PowerShell
   Select-String -Path lib\*.dart -Pattern "AIza[A-Za-z0-9_-]{35}"
   ```

2. Si encuentras claves:
   - **Problema**: Claves expuestas en el código
   - **Solución**: Mover a variables de entorno o Firebase Remote Config
   - **Documenta**: En `plantilla_seguridad.md` sección "Gestión de Claves"

**Estado actual**:
- `lib/google_maps_api_key.dart` - ⚠️ Revisar si está en el repositorio público
- `android/local.properties` - ✅ OK (no debería estar en Git)

---

### Paso 1.3: Revisar Reglas de Firebase

**Archivos a revisar**:
- `firestore.rules`
- `storage.rules` (si existe)

**Qué hacer**:
1. Abre `firestore.rules`
2. Verifica que:
   - Usuarios no autenticados NO pueden leer/escribir datos privados
   - Usuarios solo pueden modificar sus propios datos
   - Hay validaciones de campos requeridos

**Prueba manual**:
1. Abre Firebase Console → Firestore Database
2. Intenta leer una colección sin estar autenticado (desde la consola)
3. Debería dar error 403

**Documenta en `plantilla_seguridad.md`**:
- Copia las reglas actuales
- Marca qué pruebas realizaste
- Indica si pasan o no

---

### Paso 1.4: Verificar HTTPS

**Qué hacer**:
1. Ejecuta la app
2. Abre Android Studio → Logcat
3. Busca cualquier URL que empiece con `http://` (sin 's')
4. Si encuentras `http://` → ⚠️ Problema de seguridad
5. Si solo hay `https://` → ✅ Correcto

**Documenta**: En `plantilla_seguridad.md` sección "Comunicación de Red"

---

## 2. COMPROBACIONES DE PERFORMANCE

### Tiempo estimado: 1-2 horas

### Paso 2.1: Configurar Flutter DevTools

**Instalación** (si no lo tienes):
```bash
flutter pub global activate devtools
```

**Abrir DevTools**:
```bash
# Opción 1: Desde terminal
flutter pub global run devtools

# Opción 2: Desde Android Studio
# Run → Open Flutter DevTools
```

---

### Paso 2.2: Medir Tiempo de Inicio

**Qué hacer**:
1. Ejecuta la app en modo profile:
   ```bash
   flutter run --profile
   ```

2. Mide el tiempo desde que tocas el icono hasta que la app está lista:
   - **Cold start**: Cierra completamente la app, espera 5 segundos, ábrela
   - **Warm start**: Minimiza la app, vuelve a abrirla

3. Anota los tiempos en `plantilla_performance.md`

**Objetivo**: 
- Cold start < 3 segundos
- Warm start < 1 segundo

---

### Paso 2.3: Medir FPS y Memoria

**Qué hacer**:
1. Con DevTools abierto, navega por las pantallas principales:
   - Inicio de sesión
   - Lista de eventos
   - Lista de clases
   - Detalle de anuncio
   - Formulario de anuncio

2. Para cada pantalla:
   - Observa el FPS (debe estar cerca de 60)
   - Revisa el uso de memoria en la pestaña "Memory"
   - Haz scroll en listas y observa si hay lag

3. Captura pantallas de:
   - Gráfica de FPS
   - Gráfica de memoria
   - Timeline de performance

4. Anota en `plantilla_performance.md`:
   - FPS promedio por pantalla
   - Memoria pico por pantalla
   - ¿Hay lag en scroll?

**Objetivos**:
- FPS > 55
- Memoria < 250 MB por pantalla
- Scroll fluido sin lag

---

### Paso 2.4: Analizar Operaciones de Red

**Qué hacer**:
1. En DevTools, ve a la pestaña "Network"
2. Realiza estas operaciones y mide el tiempo:
   - Login
   - Cargar lista de anuncios
   - Cargar detalle de anuncio
   - Subir imagen
   - Publicar anuncio

3. Anota en `plantilla_performance.md`:
   - Tiempo de cada operación
   - Tamaño de datos transferidos

**Objetivo**: Tiempo de respuesta < 2 segundos

---

## 3. COMPROBACIONES DE ACCESIBILIDAD

### Tiempo estimado: 2-3 horas (2 dispositivos)

### Paso 3.1: Preparar Dispositivos

**Necesitas**:
- 2 dispositivos Android (móvil + tablet si es posible)
- Versiones Android diferentes (ej: Android 11 y Android 13)

**Instalar app**:
```bash
flutter install --release
```

---

### Paso 3.2: Activar TalkBack

**En cada dispositivo**:
1. Ve a **Configuración** → **Accesibilidad** → **TalkBack**
2. Activa TalkBack
3. Lee las instrucciones de gestos (aparecerán en pantalla)

**Gestos básicos**:
- **Deslizar derecha/izquierda**: Navegar entre elementos
- **Doble toque**: Activar elemento
- **Deslizar arriba/abajo**: Scroll
- **Dos dedos deslizar**: Scroll continuo

---

### Paso 3.3: Ejecutar Tareas con TalkBack

**Para cada dispositivo, completa `plantilla_accesibilidad.md`**:

#### Tarea 1: Registro de Usuario
1. Abre la app
2. Navega hasta el formulario de registro
3. Para cada campo (Email, Contraseña, Botones):
   - ¿Qué dice TalkBack? (anota exactamente)
   - ¿Es correcto? (Sí/No)
   - ¿El orden de navegación es lógico? (Sí/No)
   - ¿Puedes activar el elemento? (Sí/No)

#### Tarea 2: Publicar Anuncio
1. Navega a "Crear Anuncio"
2. Recorre todos los campos del formulario
3. Anota observaciones para cada elemento

#### Tarea 3: Buscar Anuncio
1. Ve a la búsqueda
2. Prueba el campo de búsqueda
3. Navega por los resultados
4. Anota si las tarjetas de anuncios son accesibles

#### Tarea 4: Contactar Usuario
1. Abre un anuncio
2. Intenta contactar con el usuario
3. Anota si el flujo es accesible

---

### Paso 3.4: Documentar Problemas

**Para cada problema encontrado**:
1. Describe el problema
2. Indica la ubicación (pantalla, elemento)
3. Sugiere solución
4. Clasifica: Crítico / Menor

**Ejemplo**:
```
Problema: El botón "Publicar" no tiene etiqueta descriptiva
Ubicación: Pantalla "Crear Anuncio", botón inferior
TalkBack dice: "Botón" (no dice qué hace)
Solución: Añadir semanticLabel="Publicar anuncio"
Severidad: Crítico (bloquea funcionalidad)
```

---

## 4. COMPROBACIONES DE USABILIDAD

### Tiempo estimado: 3-5 días (reclutamiento + sesiones)

### Paso 4.1: Reclutar Participantes

**Necesitas**: 5-8 participantes

**Perfil ideal**:
- Usuarios objetivo de tu app (músicos, estudiantes, etc.)
- Diferentes niveles de experiencia con apps móviles
- Edades variadas

**Cómo reclutar**:
- Amigos/familiares
- Compañeros de universidad
- Grupos de Facebook/WhatsApp relacionados

---

### Paso 4.2: Preparar Sesión

**Antes de cada sesión**:
1. Prepara el dispositivo con la app instalada
2. Crea un usuario de prueba (si es necesario)
3. Ten lista la plantilla `plantilla_usabilidad.md`
4. Prepara un cronómetro
5. Graba la pantalla (con permiso del participante)

---

### Paso 4.3: Ejecutar Sesión

**Duración**: 30-45 minutos por participante

**Estructura**:
1. **Introducción** (5 min):
   - Explica que es una prueba de usabilidad
   - No es un examen, queremos mejorar la app
   - Graba la pantalla (si acepta)

2. **Tareas** (25-30 min):
   - Tarea 1: Registro/Inicio de sesión
   - Tarea 2: Publicar anuncio
   - Tarea 3: Buscar anuncio
   - Tarea 4: Contactar usuario
   - Tarea 5: Gestionar mis anuncios

3. **Cuestionario** (10 min):
   - Cuestionario SUS (10 preguntas)
   - Preguntas abiertas

**Durante cada tarea**:
- Anota el tiempo de inicio y fin
- Cuenta los errores
- Observa si completa la tarea
- Anota comentarios del participante

---

### Paso 4.4: Analizar Resultados

**Crea una tabla resumen**:

| Participante | Tarea 1 | Tarea 2 | Tarea 3 | Tarea 4 | Tarea 5 | SUS Score |
|--------------|---------|---------|---------|---------|---------|-----------|
| P1 | ✅ 45s | ✅ 2m | ✅ 30s | ✅ 1m | ✅ 1m30s | 85 |
| P2 | ✅ 1m | ❌ 5m | ✅ 45s | ✅ 2m | ✅ 2m | 72 |
| ... | | | | | | |

**Calcula**:
- Tasa de éxito por tarea: (tareas completadas / total) × 100
- Tiempo promedio por tarea
- Puntuación SUS promedio
- Problemas más comunes

---

### Paso 4.5: Documentar Hallazgos

**En la memoria, incluye**:
1. Resumen de participantes (número, perfil)
2. Tabla de resultados
3. Problemas más frecuentes
4. Mejoras implementadas basadas en feedback
5. Capturas de pantalla de flujos problemáticos

---

## Checklist Final

Antes de considerar completas las comprobaciones manuales:

### Seguridad
- [ ] Permisos revisados y justificados
- [ ] Claves API no expuestas
- [ ] Reglas Firebase probadas
- [ ] Solo HTTPS usado

### Performance
- [ ] Tiempo de inicio medido
- [ ] FPS medido en todas las pantallas
- [ ] Memoria analizada
- [ ] Operaciones de red medidas

### Accesibilidad
- [ ] 2 dispositivos probados con TalkBack
- [ ] 4 tareas completadas en cada dispositivo
- [ ] Problemas documentados
- [ ] Soluciones propuestas

### Usabilidad
- [ ] 5-8 participantes reclutados
- [ ] Todas las sesiones completadas
- [ ] Cuestionarios SUS recopilados
- [ ] Resultados analizados
- [ ] Mejoras documentadas

---

## Próximos Pasos Después de Completar

1. **Consolidar resultados** en `tabla_resumen_comprobaciones.md`
2. **Redactar sección "Resultados"** en la memoria
3. **Adjuntar evidencias** (capturas, reportes, tablas)
4. **Incluir en "Conclusiones"** qué se mejoró basado en las pruebas

---

## Recursos Adicionales

- [Flutter DevTools Guide](https://docs.flutter.dev/tools/devtools)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)
- [SUS Questionnaire](https://www.usability.gov/how-to-and-tools/methods/system-usability-scale.html)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

**¿Dudas?** Consulta las plantillas individuales para más detalles sobre cada comprobación.

