#!/usr/bin/env python3
import asyncio
import sys
import getopt

# ==============================
# KONFIGURASI
# ==============================
LISTEN_ADDR = "0.0.0.0"
LISTEN_PORT = 8080
PASSWORD = "rimurutempest"  # wajib header X-Pass

BUFLEN = 65536
TIMEOUT = 60
DEFAULT_HOST = "127.0.0.1:109"

RESPONSE = (
    "HTTP/1.1 101 <b><font color="cyan">Script by t.me/xiestorez</font></b>\r\n"
    "Upgrade: websocket\r\n"
    "Connection: Upgrade\r\n"
    "Sec-WebSocket-Accept: proxy\r\n\r\n"
)


# ==============================
# Fungsi Util
# ==============================
def parse_args(argv):
    global LISTEN_ADDR, LISTEN_PORT
    try:
        opts, _ = getopt.getopt(argv, "hb:p:", ["bind=", "port="])
    except getopt.GetoptError:
        print("Usage: proxy.py -b <bindAddr> -p <port>")
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-b", "--bind"):
            LISTEN_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTEN_PORT = int(arg)


def find_header(buffer: str, header_name: str) -> str:
    """Cari header HTTP dalam request"""
    for line in buffer.split("\r\n"):
        if line.lower().startswith(header_name.lower() + ":"):
            return line.split(":", 1)[1].strip()
    return ""


# ==============================
# Proxy Handler
# ==============================
async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
    try:
        data = await reader.read(BUFLEN)
        if not data:
            writer.close()
            await writer.wait_closed()
            return

        request = data.decode("latin1", errors="ignore")

        host_port = find_header(request, "X-Real-Host") or DEFAULT_HOST
        passwd = find_header(request, "X-Pass")

        # Validasi Password
        if PASSWORD and passwd != PASSWORD:
            writer.write(b"HTTP/1.1 403 Forbidden\r\n\r\nWrongPass!")
            await writer.drain()
            writer.close()
            await writer.wait_closed()
            return

        # Pisahkan host dan port
        if ":" in host_port:
            host, port = host_port.split(":")
            port = int(port)
        else:
            host, port = host_port, 80

        # Koneksi ke target
        try:
            target_reader, target_writer = await asyncio.open_connection(host, port)
        except Exception as e:
            writer.write(
                f"HTTP/1.1 502 Bad Gateway\r\n\r\nTarget error: {e}".encode()
            )
            await writer.drain()
            writer.close()
            await writer.wait_closed()
            return

        # Kirim respon sukses ke client
        writer.write(RESPONSE.encode())
        await writer.drain()

        # Relay data (2 arah)
        async def relay(src, dst):
            try:
                while not src.at_eof():
                    buf = await src.read(BUFLEN)
                    if not buf:
                        break
                    dst.write(buf)
                    await dst.drain()
            except Exception:
                pass
            finally:
                dst.close()

        await asyncio.gather(
            relay(reader, target_writer),
            relay(target_reader, writer),
        )

    except Exception as e:
        print(f"[ERROR] {e}")
    finally:
        if not writer.is_closing():
            writer.close()
            await writer.wait_closed()


# ==============================
# Main
# ==============================
async def main():
    print(f"[*] Python Proxy Listening on {LISTEN_ADDR}:{LISTEN_PORT}")
    server = await asyncio.start_server(handle_client, LISTEN_ADDR, LISTEN_PORT)

    async with server:
        await server.serve_forever()


if __name__ == "__main__":
    parse_args(sys.argv[1:])
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[!] Stopped")
