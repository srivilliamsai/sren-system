from flask import Flask, request, jsonify

app = Flask(__name__)

def _build_response():
    # Temporary dummy response; replace with real TensorFlow model call later
    return jsonify({"emotion": "happy", "confidence": 0.92})

@app.route("/predict", methods=["POST"])
def predict():
    _ = request.get_json(silent=True) or {}
    return _build_response()

@app.route("/analyze", methods=["POST"])
def analyze():
    payload = request.get_json(silent=True) or {}
    if not payload.get("imageUrl") and not payload.get("imageData"):
        return jsonify({"error": "imageUrl or imageData is required"}), 400
    return _build_response()

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
