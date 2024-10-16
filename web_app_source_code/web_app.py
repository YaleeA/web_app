import socket
from flask import Flask, render_template, request
import logging

application = Flask(__name__)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
file_handler = logging.FileHandler('app.log')
formatter = logging.Formatter('%(levelname)s - %(asctime)s - %(message)s')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


@application.after_request
def log_request_info(response):
    log_data = {
        'client_ip': request.remote_addr,
        'request_method': request.method,
        'request_path': request.path,
        'request_status_code': response.status_code,
        'web_server': socket.gethostname()
    }
    logger.info(f"Request details: {log_data}")
    return response


@application.route('/', methods=['GET'])
def home():
    hostname = socket.gethostname()
    return render_template('home_page.html', hostname=hostname)


@application.route('/health', methods=['GET'])
def health_check_endpoint():
    hostname = socket.gethostname()
    return render_template('health_page.html', hostname=hostname)


if __name__ == '__main__':
    # Explicitly set host and port to match the Dockerfile's EXPOSE directive
    application.run(host='0.0.0.0', port=5000)
