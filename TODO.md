* [*DONE*]
- ~~massive refactor needed in live/index~~
- ~~Figure out how to pass filter state between image :index and :show~~
- ~~handle inter-page paging (paging boundaries just loop the page currently)~~
- ~~handle case where changing to an empty pageset while in :show breaks everything~~
- ~~empty page set in show should knock user back to gallery view~~
- ~~reloading in show can either infinite loop (??) or crash....~~
- ~~allow bulk tag updates to images~~
- ~~add "clear selected images" button to sidebar~~
- ~~make add/replace selectable when tagging in montage~~
- ~~allow tagging to work properly when in :show~~
- ~~tagging while in :show does not refresh tag list~~
- ~~Add in UI ability to create tagsets~~
  - ~~Show should work~~
  - ~~New should work~~
  - ~~Edit Should work~~
  - ~~All of the above should also show associated tags (initially in "ugly" format)~~
- ~~Add in UI ability to create filtersets (similar to tagsets)~~
  - ~~Show should work~~
  - ~~New should work~~
  - ~~Edit Should work~~
- ~~Add ability to "apply" a tagset to the active list of tags~~
- ~~Add ability to "apply" a filterset to active list of tag filters~~
- ~~Figure out why the heck gallerylive/index uses two different methods of sub-pagination navigation!??!?~~
  - ~~send_filter_update({:show,....})~~
  - ~~apply_action(socket, :show....)~~
- ~~add "clear selected tags" to filters/tags~~
- ~~increase density of gallery view to show more thumbs~~
  - ~~decrease thumb size (from 160 -> 120)~~
  - ~~decrease CSS area for image list elements~~
- ~~in montage view - there appears to be a problem where the thumbnail order differs from the actual image when clicked.~~
- ~~switching filters in show works but displays the wrong image relative to the :id~~
- ~~handle filters returning only a single image~~
- ~~force ordering of paginated image queries~~
- ~~fix changing filters in show sometimes display incorrect image~~
- ~~Pages are "wrapping around"~~
  - ~~Is this a paginator "feature"? If so I hate it~~
  - ~~Make it not happen.~~
    - ~~See if something in the page tuple generation can be changed to fix it~~
  - ~~Make next_images/prev_image nil on end of list boundaries (to stop buttons from showing)~~
- ~~Massive rewrite on pagination:~~
  - ~~Switched to Paginator~~
  - ~~Key based pagination (instead of pages)~~
  - ~~Inter-page image pagination works!!!!~~
  - ~~You can now start the gallary at a given image id~~
    - ~~You cannot back-paginate prior to that id~~

* [*FEATURES*]
- improve clearing filters

* [*FIXES/CLEANUPS*]
- Tags aren't selected by default in display view filter control but should be
  - have the filter prefer image.tags then selected_tags; ~~null out image on montage~~
- Fix missing menu errors on main landing page
- [PARTIAL] cleanup send_*_update functions in GalleryLive/index.ex
- [PARTIAL] Possible refactor with onagal.images as well
- Refactoring pass on onagal_fs, its a rats nest in there
- More pagination fallout cleanup...

* [*STYLING*]
- Make "tags" displays "pretty" (in tagsets/tags/images)
- style sidebar
- style navbar
- style all the things
