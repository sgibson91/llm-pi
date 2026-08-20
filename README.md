# LLM Pi

**A Raspberry Pi Configuration for running local LLMs with workflow automation**

Run a local large language model on your Raspberry Pi with a browser-based workflow builder — no cloud dependency, no API keys, no data leaving your network.

This project deploys [Ollama](https://ollama.ai) (LLM inference) and [n8n](https://n8n.io) (workflow automation) via Docker Compose, configured and managed with a single Ansible playbook.

## Features

**Ollama**: Serves local LLM inference on port 11434. Supports multiple models — configure as many as your storage allows and swap between them on the fly.

**n8n**: A workflow automation platform with a visual editor, accessible on port 5678. Use it to build chatbots, summarisers, document processors, or any LLM-powered automation. Connects to Ollama over Docker's internal network at `http://ollama:11434`.

**IMPORTANT NOTE**: The Raspberry Pi 4 (4 GB) is the minimum viable hardware. With Ollama and a model loaded, plus n8n, you'll be near RAM capacity. Stick to small models (1B–3B parameters) and consider setting `ollama_num_parallel: 1` in your `config.yml` if you encounter OOM issues.

## Recommended Pi and OS

You should use a Raspberry Pi 4 model B (4 GB+) or better. More RAM means larger models or more concurrent requests.

The configuration is tested against Raspberry Pi OS (64-bit) and should work on any Debian-based distribution.

## Setup

  1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):
     1. (If on Pi/Debian): `sudo apt-get install -y python3-pip`
     2. (Everywhere): `pip3 install ansible`
  2. Clone this repository: `git clone https://github.com/sgibson91/llm-pi.git`, then enter the directory: `cd llm-pi`.
  3. Install requirements: `ansible-galaxy collection install -r requirements.yml`
  4. Make copies of the following files and customise them to your liking:
     - `example.inventory.ini` to `inventory.ini` (replace the IP address with your Pi's IP, or comment that line and uncomment the `connection=local` line if you're running it on the Pi itself).
     - `example.config.yml` to `config.yml`
  5. Run the playbook: `ansible-playbook main.yml`

> **If running locally on the Pi**: You may encounter a "permission denied" error connecting to the Docker daemon. If so, log out and back in (or reboot), then run the playbook again. If the error persists: `sudo usermod -aG docker $USER`

> **Slow model pulls**: On a slow connection, the model pull may exceed the SSH timeout. Run with `-T 600` to increase it: `ansible-playbook main.yml -T 600`

## Usage

### n8n

Visit the Pi's IP address with port 5678 (e.g. http://192.168.1.10:5678/) to access the n8n workflow editor.

To chat with your models, create a workflow with a **Chat Trigger** node connected to an **Ollama** node. Set the Ollama base URL to `http://ollama:11434` and select your model.

### Ollama API

The Ollama API is exposed on port 11434. You can interact with it directly:

```bash
# List available models
curl http://192.168.1.10:11434/api/tags

# Chat with a model
curl http://192.168.1.10:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [{"role": "user", "content": "Hello!"}]
}'
```

## Configuration

All options are documented in `example.config.yml`:

```yaml
# Location where configuration files will be stored.
config_dir: /opt/ollama-n8n

# Models to pull (list as many as your hardware will allow).
ollama_models:
  - "llama3.2:1b"

# Ports.
ollama_port: 11434
n8n_port: 5678

# Uncomment to constrain resources on a 4 GB Pi:
# ollama_num_parallel: 1
# ollama_max_loaded_models: 1
```

## Updating

To upgrade to the latest container images:

```bash
cd /opt/ollama-n8n
docker compose pull
docker compose up -d --no-deps
docker system prune --all
```

Or re-run the playbook: `ansible-playbook main.yml`

## Uninstall

```bash
cd /opt/ollama-n8n
docker compose down -v
docker system prune -af
sudo rm -rf /opt/ollama-n8n
```

## License

MIT

## Author

This project was created in 2026 by [Sarah Gibson](https://sgibson91.github.io/).
