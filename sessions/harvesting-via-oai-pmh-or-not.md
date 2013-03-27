LibDevConX 2013 - Harvesting via OAI-PMH or not
-----------------------------------------------

2013-03-25 2:45pm

Mike's starting question: *Librarians ask about ScholarSphere supporting OAI-PMH. What are the reasons to support a 12year old niche protocol? Or some other protocol?*

Motivations to support harvesting:

- Everyone needs to be harvested by Google/Bing/etc (OAI-PMH give this)
- May want to be harvested in other more specific contexts (e.g. for IR) and OAI-PMH widely used in scholarly world

For OAI-PMH:

- simple, consistent API
- easier to harvest than running a crawler or spider
- DPLA is doing OAI-PMH with MODS
- WGBH does OAI-PMH to be harvested by Digital Commonwealth <http://www.digitalcommonwealth.org/requirements/>
- OAI-PMH not hard to do, Ruby gem available but more to maintain. Stanford have done recent work on the gem to improve it.

Alternative suggestions:

- use sitemap and embed metadata using RDFa
- common crawl <http://commoncrawl.org/> index URL services shows whether your data is being harvested by them and available on AWS. Web data commons <http://webdatacommons.org/> folks in Germany are extracting microdata and exposing nquads data
- current status is that to do high level aggregation, OAI-PMH is the current way. This is used in Orbis Cascade Alliance <http://www.orbiscascade.org/> for 30+ institutions using OAI-PMH. Question is about the future and what the way forward is
- many cultural heritage institutions don't have good online presence to harvest via web or APIs like OAI-PMH, they give DB data dumps. Suggestions that providing simple tools to allow such to do sitemap and schema.org data.

How should we compare OAI-PMH vs sitemaps/wbecrawl? Argument that one should use sitemaps to put in only the things should be harvested. Comments that this might not be the same as for every client - how to support the notions of selective harvesting provided by OAI-PMH. Can do this by post-processing but not efficient. Concerns that there may be many round-trips for sitemap based sync.

Simeon (me) argues that the NISO/OAI ResourceSync project is thinking along very similar lines to what has been expressed. Developing sitemaps based sync framework:

- *concepts:* support three functions: baseline sync (initial copy), incremental sync (efficient update), and audit (check that your copy is in sync)
- *documents:* resource list is snapshot list of all resources available, basically a sitemap with optional additional metadata; change list is list of updates in same format; dumps combine a manifest of resources or changes packaged in a ZIP with the bitstreams themselves; capability list describes what capabilities are available for a set of resources. Also archives of these provide historical records, all using the sitemaps format
- *discovery:* proposal to use .well-known/resourcesync.xml URI and/or XHTML link elements
- beta spec at <http://www.openarchives.org/rs/0.5>
- discussion group at <https://groups.google.com/d/forum/resourcesync>
- going to have v0.6 in a few weeks which separates the core capabailities from the archives in separate documents. Also add document describing push methods (XMPP, http callback etc) that were in the earlier draft before we moved back to the sitemaps format <http://www.openarchives.org/rs/0.1/resourcesync#PushingChangesets>
- picture of links between documents below (changed slightly from 0.5 spec, will be reflected in 0.6). This is perhaps a bit more complicated than need because it includes the optional sitameps paging mechanism documents (using sitemapindex, shown with dashed line)

![ResourceSync object hierarchy](https://github.com/ldcx/ldcx-2013/blob/master/sessions/harvesting-via-oai-pmh-or-not--resourcesync.png)

Could OAI-PMH libraries be retrofitted to provide multi-format support to help migration for? Suggestion that trying to implement over Content DM would be good, would also help refine/validate spec.

Bess said that Stanford use OAI-PMH internally to get set of things that have been published in central system, using sets mechanism, to get updates for different Hydra heads. University of North Texas also using internally. Stanford also using OAI-PMH for discovery system over repositories (usually e-prints, dspace, greenstone) in Africa.

DTU example of use case where OAI-PMH should never have been used. Was used in situation where Danish ministry had plan to harvest from Universities at 8am on a particular day. The Universities could not tell when done, would have been better to have a push.

Requests for validator for ResourceSync, was very useful with OAI-PMH. Simeon said there is working source simulator and client code <https://github.com/resync>, some demos (not quite up to date) at <http://resync.library.cornell.edu/>. Will have to think about validator

What do people do for OAI-PMH discovery? There is the registry but not well maintained. Also UIUC registry automatically maintained. Cory notes OpenDOAR has links to OAI-PMH endpoints. Registries:

- <http://www.openarchives.org/Register/BrowseSites>  -- lists 1944 repos but is not checked for current activity
- <http://gita.grainger.uiuc.edu/registry/> -- lists 2848 repos currently working
- based on UIUC registry data, Jason Ronallo looked for robots.txt and sitemaps: <http://capsys.herokuapp.com/profiles> (for each site look at its "Achievements" for implementation of robots.txt or sitemaps)

Question about whether there should be a ResourceSync entry in robots.txt. In spite of the possibilities of discovery links in HTML and use of .well-known URI there seemed to be a sense that robots.txt is a good place to have a link. Suggestion that having ResourceSync discovery in robots.txt with something like

    Sitemap: http://www.example.com/sitemap.xml
    ResourceSync: http://www.example.com/capabilities.xml

(in some cases might be same URI as for Sitemap)

Danbri - should there be a property in schema.org that points to the OAI-PMH baseURL? Agreement that this would be good, plea from Simeon to also add for ResourceSync while at it.

Discussion with Jason Ronallo: Should have some way to handle the case of a resource that is the scan of a postcard - images of two sides and the metadata. How would it be best be represented as a unit in ResourceSync? Simeon suggests linking the component resources with relations, e.g. <http://www.openarchives.org/rs/0.5/resourcesync#LinkRelRes> but we haven't articulated this particular case. Note issue that if extra information is exposed in the sitemap then this is outside of the datestamping mechanism for resources and so have to be careful that updates will always be seen (cf. known issue with set membership changes in OAI-PMH).

ACTION - danbri - add property for OAI-PMH baseURL to schema.org. Just a single URI is required, a client will then have to add query parameters to use OAI but the endpoint is self-describing (via baseURI?verb=Identify)

ACTION - danbri - add property for ResorceSync discovery link in schema.org. cf. proposal for link relation in current spec draft: <http://www.openarchives.org/rs/0.5/resourcesync#xhtmllinkEle> . Simeon will get this into the ResourceSync spec.

ACTION - EVERYONE - for anyone interested please send comments on ResourceSync to the google group <https://groups.google.com/d/forum/resourcesync>
