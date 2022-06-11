# ubuntu-server-postinstall

This is a script I use post-install on Ubuntu-based servers. It includes a few things I generally need on a fresh install, including:

- Nginx
- PostgreSQL
- Node
- Rust
- Redis
- CrowdSec

## Usage

```bash
wget https://raw.githubusercontent.com/robertwayne/ubuntu-server-postinstall/main/src/install.sh && sudo chmod +x ./install.sh && sudo ./install.sh && rm ./install.sh
```
