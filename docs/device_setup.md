# Local SSH Setup and Discovery (General Linux)

| Term | Plain-English Definition |
|------|---------------------------|
| **SSH** | Secure Shell — lets you log into one computer’s terminal from another. |
| **SSHD** | The SSH “server” process that listens for incoming SSH connections. |
| **IP Address** | The number your router gives each device so they can talk on the network. |
| **Router IP** | The address used to reach your home router (gateway). |
| **nmap** | A network scanner that finds devices and their IPs. |

---

## Goal

Be able to plug in a Linux machine anywhere on the local network and connect to it over SSH from another computer, even if it has no screen.

---

## 1. Initial Setup (Run Once on the Target Linux Machine)

Install and enable the SSH server:

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

Confirm it’s running:

```bash
systemctl status ssh --no-pager
```

### (Optional) Make the Machine Headless

Disable the graphical desktop so it boots straight to text mode:

```bash
sudo systemctl set-default multi-user.target
```

To restore the GUI later:

```bash
sudo systemctl set-default graphical.target
```

### (Optional) Ensure Networking Connects Automatically

Check and enable autoconnect:

```bash
sudo nmcli connection show
sudo nmcli connection modify "your connection name" connection.autoconnect yes
```

---

## 2. Find the Device’s IP Address After Boot

If you’re at the device and have a keyboard:

```bash
hostname -I
```

If it’s headless and you can’t see the screen:

### Step 1 — Find Your Router’s Address

On your laptop:

```bash
ip route | grep default
```

Example output:

```
default via 192.168.1.1 dev wlan0
```

Router IP = `192.168.1.1`

### Step 2 — Scan the Network for Devices

```bash
sudo apt install -y nmap   # if not already installed
sudo nmap -sn 192.168.1.1/24
```

Look for a line showing your machine’s MAC or vendor (Lenovo, etc.).

Example result:

```
Nmap scan report for 192.168.1.47
MAC Address: 1C:1B:0D:3A:2B:7C (Lenovo)
```

Now you know the headless device’s IP = `192.168.1.47`.

---

## 3. Connect from Your Laptop

```bash
ssh username@192.168.1.47
```

Type “yes” at the fingerprint prompt, then enter your password.

When connected, you’ll see:

```
username@mint:~$
```

Exit when finished:

```bash
exit
```

---

## 4. Optional Improvements

### a. Key-Based Login

On your laptop:

```bash
ssh-keygen -t ed25519 -C "lan-login"
ssh-copy-id username@192.168.1.47
```

Now SSH in without typing a password:

```bash
ssh username@192.168.1.47
```

### b. Static IP Reservation

In your router’s web UI, open **DHCP / Address Reservation**, find the device by MAC address, and assign its IP permanently (e.g. `192.168.1.47`).

### c. Power Recovery

In BIOS, set **Power On after AC loss = Enabled** so it boots automatically when plugged in.

---

## 5. Quick Command Recap

| Purpose | Command |
|----------|----------|
| Install SSH server | `sudo apt install -y openssh-server` |
| Enable SSH on boot | `sudo systemctl enable --now ssh` |
| Disable GUI (optional) | `sudo systemctl set-default multi-user.target` |
| Find router IP | `ip route | grep default` |
| Scan network for devices | `sudo nmap -sn 192.168.1.0/24` |
| Connect via SSH | `ssh user@device_ip` |
| Exit session | `exit` |

---

### Step 8 — Verify User Permissions (Audio Group)

If you can see the microphone in `/proc/asound/cards` but `arecord -l` still “no soundcards found,” check your user permissions:

```bash
groups
```

If the word **audio** is missing, add yourself to the audio group:

```bash
sudo usermod -aG audio $USER
```

Then **log out and back in** (or reboot) for the change to take effect.

After that, re-run:

```bash
arecord -l
```

The microphone should now appear.

## Expected Result

When the Linux machine is plugged into power and the network, it boots automatically, joins your LAN, and accepts SSH connections from your laptop using the IP you found via the router scan.
