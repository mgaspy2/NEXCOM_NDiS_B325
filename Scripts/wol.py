import socket
import time
from datetime import datetime

# Configuration
REPEAT_COUNT = 3                        # How many times to send each packet
TRANSMISSION_DELAY = 1.5                # Delay between transmissions (seconds)
BROADCAST_ADDRESS = "255.255.255.255"   # Network broadcast address
WOL_PORT = 9                            # Standard Wake-on-LAN port

# MAC addresses to wake up
MAC_ADDRESSES = [
    "54:b2:03:13:5a:b0",  # pellico
]


def wake_on_lan(mac_address, repeat_count=1, delay=0):
    # Clean and validate MAC address
    mac_clean = mac_address.replace(":", "").replace("-", "")
    if len(mac_clean) != 12:
        raise ValueError("Invalid MAC address format")

    # Build magic packet: 6 bytes of FF + MAC address repeated 16 times
    data = bytes.fromhex("FF" * 6 + mac_clean * 16)

    # Send packet via UDP broadcast
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        for i in range(repeat_count):
            current_time = datetime.now().strftime("%H:%M:%S.%f")[:-3]
            sock.sendto(data, (BROADCAST_ADDRESS, WOL_PORT))
            print(f"[{current_time}] → {BROADCAST_ADDRESS}:{WOL_PORT} | MAC: {mac_address} | Packet {i+1}/{repeat_count}")
            if i < repeat_count - 1:
                time.sleep(delay)
            else:
                print()

if __name__ == "__main__":
    for mac in MAC_ADDRESSES:
        print("Wake on LAN:")
        wake_on_lan(mac, repeat_count=REPEAT_COUNT, delay=TRANSMISSION_DELAY)
