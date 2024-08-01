from flask import Flask, render_template_string
from kubernetes import client, config
import os
from os.path import join, dirname
from dotenv import load_dotenv

app = Flask(__name__)

# Use in-cluster config when running inside a pod
if os.path.exists("/var/run/secrets/kubernetes.io/serviceaccount"):
    config.load_incluster_config()
else:
    config.load_kube_config()

v1 = client.CoreV1Api()

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Kubernetes Cluster Status</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Kubernetes Cluster Status</h1>
    {% for namespace, resources in data.items() %}
        <h2>Namespace: {{ namespace }}</h2>
        <table>
            <tr>
                <th>Resource</th>
                <th>Requests</th>
                <th>Limits</th>
            </tr>
            {% for resource, values in resources.items() %}
            <tr>
                <td>{{ resource }}</td>
                <td>{{ values['requests'] }}</td>
                <td>{{ values['limits'] }}</td>
            </tr>
            {% endfor %}
        </table>
    {% endfor %}
</body>
</html>
"""


@app.route("/")
def cluster_status():
    dotenv_path = join(dirname(__file__), ".env")
    load_dotenv(dotenv_path)

    namespace = os.environ.get("TARGET_NAMESPACE")
    namespaces_to_check = [namespace]  # Add your namespaces here
    data = {}

    for ns in namespaces_to_check:
        pods = v1.list_namespaced_pod(ns)
        resources = {
            "cpu": {"requests": 0, "limits": 0},
            "memory": {"requests": 0, "limits": 0},
        }

        for pod in pods.items:
            for container in pod.spec.containers:
                if container.resources.requests:
                    cpu_request = container.resources.requests.get("cpu", "0")
                    mem_request = container.resources.requests.get("memory", "0")
                    resources["cpu"]["requests"] += (
                        float(cpu_request[:-1])
                        if cpu_request.endswith("m")
                        else float(cpu_request) * 1000
                    )
                    resources["memory"]["requests"] += (
                        int(mem_request[:-2])
                        if mem_request.endswith("Mi")
                        else int(mem_request[:-2]) * 1024 * 1024
                    )

                if container.resources.limits:
                    cpu_limit = container.resources.limits.get("cpu", "0")
                    mem_limit = container.resources.limits.get("memory", "0")
                    resources["cpu"]["limits"] += (
                        float(cpu_limit[:-1])
                        if cpu_limit.endswith("m")
                        else float(cpu_limit) * 1000
                    )
                    resources["memory"]["limits"] += (
                        int(mem_limit[:-2])
                        if mem_limit.endswith("Mi")
                        else int(mem_limit[:-2]) * 1024 * 1024
                    )

        resources["cpu"]["requests"] = f"{resources['cpu']['requests']}m"
        resources["cpu"]["limits"] = f"{resources['cpu']['limits']}m"
        resources["memory"][
            "requests"
        ] = f"{resources['memory']['requests'] // (1024 * 1024)}Mi"
        resources["memory"][
            "limits"
        ] = f"{resources['memory']['limits'] // (1024 * 1024)}Mi"

        data[ns] = resources

    return render_template_string(HTML_TEMPLATE, data=data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
