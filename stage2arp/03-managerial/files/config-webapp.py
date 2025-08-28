from flask import Flask, render_template, request, jsonify
import subprocess

app = Flask(__name__)

# Paths to the scripts
MAINTNODE_SETUP_SCRIPT = "/usr/local/bin/maintnode-setup"
NETWORK_SETUP_SCRIPT = "/usr/local/bin/network-setup"


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/run-maintnode-setup", methods=["POST"])
def run_maintnode_setup():
    uuid = request.form.get("uuid")
    server = request.form.get("server")

    if not uuid or not server:
        return jsonify({"error": "Both UUID and Server are required."}), 400

    try:
        result = subprocess.run(
            [MAINTNODE_SETUP_SCRIPT, uuid, server],
            capture_output=True,
            text=True,
            check=True,
        )
        return jsonify({"output": result.stdout})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": e.stderr}), 500


@app.route("/run-network-setup", methods=["POST"])
def run_network_setup():
    ip = request.form.get("ip")
    netmask = request.form.get("netmask")
    gateway = request.form.get("gateway")
    dns = request.form.get("dns")

    if not ip or not netmask or not gateway or not dns:
        return (
            jsonify({"error": "All fields (IP, Netmask, Gateway, DNS) are required."}),
            400,
        )

    try:
        result = subprocess.run(
            [NETWORK_SETUP_SCRIPT, ip, netmask, gateway, dns],
            capture_output=True,
            text=True,
            check=True,
        )
        return jsonify({"output": result.stdout})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": e.stderr}), 500


if __name__ == "__main__":
    # Serve on port 80 for captive portal HTTP
    app.run(host="0.0.0.0", port=80)
