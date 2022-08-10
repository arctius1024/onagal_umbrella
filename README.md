# Onagal

## Purpose

A basic image management system consisting of several parts:

- onagal: [75%] Data-store is a PostgreSQL database, along with an ecto interface to the data. Other utility modules may go here 
as well.

- onagal_web: [15%] Web front-end (early rough-out) allow images with static tags (and possibly KV tags in the future) and
a matching "gallery" system allow groups of tags to be saved into a "gallery" as preset filters for slide show presentations.

- onagal_fs: [80%] Filesystem importer (WIP). An elixir process that uses inotify filesystem events to watch 
an upload directory for new files. If the file is an image it will be moved into a groomed storage area, its
meta-data stored into the data store and be available via the web ui. Also handles file removal/cleanup. 

- ~~onagal_crawl: [75%] Bulk import system (WIP - refactor). Pass it a top level directory and it will recurse, find all
files with an image file type (only looks at extension, may improve that later) and store basic meta-data into a data store.
The file will then be moved into a groomed storage area and then be available via the web ui. This is likely to only be used once,
as any future image imports would be done via the upload importer. !! This may be replaced by utilizing the auto importer and 
moving relevant files into the "import" directory. !!~~  Removed, some functionality merged with onagal_fs.

- Future phases may include KV tags (rather than static keyword tags), date range filtering, EXIM meta-data extraction/tagging,
basic reporting capabilities, random slideshows, ability to embed a gallery on another page via an embed code. Who knows,
all exciting stuff.

## Background

This is a "pet project" intended to help me learn Elixir, Ecto, Phoenix, LiveView and potentially other related
technologies and packages. Along the way hopefully I'll pick up some best practices and ways of working to help
improve my FP and Elixir coding skills.

While I do intend to make this a fully functioning application (eventually) it is not something I spend most of my
time on, nor am I terribly familiar with most of the technologies involved. It may never get finished, the code may
be terrible, it may cause any computer running it to spontaneously explode. Caveat Emptor.

Tech stack:
* Linux:  PopOs! 20.04 LTS / LKV 5.17
* erlang: 24.3.4
* elixir: 1.13.4-otp-24

Constructive criticisms most welcome, especially if they come in PR or links to solid documentation.

In particular if there is a good file/path traversing hex package I'd be most interested - the few that I saw seemed outdated
or not fit for purpose. I'd rather not be in the business of custom writing that sort of thing if I can avoid it.
