# Retake Android XR System Design

## 1. Purpose

This document describes the proposed system architecture for Retake as an Android XR spatial reconstruction product. It focuses on the future Android XR experience while acknowledging the current iOS overlay MVP as a separate validation client.

Retake combines XR tracking, environment scanning, media alignment, generative reconstruction, and capture workflows to let users recreate and explore anime, film, TV, and historical locations in real-world space.

## 2. Design Goals

- Provide a stable Android XR experience for scanning, aligning, exploring, and capturing scenes.
- Keep basic alignment workflows local-first and responsive.
- Support cloud-assisted reconstruction for high-cost generative and 3D processing.
- Preserve user privacy through data minimization and explicit upload consent.
- Keep platform-specific XR code isolated from product and reconstruction logic.
- Allow scene representations to evolve from simple planes to meshes, point clouds, Gaussian splats, and neural renderable assets.

## 3. High-Level Architecture

```text
Android XR Client
  ├── XR Runtime Adapter
  ├── Tracking and Scene Understanding
  ├── Scan Manager
  ├── Alignment Engine
  ├── Spatial Renderer
  ├── Capture Pipeline
  ├── Local Project Store
  └── Sync and Job Client

Cloud Services
  ├── API Gateway
  ├── Auth and Entitlements
  ├── Project Metadata Service
  ├── Reconstruction Job Service
  ├── Media Processing Service
  ├── Asset Storage
  └── Observability

Offline / Local Mode
  ├── Reference media import
  ├── Manual spatial alignment
  ├── Local project save and restore
  └── Photo/video capture without cloud reconstruction
```

## 4. Client Architecture

### 4.1 Android XR App Shell

Responsibilities:

- Manage app lifecycle in Android XR.
- Route between Library, Scan, Align, Reconstruct, Explore, and Capture modes.
- Handle permissions for camera, spatial tracking, storage, network, and media access.
- Provide safety UI for passthrough visibility, tracking quality, and movement warnings.

Recommended implementation:

- Kotlin for application logic.
- Jetpack Compose for 2D panels and project management UI.
- Android XR compatible rendering stack for immersive spatial content.
- Dependency injection to isolate platform services from domain logic.

### 4.2 XR Runtime Adapter

Responsibilities:

- Wrap Android XR platform APIs.
- Expose normalized interfaces for head pose, controller or hand input, anchors, planes, depth, meshes, and passthrough state.
- Hide device-specific differences from the rest of the app.

Core interface examples:

```text
XrSession
XrPoseProvider
XrAnchorProvider
XrSceneUnderstandingProvider
XrInputProvider
XrPassthroughController
```

Design note:

Android XR APIs and device capabilities may evolve. Platform calls should remain behind this adapter so tracking, rendering, and alignment logic can be tested independently.

### 4.3 Tracking and Scene Understanding

Responsibilities:

- Read device pose and tracking state.
- Detect planes and stable spatial features.
- Consume depth, mesh, or scene understanding outputs when available.
- Estimate scan quality and coverage.
- Notify the UX layer about tracking loss or low-confidence areas.

Outputs:

- `TrackingState`
- `WorldPose`
- `PlaneObservation`
- `FeatureObservation`
- `SceneMesh`
- `ScanQualityMetrics`

### 4.4 Scan Manager

Responsibilities:

- Orchestrate environment scanning sessions.
- Build a local scene representation from available XR observations.
- Track scan coverage, quality, and completeness.
- Persist scan summaries for relocalization and reconstruction.

Scan representation levels:

| Level | Representation | Use |
| --- | --- | --- |
| L0 | Platform anchors and planes | Manual alignment MVP |
| L1 | Sparse visual features and keyframes | Assisted alignment |
| L2 | Mesh or point cloud | Reconstruction and occlusion |
| L3 | Gaussian splats or neural assets | High-fidelity exploration |

### 4.5 Alignment Engine

Responsibilities:

- Maintain transforms from reference media space to world space.
- Support manual translation, rotation, scale, opacity, and depth controls.
- Suggest initial alignment from visual features when available.
- Anchor alignment state to persistent world references.
- Detect drift and relocalization changes.

Core transform chain:

```text
ReferenceMediaSpace
  -> SourceCameraEstimate
  -> SceneAlignmentTransform
  -> WorldAnchorSpace
  -> XrWorldSpace
  -> UserViewSpace
```

MVP behavior:

- User manually places a reference image plane in the environment.
- Alignment is saved relative to a world anchor.
- Renderer displays the aligned reference with adjustable opacity.

Future behavior:

- Feature matching estimates source camera pose.
- Detected real-world geometry constrains placement.
- Generated 3D assets inherit the same world-space alignment.

### 4.6 Spatial Renderer

Responsibilities:

- Render reference planes, guides, generated assets, scan visualizations, and capture previews.
- Support passthrough-safe compositing.
- Render occlusion when depth or mesh data is available.
- Support multiple asset types: image planes, meshes, splats, billboards, particles, and volumetric proxies.

Rendering modes:

- Scan Mode: coverage visualization and tracking feedback.
- Align Mode: reference overlay, handles, guides, opacity controls.
- Explore Mode: minimal UI, reconstructed content, passthrough awareness.
- Capture Mode: stable composition preview and export framing.

### 4.7 Capture Pipeline

Responsibilities:

- Capture photos from the current XR viewpoint.
- Record short videos with stable virtual content.
- Composite passthrough imagery and virtual scene content.
- Save outputs to device media storage.
- Attach optional project metadata and provenance.

Capture types:

- Local alignment photo.
- Reconstructed scene photo.
- Short stabilized video.
- Before/after comparison export.

### 4.8 Local Project Store

Responsibilities:

- Store projects on device by default.
- Persist reference media, scan summaries, anchors, alignment transforms, generated asset manifests, and captures.
- Support project restore without network connectivity.

Suggested storage:

- Room or SQLite for structured metadata.
- App-private file storage for media and scan artifacts.
- Content URI access for imported media where appropriate.

Core tables:

- `projects`
- `reference_media`
- `spatial_scans`
- `world_anchors`
- `alignment_states`
- `generated_assets`
- `captures`
- `reconstruction_jobs`

## 5. Cloud Architecture

Cloud services are optional for basic local alignment but required for high-cost reconstruction workflows.

### 5.1 API Gateway

Responsibilities:

- Terminate client API requests.
- Enforce authentication and rate limits.
- Route traffic to metadata, upload, and reconstruction services.

### 5.2 Project Metadata Service

Responsibilities:

- Store cloud-backed project records.
- Track reconstruction job status.
- Store asset manifests and provenance.
- Support sync across user devices when enabled.

### 5.3 Media Processing Service

Responsibilities:

- Normalize reference images and extracted frames.
- Compute image embeddings and visual features.
- Estimate source camera parameters where possible.
- Prepare inputs for reconstruction jobs.

### 5.4 Reconstruction Job Service

Responsibilities:

- Accept reconstruction requests.
- Validate user consent and input payloads.
- Schedule asynchronous processing.
- Run or delegate 3D reconstruction and generative scene completion.
- Publish progressive results and final assets.

Job stages:

```text
Queued
  -> Input Validation
  -> Feature Extraction
  -> Pose / Alignment Refinement
  -> Geometry Reconstruction
  -> Generative Completion
  -> Asset Packaging
  -> Quality Evaluation
  -> Ready
```

### 5.5 Asset Storage

Responsibilities:

- Store uploaded scan artifacts and media inputs.
- Store generated assets and preview renders.
- Support signed upload and download URLs.
- Apply retention policies and deletion requests.

Asset categories:

- Reference media derivatives.
- Scan summaries.
- Meshes.
- Point clouds.
- Gaussian splat packages.
- Generated textures and material data.
- Preview thumbnails.
- Exported captures when cloud backup is enabled.

## 6. Data Flow

### 6.1 Local Manual Alignment Flow

```text
User imports reference image
  -> Client stores ReferenceMedia locally
  -> User starts XR session
  -> Scan Manager creates world anchor
  -> User places reference plane
  -> Alignment Engine stores transform
  -> Spatial Renderer displays overlay
  -> Capture Pipeline saves photo or video
```

### 6.2 Assisted Alignment Flow

```text
User imports reference image
  -> Media Processing extracts visual features
  -> Scan Manager collects keyframes and scene features
  -> Alignment Engine matches source features to live observations
  -> App suggests initial transform
  -> User refines placement
  -> AlignmentState is saved relative to WorldAnchor
```

### 6.3 Cloud Reconstruction Flow

```text
User requests reconstruction
  -> Client explains upload scope and asks for consent
  -> Client uploads minimal reference media and scan artifacts
  -> Reconstruction Job Service creates job
  -> Media Processing extracts source features
  -> Reconstruction pipeline generates spatial assets
  -> Asset Storage stores packaged results
  -> Client downloads manifest and preview assets
  -> Spatial Renderer displays generated content in world space
```

### 6.4 Relocalization Flow

```text
User opens saved project at location
  -> Client loads SpatialScan and WorldAnchor metadata
  -> XR Runtime attempts relocalization
  -> Tracking layer reports confidence
  -> Alignment Engine restores transforms
  -> Renderer displays content when confidence is sufficient
```

## 7. Data Model

### 7.1 UserProject

```json
{
  "id": "project_123",
  "title": "Anime street corner retake",
  "createdAt": "2026-06-01T00:00:00Z",
  "updatedAt": "2026-06-01T00:00:00Z",
  "locationHint": "optional user-provided place name",
  "privacyMode": "local_only"
}
```

### 7.2 ReferenceMedia

```json
{
  "id": "media_123",
  "projectId": "project_123",
  "type": "image",
  "localUri": "content://...",
  "sourceTitle": "optional title",
  "sourceNotes": "optional attribution or notes",
  "width": 1920,
  "height": 1080
}
```

### 7.3 AlignmentState

```json
{
  "id": "alignment_123",
  "projectId": "project_123",
  "worldAnchorId": "anchor_123",
  "transform": {
    "translation": [0.0, 1.4, -2.0],
    "rotation": [0.0, 0.0, 0.0, 1.0],
    "scale": [1.0, 1.0, 1.0]
  },
  "opacity": 0.37,
  "confidence": 0.82
}
```

### 7.4 GeneratedAsset

```json
{
  "id": "asset_123",
  "projectId": "project_123",
  "jobId": "job_123",
  "assetType": "gaussian_splat",
  "manifestUri": "https://storage.example/assets/asset_123/manifest.json",
  "coordinateSpace": "world_anchor",
  "quality": "preview",
  "provenance": {
    "generated": true,
    "sourceMediaIds": ["media_123"]
  }
}
```

## 8. APIs

Initial client-facing APIs:

```text
POST /v1/uploads/presign
POST /v1/projects
GET  /v1/projects/{projectId}
POST /v1/reconstruction-jobs
GET  /v1/reconstruction-jobs/{jobId}
GET  /v1/reconstruction-jobs/{jobId}/assets
DELETE /v1/projects/{projectId}
```

The client should be able to run without these APIs for local-only Phase 1 workflows.

## 9. Reconstruction Pipeline

### 9.1 Inputs

- Reference image or extracted video frame.
- Optional user crop or mask.
- Camera metadata when available.
- Scan summary, keyframes, sparse features, planes, mesh, or point cloud.
- Manual or assisted alignment transform.

### 9.2 Outputs

- Asset manifest.
- Preview thumbnail.
- Spatial asset package.
- Estimated transform relative to project world anchor.
- Quality metrics and warnings.
- Provenance metadata.

### 9.3 Asset Representation Strategy

Use progressive fidelity:

1. Reference image plane for MVP.
2. Layered billboards for simple parallax.
3. Mesh proxies for buildings, signs, and props.
4. Gaussian splats for realistic captured or generated appearance.
5. Hybrid neural assets for future high-fidelity scene exploration.

## 10. Privacy and Security

Principles:

- Local-first by default.
- Explicit consent before uploading media, scan data, or location-linked metadata.
- Minimize uploaded data for each reconstruction job.
- Encrypt transport with TLS.
- Use signed URLs for upload and download.
- Support project deletion and associated cloud asset deletion.
- Avoid public sharing of location scans without explicit user action.

Sensitive data:

- Camera frames.
- Environmental scans.
- Location hints and anchors.
- Reference media.
- Generated captures.

## 11. Safety

Safety requirements:

- Maintain passthrough visibility during movement.
- Limit maximum opacity for large overlays when the user is walking.
- Show tracking-loss warnings immediately.
- Provide a quick way to hide virtual content.
- Avoid placing interactive UI in ways that block environmental awareness.
- Encourage stationary capture for high-immersion modes.

## 12. Performance Targets

Client:

- XR interactive rendering should remain comfortable for the target Android XR device.
- Alignment controls should feel immediate.
- Scan quality visualization should update in near real time.
- Local project save should complete within a few seconds for normal MVP sessions.

Cloud:

- Reconstruction jobs should be asynchronous.
- Preview results should be available before final high-quality output when possible.
- Large assets should stream progressively.
- Failed jobs should return actionable error states.

## 13. Observability

Client telemetry:

- App mode transitions.
- Scan duration and completion.
- Tracking quality changes.
- Alignment edit operations.
- Capture success or failure.
- Reconstruction request and download status.
- Crash and performance metrics.

Cloud telemetry:

- Upload success rate.
- Job queue time.
- Stage-level reconstruction latency.
- Asset packaging failures.
- Storage usage.
- API errors.

Privacy note:

Telemetry should avoid raw camera frames, raw scans, and precise location data unless the user explicitly opts in for diagnostics.

## 14. Failure Modes

| Failure | User Impact | Handling |
| --- | --- | --- |
| Tracking loss | Virtual content drifts or disappears | Pause alignment, show recovery guidance |
| Poor scan quality | Reconstruction is unstable | Show scan quality feedback and ask for more coverage |
| Cloud upload fails | Reconstruction cannot start | Retry with resumable upload |
| Reconstruction job fails | No generated asset | Provide reason and allow retry with lower quality |
| Relocalization fails | Saved scene cannot restore | Fall back to manual realignment |
| Asset too large | Slow loading | Stream progressive assets and provide low-fidelity preview |

## 15. Testing Strategy

Client tests:

- Unit tests for project data model and transform math.
- Integration tests for local project persistence.
- XR runtime adapter tests with mocked tracking data.
- Manual device tests for scan, alignment, capture, and relocalization.

Pipeline tests:

- Golden input fixtures for reconstruction jobs.
- Asset manifest validation.
- Regression checks for transform consistency.
- Failure injection for upload, queue, processing, and download stages.

UX validation:

- Time-to-first-capture study.
- Manual alignment difficulty study.
- Tracking confidence comprehension study.
- Safety review for immersive viewing modes.

## 16. Current Repository Mapping

The current repository contains an iOS SwiftUI MVP:

```text
Retake/
  CameraModel.swift
  CameraOverlayView.swift
  CameraPreviewView.swift
  ContentView.swift
  RetakeApp.swift
```

This code validates the Phase 0 overlay workflow. Android XR implementation should be added as a separate client directory in the future, for example:

```text
android-xr/
  app/
  core/
  xr/
  renderer/
  reconstruction/
  data/
```

The iOS app can remain as a companion prototype while Android XR becomes the primary product direction.
