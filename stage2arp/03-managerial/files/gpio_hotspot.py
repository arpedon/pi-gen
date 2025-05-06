import os
from gpiozero import Button
from signal import pause

# GPIO 17 is active low
hotspot_button = Button(17, pull_up=True, hold_time=10)  # Hold for 10 seconds to enable
hotspot_enabled = False  # Track the hotspot state


def start_hotspot():
    global hotspot_enabled
    if not hotspot_enabled:
        print("Starting hotspot and web app...")
        os.system("sudo systemctl start hostapd")
        os.system("sudo systemctl start dnsmasq")
        os.system("sudo systemctl start config-webapp")
        hotspot_enabled = True


def stop_hotspot():
    global hotspot_enabled
    if hotspot_enabled:
        print("Stopping hotspot and web app...")
        os.system("sudo systemctl stop hostapd")
        os.system("sudo systemctl stop dnsmasq")
        os.system("sudo systemctl stop config-webapp")
        hotspot_enabled = False


def handle_button_release():
    global hotspot_enabled
    if not hotspot_enabled:
        # Enable hotspot when button is held for 10 seconds and released
        start_hotspot()


def handle_button_press():
    global hotspot_enabled
    if hotspot_enabled:
        # Disable hotspot when button is pressed for 2 seconds
        stop_hotspot()


# Trigger actions
hotspot_button.when_held = (
    handle_button_release  # Enable hotspot on 10-second hold and release
)
hotspot_button.when_pressed = handle_button_press  # Disable hotspot on 2-second press

print("Monitoring GPIO 17 for hotspot control...")
pause()
