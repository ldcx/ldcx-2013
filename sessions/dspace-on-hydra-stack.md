DSpace on the hydra stack
=========================

2013-03-26 1pm

What does DSpace do?
--------------------

- two step accession process:
    1. submission part which include
        - metadata entry, then file upload
        - configurable submission templates per collection (required elements etc.)
        - alternative is batch upload (using DSpace specific simple archive format), SWORD deposit
    2. workflow with three optional async steps (model behind has task pool with individuals with roles)
        - collection manager would determine whether appropriate for collection
        - metadata specialist might refine metadata
        - review before final session

- many people do batch edit (dump, edit, batch upload again) and the DB transaction facility is leveraged to mean that a failure part-way through a batch update will cause failure of the whole batch without partial completion

- DSpace has lightweight support for identities for authentication/authorization
- separate notion of identities in metadata that may be linked to external authority control

- metadata: scheme, element, qualifier, language
- containers: collections and communities are both units of discovery and of administration (Tim says this is a big issue for them and a problem)
- allowed metadata predicates in DB give {scheme,element} values allowed in system
- an item is in just one "owning collection" but there is a notion of linking to make something appear to be in other collections

- access controls (read/write) may be attached in a very fine grained way
- has embargo notion which is widely used

- data model around which much is based:
    - community
    - collection
        - item
            - datastream

- recent DSpace has notion of canned curation tasks which may be attached at certain points
    - designed to be machine triggered, e.g. run virus check on incoming content; if there is DOI in citations then look up bibtex data
    - tasks are jvm code, once in system can be hooked up via std configuration

What hydra heads are like DSpace?
---------------------------------

1. sufia close
    - has hooks for authority control
    - has embargo
    - has a notion of custom machine tasks
2. hydrus from Standford has workflow
    - has collections (for UI) and apos (for access control etc.)
    - hydrus workflow demo: roles for collection: owner, managers, reviewers, depositors, viewer; collection has status, defaults/requirements for embargo delay, visibility, requirement for review, license; each item in collection has status in workflow; keeps track of item history;
    - hydrus has notions only of individuals and everyone so far; DSpace has users and groups (defined internally, group management UI) for permissions.
    - hydrus has early assignment of ids whereas DSpace assigns persistent ids late which causes problems with systems such as SWORD where you need an id to pass back in response to a deposit. Nobody present argues that this early assignment would be bad.
    - hydrus has email notification and a dashboard. This mirrors DSpace
3. argo
    - has workflow tasks that are similar to DSpace curation tasks

What of DSpace is missing from hydra systems?
---------------------------------------------

1. SWORD deposit plugin
    - use cases: publisher deposit, repo->repo
    - Ben Armintor has been working on Fedora 3.6 SWORD 1.3 plugin (use case is BMC article deposit direct into Fedora)
    - comments that SWORD deposit into a hydra system should go through the hydra stack so that it gets a rights metadata stream and goes through any other business logic in hydra
2. group management
3. template metadata forms/requirement on per collection basis (in DSpace this relies upon the template registry functionality but perhaps that isn't the best underpinning)
4. batch load facility in DSpace is transactional, currently not trivially supported with Fedora
5. deployability - DSpace is very easy to deploy.
    - Justin comments that he is quite close to being able to deploy sufia as a war file
    - other comments that this might be required for broader adoption, along with other things like language localization, but need to get functional match first

What is most important is transcending DSpace?
----------------------------------------------

- workflow system
    - Justin - suggests that hydrus workflow would be the starting point
    - Tom/Simeon - can the workflow of hydrus be abstracted so that it could be used with sufia or other?
    - Justin - 2 weeks to abstract ??
- group management
    - Justin - other people want group management separate from the DSpace discussion

Practical questions is how to get parts required from hydrus and sufia to work together?
----------------------------------------------------------------------------------------

- suggestion to create gem for hydrus (it took about 2 weeks full-time for sufia) - est. 1 person-month effort
- selection of appropriate elements from sufia and hydrus - est. ?? effort
- Tim says that once Oregon Digital project is done (maybe 1.5 years from now) then might have time to spend on migrating DSpace; maybe UofO would also be interested (perhaps sooner)

![Whiteboard Image](https://raw.github.com/ldcx/ldcx-2013/master/sessions/dspace-on-hydra-stack.jpg)