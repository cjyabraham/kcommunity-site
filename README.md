# Kubernetes Community Site Generator

This repository contains the [hugo](https://gohugo.io/) site and generator scripts for the
Kubernetes Community site.  Much of the content is generated from the [kubernetes/commmunity](https://github.com/kubernetes/community)
directly and care should be taken when working within the [content directory](content/) directly. 

The heavy lifting occurs within [gen-site.sh](gen-site.sh) script. If not being called externally,
it will clone the [kubernetes/commmunity](https://github.com/kubernetes/community) within the
[build](build/) directory then sync specific directories and files to the [content directory](content/). 

Content is synced following the below rules:
* Directories prefixed with `sig-` will be synced to the `special-interest-groups` directory.
* Directories prefixed with `wg-` will be synced to the `working-groups` directory.
* Other directories that are not included in the [exclude.list](exclude.list) are copied to the 
  root of the [content directory](content/).
* Files at the root of the directory will **only** be copied over if they are listed in the
  [include.list](include.list) with the exclusion of `sig-list.md` and `README.md`.
* `sig-list.md` is copied to both the `special-interest-groups` and `working-groups` and renamed
  to `README.md`.
* The `README.md` from the root of the community repo is copied over to the root of the
  [content directory](content/) for now.


Next it will go through all the files within the [content directory](content/) and search for any
links that may need to be corrected to function outside of github along with inserting a [front-matter](https://gohugo.io/content-management/front-matter/)
header (if needed).

Lastly, any `README.md` files are renamed to `_index.md`. These function similarly to `README.md`
files within a github repository, but are what hugo is expecting.

At that point the site can be previewed locally with `hugo serve`, or the site built with `hugo`.
If it is built, the default location is `build/public`. 
