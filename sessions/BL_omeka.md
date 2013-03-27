BLOmeka
=======
Omeka: from George Mason; blog like util for faculty, etc. to quickly stand up exhibitions.

Problems: no metadata, PHP stack, not long term sustainable.

Atrium: ~6 mos. away from completion for ~2 yrs.

It would be better if you could use resources in Hydra to build exhibitions.

What would a digital exhibit look like on Blacklight?

What is an exhibit? 
 A. Digital representation of a (physical) small set of exemplar items, selected, descibed, put somewhere with signs, or:
 B. Above w/ more featues, like searching, facets, additional info. (ND definition), or:
 C. A bit of both. An augemented catalog.

Stanford has collections of objects described at various levels. Use cases:
 1. Surface digitized material (Reid Dennis Collection).
 2. Represent high-profile material (Bassi-Veratti), full scale site.
 3. lib.stanford.edu/telaviv like C above. Enhanced version of physical collection. Basically a wrapper for pointers, built in Drupal; not sustainable, esp. wrt. migrations doesn't actually aggregate anything.
 4. Not really exhibits, but but users should be able to tag items, make their own collections and attach descriptive info. 

Other examples:
 1. http://andrestudios.nypl.org. Blacklight with some extra narrative pages. (Exhibit type B above)
 2. http://dl.tufts.edu (type C above), also BL, over Fedora, but links to external sites.
 3. http://search.lib.virginia.edu/music Not exactly an exhibition, but a topical/filtered page that auto-aggregates content/new-content. Atrium sort of does this (true?)
 4. http://braceroarchive.org
 5. http://d.lib.ncsu.edu/collections/catalog/0005096 (e.g.). How to incorporate other content?

Building and extending (adding pages) it still needs to be easy enough for non-engineers (e.g. curators) to do. They're not going to become Rails hackers. That doesn't mean help won't be needed with branding/themeing, but content-specialist should be able to get quite far (content and filtering wise) without developer help.

Content added by curators etc. should also be indexed. How?
 * Update Solr? Newer Solr features (join tables? not performant?)
 * Separate DB
 * Separate Solr

ND experience w/ adding ad-hoc content to BL was not good [PLEASE FILL OUT]

Sufia is going to have a feature that allows users to create collections, add a cover flow image, additional descriptive data, a new, clean URI by OR this summer. (See Stanford use case 4 above). This is on Hydra though, not BL. Could Hydra be swapped out for any persistent storage layer?

Should BL have a biographical-sketch sort-of field?
