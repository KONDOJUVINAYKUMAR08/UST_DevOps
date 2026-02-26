'''2. Local Port & Process "Traffic Cop"
A tool that maps every open network port on the machine to its 
specific Process ID (PID) and the user running it. It generates 
a summary of "Suspicious Ports" (e.g., anything open that isn't 
on a pre-approved whitelist).

Key Libraries: psutil, socket.'''

import psutil

whitelist = [5432, 3242, 2345]

for conn in psutil.net_connections():
    if conn.laddr:
        port=conn.laddr.port
        pid=conn.pid

        if pid:
            process = psutil.Process(pid)

            if port not in whitelist:
                print("Suspicious Port", port)