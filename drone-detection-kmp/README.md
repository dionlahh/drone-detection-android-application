# Drone Detection Kotlin Multiplatform

This module is the new Kotlin Multiplatform (KMP) home for the Drone Detection project.  
It aims to unify the legacy Android (Java) object detector and the Flutter map UI in a single code base that can target Android first, and progressively expand to iOS and desktop.

## Project Structure

- `shared`: Cross-platform business logic, models, and coroutine-based repositories.
- `androidApp`: Native Android entry point that consumes the shared layer. Currently exposes a placeholder UI while porting of the camera and map stacks is in progress.

## Next Steps

1. **Bridge Object Detection**  
   - Wrap the existing `YoloV5Classifier` pipeline with `TensorflowDetectionEngine`.  
   - Expose camera preview frames via CameraX and feed them into the shared detection repository.

2. **Port Map Experience**  
   - Recreate map features with Compose Multiplatform + Mapbox/Google Maps SDK on Android.  
   - Port BLoC state machines to shared Kotlin flows for reuse.

3. **Compose Multiplatform UI Shell**  
   - Replace the placeholder Activity XML with a Compose UI hosted from the shared module.  
   - Align navigation and state management with the Flutter feature set.

4. **iOS Target (Optional for now)**  
   - Add a SwiftUI wrapper that consumes the shared module.  
   - Implement `DetectionEngine` using CoreML or remote inference.

## Development

The existing `gradlew` in the repository root can be reused to build the new project once modules are wired into the workspace build.  
For now, the modules are isolated so that the legacy apps remain untouched during the migration.

