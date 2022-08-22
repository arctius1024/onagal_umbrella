
- Refactoring pass on onagal_fs, its a rats nest in there
- Possible refactor with onagal.images as well
- massive refactor needed in live/index
X Figure out how to pass filter state between image :index and :show
X handle inter-page paging (paging boundaries just loop the page currently)
X handle case where changing to an empty pageset while in :show breaks everything
- empty page set in show should knock user back to gallery view 
- switching filters in show works but displays the wrong image relative to the :id
- reloading in show can either infinite loop (??) or crash....
