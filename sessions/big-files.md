Big files
=========

What is large?
- 200M uploading or downloading over the web can be a problem for people
- 1 GB
- 2 GB
- 10's of gigs - an hour of uncompressed HD video
- potentially 100's of gigs - drive images

(side topic: does the data segment gracefully? and re-assemble?)

Problems to address

- Self deposit
- Storage
  + Redundancy
  + Versioning
- Distribution (problems on both tech and human sides here)
- Derivatives (computation time)
- Interrupted transfer (also: how can you tell?)

Possible solutions

- BitTorrent (but social stigma a problem: rebranding needed?)
  + helps w/ distribution & redunancy
- DropBox
  + good for self deposit, but only up to ~2 gigs
- Glacier: http://aws.amazon.com/glacier/
- Sneaker-net (put it on a hard drive or USB stick, carry it over)
- Deposit a reference to an external resource, pull it down eventually.
- FTP server people can upload to, then notify us when it's ready.
  + Downside: lots of people don't have a good FTP tool by default
- In-house shared mount point
- PSU - DropBox solution
- Make a Dropbox / Box / etc. abstraction library in Ruby?
- Explore BitTorrent or related solution
- New Mega upload site?
- Dropbox, Box, etc.

Desired Features - Deposit

- Desktop client (e.g. DropBox) is really handy for users
- How to know when upload is done. In dropbox case, they don't present the file until it's ready. In multi-file case, um, ...
  + also, how to know it's correct
  + manifest / checksum / etc.
- How to retain hierarchy (or sequence) of multiple files
- Security / privacy
- Interruptability
  + how long a break is too long?
  + user/client induced (e.g. they disconnect on the ride home, or run out of power)
  + low-bandwidth connection
  + network disruption
  + receiving end disruption (e.g. server maintenance)
  + recovery and data corruption
- Capacity negotiation
  + can we really accept 1TB this minute?
  + DuraCloud used a checkm manifest. Allows resumable xfer, and progress check.
- Live stream capture
- Completion status (% done)
- Bandwidth limits so user's machine statys usable
- Capture metadata for deposit?

Features - Delivery

- availabilty notification
- delivery location(s)
- partial delivery? e.g. GIS data, map tile
- derivatives (incl. real-time)
- concurrent
- live streaming

It's too big. Where do we start?
- Concrete use case: Bess needs to be able to recieve a 120 G file through self deposit.
- One solution: user puts it somewhere (and up to 2-5 gigs, on DropBox/Box/SendIt) and gives you a URL.

Some institutions have an institutional agreement w/ DropBox. Has a cost.

Can we implement a Mac / PC / Linux client that basically wraps rsync and provides a Dropbox-like solution for users?
- There will be security configuration price
- "Seafile" appears to be an open-source Dropbox alternative, cross-platform. Maybe we don't have to start from scratch.