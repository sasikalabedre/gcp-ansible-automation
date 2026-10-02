# Terraform + Ansible GCP Automation

## Project Overview

This project demonstrates how to use **Terraform and Ansible together** to provision and configure web servers on Google Cloud Platform (GCP).

* **Terraform** is used for infrastructure provisioning.
* **Ansible** is used for server configuration and application setup.
* **Nginx** is installed and configured as the web server.
* A simple HTML webpage is deployed automatically to multiple GCP VMs.

The project also combines several Ansible concepts such as inventory groups, multiple servers, variables, variable files, loops, handlers, registered variables, debugging, and service management.

---

## Architecture

```text
                    Git / Local Machine
                           |
                           |
                     Terraform
                           |
                           v
                    Google Cloud (GCP)
                           |
             +-------------+-------------+
             |                           |
             v                           v
        Web Server 1                Web Server 2
        automation-web-01           automation-web-02
             |                           |
             +-------------+-------------+
                           |
                        Ansible
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
          Packages       Nginx        HTML Page
             |             |             |
             +-------------+-------------+
                           |
                           v
                     Web Browser
```

---

## Technologies Used

* Google Cloud Platform (GCP)
* Terraform
* Ansible
* Nginx
* Linux
* YAML
* HCL
* HTML
* Git / GitHub

---

## Project Structure

```text
gcp-ansible-automation/
│
├── infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
│
└── ansible/
    ├── inventory
    ├── playbook.yml
    │
    ├── group_vars/
    │   └── webservers.yml
    │
    └── vars/
        └── packages.yml
```

---

# Part 1: Terraform Infrastructure

Terraform is responsible for creating the GCP infrastructure.

## Resources Created

Terraform creates:

1. VPC
2. Subnet
3. Firewall rule
4. Two GCP Compute Engine VMs
5. External IP addresses for the VMs

---

## VPC

A custom VPC is created:

```text
devops-automation-vpc
```

Auto-created subnets are disabled:

```hcl
auto_create_subnetworks = false
```

This allows us to create our own subnet.

---

## Subnet

A custom subnet is created:

```text
devops-automation-subnet
```

CIDR:

```text
10.20.0.0/24
```

The subnet belongs to the custom VPC.

---

## Firewall

A firewall is created to allow:

```text
SSH  → TCP 22
HTTP → TCP 80
```

The firewall uses a dynamic block so multiple firewall rules can be managed from a variable.

---

## Multiple VMs Using Count

Terraform creates two web servers using:

```hcl
count = 2
```

The VM names are generated automatically:

```text
automation-web-01
automation-web-02
```

This demonstrates how Terraform can create multiple similar resources without writing the same resource block twice.

---

## Public IP

Each VM has an external IP configured directly inside the network interface:

```hcl
access_config {}
```

Terraform then exposes the IP addresses through outputs.

---

## Terraform Outputs

The project outputs:

* VPC name
* Subnet name
* Web server names
* External IP addresses
* Internal IP addresses

These values are useful when connecting Ansible to the newly created servers.

---

# Part 2: Ansible Configuration

After Terraform creates the infrastructure, Ansible is used to configure the VMs.

The Ansible control machine connects to both servers through SSH.

---

## Ansible Inventory

The inventory contains both web servers:

```ini
[webservers]
web1 ansible_host=VM_1_EXTERNAL_IP
web2 ansible_host=VM_2_EXTERNAL_IP
```

The inventory group is:

```text
webservers
```

This allows the same playbook to run against multiple servers.

---

## Inventory Concepts Practiced

This project demonstrates:

* Inventory
* Inventory groups
* Multiple servers
* Host aliases
* Group variables
* Group commands
* Multi-server playbooks
* SSH connection configuration

---

# Ansible Variables

Group variables are stored separately:

```text
group_vars/webservers.yml
```

Example:

```yaml
nginx_port: 80
website_title: "DevOps GCP Automation"
environment: "development"
```

These variables can be used inside the playbook.

For example:

```yaml
{{ website_title }}
```

Ansible replaces the variable with its actual value during execution.

---

# Variables File

Packages are stored in:

```text
vars/packages.yml
```

Example:

```yaml
packages:
  - nginx
  - git
  - curl
```

The playbook loads this file using:

```yaml
vars_files:
  - vars/packages.yml
```

This keeps the package list separate from the main playbook.

---

# Ansible Loop

The project uses a loop to install multiple packages.

```yaml
loop: "{{ packages }}"
```

The variable:

```text
packages
```

contains the complete list:

```text
nginx
git
curl
```

Ansible processes one item at a time.

```text
packages
   |
   +--> item = nginx
   |
   +--> item = git
   |
   +--> item = curl
```

The special Ansible variable:

```text
item
```

represents the current item being processed by the loop.

---

# Become

The playbook uses:

```yaml
become: yes
```

This allows Ansible to execute privileged tasks using elevated permissions.

For example, installing packages and writing files under:

```text
/var/www/html/
```

requires appropriate privileges.

---

# Installing Packages

The playbook installs:

```text
nginx
git
curl
```

using the Ansible APT module.

Instead of writing three separate installation tasks, a loop is used.

This demonstrates reusable automation.

---

# Creating the Website

Ansible uses the built-in:

```yaml
ansible.builtin.copy
```

module to create the HTML file:

```text
/var/www/html/index.html
```

The HTML content is written directly inside the playbook.

Example:

```html
<h1>{{ website_title }}</h1>
<p>Environment: {{ environment }}</p>
<p>Server: {{ inventory_hostname }}</p>
<p>Nginx Port: {{ nginx_port }}</p>
```

Ansible replaces the variables with their values when the playbook runs.

---

# Inventory Hostname

The variable:

```text
{{ inventory_hostname }}
```

is provided automatically by Ansible.

For example:

```text
web1
web2
```

This allows each server to display its own inventory name.

---

# File Ownership and Permissions

The HTML file is configured with:

```yaml
owner: www-data
group: www-data
mode: '0644'
```

This controls:

* File owner
* File group
* File permissions

---

# Handlers

The project uses an Ansible handler:

```yaml
handlers:
  - name: Restart Nginx
```

The HTML creation task contains:

```yaml
notify: Restart Nginx
```

The handler runs when the task reports a change.

Concept:

```text
Task changes something
        |
        v
notify
        |
        v
Handler
        |
        v
Restart Nginx
```

This demonstrates Ansible's **handler and notify mechanism**.

---

# Nginx Service Management

Ansible ensures that Nginx is running:

```yaml
state: started
```

It also enables Nginx to start automatically after a server reboot:

```yaml
enabled: yes
```

---

# Register

The project checks the Nginx service using:

```bash
systemctl is-active nginx
```

The result is stored using:

```yaml
register: nginx_status
```

The registered variable contains information about the command execution.

---

# Debug

The project displays the registered output using:

```yaml
debug:
  var: nginx_status.stdout
```

This allows us to see the actual service status returned by the server.

For example:

```text
active
```

---

# Changed When

The service status check uses:

```yaml
changed_when: false
```

This tells Ansible:

> This task is only checking something; it did not change the server.

Therefore, the check is not incorrectly reported as a changed task.

---

# Complete Automation Flow

The complete project workflow is:

```text
1. Terraform
      |
      v
2. Create GCP VPC
      |
      v
3. Create Subnet
      |
      v
4. Create Firewall
      |
      v
5. Create two VMs
      |
      v
6. Get VM IP addresses
      |
      v
7. Add VM IPs to Ansible inventory
      |
      v
8. Ansible connects using SSH
      |
      v
9. Install required packages
      |
      v
10. Configure Nginx
      |
      v
11. Create HTML webpage
      |
      v
12. Restart Nginx when required
      |
      v
13. Check Nginx status
      |
      v
14. Display registered output
      |
      v
15. Access webpage through VM external IP
```

---

# Ansible Concepts Practiced

This project combines the following Ansible concepts:

### Inventory

Defines the target servers.

### Inventory Groups

Groups multiple servers together.

### Multiple Servers

Runs the same automation against multiple VMs.

### Host Aliases

Uses names such as:

```text
web1
web2
```

instead of repeatedly using IP addresses.

### Group Variables

Stores variables applicable to the web server group.

### Variables Files

Stores reusable variables outside the main playbook.

### vars_files

Loads external variable files into the playbook.

### Loops

Repeats a task for multiple items.

### Become

Provides privilege escalation for administrative tasks.

### Handlers

Runs actions when a task changes something.

### Notify

Triggers a handler after a change.

### Register

Stores command/task output in a variable.

### Debug

Displays variable information.

### Service Management

Starts, enables, and checks Nginx.

### Multi-Server Playbook

Uses one playbook to configure multiple servers.

---

# What I Learned From This Project

This project helped combine **Infrastructure as Code** and **Configuration Management**.

```text
Terraform
   =
Infrastructure Provisioning

Ansible
   =
Configuration Management
```

Terraform answers:

> "What infrastructure should exist?"

Ansible answers:

> "How should the servers be configured?"

Together:

```text
Terraform → Creates infrastructure
Ansible   → Configures infrastructure
Nginx     → Serves application/web content
```

---

# Final Result

Two GCP VMs are provisioned and configured automatically.

Each VM has:

* Nginx installed
* Git installed
* Curl installed
* HTML webpage deployed
* Nginx running
* Nginx enabled at boot
* Server-specific information displayed on the webpage

The project demonstrates a basic real-world DevOps workflow using **Terraform + Ansible + GCP + Nginx**.

---

# Key DevOps Concepts

```text
Infrastructure as Code
        ↓
Terraform
        ↓
Cloud Infrastructure
        ↓
Configuration Management
        ↓
Ansible
        ↓
Web Server Configuration
        ↓
Nginx
        ↓
Application/Webpage

