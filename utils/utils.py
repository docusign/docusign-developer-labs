import logging

from flask import Flask, render_template_string, request
from multiprocessing import Process
from urllib.parse import unquote

HOST = 'localhost'
PORT = 8080

SUCCESS_PAGE_SOURCE = """
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<script>
        fetch('http://{{host}}:{{port}}/shutdown')
        setTimeout(function () { window.close();}, 5000);
    </script>
</head>

<body>
Ok. You may close this tab and return to the shell. This window closes automatically in five seconds.

</body>
</html>
"""

ERROR_PAGE_SOURCE = """
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title></title>
</head>

<body>
Bad request.

</body>
</html>
"""

EMBED_PAGE_SOURCE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset=\"utf-8\" />
    <title>Embedded Workflow</title>
    <script>
        setTimeout(function () { fetch('http://{{host}}:{{port}}/shutdown');}, 10000);
    </script>
    <style>
        html,
        body {
            padding: 0;
            margin: 0;
            font: 13px Helvetica, Arial, sans-serif;
        }
    </style>
</head>
<body>
    <div>
        <br />
        <h2>The document has been embedded using Maestro Embedded Workflow</h2>
        <br />
        <iframe src=\"{{instance_url}}\" width=800 height=600>
        </iframe>
    </div>
</body>
</html>
"""

app = Flask(__name__)
app.env = "development"
logging.getLogger('werkzeug').disabled = True

def run_app():
    app.run(host=HOST, port=PORT, debug=False, use_reloader=False)


server = Process(target=run_app)
def run_server():
    server.run()


def shutdown_server():
    if server.is_alive():
        server.terminate()
        server.join()


@app.route('/shutdown')
def shutdown():
    shutdown_server()
    return 'Server shutting down...'


@app.route('/embed', methods=["GET"])
def embed_instance():
    instance_url = request.args.get("instance_url")
    if instance_url:
        return render_template_string(EMBED_PAGE_SOURCE, host=HOST, port=PORT, instance_url=unquote(instance_url))
