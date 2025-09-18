from flask import Flask, render_template, request, jsonify
import os
import subprocess

app = Flask(__name__)

# Paths to the scripts
MAINTNODE_SETUP_SCRIPT = "/usr/local/bin/maintnode-setup"
NETWORK_SETUP_SCRIPT = "/usr/local/bin/network-setup"


@app.route("/")
def index():
    return render_template("index.html")


def _script_exists(path: str) -> bool:
    return os.path.isfile(path) and os.access(path, os.X_OK)


def _run_script(argv):
    try:
        result = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            check=False,
        )
        payload = {
            "argv": argv,
            "returncode": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
        }
        status = 200 if result.returncode == 0 else 400
        return jsonify(payload), status
    except FileNotFoundError as e:
        return (
            jsonify({
                "argv": argv,
                "error": f"Executable not found: {e}",
            }),
            500,
        )
    except Exception as e:
        return (
            jsonify({
                "argv": argv,
                "error": f"Unexpected error: {e}",
            }),
            500,
        )


@app.route("/run-maintnode-setup", methods=["POST"])
def run_maintnode_setup():
    uuid = request.form.get("uuid", "").strip()
    mechbase_url = request.form.get("server", "").strip()
    tailscale_key = request.form.get("tailscale_key", "").strip()
    readonly = request.form.get("readonly", "true").strip() or "true"

    if not _script_exists(MAINTNODE_SETUP_SCRIPT):
        return jsonify({"error": f"Script not found or not executable: {MAINTNODE_SETUP_SCRIPT}"}), 500

    if not uuid:
        return jsonify({"error": "uuid is required"}), 400

    argv = [
        MAINTNODE_SETUP_SCRIPT,
        f"--maintnode-config-uuid={uuid}",
        f"--readonly-filesystem={readonly}",
    ]
    if tailscale_key:
        argv.append(f"--tailscale-auth-key={tailscale_key}")
    if mechbase_url:
        argv.append(f"--mechbase-url={mechbase_url}")

    return _run_script(argv)


@app.route("/run-network-setup", methods=["POST"])
def run_network_setup():
    ip = (request.form.get("ip", "").strip())
    netmask = (request.form.get("netmask", "").strip())
    gateway = (request.form.get("gateway", "").strip())
    dns = (request.form.get("dns", "").strip())

    if not _script_exists(NETWORK_SETUP_SCRIPT):
        return jsonify({"error": f"Script not found or not executable: {NETWORK_SETUP_SCRIPT}"}), 500

    if not ip or not netmask or not gateway or not dns:
        return jsonify({"error": "All fields (ip, netmask, gateway, dns) are required."}), 400

    argv = [NETWORK_SETUP_SCRIPT, ip, netmask, gateway, dns]
    return _run_script(argv)


if __name__ == "__main__":
    # Serve on port 80 for captive portal HTTP
    app.run(host="0.0.0.0", port=80)
