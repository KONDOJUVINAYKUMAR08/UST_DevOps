from flask import Flask, render_template, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/services")
def services():
    return render_template("services.html")

@app.route("/contact")
def contact():
    return render_template("contact.html")

@app.route("/api/info")
def api_info():
    return jsonify({
        "owner": "Vinay Kumar",
        "role": "DevOps Engineer",
        "services": [
            "Cloud Migration",
            "CI/CD Automation",
            "Docker Deployment"
        ],
        "status": "Running Successfully 🚀"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)



"""
Install depencies in Instance.

    sudo apt update && sudo apt upgrade -y
    sudo apt install python3 python3-pip python3-venv nginx -y
    python3 -m venv venv
    source venv/bin/activate
    pip install flask gunicorn

move this folder to ubuntu or linux instance using:
scp -i "example.pem" "path of zip" ubuntu@public_ip:/home/ubuntu


for reverse proxy:
    go to /etc from home
    cd nginx
    cd sites-enabled
    sudo vi default
        delete everything there using :%d and insert:
            server {
                listen 80;
                server_name _;
                location / {
                    proxy_pass http://127.0.0.1:5000;
                }
            }
    save and goto root directory ~ and goto flask-app
    **** Restart nginx server
        sudo systemctl restart nginx
    run app
    python app.py
"""