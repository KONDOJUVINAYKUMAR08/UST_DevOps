'''8. Local "Web-Hook" Trigger
A small Python web server that stays idle until it receives a specific 
"GET" request from another machine on the local network. Upon receiving it,
 it executes a pre-defined local maintenance script (like clearing logs).

Key Libraries: flask or http.server.'''

from flask import Flask, request

app=Flask(__name__)

@app.route('/trigger')
def trigger(methods=['GET']):
    if request.method == "GET":
        return "Triggered"

if __name__ == "__main__":
    app.run(debug=True)