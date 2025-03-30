## Simple Deploy automation using SSH

## Usage:

1. Create a copy of the `env.example` as `.env`
2. Change the `SSH_HOST` with your vps ip
3. Copy the `docker-compose.prod.yml` file to your VPS
4. Execute the `scripts/deploy.sh`

### Proxy configuration

Go to `vps host:81` then log into Nginx Proxy Manager, and add a new `Proxy Host`. The options should be something like this:

<img width="522" alt="image" src="https://github.com/user-attachments/assets/0f8a0dd5-5104-4a71-b7ba-949e4cbd8394" />

Then the web project will be available at your domain name, ex `my-domain.com`
