
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

- Make "tags" displays "pretty" (in tagsets/tags/images)
- switching filters in show works but displays the wrong image relative to the :id
- cleanup send_*_update functions in GalleryLive/index.ex
- Refactoring pass on onagal_fs, its a rats nest in there
- Possible refactor with onagal.images as well
- add "clear selected tags" to filters/tags 
- style sidebar
- style navbar
- style all the things
