from flask import Flask, Response
from prometheus_client import Counter, generate_latest, REGISTRY
import os
import socket

app = Flask(__name__)

visitas = Counter("visitas_total", "Total de visitas na aplicação")


@app.route("/")
def hello():
    visitas.inc()
    hostname = socket.gethostname()
    env = os.getenv("ENV", "dev")
    return f"Olá do Pod {hostname} | Ambiente: {env} | Visita número: {int(visitas._value.get())}"


@app.route("/metrics")
def metrics():
    return Response(generate_latest(REGISTRY), mimetype="text/plain")


@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
