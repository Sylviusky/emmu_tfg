# Plantilla de Pruebas de Performance

## Información General
- **Fecha**: ___________
- **Evaluador**: ___________
- **Dispositivo**: ___________
- **Versión Android**: ___________
- **Versión de la App**: ___________
- **Herramienta utilizada**: ☐ Android Profiler ☐ Flutter DevTools ☐ Firebase Performance ☐ Otra: ___________

---

## Métricas de Inicio de la Aplicación

### Primera Apertura (Cold Start)
- **Tiempo hasta primer frame**: ___________
- **Tiempo hasta UI interactiva**: ___________
- **Tiempo total de inicio**: ___________

### Apertura Posterior (Warm Start)
- **Tiempo hasta primer frame**: ___________
- **Tiempo hasta UI interactiva**: ___________
- **Tiempo total de inicio**: ___________

**Objetivo**: < 3 segundos para cold start, < 1 segundo para warm start

---

## Métricas de Navegación

| Pantalla | Tiempo de Carga | FPS Promedio | FPS Mínimo | Observaciones |
|----------|-----------------|--------------|------------|---------------|
| Inicio de Sesión | | | | |
| Lista de Eventos | | | | |
| Lista de Clases | | | | |
| Detalle de Anuncio | | | | |
| Formulario de Anuncio | | | | |
| Perfil de Usuario | | | | |

**Objetivo**: FPS > 55, tiempo de carga < 1 segundo

---

## Métricas de Memoria

### Uso de Memoria por Pantalla

| Pantalla | Memoria Pico (MB) | Memoria Promedio (MB) | Observaciones |
|----------|-------------------|----------------------|---------------|
| Inicio de Sesión | | | |
| Lista de Eventos | | | |
| Lista de Clases | | | |
| Detalle de Anuncio | | | |
| Formulario de Anuncio | | | |
| Perfil de Usuario | | | |

**Objetivo**: < 250 MB por pantalla

### Análisis de Fugas de Memoria
- **¿Se detectaron fugas?**: ☐ Sí ☐ No
- **Descripción**: 
  _________________________________________________________

---

## Métricas de Red

### Operaciones de Red

| Operación | Tiempo de Respuesta | Tamaño de Datos | Observaciones |
|-----------|---------------------|-----------------|---------------|
| Login | | | |
| Cargar Lista de Anuncios | | | |
| Cargar Detalle de Anuncio | | | |
| Subir Imagen | | | |
| Publicar Anuncio | | | |
| Buscar Anuncios | | | |

**Objetivo**: Tiempo de respuesta < 2 segundos para operaciones normales

---

## Métricas de Rendimiento en Scroll

### Lista de Anuncios
- **FPS durante scroll**: ___________
- **FPS mínimo**: ___________
- **¿Hay lag o stuttering?**: ☐ Sí ☐ No
- **Observaciones**: 
  _________________________________________________________

**Objetivo**: FPS > 55 durante scroll

---

## Análisis de Imágenes

### Carga de Imágenes
- **Tiempo promedio de carga**: ___________
- **¿Se usa lazy loading?**: ☐ Sí ☐ No
- **¿Se usa caching?**: ☐ Sí ☐ No
- **Tamaño promedio de imagen**: ___________

**Observaciones**: 
_________________________________________________________

---

## Benchmark de Operaciones Críticas

| Operación | Tiempo Medido | Objetivo | ¿Cumple? |
|-----------|---------------|----------|----------|
| Renderizado de lista (100 items) | | < 300ms | ☐ Sí ☐ No |
| Serialización de datos | | < 50ms | ☐ Sí ☐ No |
| Búsqueda local | | < 100ms | ☐ Sí ☐ No |
| Filtrado de resultados | | < 200ms | ☐ Sí ☐ No |

---

## Problemas Detectados

### Problemas Críticos
1. _________________________________________________________
2. _________________________________________________________

### Problemas Menores
1. _________________________________________________________
2. _________________________________________________________

---

## Optimizaciones Aplicadas

1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

---

## Recomendaciones

1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

---

## Capturas de Pantalla / Gráficas

**Nota**: Adjuntar capturas de:
- Android Profiler (CPU, Memory, Network)
- Flutter DevTools (Performance, Memory)
- Firebase Performance Monitoring (si aplica)

---

## Criterios de Aceptación

- [ ] Tiempo de inicio < 3 segundos (cold start)
- [ ] FPS > 55 en todas las pantallas
- [ ] Uso de memoria < 250 MB por pantalla
- [ ] No hay fugas de memoria detectadas
- [ ] Tiempo de respuesta de red < 2 segundos
- [ ] Scroll fluido sin lag

