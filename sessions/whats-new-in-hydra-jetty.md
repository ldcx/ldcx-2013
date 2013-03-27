# Whats New in Hydra 6

Major Impetus: new SOLR index scheme

## SOLR

### Old Way

 `title_t` - this is a dynamic field (*_t -> is a text_field)

 * hard to say if it was multi-valued
 * to get around this we'd store `title_sort`; which was single valued
 * might also store as `title_s`

Ultimately not clear how SOLR thinks of this

### Inspiration

Looked to Sunspot for inspiration; For indexing ActiveRecord objects into SOLR

*  `title_te` - text english
*  `title_s` - string
*  `title_i` - integer
*  `title_dt` - date format (very strict)
*  Stored - `s`
*  Indexed - `i`
* Multi-valued - `m`

Resulting - `title_sim`; Title field is a string that is indexed and multi-valued

*You can use this schema with older versions of Hydra/Blacklight.*
This is the default going forward.

### Helpers

OM

   # This generates
   set_terminology do |t|
     t.root(path: 'mods')
     t.title, index_as: :stored, :searchable # infers mods/title
   end

SOLR documents were getting very large, as each field had multiple elements in a SOLR document.

   set_terminology do |t|
     t.root(path: 'mods')

     # :index_as symbol is used for referencings a bunch macros in Solrizer
     t.title, index_as: :stored_searcharble
     # OR
     # t.title, index_as: [:text, :stored, :indexed]
   end


Reducing number of fields that SOLR; You'll need to rebuild your index from scratch.

## Hydra Gems Splitup

hydra-head

*  hydra-access-controls
*  hydra-core
*  hydra-file-access: the legacy junk drawer (this will be dropped after v5.4)

## Hydra Downloads Controller

This is in the works

## Managed Datastreams

We are moving from Inline to Managed datastreams. This should keep your XML documents smaller (though you'll have more files)

## Going Forward

Justin is asking for assistance on ActiveFedora

Discuss read vs. write; When querying, find from SOLR, then lazily load from Fedora.