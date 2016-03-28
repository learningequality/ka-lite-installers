## What is this?

This directory contains a Dockerfile for building unsigned debs. You'll have to look up how to run docker on your
platform -- Windows and OSX users need to install docker-machine. Follow the 
[install instructions](https://docs.docker.com/engine/installation/) on the docker website.

## So how do I build the .deb file?

The given image builds an *unsigned* deb based on the latest pre-release of 
[ka-lite-static](https://pypi.python.org/pypi/ka-lite-static/) uploaded to PyPI.
You can then access the docker container and copy it to your local machine to do whatever you'd like with it.
To build:

1. Modify the line `ENV deb_ver=0.16~b4` in the Dockerfile to build a deb with the indicated version.
2. Run `docker build .` in this directory. At the end you should see some output with a commit hash like this:
```
dpkg-source: info: using options from ka-lite-source-0.16~b4/debian/source/options: --extend-diff-ignore=\.egg-info$
dpkg-buildpackage: full upload (original source is included)
---> a060b914cd74
Removing intermediate container 8fcf3c7baa1b
Successfully built a060b914cd74
```
3\. Enter the container from that commit and mount a local directory so you can copy the deb to your host machine.
   Run this command with appropriate values: `docker run -v <host dir>:/mnt/ -it <commit hash>`
   That will mount `<host dir>` on the host machine to `/mnt/` in the container, and start an interactive prompt at 
   the state indicated by `<commit hash>`. Use the hash from the last step (i.e. `a060b914cd74`).
   See the docker [docs on VOLUME option](https://docs.docker.com/engine/userguide/containers/dockervolumes/#mount-a-host-directory-as-a-data-volume)
   for valid `<host dir>` values.
    
## What if I want a signed deb?

This image builds from a ka-lite-static pre-release, so it's not appropriate for an actual release. Start by reading 
the 
[build instructions](https://docs.google.com/document/d/1Z7EMFfGc70pk3-888BMAugGwsEOyef93oolphL286fs/edit#bookmark=id.abaetd64tz9j).
You can easily modify the Dockerfile to create an actual release with a little manual intervention:
 
1. Modify the line `RUN pip install --pre ka-lite-static -d . && \` by removing the `--pre` option.
2. Build the image as above: `docker build .`
3. Start an interactive prompt as in step 3 above: `docker run -v <host dir>:/mnt/ -it <commit hash>`.
4. Go to the directory with the *new* source (`/ka-lite-source-<ver>`, where `<ver>` is the value of `deb_ver` 
   environment variable you set in the Dockerfile).
5. Modify the changelog with `dch` as described in the build instructions.
6. Run `debuild --no-lintian`.
7. Finally, you can copy the resulting deb to your host machine as above.