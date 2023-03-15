Use: https://github.com/induna-crewneck/dietpi-bypass-openvpn/blob/main/README-dockerupdate.md


# Docker info

For this we will use the plex container (https://hub.docker.com/r/linuxserver/plex)

To show existing containers run ``docker container list`` which will give out the info we need:
```
CONTAINER ID   IMAGE                     COMMAND   CREATED         STATUS      PORTS     NAMES
20d6ca394f40   lscr.io/linuxserver/plex  "/init"   10 months ago   Up 7 days             plex
```

To show downloaded images, run ``docker image ls``:
```
REPOSITORY                              TAG       IMAGE ID       CREATED         SIZE
lscr.io/linuxserver/plex                latest    b80e4f877a1f   10 months ago   276MB
```

## Backing up Docker container
Useful before updating

Syntax: ``docker export [OPTIONS] CONTAINER`` (Export a container’s filesystem as a tar archive)
Note: Command does not export the contents of volumes.
By default the ``--output`` will store to /root
``
docker export --output="/mnt/Seagate/Plexbackup/plexcontainer-20230315.tar" 20d6ca394f40
``
This can be imported with ``docker import TAR``

## Updating existing Docker container

```
docker stop <container_id>
docker rm <container_id>
docker rmi <image_id>
docker pull <image_name:image_tag>
```

```
docker stop 20d6ca394f40
docker rm 20d6ca394f40
docker rmi b80e4f877a1f
docker pull lscr.io/linuxserver/plex:latest
```
