import base64
import json
import requests

import cv2

# ==========================================
# 🔧 HEADCOUNT VERSION (People Counter)
# ==========================================
API_KEY = "AIzaSyDZyTQNS2eO8wg6wQMPKTMKk8ffEhssVIs" 
IMAGE_PATH = "pic2_1.jpeg"  # Remember to change this to your actual image filename!
# ==========================================

def analyze_room():
    print(f"🚀 Loading {IMAGE_PATH}...")
    
    try:
        # 1. Load image
        with open(IMAGE_PATH, "rb") as image_file:
            base64_image = base64.b64encode(image_file.read()).decode()

        # 2. Ask Google for Objects (Key step for counting people)
        url = f"https://vision.googleapis.com/v1/images:annotate?key={API_KEY}"
        payload = {
            "requests": [{
                "image": {"content": base64_image},
                "features": [
                    {"type": "OBJECT_LOCALIZATION"}, # Detect objects (draw boxes around people)
                    {"type": "LABEL_DETECTION"},     # Helper to identify the scene context
                    {"type": "FACE_DETECTION"}       # Use face count for better accuracy
                ]
            }]
        }

        # 3. Send to Google
        print("📡 Sending to Vision AI...")
        response = requests.post(url, json=payload)
        results = response.json()

        # 4. Statistical Logic
        real_person_count = 0  # Specifically counts "Person" objects
        face_count = 0         # Number of faces (often more accurate)
        other_evidence = 0     # Count other active equipment
        
        if "responses" in results:
            response0 = results["responses"][0]

            # Count "Person" objects (Only counts if AI is sure it's a person)
            for obj in response0.get("localizedObjectAnnotations", []):
                if obj['name'] == "Person":
                    real_person_count += 1
                    print(f"   found a person (Confidence: {int(obj['score']*100)}%)")
                else:
                    other_evidence += 1 # Counts computers, desks, etc.

            # Face Count (Usually more stable than full-body detection)
            face_count = len(response0.get("faceAnnotations", []))

        # 5. Output Final Results
        print("\n" + "="*40)
        
        # Priority 1: If faces are detected (Highest accuracy)
        if face_count > 0:
            print(f"👥 REAL PEOPLE COUNT (FACES): {face_count}")
            print(f"✅ STATUS: OCCUPIED")
            print("💡 ACTION: Keep AC/Lights ON")

        # Priority 2: If body shapes are detected
        elif real_person_count > 0:
            print(f"👥 REAL PEOPLE COUNT: {real_person_count}")
            print(f"✅ STATUS: OCCUPIED")
            print("💡 ACTION: Keep AC/Lights ON")
        
        # Priority 3: If no people are counted, but equipment is active 
        # (Prevents false empty if person is blocked)
        elif other_evidence > 0:
            print(f"👥 REAL PEOPLE COUNT: 0 (But active equipment found)")
            print(f"✅ STATUS: OCCUPIED (Equipment Detected)")
            print("💡 ACTION: Keep AC/Lights ON")
            
        # Priority 4: Totally Empty
        else:
            print(f"👥 REAL PEOPLE COUNT: 0")
            print(f"❌ STATUS: EMPTY")
            print("⚠️ ACTION: ALERT! Check for energy waste.")
            
        print("="*40 + "\n")

    except Exception as e:
        print(f"❌ Error: {e}")


def analyze_camera_local(camera_index=0):
    print("🎥 Starting local camera detection (press 'Ctrl + C' to quit)...")

    cap = cv2.VideoCapture(camera_index)
    if not cap.isOpened():
        print("❌ Error: Could not open camera.")
        return

    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    )

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("❌ Error: Failed to read from camera.")
                break

            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
            face_count = len(faces)

            for (x, y, w, h) in faces:
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

            cv2.putText(
                frame,
                f"Faces: {face_count}",
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                1,
                (0, 255, 0),
                2,
            )

            cv2.imshow("Local Headcount", frame)

            if cv2.waitKey(1) & 0xFF == ord("q"):
                break
    finally:
        cap.release()
        cv2.destroyAllWindows()

if __name__ == "__main__":
    analyze_camera_local()

