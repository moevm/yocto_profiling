import argparse
import socket
# from http.server import HTTPServer, BaseHTTPRequestHandler


def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return ip

if __name__ == "__main__":
    # parser = argparse.ArgumentParser(description="Start HTTP server")
    # parser.add_argument("--port", type=int, default=8000,
    #                     help="Port for listening (default 8000)")
    # args = parser.parse_args()

    ip = get_local_ip()

    print(ip)
   