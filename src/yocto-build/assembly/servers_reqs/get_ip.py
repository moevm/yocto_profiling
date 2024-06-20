import argparse
import socket

# from http.server import HTTPServer, BaseHTTPRequestHandler


# def get_local_ip():
#     s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#     s.connect(("8.8.8.8", 80))
#     ip = s.getsockname()[0]
#     s.close()
#     return ip

DNS_SERVERS = ["8.8.8.8", "77.88.8.8", "77.88.8.1", "8.8.4.4", "1.1.1.1", "1.0.0.1"]


def get_local_ip():
    for dns_server in DNS_SERVERS:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect((dns_server, 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except socket.error:
            pass

    print("Error: All DNS servers are not available.")
    return None


if __name__ == "__main__":
    ip = get_local_ip()

    print(ip)
