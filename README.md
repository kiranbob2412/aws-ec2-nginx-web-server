AWS EC2 Nginx Web Server Deployment

«Production-minded AWS EC2 web server deployment using Linux, Nginx, Bash automation, SSH, and AWS networking fundamentals.»

"AWS" (https://img.shields.io/badge/AWS-EC2-orange)
"Linux" (https://img.shields.io/badge/Linux-Ubuntu-E95420)
"Nginx" (https://img.shields.io/badge/Web%20Server-Nginx-009639)
"Bash" (https://img.shields.io/badge/Automation-Bash-4EAA25)
"Status" (https://img.shields.io/badge/Deployment-Successful-success)

---

Project Overview

This project demonstrates the deployment of a production-style static web server on Amazon EC2 using Ubuntu Linux and Nginx.

The objective was not simply to install a web server, but to implement the complete infrastructure workflow:

AWS provisioning → network access control → secure SSH access → Linux server configuration → automated Nginx installation → application deployment → service validation → public HTTP verification → deployment evidence

The deployment uses a Bash automation script to reduce manual configuration and make the server setup repeatable.

---

Architecture

                         Internet
                            │
                            │ HTTP : 80
                            ▼
                 ┌─────────────────────┐
                 │   AWS Security      │
                 │       Group         │
                 │                     │
                 │ TCP 80  → 0.0.0.0/0│
                 │ TCP 22  → My IP     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      AWS EC2        │
                 │   Ubuntu Linux      │
                 │                     │
                 │   Nginx Web Server  │
                 │         │           │
                 │         ▼           │
                 │ /var/www/html/      │
                 │     index.html      │
                 └──────────┬──────────┘
                            │
                            ▼
                     Public Web Page

---

Technology Stack

Layer| Technology
Cloud Platform| AWS
Compute| Amazon EC2
Operating System| Ubuntu Linux
Web Server| Nginx
Automation| Bash
Access| SSH
Networking| AWS Security Groups
Validation| "nginx -t", "systemctl", "curl"
Version Control| Git / GitHub

---

Repository Structure

aws-ec2-nginx-web-server/
│
├── README.md
├── .gitignore
│
├── src/
│   └── index.html
│
├── scripts/
│   └── install-webserver.sh
│
└── assets/
    └── screenshots/
        ├── ssh-connection.png
        └── live-webpage.png

Component Responsibilities

"src/index.html"

Contains the custom landing page deployed to the EC2 web server.

"scripts/install-webserver.sh"

Automates:

- Package repository update
- Nginx installation
- Nginx service enablement
- Nginx startup
- Web page deployment
- Nginx configuration validation
- Service health validation
- Local HTTP health check

"assets/screenshots/"

Contains deployment evidence captured from the actual environment.

---

Deployment Workflow

1. Provision EC2

An Ubuntu EC2 instance was provisioned in AWS with a dedicated key pair.

The instance was configured with:

- Ubuntu Linux
- Public IPv4 address
- Security Group
- SSH access
- HTTP access

The EC2 instance acts as the compute layer for the web application.

---

2. Configure Network Access

The Security Group was configured with the minimum network access required for the deployment.

SSH

Protocol: TCP
Port: 22
Source: My IP

SSH access was restricted to the administrator's IP rather than exposing port 22 globally.

HTTP

Protocol: TCP
Port: 80
Source: 0.0.0.0/0

Port 80 was exposed publicly because the web server must be reachable from the Internet.

---

3. Secure SSH Access

The EC2 key pair was stored locally and protected with restricted permissions.

chmod 400 ~/nginx.pem

The server was accessed using:

ssh -i ~/nginx.pem ubuntu@<EC2_PUBLIC_IP>

The SSH session was successfully established and verified.

---

4. Deploy the Project

The GitHub repository was cloned directly onto the EC2 instance:

git clone https://github.com/kiranbob2412/aws-ec2-nginx-web-server.git

The project files were then inspected:

ls -l scripts/install-webserver.sh
ls -l src/index.html

---

5. Prepare the Deployment Files

The custom landing page was copied into a temporary deployment location:

sudo cp src/index.html /tmp/index.html

The deployment script was also prepared:

sudo cp scripts/install-webserver.sh /tmp/install-webserver.sh
sudo chmod +x /tmp/install-webserver.sh

---

6. Automated Nginx Installation

The deployment script was executed with elevated privileges:

sudo /tmp/install-webserver.sh

The script performs the following sequence:

apt update
     ↓
Install Nginx
     ↓
Enable Nginx
     ↓
Start Nginx
     ↓
Deploy index.html
     ↓
Validate nginx configuration
     ↓
Restart Nginx
     ↓
Verify service health
     ↓
HTTP 200 health check

Successful deployment produced:

==========================================
 NGINX DEPLOYMENT SUCCESSFUL
 HTTP STATUS: 200
 WEB ROOT: /var/www/html
==========================================

---

7. Nginx Configuration Validation

The Nginx configuration was validated before considering the deployment successful:

sudo nginx -t

Expected result:

syntax is ok
test is successful

---

8. Service Validation

Nginx service state was verified using:

sudo systemctl status nginx --no-pager

Startup persistence was checked using:

sudo systemctl is-enabled nginx

This ensures Nginx is configured to start automatically when the instance boots.

---

9. HTTP Health Check

The local web endpoint was tested from the EC2 instance:

curl -I http://127.0.0.1

The deployment returned:

HTTP/1.1 200 OK

This confirms that:

- Nginx is running
- Port 80 is serving traffic
- The web root is accessible
- The deployment is responding successfully

---

10. Public Deployment Verification

The application was then accessed through the EC2 public IPv4 address:

http://<EC2_PUBLIC_IP>

The custom landing page was successfully served from the EC2 instance.

SSH Connection Evidence

"SSH Connection" (assets/screenshots/ssh-connection.png)

Live Web Application

"Live Webpage" (assets/screenshots/live-webpage.png)

---

Automation Design

The deployment script uses defensive Bash practices:

set -Eeuo pipefail

This provides:

- Fail-fast behavior
- Detection of unset variables
- Better pipeline error handling

The script also validates prerequisites and service health instead of assuming that package installation automatically means the deployment succeeded.

Deployment Checks

Root privilege validation
        ↓
Package installation
        ↓
Nginx version check
        ↓
Service enablement
        ↓
Service startup
        ↓
Application deployment
        ↓
nginx configuration test
        ↓
Service health check
        ↓
HTTP status validation

---

Challenges Encountered & Resolutions

1. Incorrect EC2 SSH Key

Initially, SSH authentication failed because the wrong private key was being used.

The EC2 instance was configured with the "nginx" key pair, so the correct local key was identified and used:

ssh -i ~/nginx.pem ubuntu@<EC2_PUBLIC_IP>

Lesson: Always verify the EC2 instance's configured key pair before troubleshooting SSH authentication.

---

2. Permission Error While Preparing Deployment Files

An initial attempt to copy the HTML file into "/tmp" as the normal Ubuntu user failed:

Permission denied

The operation was corrected using appropriate administrative privileges:

sudo cp src/index.html /tmp/index.html

Lesson: Understand Linux filesystem permissions instead of changing permissions unnecessarily.

---

3. Duplicate HTTP Security Group Rule

While configuring HTTP access, AWS reported that an identical rule already existed.

The existing rule was retained rather than creating another duplicate rule.

Lesson: Security Group rules are uniquely identified by protocol, port and source. Duplicate rules provide no additional functionality.

---

4. Git Repository History Synchronization

The local repository and GitHub repository initially contained independent commit histories.

The histories were reconciled before pushing the final project.

Lesson: Repository initialization should ideally happen from a single source, or divergent histories should be deliberately reconciled before continuing development.

---

5. Deployment Verification

Instead of treating successful package installation as proof of deployment, multiple validation layers were used:

Nginx configuration
        +
Systemd service state
        +
Local HTTP response
        +
Public HTTP access
        =
Verified deployment

This approach reduces false positives during infrastructure deployment.

---

Security Considerations

The project follows basic cloud security principles:

- SSH access restricted to the administrator's IP.
- HTTP exposed only because public web access is required.
- Private key files are excluded through ".gitignore".
- AWS credential directories are excluded from Git.
- No private credentials or secrets are stored in the repository.
- Nginx configuration is validated before service restart.
- Deployment is performed using least-required administrative privileges.

«Production note: In a real production environment, HTTPS/TLS, domain-based access, centralized logging, monitoring, patch management, IAM controls, backups, and infrastructure-as-code would be added according to the application's requirements.»

---

Validation Checklist

Validation| Result
EC2 instance reachable| ✅
SSH authentication| ✅
Ubuntu server operational| ✅
Nginx installed| ✅
Nginx enabled at boot| ✅
Nginx running| ✅
Nginx configuration valid| ✅
Custom HTML deployed| ✅
Local HTTP response| ✅ "200 OK"
Public webpage accessible| ✅
Deployment screenshots captured| ✅
GitHub repository synchronized| ✅
Git working tree clean| ✅

---

Project Outcome

The project successfully demonstrates an end-to-end AWS web server deployment:

AWS EC2
   ↓
Ubuntu Linux
   ↓
Secure SSH Access
   ↓
Nginx Installation
   ↓
Bash Automation
   ↓
Custom Web Application
   ↓
Service Validation
   ↓
HTTP Health Check
   ↓
Public Internet Access

The final result is a repeatable, documented, and validated Nginx deployment on AWS EC2, with deployment evidence maintained in GitHub.

---

Skills Demonstrated

Cloud

- AWS EC2
- Security Groups
- Public IPv4 networking
- Cloud-based compute provisioning

Linux

- Ubuntu administration
- SSH
- Linux permissions
- Systemd
- Service management
- Package management
- Network/service validation

DevOps

- Bash automation
- Git
- GitHub
- Deployment validation
- Infrastructure troubleshooting
- Operational documentation

Web Infrastructure

- Nginx
- HTTP
- Web root management
- Health checks
- Static web deployment

---

Author

KUCHIPUDI KIRAN BABU

Cloud Engineer | AWS | Linux | DevOps

Focused on building reliable cloud infrastructure, automation workflows, and production-oriented AWS projects.

---

Project Status

Deployment Status: ✅ SUCCESSFUL

Platform: AWS EC2
Web Server: Nginx
Operating System: Ubuntu Linux
Automation: Bash
HTTP Validation: "200 OK"
Repository: GitHub
