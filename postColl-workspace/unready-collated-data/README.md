## Unready Collated Data Directory
### Caution!
ebb: The files in this directory are in an incomplete state. They contain partially corrected or uncorrected collation data, and there are gaps when I have reserved passages to withhold from automated collation. These are usually represent major, serious differences of some editions from the others that need to be carefully woven back into the collation files, but that we have not completed that work yet. 

Nevertheless, I am storing this collection in order to prepare [HTML output](https://pghfrankenstein.github.io/Pittsburgh_Frankenstein/P1_tableView.html) to ease the Annotations team’s work in quickly inspecting how passages compare across editions. This should give us a quick view of passages that *do* align and may be handy for the Annotations team, even if incomplete. 

**As of 2019-04-14** we have processed units C01 - C26 with collateX in 10 different batches. These batch outputs may be found in:
```Pittsburgh-Frankenstein repo > collateX-Prep > Full_Part{1-10}_xmlOutput```.
Batches 1 through 3.2 are corrected (and represent collation of the first 1/3 of the novel from C01 through C10). From batches 3.5 onward, the collation outputs are *uncorrected* and almost certainly are missing some fragmented passages reserved from collation.

If a passage we are looking for is **missing** in these files, it will not appear in my [HTML output](https://pghfrankenstein.github.io/Pittsburgh_Frankenstein/P1_tableView.html). We will be able to locate it by inspecting reserved “fragmented” collation files, which may be found in directories named like this:
```Pittsburgh-Frankenstein repo > collateX-Prep > collChunkFrags-{edition}-Part{3.5-10}```.
(Here, `{edition}` could be msColl, 1831, 1818, Thomas, etc.) The XML files inside contain usually short passages from one or two editions that are designed to be added back into the output collation files by hand. These may be worth consulting, or, if you are stuck trying to find a passage, just contact me at @ebeshero or by e-mail, or better yet, open an issue on this repo. 