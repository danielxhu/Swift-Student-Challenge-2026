# ⏳ Linger: Hold onto time, gently.

> A privacy-first cognitive-training app designed to support seniors experiencing cognitive decline. 
> Developed for the **Apple Swift Student Challenge 2026**.

## 📖 Overview
**Linger** is an accessible, offline-first iOS application engineered to assist seniors with memory retention and cognitive training. By translating dense medical research into an intuitive digital experience, Linger is designed around techniques used in dementia care, such as errorless learning, while providing caregivers with actionable insights, all without compromising user privacy.

## ✨ Core Features
* **🧠 Comprehensive Training Hub:** Features 6 specialized cognitive modules, including *Family Faces*, *Spatial Memory*, *Visual Focus*, and *Math Fitness*.
* **🛡️ Errorless Learning Mechanism:** Integrates a research-informed 10-second delayed visual hint system (glowing animations) to guide users to correct answers, fundamentally preventing user frustration and anxiety.
* **📊 Caregiver Dashboard:** A built-in 5-session progress summary that visualizes recent performance data to help caregivers adjust therapeutic settings.
* **🔒 100% Offline & Privacy-First:** Medical data and family photos are highly sensitive. Linger guarantees strict privacy by operating entirely offline with zero cloud dependency.
* **🔊 Auditory Accessibility:** Features soothing background audio and spoken VoiceOver instructions for visually impaired users.

## 🛠️ Technical Architecture
To build a robust and accessible experience, I utilized several native Apple frameworks:
* **SwiftUI:** Constructed the reactive, high-contrast user interface and seamless state transitions across brain-training modules.
* **Core Data:** Persistently stores custom "Family Faces" profiles (names, relationships, photo data) locally on the device.
* **AVFoundation:** Powers the calming background music (`AVAudioPlayer`) and speaks instructions aloud (`AVSpeechSynthesizer`).
* **PhotosUI:** Implemented `PhotosPicker` for secure, native import of real family photos.
* **AppStorage:** Handles lightweight persistent tracking, such as securely locking the Caregiver settings.

## 🤖 AI Collaboration 
During development, I utilized **Gemini** as a collaborative brainstorming partner:
1.  **Literature Synthesis:** Summarized extensive medical literature on Alzheimer’s disease to inspire the app's core concepts (e.g., Errorless Learning and Daily Olfactory tasks).
2.  **Architecture Design:** Assisted in troubleshooting complex SwiftUI state management and structuring the metrics data engine.

## 🚀 How to Run
1. Clone this repository or download the `Linger.swiftpm` file.
2. Open the file using **Swift Playgrounds** (on Mac/iPad) or **Xcode**.
3. Run the project in full-screen mode to experience the complete audio and visual journey.

---
*Designed & Developed by Daniel Hu*
