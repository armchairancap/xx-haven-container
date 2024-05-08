## Example for Haven with Tor Hidden Service

See [this post](https://armchairancap.github.io/blog/2024/05/08/can-securedrop-reinvent-the-wheel-probably-not) for more.

### tldr

Clone this repo, enter this `tor` directory and put file(s) that you want to share over Tor in `./tor-docs/`. Then use Haven to inform the other party where to get the file:

- tor-config/ - Tor Hidden Service configuration file (for NGINX)
- tor-docs/  - put your file(s) shared over Hidden Service (file.txt, etc.) to this directory
- tor-service/ - Tor identity will be stored here. Delete it every time after running if you don't want to retain or leave it here

Then run `docker compose up`. 

Haven will be at https://localhost:443, while Hidden Service will be accessible at the address contained in `./tor-service/hostname`.

### Credit

- https://github.com/ha1fdan/hidden-service-docker for Hidden Service example
