[![Build Status](https://travis-ci.org/n-sakuma/internal_wiki.png)](https://travis-ci.org/n-sakuma/internal_wiki)
[![Coverage Status](https://coveralls.io/repos/n-sakuma/internal_wiki/badge.png?branch=develop)](https://coveralls.io/r/n-sakuma/internal_wiki?branch=develop)
[![Dependency Status](https://gemnasium.com/n-sakuma/internal_wiki.png)](https://gemnasium.com/n-sakuma/internal_wiki)

# Internal Wiki

It is a Wiki for use in a limited environment.


## How To Use

### Requirements

* Linux (Ubuntu/Debian/CentOS )
* ruby 1.9.3+
* git 1.7.10+
* PostgreSQL
* Elastic Search


### clone sourcecode

```
git clone git://github.com/n-sakuma/internal_wiki.git
```

### cp sample files

### DB (PostgreSQL)

#### For postgresql

```bash
$ cp config/database.yml{.postgresql,}
```

#### For some

```
$ cp config/database.yml{.sample,}

#... and edit database.yml
```

### application settings

```
cp config/application.yml{.sample}
```

#### [Option] Get Google OAuth key

Using OAuth 2.0 to Access Google APIs

[Document](https://developers.google.com/accounts/docs/OAuth2)


#### Amazon SES key (if you need)

### migration

#### DB

```bash
$ rake db:craete db:migrate db:seed
```

## Tips

### Elastic Search Reindex

```bash
$ RAILS_ENV=production rake tire:import CLASS='Page' FORCE=true
```

## Smart development log view (Chrome only)

Install the extension from [Chrome WebStore.](https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)
