
X massive refactor needed in live/index
X Figure out how to pass filter state between image :index and :show
X handle inter-page paging (paging boundaries just loop the page currently)
X handle case where changing to an empty pageset while in :show breaks everything
X empty page set in show should knock user back to gallery view 
X reloading in show can either infinite loop (??) or crash....
X allow bulk tag updates to images

- switching filters in show works but displays the wrong image relative to the :id
- Refactoring pass on onagal_fs, its a rats nest in there
- Possible refactor with onagal.images as well
- add "clear selected images" button to sidebar
- add "clear selected tags" to filters/tags 
- style sidebar
- style navbar
- style all the things
