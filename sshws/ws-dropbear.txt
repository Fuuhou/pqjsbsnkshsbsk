#!/usr/bin/env python
import socket
import threading
import sys

# Konfigurasi Server
LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = int(sys.argv[1])
PASS = ''

# Konstanta
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:109'
RESPONSE = (
    'HTTP/1.1 101 <b><font color="cyan">Script by t.me/superxiez</font></b>\r\n'
    'Upgrade: websocket\r\n'
    'Connection: Upgrade\r\n'
    'Sec-WebSocket-Accept: foo\r\n\r\n'
)


class Server(threading.Thread):
    def __init__(self, host, port):
        super().__init__()
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threads_lock = threading.Lock()
        self.log_lock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, self.port))
        self.soc.listen(0)
        self.running = True

        try:
            while self.running:
                try:
                    client_socket, addr = self.soc.accept()
                    client_socket.setblocking(1)
                except socket.timeout:
                    continue

                conn = ConnectionHandler(client_socket, self, addr)
                conn.start()
                self.add_conn(conn)
        finally:
            self.running = False
            self.soc.close()

    def print_log(self, message):
        with self.log_lock:
            print(message)

    def add_conn(self, conn):
        with self.threads_lock:
            if self.running:
                self.threads.append(conn)

    def remove_conn(self, conn):
        with self.threads_lock:
            if conn in self.threads:
                self.threads.remove(conn)

    def close(self):
        self.running = False
        with self.threads_lock:
            for conn in list(self.threads):
                conn.close()


class ConnectionHandler(threading.Thread):
    def __init__(self, client_socket, server, addr):
        super().__init__()
        self.client_closed = False
        self.target_closed = True
        self.client = client_socket
        self.client_buffer = ''
        self.server = server
        self.log = f'Connection: {addr}'

    def close(self):
        if not self.client_closed:
            try:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
            except:
                pass
            self.client_closed = True

        if not self.target_closed:
            try:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
            except:
                pass
            self.target_closed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
            host_port = self.find_header(self.client_buffer, 'X-Real-Host') or DEFAULT_HOST

            if self.find_header(self.client_buffer, 'X-Split'):
                self.client.recv(BUFLEN)

            if host_port:
                passwd = self.find_header(self.client_buffer, 'X-Pass')
                if PASS and passwd == PASS:
                    self.method_CONNECT(host_port)
                elif PASS and passwd != PASS:
                    self.client.send(b'HTTP/1.1 400 WrongPass!\r\n\r\n')
                elif host_port.startswith(('127.0.0.1', 'localhost')):
                    self.method_CONNECT(host_port)
                else:
                    self.client.send(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                self.server.printLog('- No X-Real-Host!')
                self.client.send(b'HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += f' - error: {getattr(e, "strerror", str(e))}'
            self.server.printLog(self.log)
        finally:
            self.close()
            self.server.removeConn(self)

    def find_header(self, buffer, header_name):
        index = buffer.find(header_name + ': ')
        if index == -1:
            return ''
        index = buffer.find(':', index)
        value_start = index + 2
        value_end = buffer.find('\r\n', value_start)
        return buffer[value_start:value_end] if value_end != -1 else ''

    def connect_target(self, host):
        if ':' in host:
            host, port = host.split(':')
            port = int(port)
        else:
            port = 443 if getattr(self, 'method', '') == 'CONNECT' else int(sys.argv[1])

        info = socket.getaddrinfo(host, port)[0]
        self.target = socket.socket(info[0], info[1], info[2])
        self.target_closed = False
        self.target.connect(info[4])

    def method_CONNECT(self, path):
        self.log += f' - CONNECT {path}'
        self.connect_target(path)
        self.client.sendall(RESPONSE.encode())
        self.client_buffer = ''
        self.server.printLog(self.log)
        self.do_connect()

    def do_connect(self):
        sockets = [self.client, self.target]
        count = 0
        while True:
            count += 1
            ready, _, error = select.select(sockets, [], sockets, 3)
            if error or count == TIMEOUT:
                break
            for sock in ready:
                try:
                    data = sock.recv(BUFLEN)
                    if not data:
                        break
                    if sock is self.target:
                        self.client.send(data)
                    else:
                        while data:
                            sent = self.target.send(data)
                            data = data[sent:]
                    count = 0
                except:
                    break


def print_usage():
    print('Usage: proxy.py -p <port>')
    print('       proxy.py -b <bindAddr> -p <port>')
    print('       proxy.py -b 0.0.0.0 -p 80')

def parse_args(argv):
    global LISTENING_ADDR
    global LISTENING_PORT

    try:
        opts, _ = getopt.getopt(argv, "hb:p:", ["bind=", "port="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ('-b', '--bind'):
            LISTENING_ADDR = arg
        elif opt in ('-p', '--port'):
            LISTENING_PORT = int(arg)

def main():
    print('\n:------- PythonProxy -------:\n')
    print(f'Listening addr: {LISTENING_ADDR}')
    print(f'Listening port: {LISTENING_PORT}\n')
    print(':---------------------------:\n')

    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()

    try:
        while True:
            time.sleep(2)
    except KeyboardInterrupt:
        print('Stopping...')
        server.close()

if __name__ == '__main__':
    parse_args(sys.argv[1:])
    main()
