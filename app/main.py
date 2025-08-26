from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "Welcome to Docker Demo with PyCharm!",
        "project": "docker_demo",
        "status": "running in container",
        "python_version": os.sys.version
    })

@app.route('/api/demo')
def demo():
    return jsonify({
        "demo": "PyCharm + Docker integration",
        "container": "python:3.11-slim",
        "framework": "Flask",
        "ide": "PyCharm"
    })

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "project": "docker_demo"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)