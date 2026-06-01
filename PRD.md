# Retake Android XR Product Requirements Document

## 1. Summary

Retake is an Android XR spatial experience for recreating and exploring real-world locations from anime, movies, TV shows, and historical media.

The product begins with a proven 2D scene-matching workflow: users select a reference image, align it with the real-world location, and capture a recreated photo. The Android XR product expands this into spatial computing. Users wearing XR glasses can scan the surrounding environment, generate a 3D map of the real location, align it with source media, reconstruct missing scene elements with generative AI, and explore the location as an immersive 3D scene rather than a single camera angle.

## 2. Problem

Fans and travelers often visit real-world locations that appeared in anime, films, TV shows, music videos, or historical photos. Today, most recreation workflows are limited to manually comparing a screenshot with a live camera view.

This creates several limitations:

- Users can only recreate the original camera angle.
- The experience is mostly static and photo-based.
- It is difficult to understand how the fictional or historical scene exists in full 3D space.
- Missing elements from the original content, such as characters, props, signs, buildings, or period-specific details, cannot be visualized naturally.
- The user cannot walk around the reconstructed scene or capture new viewpoints.

## 3. Vision

Retake should turn media locations into explorable spatial memories.

Instead of asking users to match a single frame, Retake should let users scan the real location, reconstruct the surrounding space, align the space with source media, and view generative 3D scene elements anchored in the real world. A user visiting an anime pilgrimage location should be able to see the original animated scene reconstructed around them, walk through it, and capture photos or videos from angles that were never shown in the original work.

## 4. Goals

- Build an Android XR-first experience for immersive location recreation.
- Support real-world scene scanning and spatial understanding.
- Align source media with scanned real-world geometry.
- Reconstruct missing scene details using generative AI and 3D reconstruction techniques.
- Let users freely explore reconstructed scenes from new viewpoints.
- Provide high-quality capture and sharing workflows for photos and videos.
- Preserve the existing iOS 2D overlay workflow as a lightweight validation path and companion concept.

## 5. Non-Goals

- Full production-grade film VFX editing in the initial release.
- Fully automated reconstruction for every possible media source without user guidance.
- Real-time high-fidelity 3D generation for large city-scale environments in the MVP.
- Copyright bypassing, source media redistribution, or unauthorized asset extraction.
- Social network features beyond basic export and sharing in the first Android XR release.

## 6. Target Users

### Primary Users

- Anime pilgrimage fans visiting real-world locations.
- Film and TV tourism users recreating iconic scenes.
- Travel photographers who want scene-aligned creative captures.

### Secondary Users

- Historical photo recreation enthusiasts.
- Tourism boards and cultural location guides.
- Location scouts, creators, and spatial storytellers.
- Museums and educational experience designers.

## 7. Core Use Cases

### 7.1 Anime Pilgrimage Scene Reconstruction

A user visits a real-world location featured in an anime. They put on Android XR glasses, select a reference scene, scan the environment, and see reconstructed virtual scene elements aligned with the physical location. They walk around, inspect the scene, and capture a unique photo from a new angle.

### 7.2 Film and TV Location Exploration

A user visits a filming location and selects a still from the movie or show. Retake aligns the still with the scanned environment and overlays reconstructed set dressing, props, or atmosphere in spatial context.

### 7.3 Historical Photo Retake

A user stands at the location of an old photograph. Retake aligns the archival image with the present-day environment and reconstructs historical elements, allowing the user to compare past and present spatially.

### 7.4 Creator Capture Workflow

A creator scans a location, loads a reference scene, adjusts alignment, chooses virtual reconstruction intensity, and exports short spatial videos or photos for social sharing.

## 8. Product Scope

### 8.1 Phase 0: Existing iOS 2D Validation

Status: implemented as the current MVP.

Requirements:

- Select a reference image from the photo library.
- Display live camera preview.
- Overlay the reference image with adjustable opacity.
- Capture a clean photo without the overlay.
- Save the captured photo to the photo library.

Purpose:

- Validate the basic retake behavior.
- Prove that users understand and value reference-based scene alignment.
- Provide a simple mobile companion workflow.

### 8.2 Phase 1: Android XR Spatial Retake MVP

Requirements:

- Launch Android XR app in immersive mode.
- Select or import a reference media frame.
- Scan the local environment using available XR tracking and scene understanding APIs.
- Display a spatial reference plane or ghost overlay aligned to the user view.
- Support manual alignment controls for translation, rotation, scale, and opacity.
- Anchor the aligned scene to the real-world location.
- Capture spatially aligned photos or short videos.
- Save scan metadata and alignment sessions locally.

Success Criteria:

- User can scan a small location area within 1-3 minutes.
- User can align a reference scene with acceptable visual accuracy.
- Anchored reference remains stable while the user moves around.
- Captured output clearly communicates the original scene and real location alignment.

### 8.3 Phase 2: Scene Understanding and Assisted Alignment

Requirements:

- Detect planes, corners, dominant lines, facades, windows, signs, and other visual landmarks.
- Extract feature matches between source media and live camera frames.
- Estimate initial camera pose from the reference image and scanned environment.
- Suggest automatic or semi-automatic alignment.
- Allow users to accept, refine, or reject alignment suggestions.
- Persist a reusable location anchor for future visits.

Success Criteria:

- Reduce manual alignment time by at least 50% compared with Phase 1.
- Maintain stable anchors across short relocalization interruptions.
- Provide understandable alignment confidence feedback.

### 8.4 Phase 3: Generative 3D Scene Reconstruction

Requirements:

- Generate or reconstruct missing scene elements from source media.
- Represent reconstructed content as spatial assets, such as planes, meshes, Gaussian splats, billboards, or neural renderable assets.
- Support user-controlled reconstruction intensity: subtle, balanced, immersive.
- Allow hiding, showing, and repositioning generated elements.
- Clearly distinguish generated content from physical reality in editing modes.
- Export rendered photos and videos from arbitrary user viewpoints.

Success Criteria:

- Reconstructed elements are spatially coherent with the scanned environment.
- Users can capture outputs from viewpoints not present in the original source frame.
- Generated assets do not block essential safety visibility during movement.

### 8.5 Phase 4: Location Library and Shared Experiences

Requirements:

- Save completed location scenes as reusable projects.
- Build a personal library of scanned locations and reference media.
- Support curated location packs for popular pilgrimage and filming sites.
- Allow sharing of lightweight scene alignment metadata where legally appropriate.
- Support privacy controls for scan data and location metadata.

Success Criteria:

- Users can revisit and reopen past scenes.
- Location packs reduce setup time for known locations.
- Shared data excludes private imagery unless explicitly included by the user.

## 9. Functional Requirements

### 9.1 Reference Media

- Import image frames from local storage.
- Support common image formats such as JPEG, PNG, WebP, and HEIF where platform support allows.
- Store reference media metadata, including title, source, notes, and optional location hint.
- Allow cropping and basic framing before alignment.

### 9.2 Environment Scanning

- Start, pause, resume, and finish scans.
- Visualize scan coverage and tracking quality.
- Detect surfaces and spatial features relevant to scene alignment.
- Store lightweight scan representations for later relocalization.
- Warn users when lighting, motion, or feature quality is insufficient.

### 9.3 Alignment

- Provide manual controls for position, rotation, scale, opacity, and depth.
- Support snap-to-plane and snap-to-feature behaviors when confidence is high.
- Show alignment confidence and drift warnings.
- Save alignment transforms relative to a world anchor.
- Support reset and version history for alignment edits.

### 9.4 Reconstruction

- Submit selected reference media, scan data summaries, and alignment data to reconstruction pipelines.
- Support asynchronous reconstruction jobs.
- Notify users when generated assets are ready.
- Allow local preview of low-fidelity reconstruction before high-quality rendering.
- Store generated assets with provenance metadata.

### 9.5 Capture and Export

- Capture photos from the current XR viewpoint.
- Capture short video clips with stable virtual content.
- Export with optional watermark or metadata.
- Save captures to the device gallery.
- Support common sharing targets through Android share sheets.

### 9.6 Project Management

- Create, rename, duplicate, and delete projects.
- Associate each project with reference media, scan data, alignment data, generated assets, and captures.
- Support local-first operation for basic alignment.
- Sync optional cloud-backed reconstruction results when enabled.

## 10. Non-Functional Requirements

### Performance

- Maintain comfortable XR frame rates for all interactive modes.
- Keep tracking and alignment UI responsive under normal thermal conditions.
- Stream high-cost reconstruction results progressively instead of blocking the session.

### Reliability

- Preserve projects during app interruptions.
- Recover from tracking loss with clear user guidance.
- Store reconstruction jobs durably so network interruptions do not lose progress.

### Privacy

- Treat camera frames, scans, location metadata, and reference media as sensitive user data.
- Keep basic projects local by default.
- Upload only the minimum data required for cloud reconstruction.
- Provide clear user consent before cloud processing.

### Safety

- Avoid fully opaque overlays during movement.
- Preserve passthrough visibility and environmental awareness.
- Warn users before using immersive content in crowded or unsafe locations.

### Legal and Content

- Encourage users to provide media they have rights to use.
- Store source attribution where provided.
- Avoid shipping copyrighted media assets without permission.
- Mark generated content and retain provenance metadata.

## 11. UX Requirements

### Main Modes

- Library: manage projects and reference media.
- Scan: capture spatial information about the location.
- Align: place the reference scene into the real-world environment.
- Reconstruct: request, preview, and adjust generated scene elements.
- Explore: walk around the aligned scene.
- Capture: take photos and videos.

### Interaction Principles

- Minimize text while the user is wearing XR glasses.
- Prefer spatial handles, direct manipulation, gaze, controller, and hand gestures.
- Always provide an easy reset action.
- Separate safe navigation mode from high-immersion viewing mode.
- Make tracking quality and reconstruction progress visible but unobtrusive.

## 12. Data Model

Core entities:

- `UserProject`: top-level project container.
- `ReferenceMedia`: imported source image or frame metadata.
- `SpatialScan`: captured environment representation and quality metrics.
- `WorldAnchor`: persistent coordinate reference for relocalization.
- `AlignmentState`: transforms mapping source media and generated content into world space.
- `GeneratedAsset`: reconstructed spatial content with provenance and quality metadata.
- `Capture`: exported photo or video output.

## 13. Metrics

Product metrics:

- Time from launch to first aligned capture.
- Scan completion rate.
- Alignment completion rate.
- Average manual alignment time.
- Reconstruction job completion rate.
- Capture export rate.
- Project revisit rate.

Quality metrics:

- Anchor drift over time.
- Relocalization success rate.
- Tracking loss frequency.
- Reconstruction job latency.
- User-rated reconstruction quality.
- Crash-free sessions.

## 14. Risks and Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| XR hardware APIs change | High | Keep platform integration behind abstraction layers |
| Alignment is too hard manually | High | Build assisted alignment and clear visual guidance |
| Reconstruction quality is inconsistent | High | Start with constrained scene elements and user-controlled intensity |
| Cloud processing is expensive | Medium | Use local previews, compression, job queues, and tiered quality |
| Copyright concerns | High | Require user-provided media, store provenance, avoid bundled copyrighted assets |
| User safety in immersive mode | High | Preserve passthrough visibility and limit opacity while moving |
| Privacy concerns around scans | High | Local-first storage, explicit upload consent, data minimization |

## 15. Open Questions

- Which Android XR device capabilities should be considered baseline for MVP?
- What scene representation should Phase 1 persist: sparse map, mesh, point cloud, or platform anchor metadata?
- How much reconstruction should run locally versus in the cloud?
- What media import and attribution workflow is required for public sharing?
- Should the first Android XR MVP support curated locations or only user-created projects?
- What quality threshold is acceptable for generated assets in an outdoor location?

## 16. Release Plan

### Milestone A: Android XR Prototype

- Basic XR app shell.
- Reference image import.
- Passthrough view with spatial reference overlay.
- Manual transform controls.
- Photo capture.

### Milestone B: Scan and Anchor MVP

- Environment scan flow.
- Persistent anchors.
- Project save and restore.
- Tracking quality UI.

### Milestone C: Assisted Alignment

- Feature detection.
- Initial pose suggestion.
- Alignment confidence.
- Drift and relocalization handling.

### Milestone D: Reconstruction Preview

- Async reconstruction job flow.
- Low-fidelity generated asset preview.
- User controls for generated content visibility and intensity.

### Milestone E: Immersive Retake Beta

- Explore mode.
- Video capture.
- Project library.
- Privacy and consent controls.
- Curated beta test locations.
