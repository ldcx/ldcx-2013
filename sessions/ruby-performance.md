# Ruby Performance

## App loading monitoring

* Rubyprof - usable on any ruby code; not recommended
* NewRelic - gem installed, gem deployed, overview of whats going on
* ActiveSupport::Notifications
* Warning threshold settings in Rails core; Will automatically query explain slow queries
* Grinder - auto distributes scripts to workers that then beat up on a server
* Instrumental - https://instrumentalapp.com/

Reference: https://www.ruby-toolbox.com/categories/rails_instrumentation

## External HTTP testing

* SolrMeter - test and benchmark Solr
* ApacheBench -
* HTTPerf -
* webpagetest.org
* Chrome Page Speed extension
* YSlow
* LoadImpact.com

## Passenger

Prespin your page;

## Load Balancing

### Stanford

* Sessions are pinned to a single node; Can use Solr query caching

## Solr

Recommend moving to SolrCloud

### SolrCloud

* Automatic sharding
* Multimaster replication
* Java 7 performed a fair amount better than Java 6
* Look at the Cache ratio you are getting
  * Get hitratio close to 1
  * Keep evictions low, as those are cache records that are being replaced by other cache records
  * Bad Solr performance, adjust your cache size
  * If possible, warm the cache via config setting (run a query with a facet)
* Optimize Solr - take all of the extents and compress; Doubles disk usage during the optimize
* Talk to Erik Hatcher (he wrote the book)
* DTU and Stanford have some excellent knowledge
* Enable turning on debug option for Solr
* Don't have keywords as a Facet

## Rails

* Ruby 2 - much faster, please move towards it
* Rails 4
* Garbage Collector - there is a back-patch for 1.9.3
* RVM on a server, useful but not without its head aches
* Rails 4 has "Russian Doll" caching; Expire a child and the parent is expired
* Invalidating cache-based on timestamp