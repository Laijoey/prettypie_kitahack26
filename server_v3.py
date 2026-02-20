import base64
import threading
import time
import datetime
import requests as req_lib
from flask import Flask, jsonify
from flask_cors import CORS
import cv2

app = Flask(__name__)
CORS(app)

# ==========================================
# CONFIG
# ==========================================
API_KEY = "AIzaSyDZyTQNS2eO8wg6wQMPKTMKk8ffEhssVIs"
CAMERA_INDEX = 0       # webcam index
SCAN_INTERVAL = 5      # seconds between Vision AI scans

# ==========================================
# ONLY B2 = real webcam
# All other rooms = fake stock photo
# ==========================================
LIVE_CAMERA_ROOM = "B2"

FAKE_ROOM_IMAGES = {
    "A1": "https://images.unsplash.com/photo-1517502884422-41eaead166d4?w=640&q=80",  # Conference room with people
    "A2": "https://images.unsplash.com/photo-1497366216548-37526070297c?w=640&q=80",  # Open office busy
    "B1": "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=640&q=80",     # Server room empty
    "C1": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=640&q=80",  # Lab with people
    "C2": "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=640&q=80",  # Empty training room
}

# Cache so we only download each image once
fake_image_cache = {}

# ==========================================
# ROOM STATE — initial values
# ==========================================
room_states = {
    "A1": {"code": "A1", "name": "Conference Room A", "occupancy": 8,  "capacity": 12, "status": "occupied", "lights": True,  "ac": True,  "energy": 18, "confidence": 0.95, "source": "static"},
    "A2": {"code": "A2", "name": "Open Office A",     "occupancy": 24, "capacity": 40, "status": "occupied", "lights": True,  "ac": True,  "energy": 32, "confidence": 0.92, "source": "static"},
    "B1": {"code": "B1", "name": "Server Room",       "occupancy": 0,  "capacity": 4,  "status": "empty",    "lights": False, "ac": True,  "energy": 45, "confidence": 0.99, "source": "static"},
    "B2": {"code": "B2", "name": "Break Room",        "occupancy": 0,  "capacity": 20, "status": "waste",    "lights": True,  "ac": True,  "energy": 12, "confidence": 0.00, "source": "pending"},
    "C1": {"code": "C1", "name": "Lab Space",         "occupancy": 6,  "capacity": 15, "status": "occupied", "lights": True,  "ac": True,  "energy": 28, "confidence": 0.88, "source": "static"},
    "C2": {"code": "C2", "name": "Training Room",     "occupancy": 0,  "capacity": 30, "status": "waste",    "lights": True,  "ac": True,  "energy": 22, "confidence": 0.00, "source": "static"},
}

alerts = []
last_webcam_frame = None   # stores latest webcam frame for snapshot
camera_available = False


# ==========================================
# HELPER: add alert
# ==========================================
def add_alert(alert_type, room_id, room_name, message):
    alerts.insert(0, {
        "type": alert_type,
        "room_id": room_id,
        "room_name": room_name,
        "message": message,
        "time": datetime.datetime.now().strftime("%H:%M"),
    })
    if len(alerts) > 20:
        alerts.pop()


# ==========================================
# HELPER: determine room status
# ==========================================
def determine_status(occupancy, lights_on, ac_on):
    if occupancy > 0:
        return "occupied"
    elif lights_on or ac_on:
        return "waste"
    else:
        return "empty"


# ==========================================
# GOOGLE VISION AI — send frame, get count
# (copied from your original vision AI code)
# ==========================================
def analyze_with_google_vision(frame):
    try:
        _, buffer = cv2.imencode('.jpg', frame)
        base64_image = base64.b64encode(buffer).decode()

        url = f"https://vision.googleapis.com/v1/images:annotate?key={API_KEY}"
        payload = {
            "requests": [{
                "image": {"content": base64_image},
                "features": [
                    {"type": "OBJECT_LOCALIZATION"},  # detects person shapes
                    {"type": "LABEL_DETECTION"},      # scene context
                    {"type": "FACE_DETECTION"},       # face count (more accurate)
                ]
            }]
        }

        response = req_lib.post(url, json=payload, timeout=5)
        results = response.json()

        real_person_count = 0
        face_count = 0
        confidence = 0.0

        if "responses" in results:
            r = results["responses"][0]

            # Count person objects
            for obj in r.get("localizedObjectAnnotations", []):
                if obj["name"] == "Person":
                    real_person_count += 1
                    confidence = max(confidence, obj["score"])
                    print(f"   [Vision AI] Found a person (confidence: {int(obj['score']*100)}%)")

            # Face count (usually more stable)
            face_count = len(r.get("faceAnnotations", []))

        # Priority: faces > body > 0
        final_count = face_count if face_count > 0 else real_person_count
        final_confidence = confidence if confidence > 0 else (0.85 if face_count > 0 else 0.0)

        return {"count": final_count, "confidence": round(final_confidence, 2)}

    except Exception as e:
        print(f"[Vision AI] Error: {e}")
        return {"count": -1, "confidence": 0.0}


# ==========================================
# OFFLINE FALLBACK — Haar cascade (no internet needed)
# ==========================================
face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

def analyze_with_local(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
    count = len(faces)
    return {"count": count, "confidence": 0.75 if count > 0 else 0.90}


# ==========================================
# BACKGROUND THREAD — scans webcam for B2 only
# ==========================================
def camera_scan_loop():
    global last_webcam_frame, camera_available

    print(f"[Scanner] Starting — monitoring room {LIVE_CAMERA_ROOM} with webcam...")
    cap = cv2.VideoCapture(CAMERA_INDEX)

    if not cap.isOpened():
        print("[Scanner] ⚠️  No webcam found — switching to demo mode.")
        demo_mode_loop()
        return

    camera_available = True
    print("[Scanner] ✅ Webcam connected.")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("[Scanner] Failed to read frame, retrying...")
            time.sleep(SCAN_INTERVAL)
            continue

        # Save latest frame for the snapshot endpoint
        last_webcam_frame = frame.copy()

        # Try Google Vision AI first, fall back to local
        result = analyze_with_google_vision(frame)
        if result["count"] == -1:
            print("[Scanner] Falling back to local detection.")
            result = analyze_with_local(frame)

        count = result["count"]
        confidence = result["confidence"]
        print(f"[Scanner] Room {LIVE_CAMERA_ROOM} → {count} people detected (confidence: {confidence})")

        # Update only B2
        old_status = room_states[LIVE_CAMERA_ROOM]["status"]
        new_status = determine_status(
            count,
            room_states[LIVE_CAMERA_ROOM]["lights"],
            room_states[LIVE_CAMERA_ROOM]["ac"],
        )

        room_states[LIVE_CAMERA_ROOM].update({
            "occupancy": count,
            "confidence": confidence,
            "status": new_status,
            "source": "vision_ai",
        })

        # Alert if room just became wasteful
        if old_status != "waste" and new_status == "waste":
            add_alert(
                "WARNING",
                LIVE_CAMERA_ROOM,
                room_states[LIVE_CAMERA_ROOM]["name"],
                "Room is empty but lights/AC are still ON — energy waste detected by Vision AI.",
            )
            print(f"[Alert] ⚠️  Waste alert triggered for {LIVE_CAMERA_ROOM}!")

        time.sleep(SCAN_INTERVAL)

    cap.release()


def demo_mode_loop():
    """Simulates Vision AI output when no webcam is available."""
    import random
    print("[Scanner] Demo mode: simulating B2 people count...")
    while True:
        count = random.choices([0, 0, 0, 1, 2], weights=[50, 20, 10, 10, 10])[0]
        confidence = round(random.uniform(0.75, 0.97), 2)

        old_status = room_states[LIVE_CAMERA_ROOM]["status"]
        new_status = determine_status(count, room_states[LIVE_CAMERA_ROOM]["lights"], room_states[LIVE_CAMERA_ROOM]["ac"])

        room_states[LIVE_CAMERA_ROOM].update({
            "occupancy": count,
            "confidence": confidence,
            "status": new_status,
            "source": "demo_simulated",
        })

        if old_status != "waste" and new_status == "waste":
            add_alert("WARNING", LIVE_CAMERA_ROOM, room_states[LIVE_CAMERA_ROOM]["name"],
                      "Demo: Room empty but AC/Lights ON.")

        time.sleep(SCAN_INTERVAL)


# ==========================================
# FAKE IMAGE FETCH & CACHE
# ==========================================
def get_fake_image(room_id):
    """Return cached base64 image for a fake-camera room."""
    if room_id in fake_image_cache:
        return fake_image_cache[room_id]

    url = FAKE_ROOM_IMAGES.get(room_id)
    if not url:
        return None

    try:
        r = req_lib.get(url, timeout=8)
        if r.status_code == 200:
            b64 = base64.b64encode(r.content).decode()
            fake_image_cache[room_id] = b64
            print(f"[Images] Cached fake image for room {room_id} ✅")
            return b64
    except Exception as e:
        print(f"[Images] Failed for {room_id}: {e}")
    return None


def preload_all_fake_images():
    print("[Images] Pre-loading all fake room images...")
    for room_id in FAKE_ROOM_IMAGES:
        get_fake_image(room_id)
    print("[Images] All done ✅")


# ==========================================
# API ROUTES
# ==========================================

@app.route("/rooms", methods=["GET"])
def get_rooms():
    return jsonify(list(room_states.values()))


@app.route("/rooms/<room_id>", methods=["GET"])
def get_room(room_id):
    room = room_states.get(room_id.upper())
    if room:
        return jsonify(room)
    return jsonify({"error": "Room not found"}), 404


@app.route("/alerts", methods=["GET"])
def get_alerts():
    return jsonify(alerts)


@app.route("/summary", methods=["GET"])
def get_summary():
    waste  = [r for r in room_states.values() if r["status"] == "waste"]
    occupied = [r for r in room_states.values() if r["status"] == "occupied"]
    return jsonify({
        "total_rooms": len(room_states),
        "occupied": len(occupied),
        "waste": len(waste),
        "waste_rooms": [r["code"] for r in waste],
    })


# ==========================================
# SNAPSHOT ENDPOINT
# GET /snapshot/B2  → real webcam frame
# GET /snapshot/A1  → fake stock photo
# ==========================================
@app.route("/snapshot/<room_id>", methods=["GET"])
def get_snapshot(room_id):
    room_id = room_id.upper()
    room = room_states.get(room_id)

    if not room:
        return jsonify({"error": "Room not found"}), 404

    image_b64 = None
    image_source = "unknown"

    if room_id == LIVE_CAMERA_ROOM:
        # --- Real webcam ---
        if last_webcam_frame is not None:
            _, buffer = cv2.imencode('.jpg', last_webcam_frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
            image_b64 = base64.b64encode(buffer).decode()
            image_source = "webcam_live"
        else:
            # Camera not warmed up yet — try a fresh capture
            cap = cv2.VideoCapture(CAMERA_INDEX)
            if cap.isOpened():
                ret, frame = cap.read()
                cap.release()
                if ret:
                    _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
                    image_b64 = base64.b64encode(buffer).decode()
                    image_source = "webcam_live"
            if not image_b64:
                image_source = "unavailable"
    else:
        # --- Fake stock photo ---
        image_b64 = get_fake_image(room_id)
        image_source = "simulated_feed"

    if not image_b64:
        return jsonify({"error": "Image not available. Check camera or internet connection."}), 503

    return jsonify({
        "room_id": room_id,
        "room_name": room["name"],
        "image_base64": image_b64,
        "image_source": image_source,          # "webcam_live" or "simulated_feed"
        "is_live": room_id == LIVE_CAMERA_ROOM,
        "occupancy": room["occupancy"],
        "capacity": room["capacity"],
        "status": room["status"],
        "confidence": room["confidence"],
        "timestamp": datetime.datetime.now().strftime("%H:%M:%S"),
    })


# ==========================================
# START SERVER
# ==========================================
if __name__ == "__main__":
    # Pre-load fake images in background
    threading.Thread(target=preload_all_fake_images, daemon=True).start()

    # Start webcam scanner for B2
    threading.Thread(target=camera_scan_loop, daemon=True).start()

    print("=" * 50)
    print("[Server] ✅ GreenPulse Vision AI Backend")
    print(f"[Server] 📷 Live camera room: {LIVE_CAMERA_ROOM}")
    print("[Server] 🌐 Running at http://localhost:5000")
    print("[Server] Routes: /rooms  /alerts  /summary  /snapshot/<room_id>")
    print("=" * 50)

    app.run(host="0.0.0.0", port=5000, debug=False)
